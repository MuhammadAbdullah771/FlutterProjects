import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/utils/result.dart';

/// Product provider for managing product and inventory state
class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider(this._productRepository);

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  Product? _selectedProduct;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Product? get selectedProduct => _selectedProduct;

  List<Product> get lowStockProducts {
    return _products.where((p) => p.isLowStock).toList();
  }

  /// Loads all products
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.getAllProducts();
      if (result.isSuccess) {
        _products = result.dataOrNull ?? [];
      } else {
        _setError(result.errorOrNull ?? 'Failed to load products');
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads products by category
  Future<void> loadProductsByCategory(String categoryId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.getProductsByCategory(categoryId);
      if (result.isSuccess) {
        _products = result.dataOrNull ?? [];
      } else {
        _setError(result.errorOrNull ?? 'Failed to load products');
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Searches products
  Future<void> searchProducts(String query) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.searchProducts(query);
      if (result.isSuccess) {
        _products = result.dataOrNull ?? [];
      } else {
        _setError(result.errorOrNull ?? 'Failed to search products');
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Gets a product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final result = await _productRepository.getProductById(id);
      if (result.isSuccess) {
        return result.dataOrNull;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets a product by SKU
  Future<Product?> getProductBySku(String sku) async {
    try {
      final result = await _productRepository.getProductBySku(sku);
      if (result.isSuccess) {
        return result.dataOrNull;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates a new product
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.createProduct(product);
      if (result.isSuccess) {
        await loadProducts(); // Reload products
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Failed to create product');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates a product
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.updateProduct(product);
      if (result.isSuccess) {
        await loadProducts(); // Reload products
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Failed to update product');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a product
  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.deleteProduct(id);
      if (result.isSuccess) {
        await loadProducts(); // Reload products
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Failed to delete product');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates product stock
  Future<bool> updateStock({
    required String productId,
    required int quantity,
    required TransactionType transactionType,
    String? referenceNumber,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productRepository.updateStock(
        productId: productId,
        quantity: quantity,
        transactionType: transactionType,
        referenceNumber: referenceNumber,
        notes: notes,
      );

      if (result.isSuccess) {
        await loadProducts(); // Reload products
        return true;
      } else {
        _setError(result.errorOrNull ?? 'Failed to update stock');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Gets transactions for a product
  Future<List<InventoryTransaction>> getProductTransactions(String productId) async {
    try {
      final result = await _productRepository.getProductTransactions(productId);
      if (result.isSuccess) {
        return result.dataOrNull ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Sets the selected product
  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Sets the loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Sets the error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

