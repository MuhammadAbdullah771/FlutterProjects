/// App-wide constants
/// This file contains all constant values used throughout the application
class AppConstants {
  // Supabase configuration keys
  // TODO: Replace these with your actual Supabase project credentials
  // Get these from: https://app.supabase.com -> Your Project -> Settings -> API
  static const String supabaseUrl = 'https://smjqzkjzdzlwefuvftuf.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_OwnNf37EQofirlFbDnyZWA_4f5uzqXH';

  // SharedPreferences keys for local storage
  static const String sessionKey = 'user_session';
  static const String userIdKey = 'user_id';

  // App information
  static const String appName = 'Smart POS';

  // Private constructor to prevent instantiation
  AppConstants._();
}
