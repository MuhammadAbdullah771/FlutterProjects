import 'package:equatable/equatable.dart';
import 'product.dart';

/// Cart item entity representing a product in the shopping cart
class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double? customPrice; // For discounts or price overrides

  const CartItem({
    required this.product,
    required this.quantity,
    this.customPrice,
  });

  /// Gets the unit price (custom price if set, otherwise product selling price)
  double get unitPrice => customPrice ?? product.sellingPrice;

  /// Gets the total price for this cart item
  double get totalPrice => unitPrice * quantity;

  /// Creates a copy of the cart item with updated fields
  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
    );
  }

  @override
  List<Object?> get props => [product, quantity, customPrice];

  @override
  String toString() => 'CartItem(product: ${product.name}, quantity: $quantity, total: $totalPrice)';
}

