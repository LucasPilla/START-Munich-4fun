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

  SkinAnalysisResult({
    required this.hasProblem,
    required this.description,
    this.condition,
    this.confidence,
    this.severity = Severity.none,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    Severity severity = Severity.none;
    final severityStr = json['severity']?.toString().toLowerCase();
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

    return SkinAnalysisResult(
      hasProblem: json['has_problem'] ?? json['hasProblem'] ?? false,
      description: json['description'] ?? '',
      condition: json['condition'],
      confidence: json['confidence']?.toDouble(),
      severity: severity,
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
    return severity == Severity.high || severity == Severity.medium;
  }
}


