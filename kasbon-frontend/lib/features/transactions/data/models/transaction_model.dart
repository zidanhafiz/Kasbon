import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';

/// Data Transfer Object for Transaction
/// Handles conversion between SQLite Map and Transaction entity
class TransactionModel {
  final String id;
  final String transactionNumber;
  final String? customerName;
  final double subtotal;
  final double discountAmount;
  final double discountPercentage;
  final double taxAmount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final double? cashReceived;
  final double? cashChange;
  final String? notes;
  final String? cashierName;
  final DateTime transactionDate;
  final DateTime? debtPaidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    this.customerName,
    required this.subtotal,
    required this.discountAmount,
    required this.discountPercentage,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.cashReceived,
    this.cashChange,
    this.notes,
    this.cashierName,
    required this.transactionDate,
    this.debtPaidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create TransactionModel from SQLite Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DatabaseConstants.colId] as String,
      transactionNumber: map[DatabaseConstants.colTransactionNumber] as String,
      customerName: map[DatabaseConstants.colCustomerName] as String?,
      subtotal: (map[DatabaseConstants.colSubtotal] as num).toDouble(),
      discountAmount: (map[DatabaseConstants.colDiscountAmount] as num?)?.toDouble() ?? 0,
      discountPercentage: (map[DatabaseConstants.colDiscountPercentage] as num?)?.toDouble() ?? 0,
      taxAmount: (map[DatabaseConstants.colTaxAmount] as num?)?.toDouble() ?? 0,
      total: (map[DatabaseConstants.colTotal] as num).toDouble(),
      paymentMethod: map[DatabaseConstants.colPaymentMethod] as String,
      paymentStatus: map[DatabaseConstants.colPaymentStatus] as String,
      cashReceived: (map[DatabaseConstants.colCashReceived] as num?)?.toDouble(),
      cashChange: (map[DatabaseConstants.colCashChange] as num?)?.toDouble(),
      notes: map[DatabaseConstants.colNotes] as String?,
      cashierName: map[DatabaseConstants.colCashierName] as String?,
      transactionDate: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colTransactionDate] as int,
      ),
      debtPaidAt: map[DatabaseConstants.colDebtPaidAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[DatabaseConstants.colDebtPaidAt] as int,
            )
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colCreatedAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colUpdatedAt] as int,
      ),
    );
  }

  /// Convert TransactionModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colTransactionNumber: transactionNumber,
      DatabaseConstants.colCustomerName: customerName,
      DatabaseConstants.colSubtotal: subtotal,
      DatabaseConstants.colDiscountAmount: discountAmount,
      DatabaseConstants.colDiscountPercentage: discountPercentage,
      DatabaseConstants.colTaxAmount: taxAmount,
      DatabaseConstants.colTotal: total,
      DatabaseConstants.colPaymentMethod: paymentMethod,
      DatabaseConstants.colPaymentStatus: paymentStatus,
      DatabaseConstants.colCashReceived: cashReceived,
      DatabaseConstants.colCashChange: cashChange,
      DatabaseConstants.colNotes: notes,
      DatabaseConstants.colCashierName: cashierName,
      DatabaseConstants.colTransactionDate: transactionDate.millisecondsSinceEpoch,
      DatabaseConstants.colDebtPaidAt: debtPaidAt?.millisecondsSinceEpoch,
      DatabaseConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
      DatabaseConstants.colUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convert TransactionModel to Transaction entity
  /// Optionally include transaction items
  Transaction toEntity({List<TransactionItem> items = const []}) {
    return Transaction(
      id: id,
      transactionNumber: transactionNumber,
      customerName: customerName,
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountPercentage: discountPercentage,
      taxAmount: taxAmount,
      total: total,
      paymentMethod: PaymentMethod.fromString(paymentMethod),
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      cashReceived: cashReceived,
      cashChange: cashChange,
      notes: notes,
      cashierName: cashierName,
      transactionDate: transactionDate,
      debtPaidAt: debtPaidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items,
    );
  }

  /// Create TransactionModel from Transaction entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      transactionNumber: transaction.transactionNumber,
      customerName: transaction.customerName,
      subtotal: transaction.subtotal,
      discountAmount: transaction.discountAmount,
      discountPercentage: transaction.discountPercentage,
      taxAmount: transaction.taxAmount,
      total: transaction.total,
      paymentMethod: transaction.paymentMethod.name,
      paymentStatus: transaction.paymentStatus.name,
      cashReceived: transaction.cashReceived,
      cashChange: transaction.cashChange,
      notes: transaction.notes,
      cashierName: transaction.cashierName,
      transactionDate: transaction.transactionDate,
      debtPaidAt: transaction.debtPaidAt,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }
}
