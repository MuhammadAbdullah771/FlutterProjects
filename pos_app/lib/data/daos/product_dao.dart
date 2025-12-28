import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../domain/entities/product.dart';

/// Data Access Object for Product operations
class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Gets all products
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Gets products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Gets a product by ID
  Future<Product?> getProductById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Gets a product by SKU
  Future<Product?> getProductBySku(String sku) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Gets low stock products
  Future<List<Product>> getLowStockProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT * FROM products 
      WHERE current_stock <= low_stock_threshold 
      ORDER BY current_stock ASC
    ''');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Searches products by name or SKU
  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final searchQuery = '%$query%';
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Inserts a product
  Future<void> insertProduct(Product product) async {
    final db = await _dbHelper.database;
    final map = product.toMap();
    map['is_synced'] = 0; // Mark as not synced
    await db.insert('products', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Updates a product
  Future<void> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    final map = product.toMap();
    map['is_synced'] = 0; // Mark as not synced
    await db.update(
      'products',
      map,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Updates product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {
        'current_stock': newStock,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// Deletes a product
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Marks product as synced
  Future<void> markAsSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets unsynced products
  Future<List<Product>> getUnsyncedProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }
}

