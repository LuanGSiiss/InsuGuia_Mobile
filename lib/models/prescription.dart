class Prescription {
  final String? id;
  final String patientId;
  final String dietType;
  final String glycemicMonitoring;
  final String basalInsulin;
  final String rapidInsulin;
  final String hypoglycemiaInstructions;
  final DateTime? createdAt;

  Prescription({
    this.id,
    required this.patientId,
    required this.dietType,
    required this.glycemicMonitoring,
    required this.basalInsulin,
    required this.rapidInsulin,
    required this.hypoglycemiaInstructions,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'diet_type': dietType,
      'glycemic_monitoring': glycemicMonitoring,
      'basal_insulin': basalInsulin,
      'rapid_insulin': rapidInsulin,
      'hypoglycemia_instructions': hypoglycemiaInstructions,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patient_id'],
      dietType: json['diet_type'],
      glycemicMonitoring: json['glycemic_monitoring'],
      basalInsulin: json['basal_insulin'],
      rapidInsulin: json['rapid_insulin'],
      hypoglycemiaInstructions: json['hypoglycemia_instructions'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
