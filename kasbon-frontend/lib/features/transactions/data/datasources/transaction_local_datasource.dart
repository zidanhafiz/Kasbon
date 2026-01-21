import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

/// Abstract interface for Transaction local data source
abstract class TransactionLocalDataSource {
  /// Create a new transaction with all its items
  /// Uses database transaction for atomicity (all or nothing)
  /// Also updates product stock
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  );

  /// Get all transactions with optional pagination
  Future<List<TransactionModel>> getTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get a single transaction by ID
  Future<TransactionModel> getTransactionById(String id);

  /// Get transaction items for a transaction
  Future<List<TransactionItemModel>> getTransactionItems(String transactionId);

  /// Get today's transaction count (for generating transaction number)
  Future<int> getTodayTransactionCount();

  /// Get transaction by transaction number
  Future<TransactionModel?> getTransactionByNumber(String transactionNumber);

  /// Get transactions by payment status (e.g., 'debt' for unpaid debts)
  Future<List<TransactionModel>> getTransactionsByPaymentStatus(String status);

  /// Update a transaction
  Future<TransactionModel> updateTransaction(
    String id, {
    String? paymentStatus,
    int? debtPaidAt,
  });
}

/// Implementation of TransactionLocalDataSource using SQLite
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TransactionLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    try {
      // Use database transaction for atomicity
      await _databaseHelper.transaction<void>((txn) async {
        // 1. Insert transaction record
        await txn.insert(
          DatabaseConstants.tableTransactions,
          transaction.toMap(),
        );

        // 2. Insert all transaction items
        for (final item in items) {
          await txn.insert(
            DatabaseConstants.tableTransactionItems,
            item.toMap(),
          );
        }

        // 3. Update product stock for each item
        for (final item in items) {
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseConstants.tableProducts}
            SET ${DatabaseConstants.colStock} = ${DatabaseConstants.colStock} - ?,
                ${DatabaseConstants.colUpdatedAt} = ?
            WHERE ${DatabaseConstants.colId} = ?
            ''',
            [
              item.quantity,
              DateTime.now().millisecondsSinceEpoch,
              item.productId,
            ],
          );
        }
      });

      return transaction;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal membuat transaksi',
        originalError: e,
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String? where;
      List<Object?>? whereArgs;

      if (startDate != null && endDate != null) {
        where =
            '${DatabaseConstants.colTransactionDate} >= ? AND ${DatabaseConstants.colTransactionDate} <= ?';
        whereArgs = [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ];
      } else if (startDate != null) {
        where = '${DatabaseConstants.colTransactionDate} >= ?';
        whereArgs = [startDate.millisecondsSinceEpoch];
      } else if (endDate != null) {
        where = '${DatabaseConstants.colTransactionDate} <= ?';
        whereArgs = [endDate.millisecondsSinceEpoch];
      }

      final results = await _databaseHelper.query(
        DatabaseConstants.tableTransactions,
        where: where,
        whereArgs: whereArgs,
        orderBy: '${DatabaseConstants.colTransactionDate} DESC',
        limit: limit,
        offset: offset,
      );

      return results.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil daftar transaksi',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final result = await _databaseHelper.getById(
        DatabaseConstants.tableTransactions,
        id,
      );

      if (result == null) {
        throw const NotFoundException(message: 'Transaksi tidak ditemukan');
      }

      return TransactionModel.fromMap(result);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil transaksi',
        originalError: e,
      );
    }
  }

  @override
  Future<List<TransactionItemModel>> getTransactionItems(
      String transactionId) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableTransactionItems,
        where: '${DatabaseConstants.colTransactionId} = ?',
        whereArgs: [transactionId],
      );

      return results.map((map) => TransactionItemModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil item transaksi',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getTodayTransactionCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final count = await _databaseHelper.count(
        DatabaseConstants.tableTransactions,
        where:
            '${DatabaseConstants.colTransactionDate} >= ? AND ${DatabaseConstants.colTransactionDate} < ?',
        whereArgs: [
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ],
      );

      return count;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil jumlah transaksi hari ini',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel?> getTransactionByNumber(
      String transactionNumber) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableTransactions,
        where: '${DatabaseConstants.colTransactionNumber} = ?',
        whereArgs: [transactionNumber],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return TransactionModel.fromMap(results.first);
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil transaksi',
        originalError: e,
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByPaymentStatus(
      String status) async {
    try {
      // For 'debt' status, get transactions that are unpaid (debt_paid_at is null)
      String where;
      List<Object?> whereArgs;

      if (status == DatabaseConstants.paymentStatusDebt) {
        // Get debts that haven't been paid yet
        where =
            '${DatabaseConstants.colPaymentStatus} = ? AND ${DatabaseConstants.colDebtPaidAt} IS NULL';
        whereArgs = [status];
      } else {
        where = '${DatabaseConstants.colPaymentStatus} = ?';
        whereArgs = [status];
      }

      final results = await _databaseHelper.query(
        DatabaseConstants.tableTransactions,
        where: where,
        whereArgs: whereArgs,
        orderBy: '${DatabaseConstants.colTransactionDate} DESC',
      );

      return results.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil transaksi berdasarkan status',
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    String id, {
    String? paymentStatus,
    int? debtPaidAt,
  }) async {
    try {
      // Build update map
      final updateMap = <String, dynamic>{
        DatabaseConstants.colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      };

      if (paymentStatus != null) {
        updateMap[DatabaseConstants.colPaymentStatus] = paymentStatus;
      }

      if (debtPaidAt != null) {
        updateMap[DatabaseConstants.colDebtPaidAt] = debtPaidAt;
      }

      // Perform update
      final rowsAffected = await _databaseHelper.update(
        DatabaseConstants.tableTransactions,
        updateMap,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw const NotFoundException(message: 'Transaksi tidak ditemukan');
      }

      // Return updated transaction
      return await getTransactionById(id);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal memperbarui transaksi',
        originalError: e,
      );
    }
  }
}
