import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

/// SQLite database helper for customers
class CustomerDatabase {
  static final CustomerDatabase instance = CustomerDatabase._init();
  static sqflite.Database? _database;

  CustomerDatabase._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customers.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        balance REAL NOT NULL DEFAULT 0,
        total_spent REAL NOT NULL DEFAULT 0,
        tags TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        reference TEXT,
        payment_method TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_transactions_customer_id ON transactions(customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_created_at ON transactions(created_at)',
    );
  }

  // Customer CRUD operations
  Future<String> insertCustomer(Customer customer) async {
    final db = await database;
    final id = customer.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final customerWithId = customer.copyWith(
      id: id,
      createdAt: customer.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert(
      'customers',
      customerWithId.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final maps = await db.query('customers', orderBy: 'name ASC');

    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(String id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    final customerWithUpdated = customer.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'customers',
      customerWithUpdated.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await database;
    // Delete transactions first (CASCADE should handle this, but being explicit)
    await db.delete('transactions', where: 'customer_id = ?', whereArgs: [id]);
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction operations
  Future<String> insertTransaction(Transaction transaction) async {
    final db = await database;
    final id =
        transaction.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final transactionWithId = transaction.copyWith(id: id);

    await db.insert(
      'transactions',
      transactionWithId.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    // Update customer balance
    await _updateCustomerBalance(db, transaction.customerId);

    return id;
  }

  Future<List<Transaction>> getTransactionsByCustomerId(
    String customerId, {
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(String id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    final transaction = await getTransactionById(id);
    if (transaction == null) return 0;

    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update customer balance after deletion
    await _updateCustomerBalance(db, transaction.customerId);

    return result;
  }

  // Calculate and update customer balance from transactions
  Future<void> _updateCustomerBalance(
    sqflite.Database db,
    String customerId,
  ) async {
    final transactions = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    double balance = 0.0;
    double totalSpent = 0.0;

    for (var map in transactions) {
      final transaction = Transaction.fromMap(map);
      if (transaction.type == TransactionType.debit) {
        balance += transaction.amount;
        totalSpent += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    await db.update(
      'customers',
      {
        'balance': balance,
        'total_spent': totalSpent,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // Get customer balance directly from transactions
  Future<double> getCustomerBalance(String customerId) async {
    final db = await database;
    final transactions = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    double balance = 0.0;
    for (var map in transactions) {
      final transaction = Transaction.fromMap(map);
      if (transaction.type == TransactionType.debit) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    return balance;
  }

  // Get all transactions with optional filters
  Future<List<Transaction>> getAllTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    String? orderBy,
  }) async {
    final db = await database;
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (type != null) {
      where += ' AND type = ?';
      whereArgs.add(type.name);
    }

    if (startDate != null) {
      where += ' AND created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    return db
        .query(
          'transactions',
          where: where,
          whereArgs: whereArgs,
          orderBy: orderBy ?? 'created_at DESC',
          limit: limit,
        )
        .then((maps) => maps.map((map) => Transaction.fromMap(map)).toList());
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
