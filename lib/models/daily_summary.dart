class DailySummary {
  final DateTime date;
  final double avgNoise;
  final double maxNoise;
  final double minNoise;
  final int totalReadings;
  final int violations;
  final String peakHour;
  final Map<String, int> sourceDistribution;
  final String aiSummary;

  DailySummary({
    required this.date,
    required this.avgNoise,
    required this.maxNoise,
    required this.minNoise,
    required this.totalReadings,
    required this.violations,
    required this.peakHour,
    required this.sourceDistribution,
    required this.aiSummary,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date'] as String),
      avgNoise: (json['avgNoise'] as num).toDouble(),
      maxNoise: (json['maxNoise'] as num).toDouble(),
      minNoise: (json['minNoise'] as num).toDouble(),
      totalReadings: json['totalReadings'] as int,
      violations: json['violations'] as int,
      peakHour: json['peakHour'] as String,
      sourceDistribution: Map<String, int>.from(json['sourceDistribution'] as Map),
      aiSummary: json['aiSummary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'avgNoise': avgNoise,
      'maxNoise': maxNoise,
      'minNoise': minNoise,
      'totalReadings': totalReadings,
      'violations': violations,
      'peakHour': peakHour,
      'sourceDistribution': sourceDistribution,
      'aiSummary': aiSummary,
    };
  }
}
