import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';
import '../database/settings_database.dart';
import '../services/backup_service.dart';
import '../../auth/auth_service.dart';
import '../routes.dart';
import '../widgets/bottom_nav_bar.dart';
import 'printer_setup_screen.dart';

/// Settings screen with backup, theme, and pricing options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsDatabase _settingsDB = SettingsDatabase.instance;
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _storePhoneController = TextEditingController();
  final TextEditingController _currencySymbolController =
      TextEditingController();
  final TextEditingController _currencyCodeController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();

  AppSettings? _settings;
  bool _isLoading = true;
  bool _googleDriveSync = true;

  // Backup-related state
  String? _driveEmail;
  DateTime? _lastBackupTime;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBackupState();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _currencySymbolController.dispose();
    _currencyCodeController.dispose();
    _taxRateController.dispose();

    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsDB.getSettings();
      setState(() {
        _settings = settings;
        _storeNameController.text = settings.storeName;
        _storeAddressController.text = settings.storeAddress ?? '';
        _storePhoneController.text = settings.storePhone ?? '';
        _currencySymbolController.text = settings.currencySymbol;
        _currencyCodeController.text = settings.currencyCode;
        _taxRateController.text = settings.defaultTaxRate.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        storeName: _storeNameController.text,
        storeAddress: _storeAddressController.text.isEmpty
            ? null
            : _storeAddressController.text,
        storePhone: _storePhoneController.text.isEmpty
            ? null
            : _storePhoneController.text,
        currencySymbol: _currencySymbolController.text,
        currencyCode: _currencyCodeController.text,
        defaultTaxRate: double.tryParse(_taxRateController.text) ?? 5.0,
      );

      await _settingsDB.updateSettings(updatedSettings);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.updateSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _settings = updatedSettings;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBackupState() async {
    final email = await BackupService.instance.getSignedInEmail();
    final last = await BackupService.instance.getLastBackupTime();
    final prefs = await SharedPreferences.getInstance();
    final sync = prefs.getBool('drive_sync_enabled') ?? true;

    setState(() {
      _driveEmail = email;
      _lastBackupTime = last;
      _googleDriveSync = sync;
    });
  }

  Future<void> _backupNow() async {
    // Check if user is signed in first
    final isSignedIn = await BackupService.instance.isSignedIn();
    if (!isSignedIn && _driveEmail == null) {
      // Show dialog to sign in first
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to sign in to your Google account to backup data to Google Drive.\n\nWould you like to sign in now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );

      if (shouldSignIn == true) {
        await _selectGoogleAccount();
        // After signing in, check if it was successful
        final email = await BackupService.instance.getSignedInEmail();
        if (email == null) {
          // User canceled sign-in
          return;
        }
        setState(() {
          _driveEmail = email;
        });
      } else {
        // User canceled, don't proceed with backup
        return;
      }
    }

    setState(() {
      _isBackingUp = true;
    });
    try {
      final ok = await BackupService.instance.backupToDrive();
      if (ok) {
        final last = await BackupService.instance.getLastBackupTime();
        setState(() {
          _lastBackupTime = last;
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Remove "Exception: " prefix if present
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isBackingUp = false;
      });
    }
  }

  Future<void> _selectGoogleAccount() async {
    try {
      final success = await BackupService.instance.signIn(
        forceSelectAccount: true,
      );
      if (success) {
        final email = await BackupService.instance.getSignedInEmail();
        setState(() {
          _driveEmail = email;
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed in to Google account successfully'),
              backgroundColor: Colors.green,
            ),
          );
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google sign-in was cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _signOutGoogle() async {
    await BackupService.instance.signOut();
    setState(() {
      _driveEmail = null;
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out from Google account')),
      );
  }

  /// Import backup from device file picker
  Future<void> _importFromDevice() async {
    try {
      // Pick backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File',
      );

      if (result == null || result.files.single.path == null) {
        // User canceled
        return;
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);

      // Read file content
      final fileContent = await file.readAsString();
      final data = jsonDecode(fileContent) as Map<String, dynamic>;

      // Confirm import
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Backup'),
          content: const Text(
            'This will replace all current data with the backup file. This action cannot be undone. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() {
        _isRestoring = true;
      });

      // Import data
      await BackupService.instance.importData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup imported successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload settings
        await _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  /// Show export options dialog
  Future<void> _showExportOptions() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save, color: Color(0xFF2196F3)),
              title: const Text('Save to Device'),
              subtitle: const Text('Save backup file to phone storage'),
              onTap: () => Navigator.pop(context, 'device'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF2196F3)),
              title: const Text('Send via Email'),
              subtitle: const Text('Email backup file to yourself'),
              onTap: () => Navigator.pop(context, 'email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (option == 'device') {
      await _exportToDevice();
    } else if (option == 'email') {
      await _exportViaEmail();
    }
  }

  /// Export backup to device storage
  Future<void> _exportToDevice() async {
    try {
      setState(() {
        _isBackingUp = true;
      });

      // Export data
      final data = await BackupService.instance.exportData();
      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'vendora_pos_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(bytes);

      // Share file (allows user to save to desired location)
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'VendoraX POS Backup File',
        subject: 'POS Backup',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to: $filePath\nYou can now save it to your desired location.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  /// Export backup via email
  Future<void> _exportViaEmail() async {
    try {
      setState(() {
        _isBackingUp = true;
      });

      // Export data
      final data = await BackupService.instance.exportData();
      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'vendora_pos_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(bytes);

      // Share via email
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'VendoraX POS Backup File\n\nThis is an automated backup of your POS data.',
        subject: 'VendoraX POS Backup - ${DateTime.now().toString().substring(0, 10)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup file ready to send via email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _restoreNow() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'Restoring will overwrite local data. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isRestoring = true;
    });
    try {
      final data = await BackupService.instance.restoreFromDrive();
      if (data == null) throw Exception('No backup found');
      final pCount = (data['products'] as List?)?.length ?? 0;
      final cCount = (data['customers'] as List?)?.length ?? 0;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Restore'),
          content: Text(
            'This will import $pCount products and $cCount customers. Proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (proceed == true) {
        await BackupService.instance.importData(data);
        final last = await BackupService.instance.getLastBackupTime();
        setState(() {
          _lastBackupTime = last;
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restore completed'),
              backgroundColor: Colors.green,
            ),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }

  Future<void> _setDriveSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('drive_sync_enabled', enabled);
    setState(() {
      _googleDriveSync = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Backup & Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Status Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data is Safe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last Backup: ${_lastBackupTime != null ? _lastBackupTime!.toLocal().toString() : 'Never'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _driveEmail != null
                                ? 'Google: $_driveEmail'
                                : 'Not connected to Google Drive',
                            style: TextStyle(
                              fontSize: 12,
                              color: _driveEmail != null
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.cloud,
                            color: Color(0xFF2196F3),
                            size: 32,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Backup Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isBackingUp ? null : _backupNow,
                icon: _isBackingUp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isBackingUp ? 'Backing Up...' : 'Back Up Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _driveEmail == null
                      ? OutlinedButton.icon(
                          onPressed: _selectGoogleAccount,
                          icon: const Icon(Icons.login),
                          label: const Text('Select Google Account'),
                        )
                      : OutlinedButton.icon(
                          onPressed: _signOutGoogle,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Management Section
            Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Google Drive Sync'),
                    subtitle: const Text('Auto-save daily'),
                    trailing: Switch(
                      value: _googleDriveSync,
                      onChanged: (value) => _setDriveSync(value),
                      activeColor: const Color(0xFF2196F3),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restore,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Restore from Google Drive'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _isRestoring ? null : _restoreNow,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_upload,
                        color: Colors.green[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Import Backup from Device'),
                    subtitle: const Text('Select backup file from phone'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _importFromDevice,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_download,
                        color: Colors.purple[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Export Backup'),
                    subtitle: const Text('Save to device or email'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _showExportOptions,
                  ),
                ], // children
              ), // Column
            ), // Card
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2196F3),
                      child: Text(
                        Supabase.instance.client.auth.currentUser?.email
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      Supabase.instance.client.auth.currentUser?.email?.split(
                            '@',
                          )[0] ??
                          'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      Supabase.instance.client.auth.currentUser?.email ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Profile view - could show more details
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Profile'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email: ${Supabase.instance.client.auth.currentUser?.email ?? 'N/A'}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'User ID: ${Supabase.instance.client.auth.currentUser?.id ?? 'N/A'}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // General Settings Section
            Text(
              'GENERAL SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.print,
                        color: Colors.purple[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Printer Setup'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrinterSetupScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.teal[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Store Profile'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _showStoreProfileDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.attach_money,
                        color: Colors.green[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Tax & Currency'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _showTaxCurrencyDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.dark_mode,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, color: Colors.red[700], size: 24),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    try {
                      await AuthService.signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error logging out: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // App Version
            Center(
              child: Text(
                'VendoraX POS v2.4.0 (Build 492)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 5,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.pos);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.inventory);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.customers);
              break;
            case 4:
              Navigator.pushReplacementNamed(context, AppRoutes.reports);
              break;
            case 5:
              // Already here
              break;
          }
        },
      ),
    );
  }

  void _showStoreProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _storeAddressController,
                decoration: const InputDecoration(
                  labelText: 'Store Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _storePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Store Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTaxCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tax & Currency'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currencySymbolController,
                decoration: const InputDecoration(
                  labelText: 'Currency Symbol',
                  hintText: 'e.g., \$, €, £, ₹',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _currencyCodeController,
                decoration: const InputDecoration(
                  labelText: 'Currency Code',
                  hintText: 'e.g., USD, EUR, GBP, INR',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taxRateController,
                decoration: const InputDecoration(
                  labelText: 'Default Tax Rate (%)',
                  hintText: '5.0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
