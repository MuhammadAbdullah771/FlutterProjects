import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/utils/result.dart';

/// Remote product repository implementation using Supabase
/// This will be used for syncing data when online
/// Currently a placeholder for future sync functionality
class RemoteProductRepository implements ProductRepository {
  final supabase.SupabaseClient _supabase;
  final Uuid _uuid = const Uuid();

  RemoteProductRepository({required supabase.SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('name');

      final products = (response as List)
          .map((map) => Product.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(products);
    } catch (e) {
      return Failure('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('name');

      final products = (response as List)
          .map((map) => Product.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(products);
    } catch (e) {
      return Failure('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      final product = Product.fromMap(Map<String, dynamic>.from(response));
      return Success(product);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return const Success(null);
      }
      return Failure('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product?>> getProductBySku(String sku) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('sku', sku)
          .maybeSingle();

      if (response == null) return const Success(null);
      final product = Product.fromMap(Map<String, dynamic>.from(response));
      return Success(product);
    } catch (e) {
      return Failure('Failed to get product by SKU: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      // Note: This query assumes Supabase supports this. You may need to adjust based on your setup
      final response = await _supabase
          .from('products')
          .select()
          .filter('current_stock', 'lte', 'low_stock_threshold')
          .order('current_stock');

      final products = (response as List)
          .map((map) => Product.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(products);
    } catch (e) {
      return Failure('Failed to get low stock products: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .or('name.ilike.%$query%,sku.ilike.%$query%')
          .order('name');

      final products = (response as List)
          .map((map) => Product.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(products);
    } catch (e) {
      return Failure('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      final map = product.toMap();
      final response = await _supabase.from('products').insert(map).select().single();

      final createdProduct = Product.fromMap(Map<String, dynamic>.from(response));
      return Success(createdProduct);
    } catch (e) {
      return Failure('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      final map = product.toMap();
      final response = await _supabase
          .from('products')
          .update(map)
          .eq('id', product.id)
          .select()
          .single();

      final updatedProduct = Product.fromMap(Map<String, dynamic>.from(response));
      return Success(updatedProduct);
    } catch (e) {
      return Failure('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
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
      // Get current product
      final productResult = await getProductById(productId);
      if (productResult.isFailure || productResult.dataOrNull == null) {
        return Failure(productResult.errorOrNull ?? 'Product not found');
      }

      final product = productResult.dataOrNull!;
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

      // Update product stock
      final updatedProduct = product.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
      );

      await updateProduct(updatedProduct);

      // Create transaction record
      final transaction = InventoryTransaction(
        id: _uuid.v4(),
        productId: productId,
        transactionType: transactionType,
        quantity: quantity,
        referenceNumber: referenceNumber,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase.from('inventory_transactions').insert(transaction.toMap());

      return Success(updatedProduct);
    } catch (e) {
      return Failure('Failed to update stock: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<InventoryTransaction>>> getProductTransactions(String productId) async {
    try {
      final response = await _supabase
          .from('inventory_transactions')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final transactions = (response as List)
          .map((map) => InventoryTransaction.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<InventoryTransaction>>> getAllTransactions({int? limit, int? offset}) async {
    try {
      var query = _supabase
          .from('inventory_transactions')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 100) - 1);

      final response = await query;

      final transactions = (response as List)
          .map((map) => InventoryTransaction.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions: ${e.toString()}');
    }
  }
}

