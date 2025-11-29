class SkinAnalysisResult {
  final bool hasProblem;
  final String description;
  final String? condition;
  final double? confidence;

  SkinAnalysisResult({
    required this.hasProblem,
    required this.description,
    this.condition,
    this.confidence,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      hasProblem: json['has_problem'] ?? json['hasProblem'] ?? false,
      description: json['description'] ?? '',
      condition: json['condition'],
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_problem': hasProblem,
      'description': description,
      'condition': condition,
      'confidence': confidence,
    };
  }
}


