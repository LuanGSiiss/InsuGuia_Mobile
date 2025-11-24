import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String specialty,
    required String crm,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Erro ao criar usuário');
      }

      await _supabase.from('doctors').insert({
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'specialty': specialty,
        'crm': crm,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  String? getCurrentDoctorId() {
    return _supabase.auth.currentUser?.id;
  }

  String? getCurrentDoctorEmail() {
    return _supabase.auth.currentUser?.email;
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
