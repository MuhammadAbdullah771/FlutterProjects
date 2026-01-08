import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../database/settings_database.dart';
import '../theme.dart';

/// Theme provider for managing light/dark mode
class ThemeProvider with ChangeNotifier {
  final SettingsDatabase _settingsDB = SettingsDatabase.instance;
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  bool get isDarkMode => _settings.isDarkMode;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _settings = await _settingsDB.getSettings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await _settingsDB.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _settingsDB.updateSettings(_settings);
    notifyListeners();
  }

  ThemeData get theme {
    return _settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
}

