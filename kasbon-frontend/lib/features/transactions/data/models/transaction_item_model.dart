import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/transaction_item.dart';

/// Data Transfer Object for TransactionItem
/// Handles conversion between SQLite Map and TransactionItem entity
class TransactionItemModel {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final double discountAmount;
  final double subtotal;
  final DateTime createdAt;

  const TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.discountAmount,
    required this.subtotal,
    required this.createdAt,
  });

  /// Create TransactionItemModel from SQLite Map
  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map[DatabaseConstants.colId] as String,
      transactionId: map[DatabaseConstants.colTransactionId] as String,
      productId: map[DatabaseConstants.colProductId] as String,
      productName: map[DatabaseConstants.colProductName] as String,
      productSku: map[DatabaseConstants.colProductSku] as String,
      quantity: map[DatabaseConstants.colQuantity] as int,
      costPrice: (map[DatabaseConstants.colCostPrice] as num).toDouble(),
      sellingPrice: (map[DatabaseConstants.colSellingPrice] as num).toDouble(),
      discountAmount: (map[DatabaseConstants.colDiscountAmount] as num?)?.toDouble() ?? 0,
      subtotal: (map[DatabaseConstants.colSubtotal] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colCreatedAt] as int,
      ),
    );
  }

  /// Convert TransactionItemModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colTransactionId: transactionId,
      DatabaseConstants.colProductId: productId,
      DatabaseConstants.colProductName: productName,
      DatabaseConstants.colProductSku: productSku,
      DatabaseConstants.colQuantity: quantity,
      DatabaseConstants.colCostPrice: costPrice,
      DatabaseConstants.colSellingPrice: sellingPrice,
      DatabaseConstants.colDiscountAmount: discountAmount,
      DatabaseConstants.colSubtotal: subtotal,
      DatabaseConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
    };
  }

  /// Convert TransactionItemModel to TransactionItem entity
  TransactionItem toEntity() {
    return TransactionItem(
      id: id,
      transactionId: transactionId,
      productId: productId,
      productName: productName,
      productSku: productSku,
      quantity: quantity,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      discountAmount: discountAmount,
      subtotal: subtotal,
      createdAt: createdAt,
    );
  }

  /// Create TransactionItemModel from TransactionItem entity
  factory TransactionItemModel.fromEntity(TransactionItem item) {
    return TransactionItemModel(
      id: item.id,
      transactionId: item.transactionId,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku,
      quantity: item.quantity,
      costPrice: item.costPrice,
      sellingPrice: item.sellingPrice,
      discountAmount: item.discountAmount,
      subtotal: item.subtotal,
      createdAt: item.createdAt,
    );
  }
}
