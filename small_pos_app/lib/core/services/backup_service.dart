import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../inventory/database/product_database.dart';
import '../../inventory/models/product_model.dart';
import '../../customers/database/customer_database.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/models/transaction_model.dart';
import '../database/settings_database.dart';
import '../models/app_settings.dart';

// Small HTTP client that injects Google OAuth Bearer token into requests
class _GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}

/// Service for backing up and restoring data from Google Drive
class BackupService {
  static final BackupService instance = BackupService._init();
  static const String _backupFileName = 'pos_backup.json';

  // ============================================================================
  // Google Drive API OAuth Client ID
  // ============================================================================
  static const String _embeddedClientId =
      '39984977372-5p4nbbjeavnatjfdcnm4bctocgobd0ha.apps.googleusercontent.com';

  GoogleSignIn? _googleSignIn;
  drive.DriveApi? _driveApi;

  BackupService._init();

  /// Initialize the service (load stored client ID or use embedded one, and try silent sign-in)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedClientId = prefs.getString('google_client_id');
    final clientId =
        storedClientId ??
        (_embeddedClientId.isNotEmpty &&
                !_embeddedClientId.contains('REPLACE_WITH_CLIENT_ID')
            ? _embeddedClientId
            : null);

    if (clientId != null && clientId.isNotEmpty) {
      // Ensure the clientId is stored so it persists without user action
      await prefs.setString('google_client_id', clientId);
      _createGoogleSignIn(clientId: clientId);
    } else {
      _createGoogleSignIn();
    }

