import 'package:equatable/equatable.dart';

/// Type of inventory transaction
enum TransactionType {
  stockIn,
  stockOut,
  adjustment,
  sale,
  return_,
}

/// Inventory transaction entity representing stock movements
class InventoryTransaction extends Equatable {
  final String id;
  final String productId;
  final TransactionType transactionType;
  final int quantity;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryTransaction({
    required this.id,
    required this.productId,
    required this.transactionType,
    required this.quantity,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an InventoryTransaction from a map
  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == map['transaction_type'] as String,
        orElse: () => TransactionType.stockIn,
      ),
      quantity: map['quantity'] as int,
      referenceNumber: map['reference_number'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts InventoryTransaction to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'transaction_type': transactionType.name,
      'quantity': quantity,
      'reference_number': referenceNumber,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Gets display name for transaction type
  String get transactionTypeDisplay {
    switch (transactionType) {
      case TransactionType.stockIn:
        return 'Stock In';
      case TransactionType.stockOut:
        return 'Stock Out';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.return_:
        return 'Return';
    }
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        transactionType,
        quantity,
        referenceNumber,
        notes,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'InventoryTransaction(id: $id, productId: $productId, type: ${transactionType.name}, quantity: $quantity)';
}

