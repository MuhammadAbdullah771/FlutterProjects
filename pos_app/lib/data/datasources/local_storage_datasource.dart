import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Local storage data source
/// Handles all local storage operations using SharedPreferences
/// This abstraction allows us to easily swap storage implementations if needed
class LocalStorageDataSource {
  final SharedPreferences _prefs;
  
  /// Constructor that takes SharedPreferences instance
  LocalStorageDataSource(this._prefs);
  
  /// Saves the user session token to local storage
  /// This allows the app to remember the user even after app restart
  Future<void> saveSession(String sessionToken) async {
    try {
      await _prefs.setString(AppConstants.sessionKey, sessionToken);
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }
  
  /// Gets the saved session token from local storage
  /// Returns null if no session is saved
  String? getSession() {
    try {
      return _prefs.getString(AppConstants.sessionKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Checks if a session exists in local storage
  /// Returns true if a session token is saved, false otherwise
  Future<bool> hasSession() async {
    try {
      final session = _prefs.getString(AppConstants.sessionKey);
      return session != null && session.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Clears the saved session from local storage
  /// Called when user signs out
  Future<void> clearSession() async {
    try {
      await _prefs.remove(AppConstants.sessionKey);
      await _prefs.remove(AppConstants.userIdKey);
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }
  
  /// Saves user ID to local storage
  /// Useful for quick access without querying the backend
  Future<void> saveUserId(String userId) async {
    try {
      await _prefs.setString(AppConstants.userIdKey, userId);
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }
  
  /// Gets the saved user ID from local storage
  /// Returns null if no user ID is saved
  String? getUserId() {
    try {
      return _prefs.getString(AppConstants.userIdKey);
    } catch (e) {
      return null;
    }
  }
}

