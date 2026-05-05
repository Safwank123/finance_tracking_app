import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<AuthResponse> signUp({required String name, required String email, required String password}) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}
