import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for database operations
class SupabaseService {
  static SupabaseClient? _client;
  
  /// Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }
  
  /// Get Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}

