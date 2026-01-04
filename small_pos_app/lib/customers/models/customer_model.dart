/// Customer model
class Customer {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final double balance;
  final double totalSpent;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.balance = 0.0,
    this.totalSpent = 0.0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'balance': balance,
      'total_spent': totalSpent,
      'tags': tags.join(','),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'balance': balance,
      'total_spent': totalSpent,
      'tags': tags,
    };
  }

  // Create from Map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      phone: map['phone'],
      email: map['email'],
      balance: (map['balance'] ?? 0.0).toDouble(),
      totalSpent: (map['total_spent'] ?? map['totalSpent'] ?? 0.0).toDouble(),
      tags: map['tags'] != null
          ? (map['tags'] is String
              ? (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
              : List<String>.from(map['tags']))
          : [],
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

  // Copy with method
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    double? balance,
    double? totalSpent,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      totalSpent: totalSpent ?? this.totalSpent,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Helper methods
  bool get hasBalance => balance > 0;
  bool get hasCredit => balance < 0;
  String get displayBalance => balance >= 0 ? '\$${balance.toStringAsFixed(2)}' : '-\$${(-balance).toStringAsFixed(2)}';
}

