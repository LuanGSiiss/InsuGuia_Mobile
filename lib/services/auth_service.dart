import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _client
          .from('doctors')
          .select()
          .eq('username', username)
          .eq('password_hash', password)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
