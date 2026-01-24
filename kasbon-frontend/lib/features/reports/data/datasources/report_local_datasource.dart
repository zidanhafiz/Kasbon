import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/report_repository.dart';
import '../models/daily_sales_model.dart';
import '../models/product_report_model.dart';
import '../models/sales_summary_model.dart';

/// Abstract interface for Report local data source
abstract class ReportLocalDataSource {
  /// Get sales summary for a date range
  Future<SalesSummaryModel> getSalesSummary({
    required DateTime from,
    required DateTime to,
  });

  /// Get top selling products for a date range
  Future<List<ProductReportModel>> getTopProducts({
    required DateTime from,
    required DateTime to,
    required ProductReportSortType sortBy,
    required int limit,
  });

  /// Get daily sales data for chart visualization
  Future<List<DailySalesModel>> getDailySales({
    required DateTime from,
    required DateTime to,
  });
}

/// Implementation of ReportLocalDataSource using SQLite
class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ReportLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<SalesSummaryModel> getSalesSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final fromMs = from.millisecondsSinceEpoch;
      final toMs = to.millisecondsSinceEpoch;

      // Query 1: Get total revenue and transaction count from transactions
      final transactionResult = await _databaseHelper.rawQuery('''
        SELECT
          COALESCE(SUM(${DatabaseConstants.colTotal}), 0) as total_revenue,
          COUNT(*) as transaction_count
        FROM ${DatabaseConstants.tableTransactions}
        WHERE ${DatabaseConstants.colTransactionDate} >= ?
          AND ${DatabaseConstants.colTransactionDate} < ?
          AND ${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''', [fromMs, toMs]);

      // Query 2: Get total profit and items sold from transaction_items
      final itemsResult = await _databaseHelper.rawQuery('''
        SELECT
          COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) as total_profit,
          COALESCE(SUM(ti.${DatabaseConstants.colQuantity}), 0) as items_sold
        FROM ${DatabaseConstants.tableTransactionItems} ti
        INNER JOIN ${DatabaseConstants.tableTransactions} t
          ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
        WHERE t.${DatabaseConstants.colTransactionDate} >= ?
          AND t.${DatabaseConstants.colTransactionDate} < ?
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''', [fromMs, toMs]);

      if (transactionResult.isEmpty || itemsResult.isEmpty) {
        return SalesSummaryModel(
          totalRevenue: 0,
          totalProfit: 0,
          transactionCount: 0,
          itemsSold: 0,
          periodStart: from,
          periodEnd: to,
        );
      }

      return SalesSummaryModel.fromQueryResults(
        transactionResult: transactionResult.first,
        itemsResult: itemsResult.first,
        periodStart: from,
        periodEnd: to,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil ringkasan penjualan',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ProductReportModel>> getTopProducts({
    required DateTime from,
    required DateTime to,
    required ProductReportSortType sortBy,
    required int limit,
  }) async {
    try {
      final fromMs = from.millisecondsSinceEpoch;
      final toMs = to.millisecondsSinceEpoch;

      // Determine ORDER BY column based on sort type
      final orderByColumn = switch (sortBy) {
        ProductReportSortType.quantity => 'quantity_sold',
        ProductReportSortType.revenue => 'total_revenue',
        ProductReportSortType.profit => 'total_profit',
      };

      final result = await _databaseHelper.rawQuery('''
        SELECT
          p.${DatabaseConstants.colId} as id,
          p.${DatabaseConstants.colName} as name,
          COALESCE(SUM(ti.${DatabaseConstants.colQuantity}), 0) as quantity_sold,
          COALESCE(SUM(ti.${DatabaseConstants.colSubtotal}), 0) as total_revenue,
          COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) as total_profit
        FROM ${DatabaseConstants.tableTransactionItems} ti
        INNER JOIN ${DatabaseConstants.tableProducts} p
          ON ti.${DatabaseConstants.colProductId} = p.${DatabaseConstants.colId}
        INNER JOIN ${DatabaseConstants.tableTransactions} t
          ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
        WHERE t.${DatabaseConstants.colTransactionDate} >= ?
          AND t.${DatabaseConstants.colTransactionDate} < ?
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
        GROUP BY p.${DatabaseConstants.colId}
        HAVING $orderByColumn > 0
        ORDER BY $orderByColumn DESC
        LIMIT ?
      ''', [fromMs, toMs, limit]);

      return result.map((row) => ProductReportModel.fromQueryResult(row)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil data produk terlaris',
        originalError: e,
      );
    }
  }

  @override
  Future<List<DailySalesModel>> getDailySales({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final fromMs = from.millisecondsSinceEpoch;
      final toMs = to.millisecondsSinceEpoch;

      final result = await _databaseHelper.rawQuery('''
        SELECT
          date(${DatabaseConstants.colTransactionDate} / 1000, 'unixepoch', 'localtime') as sale_date,
          COALESCE(SUM(${DatabaseConstants.colTotal}), 0) as revenue,
          COUNT(*) as transaction_count
        FROM ${DatabaseConstants.tableTransactions}
        WHERE ${DatabaseConstants.colTransactionDate} >= ?
          AND ${DatabaseConstants.colTransactionDate} < ?
          AND ${DatabaseConstants.colPaymentStatus} != 'cancelled'
        GROUP BY sale_date
        ORDER BY sale_date ASC
      ''', [fromMs, toMs]);

      return result.map((row) => DailySalesModel.fromQueryResult(row)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil data penjualan harian',
        originalError: e,
      );
    }
  }
}
