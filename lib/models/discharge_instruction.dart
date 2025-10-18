class DischargeInstruction {
  final String? id;
  final String patientId;
  final String instructions;
  final String treatmentSummary;
  final DateTime dischargeDate;
  final DateTime? createdAt;

  DischargeInstruction({
    this.id,
    required this.patientId,
    required this.instructions,
    required this.treatmentSummary,
    required this.dischargeDate,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'instructions': instructions,
      'treatment_summary': treatmentSummary,
      'discharge_date': dischargeDate.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory DischargeInstruction.fromJson(Map<String, dynamic> json) {
    return DischargeInstruction(
      id: json['id'],
      patientId: json['patient_id'],
      instructions: json['instructions'],
      treatmentSummary: json['treatment_summary'],
      dischargeDate: DateTime.parse(json['discharge_date']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
