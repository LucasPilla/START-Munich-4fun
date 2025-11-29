enum Severity {
  none,
  low,
  medium,
  high,
}

class SkinAnalysisResult {
  final bool hasProblem;
  final String description;
  final String? condition;
  final double? confidence;
  final Severity severity;
  final String? diseaseDescription;
  final String? severityLevel;
  final String? immediateAction;
  final List<String>? thingsToKeepInMind;
  final bool? consultDoctor;
  final String? consultDoctorReasoning;

  SkinAnalysisResult({
    required this.hasProblem,
    required this.description,
    this.condition,
    this.confidence,
    this.severity = Severity.none,
    this.diseaseDescription,
    this.severityLevel,
    this.immediateAction,
    this.thingsToKeepInMind,
    this.consultDoctor,
    this.consultDoctorReasoning,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    Severity severity = Severity.none;
    final severityStr = json['severity']?.toString().toLowerCase() ?? 
                       json['severity_level']?.toString().toLowerCase();
    if (severityStr == 'high') {
      severity = Severity.high;
    } else if (severityStr == 'medium') {
      severity = Severity.medium;
    } else if (severityStr == 'low') {
      severity = Severity.low;
    } else if (json['has_problem'] == true || json['hasProblem'] == true) {
      // Default to medium if problem exists but severity not specified
      severity = Severity.medium;
    }

    // Parse things_to_keep_in_mind
    List<String>? thingsToKeepInMind;
    if (json['things_to_keep_in_mind'] != null) {
      if (json['things_to_keep_in_mind'] is List) {
        thingsToKeepInMind = (json['things_to_keep_in_mind'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return SkinAnalysisResult(
      hasProblem: json['has_problem'] ?? json['hasProblem'] ?? false,
      description: json['description'] ?? '',
      condition: json['condition'],
      confidence: json['confidence']?.toDouble(),
      severity: severity,
      diseaseDescription: json['disease_description'],
      severityLevel: json['severity_level'],
      immediateAction: json['immediate_action'],
      thingsToKeepInMind: thingsToKeepInMind,
      consultDoctor: json['consult_doctor'],
      consultDoctorReasoning: json['consult_doctor_reasoning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_problem': hasProblem,
      'description': description,
      'condition': condition,
      'confidence': confidence,
      'severity': severity.name,
    };
  }

  /// Returns true if appointment booking should be recommended
  bool get shouldRecommendAppointment {
    return consultDoctor == true || severity == Severity.high || severity == Severity.medium;
  }
}