    // Try to sign in silently to restore previous session
    try {
      final account = await _googleSignIn?.signInSilently();
      if (account != null) {
        await _createDriveApiFromAccount(account);
        await prefs.setString('backup_email', account.email);
      }
    } catch (e) {
      // Ignore silent sign-in failures
      print('Silent sign-in failed: $e');
    }
  }

  void _createGoogleSignIn({String? clientId}) {
    // If no clientId provided, try to get it from stored preferences or embedded
    String? finalClientId = clientId;
    if (finalClientId == null || finalClientId.isEmpty) {
      // This will be set during init, but as a fallback we can check embedded
      if (_embeddedClientId.isNotEmpty &&
          !_embeddedClientId.contains('REPLACE_WITH_CLIENT_ID')) {
        finalClientId = _embeddedClientId;
      }
    }

    _googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/drive.appdata',
      ],
      clientId: finalClientId,
      // Don't force code for refresh token - this can cause issues with Web Client IDs
    );
  }

  Future<void> _createDriveApiFromAccount(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    if (auth.accessToken == null) {
      throw Exception('No access token available');
    }

    _driveApi = drive.DriveApi(_GoogleAuthClient(auth.accessToken!));
  }

  /// Sign in to Google account
  /// Returns true if successful, false if canceled, throws exception on error
  Future<bool> signIn({bool forceSelectAccount = false}) async {
    try {
      if (_googleSignIn == null) {
        // Check if we have a client ID configured
        final prefs = await SharedPreferences.getInstance();
        final clientId =
            prefs.getString('google_client_id') ??
            (_embeddedClientId.isNotEmpty &&
                    !_embeddedClientId.contains('REPLACE_WITH_CLIENT_ID')
                ? _embeddedClientId
                : null);

        if (clientId == null || clientId.isEmpty) {
          throw Exception(
            'Google Drive API Client ID is not configured. Please configure it in the code.',
          );
        }

        _createGoogleSignIn(clientId: clientId);
      }

      if (forceSelectAccount) {
        // Force account selection by signing out first
        try {
          await _googleSignIn!.signOut();
        } catch (e) {
          // Ignore sign-out errors
          print('Sign-out error (ignored): $e');
        }
      }

      // Try silent sign-in first if not forcing account selection
      GoogleSignInAccount? account;
      if (!forceSelectAccount) {
        try {
          account = await _googleSignIn!.signInSilently();
        } catch (e) {
          // Silent sign-in failed, will try interactive sign-in
          print('Silent sign-in failed, trying interactive: $e');
        }
      }

      // If silent sign-in didn't work, try interactive sign-in
      if (account == null) {
        account = await _googleSignIn!.signIn();
      }

      if (account == null) {
        // User canceled the sign-in
        return false;
      }

      await _createDriveApiFromAccount(account);

      // Save account email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_email', account.email);

      return true;
    } catch (e) {
      print('Google Sign In Error: $e');

      String errorMessage = e.toString();

      // Check for specific Google Sign-In errors
      if (errorMessage.contains('sign_in_failed') ||
          errorMessage.contains('d1.d') ||
          errorMessage.contains('PlatformException') ||
          errorMessage.contains('10:')) {
        // This is an Android OAuth configuration error
        throw Exception(
          'Google Sign-In Error 10 - OAuth Consent Screen Not Configured\n\n'
          'Your Client ID is correct, but you need to configure OAuth consent screen:\n\n'
          'STEP 1: Go to Google Cloud Console\n'
          'https://console.cloud.google.com/apis/credentials/consent?project=ordinal-rig-409609\n\n'
          'STEP 2: Configure OAuth Consent Screen\n'
          '1. Click "OAuth consent screen"\n'
          '2. Choose "External" (unless you have Google Workspace)\n'
          '3. Fill in App name: "Small POS App"\n'
          '4. Add your email: abdullah.nadeem492@gmail.com\n'
          '5. Click "Save and Continue"\n\n'
          'STEP 3: Add Test Users\n'
          '1. Scroll to "Test users" section\n'
          '2. Click "+ ADD USERS"\n'
          '3. Add: abdullah.nadeem492@gmail.com\n'
          '4. Click "SAVE"\n\n'
          'STEP 4: Enable Google Drive API\n'
          '1. Go to: APIs & Services → Library\n'
          '2. Search "Google Drive API"\n'
          '3. Click "Enable"\n\n'
          'Then try signing in again!',
        );
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('Network')) {
        throw Exception(
          'Network error: Please check your internet connection and try again.',
        );
      } else if (errorMessage.contains('Client ID') ||
          errorMessage.contains('client_id')) {
        throw Exception('Google Sign-In configuration error: $errorMessage');
      } else {
        throw Exception('Sign-in failed: $errorMessage');
      }
    }
  }

  /// Save OAuth credentials (Client ID / secret) and re-create GoogleSignIn
  Future<void> setCredentials({
    required String clientId,
    String? clientSecret,
  }) async {
    if (clientId.trim().isEmpty) {
      throw Exception('Client ID cannot be empty');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_client_id', clientId.trim());
    if (clientSecret != null && clientSecret.isNotEmpty) {
      await prefs.setString('google_client_secret', clientSecret);
    } else {
      await prefs.remove('google_client_secret');
    }

    // Re-create GoogleSignIn with new client ID
    _createGoogleSignIn(clientId: clientId.trim());

    // Sign out current session to force re-authentication with new client ID
    await signOut();
  }

  /// Get the currently configured Client ID
  Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedClientId = prefs.getString('google_client_id');
    if (storedClientId != null &&
        storedClientId.isNotEmpty &&
        !storedClientId.contains('REPLACE_WITH_CLIENT_ID')) {
      return storedClientId;
    }
    return null;
  }

  /// Sign out from Google account
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    _driveApi = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backup_email');
  }

  /// Get current signed in account email
  Future<String?> getSignedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backup_email');
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn?.isSignedIn() ?? false;
  }

  /// Export all data to JSON
  Future<Map<String, dynamic>> exportData() async {
    try {
      // Get all products
      final products = await ProductDatabase.instance.getAllProducts();

      // Get all customers
      final customers = await CustomerDatabase.instance.getAllCustomers();

      // Get all transactions
      final transactions = await CustomerDatabase.instance.getAllTransactions();

      // Get settings
      final settings = await SettingsDatabase.instance.getSettings();

      return {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'products': products.map((p) => p.toMap()).toList(),
        'customers': customers.map((c) => c.toMap()).toList(),
        'transactions': transactions.map((t) => t.toMap()).toList(),
        'settings': settings.toMap(),
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Upload backup to Google Drive
  Future<bool> backupToDrive() async {
    try {
      // Check if signed in first
      if (_driveApi == null) {
        final isCurrentlySignedIn = await isSignedIn();
        if (!isCurrentlySignedIn) {
          // Try to sign in silently first
          try {
            final account = await _googleSignIn?.signInSilently();
            if (account != null) {
              await _createDriveApiFromAccount(account);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('backup_email', account.email);
            } else {
              // Silent sign-in failed, need user interaction
              throw Exception(
                'Please sign in to Google account first. Tap "Select Google Account" to sign in.',
              );
            }
          } catch (e) {
            // If silent sign-in fails, user needs to sign in manually
            throw Exception(
              'Please sign in to Google account first. Tap "Select Google Account" to sign in.',
            );
          }
        }
      }

      // Export data
      final data = await exportData();
      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      // Check if backup file already exists
      String? fileId;
      try {
        final files = await _driveApi!.files
            .list(
              q: "name='$_backupFileName' and trashed=false",
              spaces: 'appDataFolder',
            )
            .timeout(const Duration(seconds: 10));

        if (files.files != null && files.files!.isNotEmpty) {
          fileId = files.files!.first.id;
        }
      } catch (e) {
        // File doesn't exist, will create new one
      }

      // Create or update file
      final drive.File file = drive.File();
      file.name = _backupFileName;
      file.parents = ['appDataFolder'];

      if (fileId != null) {
        // Update existing file
        await _driveApi!.files
            .update(
              file,
              fileId,
              uploadMedia: drive.Media(
                Stream.value(bytes),
                bytes.length,
                contentType: 'application/json',
              ),
            )
            .timeout(const Duration(seconds: 30));
      } else {
        // Create new file
        await _driveApi!.files
            .create(
              file,
              uploadMedia: drive.Media(
                Stream.value(bytes),
                bytes.length,
                contentType: 'application/json',
              ),
            )
            .timeout(const Duration(seconds: 30));
      }

      // Save backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_backup_time',
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      print('Backup Error: $e');
      throw Exception('Failed to backup to Google Drive: $e');
    }
  }

  /// Download backup from Google Drive
  Future<Map<String, dynamic>?> restoreFromDrive() async {
    try {
      if (_driveApi == null) {
        final signedIn = await signIn();
        if (!signedIn) {
          throw Exception('Please sign in to Google account first');
        }
      }

      // Find backup file
      final files = await _driveApi!.files
          .list(
            q: "name='$_backupFileName' and trashed=false",
            spaces: 'appDataFolder',
          )
          .timeout(const Duration(seconds: 10));

      if (files.files == null || files.files!.isEmpty) {
        throw Exception('No backup file found on Google Drive');
      }

      final fileId = files.files!.first.id!;

      // Download file
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final jsonString = utf8.decode(bytes);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return data;
    } catch (e) {
      print('Restore Error: $e');
      throw Exception('Failed to restore from Google Drive: $e');
    }
  }

  /// Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import products
      if (data['products'] != null) {
        final products = (data['products'] as List)
            .map((p) => Product.fromMap(Map<String, dynamic>.from(p)))
            .toList();

        for (final product in products) {
          await ProductDatabase.instance.createProduct(product);
        }
      }

      // Import customers
      if (data['customers'] != null) {
        final customers = (data['customers'] as List)
            .map((c) => Customer.fromMap(Map<String, dynamic>.from(c)))
            .toList();

        for (final customer in customers) {
          await CustomerDatabase.instance.insertCustomer(customer);
        }
      }

      // Import transactions
      if (data['transactions'] != null) {
        final transactions = (data['transactions'] as List)
            .map((t) => Transaction.fromMap(Map<String, dynamic>.from(t)))
            .toList();

        for (final transaction in transactions) {
          await CustomerDatabase.instance.insertTransaction(transaction);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = AppSettings.fromMap(
          Map<String, dynamic>.from(data['settings']),
        );
        await SettingsDatabase.instance.updateSettings(settings);
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Get last backup time
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('last_backup_time');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }
}
