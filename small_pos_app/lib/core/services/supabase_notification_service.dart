import 'package:supabase_flutter/supabase_flutter.dart';
import '../../inventory/models/product_model.dart';
import 'notification_service.dart';

/// Service for handling Supabase real-time push notifications
class SupabaseNotificationService {
  static final SupabaseNotificationService instance = SupabaseNotificationService._init();
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _productsChannel;

  SupabaseNotificationService._init();

  /// Initialize Supabase real-time subscriptions
  Future<void> initialize() async {
    try {
      // Subscribe to products table changes
      _productsChannel = _supabase
          .channel('products_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'products',
            callback: (payload) {
              _handleProductUpdate(payload);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'products',
            callback: (payload) {
              _handleProductInsert(payload);
            },
          )
          .subscribe();

      print('Supabase real-time subscription initialized');
    } catch (e) {
      print('Error initializing Supabase notifications: $e');
    }
  }

  /// Handle product update events
  void _handleProductUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;

      final stockQuantity = newRecord['stock_quantity'];
      final lowStockThreshold = newRecord['low_stock_threshold'];
      final productName = newRecord['name'];
      final productId = newRecord['id'];

      if (stockQuantity == null || 
          lowStockThreshold == null || 
          productName == null ||
          productId == null) {
        return;
      }

      final stockQty = (stockQuantity is int) ? stockQuantity : (stockQuantity as num).toInt();
      final threshold = (lowStockThreshold is int) ? lowStockThreshold : (lowStockThreshold as num).toInt();

      // Check if product is low in stock
      if (stockQty <= threshold) {
        final product = Product(
          id: productId.toString(),
          name: productName.toString(),
          sku: newRecord['sku']?.toString() ?? '',
          sellingPrice: (newRecord['selling_price'] ?? 0.0).toDouble(),
          costPrice: (newRecord['cost_price'] ?? 0.0).toDouble(),
          category: newRecord['category']?.toString() ?? '',
          stockQuantity: stockQty,
          lowStockThreshold: threshold,
        );

        // Show local notification
        NotificationService.instance.showLowStockNotification(product);
      }
    } catch (e) {
      print('Error handling product update: $e');
    }
  }

  /// Handle product insert events
  void _handleProductInsert(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      if (newRecord == null) return;

      final stockQuantity = newRecord['stock_quantity'];
      final lowStockThreshold = newRecord['low_stock_threshold'];
      final productName = newRecord['name'];
      final productId = newRecord['id'];

      if (stockQuantity == null || 
          lowStockThreshold == null || 
          productName == null ||
          productId == null) {
        return;
      }

      final stockQty = (stockQuantity is int) 
          ? stockQuantity 
          : ((stockQuantity as num).toInt());
      final threshold = (lowStockThreshold is int) 
          ? lowStockThreshold 
          : ((lowStockThreshold as num).toInt());

      // Check if new product is low in stock
      if (stockQty <= threshold && stockQty >= 0 && threshold > 0) {
        final product = Product(
          id: productId.toString(),
          name: productName.toString(),
          sku: newRecord['sku']?.toString() ?? '',
          sellingPrice: (newRecord['selling_price'] ?? 0.0).toDouble(),
          costPrice: (newRecord['cost_price'] ?? 0.0).toDouble(),
          category: newRecord['category']?.toString() ?? '',
          stockQuantity: stockQty,
          lowStockThreshold: threshold,
        );

        // Show local notification
        NotificationService.instance.showLowStockNotification(product);
      }
    } catch (e) {
      print('Error handling product insert: $e');
    }
  }

  /// Disconnect from real-time subscriptions
  Future<void> disconnect() async {
    try {
      await _productsChannel?.unsubscribe();
      _productsChannel = null;
    } catch (e) {
      print('Error disconnecting Supabase notifications: $e');
    }
  }
}

