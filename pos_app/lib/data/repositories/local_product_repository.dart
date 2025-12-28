import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/utils/result.dart';
import '../daos/product_dao.dart';
import '../daos/inventory_transaction_dao.dart';

/// Local product repository implementation using SQLite
/// Handles all product and inventory operations offline
class LocalProductRepository implements ProductRepository {
  final ProductDao _productDao;
  final InventoryTransactionDao _transactionDao;
  final Uuid _uuid = const Uuid();

  LocalProductRepository({
    required ProductDao productDao,
    required InventoryTransactionDao transactionDao,
  })  : _productDao = productDao,
        _transactionDao = transactionDao;

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      final products = await _productDao.getAllProducts();
      return Success(products);
    } catch (e) {
      return Failure('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String categoryId) async {
    try {
      final products = await _productDao.getProductsByCategory(categoryId);
      return Success(products);
    } catch (e) {
      return Failure('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final product = await _productDao.getProductById(id);
      return Success(product);
    } catch (e) {
      return Failure('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product?>> getProductBySku(String sku) async {
    try {
      final product = await _productDao.getProductBySku(sku);
      return Success(product);
    } catch (e) {
      return Failure('Failed to get product by SKU: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final products = await _productDao.getLowStockProducts();
      return Success(products);
    } catch (e) {
      return Failure('Failed to get low stock products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        final products = await _productDao.getAllProducts();
        return Success(products);
      }
      final products = await _productDao.searchProducts(query);
      return Success(products);
    } catch (e) {
      return Failure('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      // Check if SKU already exists
      final existing = await _productDao.getProductBySku(product.sku);
      if (existing != null) {
        return const Failure('Product with this SKU already exists');
      }

      final now = DateTime.now();
      final newProduct = product.copyWith(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
      );

      await _productDao.insertProduct(newProduct);
      return Success(newProduct);
    } catch (e) {
      return Failure('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      final existing = await _productDao.getProductById(product.id);
      if (existing == null) {
        return const Failure('Product not found');
      }

      // Check if SKU is being changed and if it conflicts with another product
      if (existing.sku != product.sku) {
        final skuConflict = await _productDao.getProductBySku(product.sku);
        if (skuConflict != null && skuConflict.id != product.id) {
          return const Failure('Product with this SKU already exists');
        }
      }

      final updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
      );

      await _productDao.updateProduct(updatedProduct);
      return Success(updatedProduct);
    } catch (e) {
      return Failure('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      final existing = await _productDao.getProductById(id);
      if (existing == null) {
        return const Failure('Product not found');
      }

      await _productDao.deleteProduct(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> updateStock({
    required String productId,
    required int quantity,
    required TransactionType transactionType,
    String? referenceNumber,
    String? notes,
  }) async {
    try {
      final product = await _productDao.getProductById(productId);
      if (product == null) {
        return const Failure('Product not found');
      }

      int newStock = product.currentStock;
      switch (transactionType) {
        case TransactionType.stockIn:
        case TransactionType.return_:
          newStock += quantity;
          break;
        case TransactionType.stockOut:
        case TransactionType.sale:
          newStock -= quantity;
          break;
        case TransactionType.adjustment:
          newStock = quantity;
          break;
      }

      if (newStock < 0) {
        return Failure('Insufficient stock. Available: ${product.currentStock}');
      }

      final now = DateTime.now();
      final updatedProduct = product.copyWith(
        currentStock: newStock,
        updatedAt: now,
      );

      // Update product stock
      await _productDao.updateProductStock(productId, newStock);

      // Create transaction record
      final transaction = InventoryTransaction(
        id: _uuid.v4(),
        productId: productId,
        transactionType: transactionType,
        quantity: quantity,
        referenceNumber: referenceNumber,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _transactionDao.insertTransaction(transaction);

      return Success(updatedProduct);
    } catch (e) {
      return Failure('Failed to update stock: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<InventoryTransaction>>> getProductTransactions(String productId) async {
    try {
      final transactions = await _transactionDao.getTransactionsByProduct(productId);
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<InventoryTransaction>>> getAllTransactions({int? limit, int? offset}) async {
    try {
      final transactions = await _transactionDao.getAllTransactions(
        limit: limit,
        offset: offset,
      );
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions: ${e.toString()}');
    }
  }
}

