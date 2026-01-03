import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../database/product_database.dart';

/// Service for managing products (online and offline)
class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProductDatabase _localDB = ProductDatabase.instance;

  // Check if online
  Future<bool> _isOnline() async {
    try {
      await _supabase.from('products').select('id').limit(1).maybeSingle();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Create product (offline-first)
  Future<String> createProduct(Product product) async {
    try {
      // Save locally first
      final id = await _localDB.createProduct(product);

      // Try to sync online
      if (await _isOnline()) {
        try {
          final response = await _supabase
              .from('products')
              .insert(product.toSupabaseMap())
              .select()
              .single();

          if (response['id'] != null) {
            final supabaseId = response['id'].toString();
            // Update local record with Supabase ID and mark as synced
            final updatedProduct = product.copyWith(
              id: supabaseId,
              isSynced: true,
            );
            await _localDB.updateProduct(updatedProduct);
            return supabaseId;
          }
        } catch (e) {
          // If online sync fails, product is saved locally
          print('Failed to sync product online: $e');
        }
      }

      return id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      // Always return from local DB (offline-first)
      return await _localDB.getAllProducts();
    } catch (e) {
      return [];
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await _localDB.getProductById(id);
    } catch (e) {
      return null;
    }
  }

  // Get product by SKU
  Future<Product?> getProductBySku(String sku) async {
    try {
      return await _localDB.getProductBySku(sku);
    } catch (e) {
      return null;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    try {
      // Update locally first
      await _localDB.updateProduct(product.copyWith(isSynced: false));

      // Try to sync online
      if (await _isOnline() && product.id != null) {
        try {
          await _supabase
              .from('products')
              .update(product.toSupabaseMap())
              .eq('id', product.id!)
              .select()
              .maybeSingle();

          // Mark as synced
          await _localDB.markAsSynced(product.id!);
          return true;
        } catch (e) {
          print('Failed to sync product update online: $e');
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      // Delete locally first
      await _localDB.deleteProduct(id);

      // Try to delete online
      if (await _isOnline()) {
        try {
          await _supabase.from('products').delete().eq('id', id);
        } catch (e) {
          print('Failed to delete product online: $e');
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Sync local products to Supabase
  Future<void> syncToCloud() async {
    if (!await _isOnline()) return;

    try {
      final unsyncedProducts = await _localDB.getUnsyncedProducts();

      for (var product in unsyncedProducts) {
        try {
          if (product.id != null && product.id!.isNotEmpty) {
            // Try to update if exists
            final response = await _supabase
                .from('products')
                .update(product.toSupabaseMap())
                .eq('id', product.id!)
                .select()
                .maybeSingle();

            if (response != null) {
              await _localDB.markAsSynced(product.id!);
            }
          } else {
            // Create new
            final response = await _supabase
                .from('products')
                .insert(product.toSupabaseMap())
                .select()
                .single();

            if (response['id'] != null) {
              final supabaseId = response['id'].toString();
              final updatedProduct = product.copyWith(
                id: supabaseId,
                isSynced: true,
              );
              await _localDB.updateProduct(updatedProduct);
            }
          }
        } catch (e) {
          print('Failed to sync product ${product.id}: $e');
        }
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // Sync from Supabase to local
  Future<void> syncFromCloud() async {
    if (!await _isOnline()) return;

    try {
      final response = await _supabase.from('products').select();

      final products = (response as List)
          .map((item) => Product.fromMap(item).copyWith(isSynced: true))
          .toList();

      // Save all products to local DB
      for (var product in products) {
        await _localDB.createProduct(product);
      }
    } catch (e) {
      print('Failed to sync from cloud: $e');
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final products = await _localDB.getAllProducts();
      final categories = products.map((p) => p.category).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      return [];
    }
  }
}
