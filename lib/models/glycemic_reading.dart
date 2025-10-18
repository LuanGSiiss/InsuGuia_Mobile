class GlycemicReading {
  final String? id;
  final String patientId;
  final DateTime readingDate;
  final String readingTime;
  final double glucoseValue;
  final String? adjustmentRecommendation;
  final DateTime? createdAt;

  GlycemicReading({
    this.id,
    required this.patientId,
    required this.readingDate,
    required this.readingTime,
    required this.glucoseValue,
    this.adjustmentRecommendation,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'reading_date': readingDate.toIso8601String().split('T')[0],
      'reading_time': readingTime,
      'glucose_value': glucoseValue,
      'adjustment_recommendation': adjustmentRecommendation,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory GlycemicReading.fromJson(Map<String, dynamic> json) {
    return GlycemicReading(
      id: json['id'],
      patientId: json['patient_id'],
      readingDate: DateTime.parse(json['reading_date']),
      readingTime: json['reading_time'],
      glucoseValue: (json['glucose_value'] as num).toDouble(),
      adjustmentRecommendation: json['adjustment_recommendation'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
