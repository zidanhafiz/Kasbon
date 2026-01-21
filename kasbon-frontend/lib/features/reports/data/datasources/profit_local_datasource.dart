import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_profitability_model.dart';
import '../models/profit_summary_model.dart';

/// Abstract interface for Profit Report local data source
abstract class ProfitLocalDataSource {
  /// Get profit summary for a date range
  Future<ProfitSummaryModel> getProfitByDateRange({
    required DateTime from,
    required DateTime to,
  });

  /// Get top profitable products
  Future<List<ProductProfitabilityModel>> getTopProfitableProducts({
    required int limit,
  });

  /// Get profitability for a specific product
  Future<ProductProfitabilityModel> getProductProfitability({
    required String productId,
  });
}

/// Implementation of ProfitLocalDataSource using SQLite
class ProfitLocalDataSourceImpl implements ProfitLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProfitLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<ProfitSummaryModel> getProfitByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final fromMs = from.millisecondsSinceEpoch;
      final toMs = to.millisecondsSinceEpoch;

      final result = await _databaseHelper.rawQuery('''
        SELECT
          COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) as total_profit,
          COALESCE(SUM(t.${DatabaseConstants.colTotal}), 0) as total_sales,
          COUNT(DISTINCT t.${DatabaseConstants.colId}) as transaction_count
        FROM ${DatabaseConstants.tableTransactions} t
        LEFT JOIN ${DatabaseConstants.tableTransactionItems} ti ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
        WHERE t.${DatabaseConstants.colTransactionDate} >= ?
          AND t.${DatabaseConstants.colTransactionDate} < ?
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
      ''', [fromMs, toMs]);

      if (result.isEmpty) {
        return ProfitSummaryModel(
          totalProfit: 0,
          totalSales: 0,
          profitMargin: 0,
          transactionCount: 0,
          periodStart: from,
          periodEnd: to,
        );
      }

      return ProfitSummaryModel.fromQueryResult(
        row: result.first,
        periodStart: from,
        periodEnd: to,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil ringkasan laba',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ProductProfitabilityModel>> getTopProfitableProducts({
    required int limit,
  }) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT
          p.${DatabaseConstants.colId} as id,
          p.${DatabaseConstants.colName} as name,
          COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) as total_profit,
          COALESCE(SUM(ti.${DatabaseConstants.colQuantity}), 0) as total_sold,
          CASE
            WHEN COALESCE(SUM(ti.${DatabaseConstants.colCostPrice} * ti.${DatabaseConstants.colQuantity}), 0) > 0
            THEN (COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) /
                  COALESCE(SUM(ti.${DatabaseConstants.colCostPrice} * ti.${DatabaseConstants.colQuantity}), 1)) * 100
            ELSE 0
          END as average_margin
        FROM ${DatabaseConstants.tableProducts} p
        LEFT JOIN ${DatabaseConstants.tableTransactionItems} ti ON ti.${DatabaseConstants.colProductId} = p.${DatabaseConstants.colId}
        LEFT JOIN ${DatabaseConstants.tableTransactions} t ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
        WHERE p.${DatabaseConstants.colIsActive} = 1
        GROUP BY p.${DatabaseConstants.colId}
        HAVING total_profit > 0
        ORDER BY total_profit DESC
        LIMIT ?
      ''', [limit]);

      return result
          .map((row) => ProductProfitabilityModel.fromQueryResult(row))
          .toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil produk terlaris',
        originalError: e,
      );
    }
  }

  @override
  Future<ProductProfitabilityModel> getProductProfitability({
    required String productId,
  }) async {
    try {
      final result = await _databaseHelper.rawQuery('''
        SELECT
          p.${DatabaseConstants.colId} as id,
          p.${DatabaseConstants.colName} as name,
          COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) as total_profit,
          COALESCE(SUM(ti.${DatabaseConstants.colQuantity}), 0) as total_sold,
          CASE
            WHEN COALESCE(SUM(ti.${DatabaseConstants.colCostPrice} * ti.${DatabaseConstants.colQuantity}), 0) > 0
            THEN (COALESCE(SUM((ti.${DatabaseConstants.colSellingPrice} - ti.${DatabaseConstants.colCostPrice}) * ti.${DatabaseConstants.colQuantity}), 0) /
                  COALESCE(SUM(ti.${DatabaseConstants.colCostPrice} * ti.${DatabaseConstants.colQuantity}), 1)) * 100
            ELSE 0
          END as average_margin
        FROM ${DatabaseConstants.tableProducts} p
        LEFT JOIN ${DatabaseConstants.tableTransactionItems} ti ON ti.${DatabaseConstants.colProductId} = p.${DatabaseConstants.colId}
        LEFT JOIN ${DatabaseConstants.tableTransactions} t ON ti.${DatabaseConstants.colTransactionId} = t.${DatabaseConstants.colId}
          AND t.${DatabaseConstants.colPaymentStatus} != 'cancelled'
        WHERE p.${DatabaseConstants.colId} = ?
        GROUP BY p.${DatabaseConstants.colId}
      ''', [productId]);

      if (result.isEmpty) {
        // Product exists but has no sales - get product info
        final productResult = await _databaseHelper.rawQuery('''
          SELECT ${DatabaseConstants.colId} as id, ${DatabaseConstants.colName} as name
          FROM ${DatabaseConstants.tableProducts}
          WHERE ${DatabaseConstants.colId} = ?
        ''', [productId]);

        if (productResult.isEmpty) {
          throw const DatabaseException(
            message: 'Produk tidak ditemukan',
          );
        }

        return ProductProfitabilityModel(
          productId: productResult.first['id'] as String,
          productName: productResult.first['name'] as String,
          totalProfit: 0,
          totalSold: 0,
          averageMargin: 0,
        );
      }

      return ProductProfitabilityModel.fromQueryResult(result.first);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Gagal mengambil data keuntungan produk',
        originalError: e,
      );
    }
  }
}
