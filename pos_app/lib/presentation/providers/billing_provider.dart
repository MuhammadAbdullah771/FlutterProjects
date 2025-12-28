import 'package:flutter/foundation.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

/// Billing provider for managing shopping cart and checkout
class BillingProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  
  int get cartItemCount => _cartItems.length;

  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get total => subtotal; // Can add tax, discount, etc. later

  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  /// Adds a product to the cart
  void addToCart(Product product, {int quantity = 1, double? customPrice}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        customPrice: customPrice,
      ));
    }

    notifyListeners();
  }

  /// Removes an item from the cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Updates the quantity of an item in the cart
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  /// Updates the price of an item in the cart
  void updatePrice(String productId, double? customPrice) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(customPrice: customPrice);
      notifyListeners();
    }
  }

  /// Clears the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Gets total quantity of items in cart
  int getTotalQuantity() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}

