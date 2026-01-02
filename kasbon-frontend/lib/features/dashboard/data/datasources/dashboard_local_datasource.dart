import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_summary_model.dart';

/// Abstract interface for Dashboard local data source
abstract class DashboardLocalDataSource {
  /// Get complete dashboard summary (all stats in one call)
  Future<DashboardSummaryModel> getDashboardSummary();

  /// Get today's total sales
  Future<double> getTodaySales();

  /// Get today's transaction count
  Future<int> getTodayTransactionCount();

  /// Get today's total profit
  Future<double> getTodayProfit();

  /// Get yesterday's total sales
  Future<double> getYesterdaySales();

  /// Get count of low stock products
  Future<int> getLowStockProductCount();
}

/// Implementation of DashboardLocalDataSource using SQLite
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DashboardLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    try {
      // Execute all queries in parallel for better performance
      final results = await Future.wait([
        getTodaySales(),
        getTodayProfit(),
        _getTodayTransactionCountInternal(),
        getYesterdaySales(),
        _getLowStockProductCountInternal(),
      ]);

      return DashboardSummaryModel.fromQueryResults(
        todaySales: results[0] as double,
        todayProfit: results[1] as double,
        transactionCount: results[2] as int,
        yesterdaySales: results[3] as double,
        lowStockCount: results[4] as int,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Gagal memuat ringkasan dashboard',
        originalError: e,
      );
    }
  }

  @override
  Future<double> getTodaySales() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COALESCE(SUM(${DatabaseConstants.colTotal}), 0) as total
        FROM ${DatabaseConstants.tableTransactions}
        WHERE date(${DatabaseConstants.colTransactionDate} / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
          AND ${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''');

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil penjualan hari ini',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getTodayTransactionCount() async {
    return _getTodayTransactionCountInternal();
  }

  Future<int> _getTodayTransactionCountInternal() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count
        FROM ${DatabaseConstants.tableTransactions}
        WHERE date(${DatabaseConstants.colTransactionDate} / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
          AND ${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''');

      return (result.first['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil jumlah transaksi hari ini',
        originalError: e,
      );
    }
  }

  @override
  Future<double> getTodayProfit() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COALESCE(SUM(
          (ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}
        ), 0) as profit
        FROM ${DatabaseConstants.tableTransactionItems} ti
        INNER JOIN ${DatabaseConstants.tableTransactions} t
          ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
        WHERE date(t.${DatabaseConstants.colTransactionDate} / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''');

      return (result.first['profit'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil laba hari ini',
        originalError: e,
      );
    }
  }

  @override
  Future<double> getYesterdaySales() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COALESCE(SUM(${DatabaseConstants.colTotal}), 0) as total
        FROM ${DatabaseConstants.tableTransactions}
        WHERE date(${DatabaseConstants.colTransactionDate} / 1000, 'unixepoch', 'localtime') = date('now', '-1 day', 'localtime')
          AND ${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''');

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil penjualan kemarin',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getLowStockProductCount() async {
    return _getLowStockProductCountInternal();
  }

  Future<int> _getLowStockProductCountInternal() async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT COUNT(*) as count
        FROM ${DatabaseConstants.tableProducts}
        WHERE ${DatabaseConstants.colStock} <= ${DatabaseConstants.colMinStock}
          AND ${DatabaseConstants.colIsActive} = 1
      ''');

      return (result.first['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil jumlah produk stok rendah',
        originalError: e,
      );
    }
  }
}
