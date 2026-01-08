import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

/// SQLite database helper for products
class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
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
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        selling_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        category TEXT NOT NULL,
        stock_quantity INTEGER,
        low_stock_threshold INTEGER,
        image_path TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Create product
  Future<String> createProduct(Product product) async {
    final db = await database;
    final id = product.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final productWithId = product.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await db.insert(
      'products',
      productWithId.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  // Read all products
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'created_at DESC');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Read product by ID
  Future<Product?> getProductById(String id) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Read product by SKU
  Future<Product?> getProductBySku(String sku) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
    );
    
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Update product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    
    return await db.update(
      'products',
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get unsynced products
  Future<List<Product>> getUnsyncedProducts() async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Mark product as synced
  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'products',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all products
  Future<int> clearAll() async {
    final db = await database;
    return await db.delete('products');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

