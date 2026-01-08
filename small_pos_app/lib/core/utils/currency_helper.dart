import '../database/settings_database.dart';

/// Helper class for currency formatting
class CurrencyHelper {
  static String _currencySymbol = '\$';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      try {
        final settings = await SettingsDatabase.instance.getSettings();
        _currencySymbol = settings.currencySymbol;
        _initialized = true;
      } catch (e) {
        // Use default
      }
    }
  }

  static Future<String> getCurrencySymbol() async {
    await initialize();
    return _currencySymbol;
  }

  static Future<String> format(double amount) async {
    final symbol = await getCurrencySymbol();
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatSync(double amount, String symbol) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

