/// Product model
class Product {
  final String? id;
  final String sku;
  final String name;
  final double sellingPrice;
  final double costPrice;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.sellingPrice,
    required this.costPrice,
    required this.category,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'category': category,
    };
  }

  // Create from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString(),
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      sellingPrice: (map['selling_price'] ?? map['sellingPrice'] ?? 0.0).toDouble(),
      costPrice: (map['cost_price'] ?? map['costPrice'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : null,
      isSynced: (map['is_synced'] ?? map['isSynced'] ?? 0) == 1,
    );
  }

  // Copy with method for updates
  Product copyWith({
    String? id,
    String? sku,
    String? name,
    double? sellingPrice,
    double? costPrice,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

