import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/skin_analysis_result.dart';
import '../../config/api_config.dart';

class SkinAnalysisApi {
  Future<SkinAnalysisResult> analyzeSkinImage(File imageFile) async {
    try {
      final uri = Uri.parse(ApiConfig.analyzeEndpoint);
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add the image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'skin_image.jpg',
      );
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SkinAnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}

