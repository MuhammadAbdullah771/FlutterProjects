/// Transaction/Ledger entry model
class Transaction {
  final String? id;
  final String customerId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String? reference; // Order ID, Invoice ID, etc.
  final PaymentMethod? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  Transaction({
    this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.description,
    this.reference,
    this.paymentMethod,
    DateTime? createdAt,
    this.updatedAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'reference': reference,
      'payment_method': paymentMethod?.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'reference': reference,
      'payment_method': paymentMethod?.name,
    };
  }

  // Create from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString(),
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] ?? ''),
        orElse: () => TransactionType.debit,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'],
      reference: map['reference'],
      paymentMethod: map['payment_method'] != null || map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == (map['payment_method'] ?? map['paymentMethod']),
              orElse: () => PaymentMethod.cash,
            )
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : null,
      isSynced: (map['is_synced'] ?? map['isSynced'] ?? 0) == 1,
    );
  }

  // Copy with method
  Transaction copyWith({
    String? id,
    String? customerId,
    TransactionType? type,
    double? amount,
    String? description,
    String? reference,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Helper methods
  bool get isDebit => type == TransactionType.debit;
  bool get isCredit => type == TransactionType.credit;
  String get displayAmount => isDebit ? '-\$${amount.toStringAsFixed(2)}' : '+\$${amount.toStringAsFixed(2)}';
}

enum TransactionType {
  debit, // Customer owes money (sale, invoice)
  credit, // Customer paid money (payment)
}

enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  cheque,
  other,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

