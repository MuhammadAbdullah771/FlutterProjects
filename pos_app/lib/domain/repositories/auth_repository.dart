import '../entities/user.dart';
import '../../core/utils/result.dart';

/// Authentication repository interface
/// This abstract class defines the contract for authentication operations
/// Any implementation (Supabase, Firebase, custom backend) must implement these methods
/// This abstraction allows us to easily swap backends without changing business logic
abstract class AuthRepository {
  /// Signs up a new user with email and password
  /// Returns a Result containing either a User on success or an error message on failure
  Future<Result<User>> signUp({
    required String email,
    required String password,
    String? fullName,
  });
  
  /// Signs in an existing user with email and password
  /// Returns a Result containing either a User on success or an error message on failure
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });
  
  /// Signs out the current user
  /// Returns a Result indicating success or failure
  Future<Result<void>> signOut();
  
  /// Gets the currently authenticated user
  /// Returns a Result containing either a User if logged in, or null if not logged in
  Future<Result<User?>> getCurrentUser();
  
  /// Checks if a user session exists (is persisted locally)
  /// Returns true if a valid session exists, false otherwise
  Future<bool> hasSession();
}

