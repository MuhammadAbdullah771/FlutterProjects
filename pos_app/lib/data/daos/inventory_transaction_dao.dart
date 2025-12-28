import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../domain/entities/inventory_transaction.dart';

/// Data Access Object for Inventory Transaction operations
class InventoryTransactionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Gets all transactions for a product
  Future<List<InventoryTransaction>> getTransactionsByProduct(String productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }

  /// Gets all transactions
  Future<List<InventoryTransaction>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inventory_transactions',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }

  /// Gets a transaction by ID
  Future<InventoryTransaction?> getTransactionById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return InventoryTransaction.fromMap(maps.first);
  }

  /// Gets transactions by type
  Future<List<InventoryTransaction>> getTransactionsByType(TransactionType type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'transaction_type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }

  /// Inserts a transaction
  Future<void> insertTransaction(InventoryTransaction transaction) async {
    final db = await _dbHelper.database;
    final map = transaction.toMap();
    map['is_synced'] = 0; // Mark as not synced
    await db.insert('inventory_transactions', map);
  }

  /// Deletes a transaction
  Future<void> deleteTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.delete('inventory_transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Marks transaction as synced
  Future<void> markAsSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'inventory_transactions',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets unsynced transactions
  Future<List<InventoryTransaction>> getUnsyncedTransactions() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inventory_transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => InventoryTransaction.fromMap(map)).toList();
  }
}

