import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';

/// SQLite database helper for expenses
class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
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
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<String> createExpense(Expense expense) async {
    final db = await database;
    final id = expense.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final expenseWithId = expense.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert(
      'expenses',
      expenseWithId.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Expense>> getAllExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    List<Map<String, dynamic>> result;

    if (startDate != null && endDate != null) {
      // Use date comparison correctly (compare date strings)
      final startDateStr = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();
      final endDateStr = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();
      
      result = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startDateStr, endDateStr],
        orderBy: 'date DESC, created_at DESC',
      );
    } else {
      result = await db.query('expenses', orderBy: 'date DESC, created_at DESC');
    }

    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<Expense?> getExpenseById(String id) async {
    final db = await database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    final expenseWithUpdated = expense.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'expenses',
      expenseWithUpdated.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM expenses ORDER BY category');
    return result.map((map) => map['category'] as String).toList();
  }

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    List<Map<String, dynamic>> result;

    if (startDate != null && endDate != null) {
      result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );
    } else {
      result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    }

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}

