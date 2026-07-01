class AccessibilityResult {
  final double contrastRatio;
  final bool passesAA;
  final bool passesAAA;
  final String recommendation;
  final AccessibilityLevel level;

  AccessibilityResult({
    required this.contrastRatio,
    required this.passesAA,
    required this.passesAAA,
    required this.recommendation,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'contrastRatio': contrastRatio,
      'passesAA': passesAA,
      'passesAAA': passesAAA,
      'recommendation': recommendation,
      'level': level.toString(),
    };
  }

  factory AccessibilityResult.fromJson(Map<String, dynamic> json) {
    return AccessibilityResult(
      contrastRatio: json['contrastRatio']?.toDouble() ?? 0.0,
      passesAA: json['passesAA'] ?? false,
      passesAAA: json['passesAAA'] ?? false,
      recommendation: json['recommendation'] ?? '',
      level: AccessibilityLevel.values.firstWhere(
        (e) => e.toString() == json['level'],
        orElse: () => AccessibilityLevel.poor,
      ),
    );
  }
}

enum AccessibilityLevel {
  excellent,
  good,
  fair,
  poor,
}
