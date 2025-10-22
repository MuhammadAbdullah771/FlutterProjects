// lib/database/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/semester_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  static const String tableName = 'Semesters';

  // Database instance ko initialize aur retrieve karna
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Database initialize karna
  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cgpa_calculator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Table create karna
  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semesterName TEXT,
        gpa REAL,
        totalCreditHours INTEGER,
        subjects TEXT
      )
    ''');
    print("Database table created: $tableName"); // Console mein log
  }

  // Naya Semester save karna
  Future<int> insertSemester(Semester semester) async {
    final db = await database;
    final map = semester.toMap();
    // ID ko remove karein taake database khud generate kare
    map.remove('id');
    return await db.insert(tableName, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Sab Semesters retrieve karna
  Future<List<Semester>> getSemesters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: 'id DESC');

    // Maps ko List<Semester> mein convert karna
    return List.generate(maps.length, (i) {
      return Semester.fromMap(maps[i]);
    });
  }

  // Semester delete karna
  Future<int> deleteSemester(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}