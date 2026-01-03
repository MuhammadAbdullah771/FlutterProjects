import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service using Supabase
class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  static bool get isAuthenticated => _client.auth.currentUser != null;

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
