import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/skin_analysis_result.dart';
import '../../config/api_config.dart';

class SkinAnalysisApi {
  /// Analyzes a skin image by sending it as base64-encoded JSON to the API
  /// 
  /// The image is converted to base64 and sent in the format:
  /// {"image": "data:image/jpeg;base64,{base64_string}"}
  /// 
  /// Set [useDataUri] to false to send only the base64 string without the data URI prefix
  Future<SkinAnalysisResult> analyzeSkinImage(
    File imageFile, {
    bool useDataUri = true,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.analyzeEndpoint);
      
      // Read image file as bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64Image = base64Encode(imageBytes);
      
      // Determine image format from file extension
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // default
      if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (fileExtension == 'webp') {
        mimeType = 'image/webp';
      }
      
      // Format image data based on preference
      final String imageData;
      if (useDataUri) {
        // Format as data URI: "data:image/jpeg;base64,{base64}"
        imageData = 'data:$mimeType;base64,$base64Image';
      } else {
        // Send only base64 string
        imageData = base64Image;
      }
      
      // Create JSON payload
      final payloadMap = {
        'image': imageData,
      };
      final payload = json.encode(payloadMap);
      
      // Debug logging (remove in production if needed)
      print('Sending request to: $uri');
      print('Payload size: ${payload.length} characters');
      print('Image data prefix: ${imageData.substring(0, imageData.length > 50 ? 50 : imageData.length)}...');
      
      // Send POST request with JSON body
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      );
      
      // Log response for debugging (remove in production if needed)
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          // Try to parse as JSON
          final jsonData = json.decode(response.body);
          
          // Check if response is already a Map
          if (jsonData is Map<String, dynamic>) {
            // Transform backend response to frontend format
            final transformedData = _transformBackendResponse(jsonData);
            return SkinAnalysisResult.fromJson(transformedData);
          } else {
            throw Exception('Invalid response format: expected JSON object, got ${jsonData.runtimeType}');
          }
        } catch (e) {
          throw Exception('Failed to parse response: $e\nResponse body: ${response.body}');
        }
      } else {
        // Handle error responses
        String errorMessage = 'Failed to analyze image: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage += '\nError: ${errorData['error']}';
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage += '\nMessage: ${errorData['message']}';
          } else {
            errorMessage += '\nResponse: ${response.body}';
          }
        } catch (_) {
          // If response is not JSON, just include the raw body
          errorMessage += '\nResponse: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Transforms the backend response format to match frontend expectations
  /// Backend returns: { "classification": { "disease_name": "..." }, "llm_assessment": {...} }
  /// Frontend expects: { "has_problem": bool, "description": "...", "condition": "...", ... }
  Map<String, dynamic> _transformBackendResponse(Map<String, dynamic> backendResponse) {
    final classification = backendResponse['classification'] as Map<String, dynamic>? ?? {};
    final llmAssessment = backendResponse['llm_assessment'] as Map<String, dynamic>? ?? {};
    
    // Clean disease name (remove newlines and trim)
    final diseaseNameRaw = classification['disease_name'] as String?;
    final diseaseName = diseaseNameRaw?.trim().replaceAll('\n', '');
    
    // Determine if there's a problem (disease detected)
    final hasProblem = diseaseName != null && 
                      diseaseName.isNotEmpty &&
                      diseaseName.toLowerCase() != 'healthy' && 
                      diseaseName.toLowerCase() != 'no disease' &&
                      diseaseName.toLowerCase() != 'normal';
    
    // Extract description from LLM assessment
    final description = llmAssessment['description'] as String? ?? 
                       llmAssessment['summary'] as String? ?? 
                       (hasProblem 
                         ? 'A skin condition has been detected: $diseaseName.'
                         : 'No significant skin issues detected.');
    
    // Extract severity level
    final severityStr = (llmAssessment['severity'] as String? ?? 
                        llmAssessment['severity_level'] as String? ?? 
                        'none').toString().toLowerCase().trim();
    
    // Safely convert consult_doctor to bool
    bool? consultDoctor;
    final consultDoctorValue = llmAssessment['consult_doctor'];
    if (consultDoctorValue != null) {
      if (consultDoctorValue is bool) {
        consultDoctor = consultDoctorValue;
      } else if (consultDoctorValue is String) {
        consultDoctor = consultDoctorValue.toLowerCase() == 'true' || 
                       consultDoctorValue.toLowerCase() == 'yes';
      } else {
        consultDoctor = hasProblem; // Default to hasProblem if value is unclear
      }
    } else {
      // Default: recommend doctor consultation if there's a problem
      consultDoctor = hasProblem;
    }
    
    // Safely extract confidence
    double? confidence;
    final confidenceValue = llmAssessment['confidence'];
    if (confidenceValue != null) {
      if (confidenceValue is double) {
        confidence = confidenceValue;
      } else if (confidenceValue is int) {
        confidence = confidenceValue.toDouble();
      } else if (confidenceValue is String) {
        confidence = double.tryParse(confidenceValue);
      }
    }
    
    // Build the transformed response
    final transformed = <String, dynamic>{
      'has_problem': hasProblem,
      'description': description,
      'condition': diseaseName,
      'confidence': confidence,
      'severity': severityStr,
      'severity_level': severityStr,
      'disease_description': llmAssessment['disease_description'] as String?,
      'immediate_action': llmAssessment['immediate_action'] as String?,
      'things_to_keep_in_mind': llmAssessment['things_to_keep_in_mind'] as List<dynamic>?,
      'consult_doctor': consultDoctor,
      'consult_doctor_reasoning': llmAssessment['consult_doctor_reasoning'] as String?,
    };
    
    return transformed;
  }
}

