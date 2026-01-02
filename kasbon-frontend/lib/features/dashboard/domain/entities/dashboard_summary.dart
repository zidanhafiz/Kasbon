import 'package:equatable/equatable.dart';

/// Dashboard summary entity containing all dashboard statistics
class DashboardSummary extends Equatable {
  /// Today's total sales (sum of transaction totals)
  final double todaySales;

  /// Today's total profit (selling_price - cost_price) * quantity
  final double todayProfit;

  /// Number of transactions today
  final int transactionCount;

  /// Yesterday's total sales for comparison
  final double yesterdaySales;

  /// Number of products with low stock (stock <= min_stock)
  final int lowStockCount;

  const DashboardSummary({
    required this.todaySales,
    required this.todayProfit,
    required this.transactionCount,
    required this.yesterdaySales,
    required this.lowStockCount,
  });

  /// Calculate the percentage change from yesterday
  /// Returns null if yesterday had zero sales (to avoid division by zero)
  double? get comparisonPercentage {
    if (yesterdaySales == 0) {
      return todaySales > 0 ? 100.0 : null;
    }
    return ((todaySales - yesterdaySales) / yesterdaySales) * 100;
  }

  /// Check if sales increased compared to yesterday
  bool get isIncrease => todaySales >= yesterdaySales;

  /// Check if there are any low stock products
  bool get hasLowStock => lowStockCount > 0;

  /// Calculate profit margin percentage
  double get profitMargin {
    if (todaySales == 0) return 0;
    return (todayProfit / todaySales) * 100;
  }

  /// Empty/default state
  static const empty = DashboardSummary(
    todaySales: 0,
    todayProfit: 0,
    transactionCount: 0,
    yesterdaySales: 0,
    lowStockCount: 0,
  );

  @override
  List<Object?> get props => [
        todaySales,
        todayProfit,
        transactionCount,
        yesterdaySales,
        lowStockCount,
      ];
}
