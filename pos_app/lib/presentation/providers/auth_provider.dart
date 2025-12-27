import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/utils/result.dart';

/// Auth provider for managing authentication state
/// This uses ChangeNotifier to notify listeners when auth state changes
/// In a production app, you might use Riverpod, Bloc, or Provider instead
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Constructor that takes AuthRepository
  /// Dependency injection allows for easy testing
  AuthProvider(this._authRepository);
  
  /// Current authenticated user
  /// Returns null if no user is logged in
  User? get currentUser => _currentUser;
  
  /// Whether an authentication operation is in progress
  bool get isLoading => _isLoading;
  
  /// Current error message, if any
  String? get errorMessage => _errorMessage;
  
  /// Whether a user is currently authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Initializes the auth provider
  /// Checks if a user session exists and loads the current user
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final result = await _authRepository.getCurrentUser();
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
      } else {
        _setError(result.errorOrNull ?? 'Failed to initialize auth');
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Signs up a new user
  /// [email] - User's email address
  /// [password] - User's password (must be at least 6 characters)
  /// [fullName] - Optional full name of the user
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Sign up failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// Signs in an existing user
  /// [email] - User's email address
  /// [password] - User's password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _currentUser = result.dataOrNull;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Sign in failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signOut();
      if (result.isSuccess) {
        _currentUser = null;
      } else {
        _setError(result.errorOrNull ?? 'Sign out failed');
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sets the loading state and notifies listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Sets the error message and notifies listeners
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Clears the error message and notifies listeners
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

