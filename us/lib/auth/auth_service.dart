import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // sign In with email
  Future<User> signInWithCredentials(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password are required");
    }
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("Login failed: User is null");
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // sign up frist time vala
  Future<User?> signUpWithCredentials(
    String email,
    String password, {
    required String phone,
    required String displayName, // Added displayName
  }) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception("Invalid email or weak password");
    }
    try {
      // Debug print
      print('📝 Signing up: $email, Name: $displayName, Phone: $phone');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'phone': phone,
          'display_name': displayName, // Standard Supabase field
          'full_name': displayName, // Also common standard
          'name': displayName, // Fallback
        },
      );
      // Email verification ON → user may be null
      return response.user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // fallback: local cleanup if needed
      throw Exception("Logout failed");
    }
  }

  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }
}
