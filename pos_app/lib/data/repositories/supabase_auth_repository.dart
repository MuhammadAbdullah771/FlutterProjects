import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/utils/result.dart';
import '../datasources/local_storage_datasource.dart';

/// Supabase implementation of AuthRepository
/// This class implements the authentication logic using Supabase
/// It handles all Supabase-specific operations while maintaining the repository interface
class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _supabase;
  final LocalStorageDataSource _localStorage;
  
  /// Constructor that takes Supabase client and local storage
  /// Dependency injection allows for easy testing and backend swapping
  SupabaseAuthRepository({
    required supabase.SupabaseClient supabase,
    required LocalStorageDataSource localStorage,
  })  : _supabase = supabase,
        _localStorage = localStorage;
  
  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Attempt to sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      // Check if signup was successful
      if (response.user == null) {
        return const Failure('Sign up failed. Please try again.');
      }
      
      // Convert Supabase user to our User entity
      final user = _mapSupabaseUserToUser(response.user!);
      
      // Save session to local storage
      await _localStorage.saveSession(response.session?.accessToken ?? '');
      
      return Success(user);
    } on supabase.AuthException catch (e) {
      // Handle Supabase authentication errors
      return Failure(_mapAuthError(e.message));
    } catch (e) {
      // Handle any other unexpected errors
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Check if sign in was successful
      if (response.user == null) {
        return const Failure('Sign in failed. Please check your credentials.');
      }
      
      // Convert Supabase user to our User entity
      final user = _mapSupabaseUserToUser(response.user!);
      
      // Save session to local storage
      await _localStorage.saveSession(response.session?.accessToken ?? '');
      
      return Success(user);
    } on supabase.AuthException catch (e) {
      // Handle Supabase authentication errors
      return Failure(_mapAuthError(e.message));
    } catch (e) {
      // Handle any other unexpected errors
      return Failure('An unexpected error occurred: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<void>> signOut() async {
    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Clear local session
      await _localStorage.clearSession();
      
      return const Success(null);
    } catch (e) {
      return Failure('Failed to sign out: ${e.toString()}');
    }
  }
  
  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // Get current user from Supabase
      final supabaseUser = _supabase.auth.currentUser;
      
      if (supabaseUser == null) {
        return const Success(null);
      }
      
      // Convert Supabase user to our User entity
      final user = _mapSupabaseUserToUser(supabaseUser);
      
      return Success(user);
    } catch (e) {
      return Failure('Failed to get current user: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> hasSession() async {
    try {
      // Check if Supabase has a session
      final hasSupabaseSession = _supabase.auth.currentSession != null;
      
      // Also check local storage
      final hasLocalSession = await _localStorage.hasSession();
      
      return hasSupabaseSession || hasLocalSession;
    } catch (e) {
      return false;
    }
  }
  
  /// Maps Supabase User to our User entity
  /// This abstraction layer allows us to change the User model without affecting Supabase code
  User _mapSupabaseUserToUser(supabase.User supabaseUser) {
    DateTime? createdAt;
    final createdAtString = supabaseUser.createdAt;
    if (createdAtString.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtString);
    }
    
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: supabaseUser.userMetadata?['full_name'] as String?,
      createdAt: createdAt,
    );
  }
  
  /// Maps Supabase auth error messages to user-friendly messages
  /// This improves user experience by showing clear, actionable error messages
  String _mapAuthError(String errorMessage) {
    // Common Supabase error messages and their user-friendly equivalents
    if (errorMessage.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorMessage.contains('Email already registered')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (errorMessage.contains('Password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (errorMessage.contains('Email')) {
      return 'Please enter a valid email address.';
    }
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    // Return the original message if no mapping found
    return errorMessage;
  }
}

