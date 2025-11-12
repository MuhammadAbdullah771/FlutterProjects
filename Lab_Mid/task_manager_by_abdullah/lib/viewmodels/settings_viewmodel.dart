import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/database_service.dart';
import '../data/services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this.databaseService,
    required this.notificationService,
  });

  final DatabaseService databaseService;
  final NotificationService notificationService;

  static const _themeKey = 'theme_mode_dark';
  static const _notificationsKey = 'notifications_enabled';
  static const _soundKey = 'notification_sound';

  bool _darkMode = false;
  bool _notificationsEnabled = true;
  NotificationSoundOption _selectedSound =
      NotificationService.soundOptions.first;

  bool get isDarkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  NotificationSoundOption get selectedSound => _selectedSound;
  List<NotificationSoundOption> get soundOptions =>
      NotificationService.soundOptions;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_themeKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

    final storedSound = prefs.getString(_soundKey);
    if (storedSound != null) {
      _selectedSound = soundOptions.firstWhere(
        (opt) => opt.id == storedSound,
        orElse: () => soundOptions.first,
      );
    }
    await notificationService.setSound(_selectedSound);
  }

  Future<void> toggleTheme(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> updateSound(NotificationSoundOption option) async {
    _selectedSound = option;
    await notificationService.setSound(option);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, option.id);
    notifyListeners();
  }

  Future<File> createBackup() => databaseService.exportDatabaseFile();

  Future<File?> latestBackupFile() => databaseService.latestBackupFile();

  Future<void> restoreBackup(File file) => databaseService.importDatabaseFile(file);

  Future<void> resetData() async {
    await databaseService.resetAll();
  }
}
