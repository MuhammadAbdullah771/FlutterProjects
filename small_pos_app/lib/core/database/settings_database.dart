import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/app_settings.dart';

/// SQLite database helper for app settings
class SettingsDatabase {
  static final SettingsDatabase instance = SettingsDatabase._init();
  static Database? _database;

  SettingsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('settings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        currency_symbol TEXT NOT NULL DEFAULT '\$',
        currency_code TEXT NOT NULL DEFAULT 'USD',
        default_tax_rate REAL NOT NULL DEFAULT 5.0,
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        store_name TEXT NOT NULL DEFAULT 'My Store',
        store_address TEXT,
        store_phone TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Insert default settings
    await db.insert(
      'settings',
      AppSettings().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppSettings> getSettings() async {
    final db = await database;
    final maps = await db.query('settings', where: 'id = ?', whereArgs: ['settings']);

    if (maps.isEmpty) {
      // Return default settings if none exist
      return AppSettings();
    }
    return AppSettings.fromMap(maps.first);
  }

  Future<void> updateSettings(AppSettings settings) async {
    final db = await database;
    final updatedSettings = settings.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      'settings',
      updatedSettings.toMap(),
      where: 'id = ?',
      whereArgs: ['settings'],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

