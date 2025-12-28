import 'package:equatable/equatable.dart';

/// Product entity representing a product in the inventory
class Product extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? categoryId;
  final double costPrice;
  final double sellingPrice;
  final int currentStock;
  final int lowStockThreshold;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.lowStockThreshold,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a Product from a map (useful for database/JSON deserialization)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String?,
      costPrice: (map['cost_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      currentStock: map['current_stock'] as int,
      lowStockThreshold: map['low_stock_threshold'] as int,
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts Product to a map (useful for database/JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category_id': categoryId,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'low_stock_threshold': lowStockThreshold,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Checks if the product is low in stock
  bool get isLowStock => currentStock <= lowStockThreshold;

  /// Calculates the profit margin
  double get profitMargin => sellingPrice - costPrice;

  /// Calculates the profit margin percentage
  double get profitMarginPercentage {
    if (sellingPrice == 0) return 0;
    return ((sellingPrice - costPrice) / sellingPrice) * 100;
  }

  /// Creates a copy of the product with updated fields
  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? categoryId,
    double? costPrice,
    double? sellingPrice,
    int? currentStock,
    int? lowStockThreshold,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        categoryId,
        costPrice,
        sellingPrice,
        currentStock,
        lowStockThreshold,
        description,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'Product(id: $id, sku: $sku, name: $name, stock: $currentStock)';
}

