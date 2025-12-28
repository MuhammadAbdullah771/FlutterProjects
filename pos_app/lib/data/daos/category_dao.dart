import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../domain/entities/category.dart';

/// Data Access Object for Category operations
class CategoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Gets all categories
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Gets a category by ID
  Future<Category?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Gets a category by name
  Future<Category?> getCategoryByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Inserts a category
  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    final map = category.toMap();
    map['is_synced'] = 0; // Mark as not synced
    await db.insert('categories', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Updates a category
  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    final map = category.toMap();
    map['is_synced'] = 0; // Mark as not synced
    await db.update(
      'categories',
      map,
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Deletes a category
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Marks category as synced
  Future<void> markAsSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets unsynced categories
  Future<List<Category>> getUnsyncedCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }
}

