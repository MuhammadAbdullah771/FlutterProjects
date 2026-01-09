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
  /// Throws custom exceptions for better error handling
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // Supabase returns "Invalid login credentials" for both cases (security)
      // We'll check if email exists by attempting password reset
      // This is a workaround since Supabase doesn't expose user existence directly
      final errorMessage = e.message.toLowerCase();
      
      // Check if it's an invalid credentials error
      if (errorMessage.contains('invalid') && 
          (errorMessage.contains('login') || errorMessage.contains('credentials'))) {
        // Try to check if email exists by attempting password reset
        // Note: This might send an email, but it's the only way to check
        try {
          await _client.auth.resetPasswordForEmail(email);
          // If password reset succeeds, email exists but password is wrong
          throw AuthException(
            'Invalid Password',
            statusCode: 'invalid_password',
          );
        } on AuthException catch (resetError) {
          // If password reset fails with "user not found", email doesn't exist
          final resetMsg = resetError.message.toLowerCase();
          if (resetMsg.contains('user not found') || 
              resetMsg.contains('email not found') ||
              resetMsg.contains('no user')) {
            throw AuthException(
              'Account not existing',
              statusCode: 'user_not_found',
            );
          }
          // Otherwise, assume invalid password (more common case)
          throw AuthException(
            'Invalid Password',
            statusCode: 'invalid_password',
          );
        } catch (_) {
          // If we can't determine, default to invalid password
          throw AuthException(
            'Invalid Password',
            statusCode: 'invalid_password',
          );
        }
      }
      
      // Check for explicit "user not found" errors
      if (errorMessage.contains('user not found') ||
          errorMessage.contains('email not found') ||
          errorMessage.contains('no user')) {
        throw AuthException(
          'Account not existing',
          statusCode: 'user_not_found',
        );
      }
      
      // Re-throw original error if we can't determine
      rethrow;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Login failed: ${e.toString()}');
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
