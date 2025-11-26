import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/glycemic_reading.dart';
import '../models/discharge_instruction.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Patient>> getPatients({bool onlyActive = false}) async {
    var query = _client.from('patients').select().order('created_at', ascending: false);

    if (onlyActive) {
      query = query.eq('is_discharged', false);
    }

    final response = await query;
    return (response as List).map((json) => Patient.fromJson(json)).toList();
  }

  Future<Patient> getPatient(String id) async {
    final response = await _client
        .from('patients')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      throw Exception('Paciente não encontrado');
    }

    return Patient.fromJson(response);
  }

  Future<Patient> createPatient(Patient patient) async {
    final response = await _client
        .from('patients')
        .insert(patient.toJson())
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('Erro ao criar paciente');
    }

    return Patient.fromJson(response);
  }

  Future<void> updatePatient(Patient patient) async {
    await _client
        .from('patients')
        .update({
          ...patient.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', patient.id!);
  }

  Future<void> deletePatient(String id) async {
    await _client.from('patients').delete().eq('id', id);
  }

  Future<Prescription?> getPrescription(String patientId) async {
    final response = await _client
        .from('prescriptions')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .maybeSingle();

    if (response == null) return null;

    return Prescription.fromJson(response);
  }

  Future<Prescription> createPrescription(Prescription prescription) async {
    final response = await _client
        .from('prescriptions')
        .insert(prescription.toJson())
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('Erro ao criar prescrição');
    }

    return Prescription.fromJson(response);
  }

  Future<List<GlycemicReading>> getGlycemicReadings(String patientId) async {
    final response = await _client
        .from('glycemic_readings')
        .select()
        .eq('patient_id', patientId)
        .order('reading_date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List).map((json) => GlycemicReading.fromJson(json)).toList();
  }

  Future<GlycemicReading> createGlycemicReading(GlycemicReading reading) async {
    final response = await _client
        .from('glycemic_readings')
        .insert(reading.toJson())
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('Erro ao registrar leitura');
    }

    return GlycemicReading.fromJson(response);
  }

  Future<DischargeInstruction?> getDischargeInstruction(String patientId) async {
    final response = await _client
        .from('discharge_instructions')
        .select()
        .eq('patient_id', patientId)
        .maybeSingle();

    if (response == null) return null;

    return DischargeInstruction.fromJson(response);
  }

  Future<DischargeInstruction> createDischargeInstruction(DischargeInstruction instruction) async {
    final response = await _client
        .from('discharge_instructions')
        .insert(instruction.toJson())
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('Erro ao criar orientação de alta');
    }

    return DischargeInstruction.fromJson(response);
  }
}
