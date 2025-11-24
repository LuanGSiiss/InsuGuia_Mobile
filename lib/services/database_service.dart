import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/glycemic_reading.dart';
import '../models/discharge_instruction.dart';
import 'auth_service.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Busca todos os pacientes (ou apenas ativos se [onlyActive] for true)
  Future<List<Patient>> getPatients({bool onlyActive = false}) async {
    try {
      final authService = AuthService();
      final doctorId = authService.getCurrentDoctorId();

      if (doctorId == null) {
        return [];
      }

      var query = _client
          .from('patients')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      if (onlyActive) {
        query = _client
            .from('patients')
            .select()
            .eq('doctor_id', doctorId)
            .eq('is_discharged', false)
            .order('created_at', ascending: false);
      }

      final response = await query;

      if (response == null) {
        print('⚠️ Supabase retornou null ao buscar pacientes.');
        return [];
      }

      if (response is! List) {
        print('⚠️ Tipo inesperado retornado de Supabase: ${response.runtimeType}');
        return [];
      }

      final patients =
          response.map((json) => Patient.fromJson(json)).toList();

      print('✅ ${patients.length} pacientes carregados com sucesso.');
      return patients;
    } catch (e, stack) {
      print('❌ Erro ao carregar pacientes: $e');
      print(stack);
      rethrow;
    }
  }

  /// Busca um paciente específico pelo ID
  Future<Patient> getPatient(String id) async {
    try {
      final response = await _client
          .from('patients')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw Exception('Paciente não encontrado');
      }

      return Patient.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar paciente: $e');
      rethrow;
    }
  }

  /// Cria um novo paciente
  Future<Patient> createPatient(Patient patient) async {
    try {
      final authService = AuthService();
      final doctorId = authService.getCurrentDoctorId();

      if (doctorId == null) {
        throw Exception('Médico não autenticado');
      }

      final patientData = patient.toJson();
      patientData['doctor_id'] = doctorId;

      final response = await _client
          .from('patients')
          .insert(patientData)
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Erro ao criar paciente');
      }

      return Patient.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar paciente: $e');
      rethrow;
    }
  }

  /// Atualiza dados de um paciente
  Future<void> updatePatient(Patient patient) async {
    try {
      await _client
          .from('patients')
          .update({
            ...patient.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', patient.id!);
    } catch (e) {
      print('❌ Erro ao atualizar paciente: $e');
      rethrow;
    }
  }

  /// Remove um paciente
  Future<void> deletePatient(String id) async {
    try {
      await _client.from('patients').delete().eq('id', id);
    } catch (e) {
      print('❌ Erro ao excluir paciente: $e');
      rethrow;
    }
  }

  /// Busca a prescrição mais recente de um paciente
  Future<Prescription?> getPrescription(String patientId) async {
    try {
      final response = await _client
          .from('prescriptions')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .maybeSingle();

      if (response == null) return null;

      return Prescription.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar prescrição: $e');
      rethrow;
    }
  }

  /// Cria uma nova prescrição
  Future<Prescription> createPrescription(Prescription prescription) async {
    try {
      final response = await _client
          .from('prescriptions')
          .insert(prescription.toJson())
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Erro ao criar prescrição');
      }

      return Prescription.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar prescrição: $e');
      rethrow;
    }
  }

  /// Retorna todas as leituras glicêmicas de um paciente
  Future<List<GlycemicReading>> getGlycemicReadings(String patientId) async {
    try {
      final response = await _client
          .from('glycemic_readings')
          .select()
          .eq('patient_id', patientId)
          .order('reading_date', ascending: false)
          .order('created_at', ascending: false);

      if (response == null) return [];

      if (response is! List) {
        print('⚠️ Tipo inesperado ao buscar leituras glicêmicas.');
        return [];
      }

      return response
          .map((json) => GlycemicReading.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar leituras glicêmicas: $e');
      rethrow;
    }
  }

  /// Cria uma nova leitura glicêmica
  Future<GlycemicReading> createGlycemicReading(
      GlycemicReading reading) async {
    try {
      final response = await _client
          .from('glycemic_readings')
          .insert(reading.toJson())
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Erro ao registrar leitura glicêmica');
      }

      return GlycemicReading.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar leitura glicêmica: $e');
      rethrow;
    }
  }

  /// 🔹 Busca instruções de alta de um paciente
  Future<DischargeInstruction?> getDischargeInstruction(String patientId) async {
    try {
      final response = await _client
          .from('discharge_instructions')
          .select()
          .eq('patient_id', patientId)
          .maybeSingle();

      if (response == null) return null;

      return DischargeInstruction.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar instrução de alta: $e');
      rethrow;
    }
  }

  /// Cria instruções de alta para um paciente
  Future<DischargeInstruction> createDischargeInstruction(
      DischargeInstruction instruction) async {
    try {
      final response = await _client
          .from('discharge_instructions')
          .insert(instruction.toJson())
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Erro ao criar instrução de alta');
      }

      return DischargeInstruction.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar instrução de alta: $e');
      rethrow;
    }
  }
}
