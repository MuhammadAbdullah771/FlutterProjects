import '../entities/product.dart';
import '../entities/inventory_transaction.dart';
import '../../core/utils/result.dart';

/// Product repository interface
/// Defines the contract for product and inventory operations
abstract class ProductRepository {
  /// Gets all products
  Future<Result<List<Product>>> getAllProducts();

  /// Gets products by category
  Future<Result<List<Product>>> getProductsByCategory(String categoryId);

  /// Gets a product by ID
  Future<Result<Product?>> getProductById(String id);

  /// Gets a product by SKU
  Future<Result<Product?>> getProductBySku(String sku);

  /// Gets low stock products
  Future<Result<List<Product>>> getLowStockProducts();

  /// Searches products
  Future<Result<List<Product>>> searchProducts(String query);

  /// Creates a new product
  Future<Result<Product>> createProduct(Product product);

  /// Updates an existing product
  Future<Result<Product>> updateProduct(Product product);

  /// Deletes a product
  Future<Result<void>> deleteProduct(String id);

  /// Updates product stock
  Future<Result<Product>> updateStock({
    required String productId,
    required int quantity,
    required TransactionType transactionType,
    String? referenceNumber,
    String? notes,
  });

  /// Gets inventory transactions for a product
  Future<Result<List<InventoryTransaction>>> getProductTransactions(String productId);

  /// Gets all inventory transactions
  Future<Result<List<InventoryTransaction>>> getAllTransactions({int? limit, int? offset});
}

