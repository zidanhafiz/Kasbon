import '../../domain/entities/dashboard_summary.dart';

/// Data transfer object for DashboardSummary
class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.todaySales,
    required super.todayProfit,
    required super.transactionCount,
    required super.yesterdaySales,
    required super.lowStockCount,
  });

  /// Create from individual query results
  factory DashboardSummaryModel.fromQueryResults({
    required double todaySales,
    required double todayProfit,
    required int transactionCount,
    required double yesterdaySales,
    required int lowStockCount,
  }) {
    return DashboardSummaryModel(
      todaySales: todaySales,
      todayProfit: todayProfit,
      transactionCount: transactionCount,
      yesterdaySales: yesterdaySales,
      lowStockCount: lowStockCount,
    );
  }

  /// Convert to entity
  DashboardSummary toEntity() {
    return DashboardSummary(
      todaySales: todaySales,
      todayProfit: todayProfit,
      transactionCount: transactionCount,
      yesterdaySales: yesterdaySales,
      lowStockCount: lowStockCount,
    );
  }
}
