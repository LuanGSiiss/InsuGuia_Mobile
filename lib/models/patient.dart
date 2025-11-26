class Patient {
  final String? id;
  final String name;
  final String sex;
  final int age;
  final double weight;
  final double height;
  final double creatinine;
  final String admissionLocation;
  final String patientType;
  final bool isDischarged;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.sex,
    required this.age,
    required this.weight,
    required this.height,
    required this.creatinine,
    required this.admissionLocation,
    this.patientType = 'não crítico',
    this.isDischarged = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sex': sex,
      'age': age,
      'weight': weight,
      'height': height,
      'creatinine': creatinine,
      'admission_location': admissionLocation,
      'patient_type': patientType,
      'is_discharged': isDischarged,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      sex: json['sex'],
      age: json['age'],
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      creatinine: (json['creatinine'] as num).toDouble(),
      admissionLocation: json['admission_location'],
      patientType: json['patient_type'] ?? 'não crítico',
      isDischarged: json['is_discharged'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? sex,
    int? age,
    double? weight,
    double? height,
    double? creatinine,
    String? admissionLocation,
    String? patientType,
    bool? isDischarged,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      creatinine: creatinine ?? this.creatinine,
      admissionLocation: admissionLocation ?? this.admissionLocation,
      patientType: patientType ?? this.patientType,
      isDischarged: isDischarged ?? this.isDischarged,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));
}
