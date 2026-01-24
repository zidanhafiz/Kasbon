# TASK_012: Basic Reports

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Completed

---

## Objective

Build basic reporting features including sales summaries (daily/weekly/monthly), top selling products, and simple charts for data visualization.

---

## Prerequisites

- [x] TASK_006: Transaction Management
- [x] TASK_010: Profit Calculation

---

## Subtasks

### 1. Report Data Layer

#### Data Source
- [x] Create `lib/features/reports/data/datasources/report_local_datasource.dart`
  - getSalesSummary(from, to)
  - getTopProducts(from, to, sortBy, limit)
  - getDailySales(from, to) - for chart

#### Repository
- [x] Create `lib/features/reports/data/repositories/report_repository_impl.dart`

### 2. Domain Layer

#### Entities
- [x] Create `lib/features/reports/domain/entities/sales_summary.dart`
- [x] Create `lib/features/reports/domain/entities/product_report.dart`
- [x] Create `lib/features/reports/domain/entities/daily_sales.dart`

#### Repository Interface
- [x] Create `lib/features/reports/domain/repositories/report_repository.dart`
  - With ProductReportSortType enum (quantity, revenue, profit)

#### Use Cases
- [x] Create `lib/features/reports/domain/usecases/get_sales_summary.dart`
- [x] Create `lib/features/reports/domain/usecases/get_top_products.dart`
- [x] Create `lib/features/reports/domain/usecases/get_daily_sales.dart`

### 3. Data Models
- [x] Create `lib/features/reports/data/models/sales_summary_model.dart`
- [x] Create `lib/features/reports/data/models/product_report_model.dart`
- [x] Create `lib/features/reports/data/models/daily_sales_model.dart`

### 4. Dependency Injection
- [x] Update `lib/config/di/injection.dart`
  - Register ReportLocalDataSource
  - Register ReportRepository
  - Register GetSalesSummary, GetTopProducts, GetDailySales use cases

### 5. Presentation Layer

#### Providers
- [x] Create `lib/features/reports/presentation/providers/date_range_provider.dart`
  - DateRangeState with DateRangeType (today, thisWeek, thisMonth, custom)
  - DateRangeNotifier for state management
- [x] Create `lib/features/reports/presentation/providers/report_provider.dart`
  - salesSummaryProvider (watches dateRangeProvider)
  - dailySalesProvider (watches dateRangeProvider)
  - topProductsByQtyProvider
  - topProductsByRevenueProvider
  - topProductsByProfitProvider

#### Screens
- [x] Create `lib/features/reports/presentation/screens/reports_hub_screen.dart`
  - Main reports hub with summary card and menu navigation
  - Quick summary cards
  - Navigation to detailed reports
- [x] Create `lib/features/reports/presentation/screens/sales_report_screen.dart`
  - Date range selector
  - Summary stats (revenue, profit, transactions, items)
  - Bar chart for daily sales
  - Daily breakdown list
- [x] Create `lib/features/reports/presentation/screens/product_report_screen.dart`
  - TabBar with 3 tabs (Qty, Revenue, Profit)
  - Top products list with ranking

#### Widgets
- [x] Create `lib/features/reports/presentation/widgets/date_range_selector.dart`
  - Horizontal chip selector: Hari Ini, Minggu Ini, Bulan Ini
- [x] Create `lib/features/reports/presentation/widgets/summary_stat_card.dart`
  - Icon, label, and value display
- [x] Create `lib/features/reports/presentation/widgets/sales_bar_chart.dart`
  - Using fl_chart
  - Daily sales bars with tooltips
- [x] Create `lib/features/reports/presentation/widgets/top_product_tile.dart`
  - Rank indicator with medal colors (gold/silver/bronze)
  - Product name
  - Value display based on sort type
- [x] Create `lib/features/reports/presentation/widgets/daily_sales_list.dart`
  - Daily breakdown with date and revenue

### 6. Navigation

- [x] Add reports routes to GoRouter
  - /reports (ReportsHubScreen)
  - /reports/sales (SalesReportScreen)
  - /reports/products (ProductReportScreen)
  - /reports/profit (ProfitReportScreen - existing)
- [x] Reports already connected to bottom navigation (via ModernAppShell)

---

## Report Entities

```dart
class SalesSummary extends Equatable {
  final double totalRevenue;
  final double totalProfit;
  final int transactionCount;
  final int itemsSold;
  final DateTime periodStart;
  final DateTime periodEnd;

  // Computed: profitMargin, averageTransactionValue
  const SalesSummary({...});
}

class ProductReport extends Equatable {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;
  final double totalProfit;

  // Computed: profitMargin, averagePrice, averageProfitPerUnit
  const ProductReport({...});
}

class DailySales extends Equatable {
  final DateTime date;
  final double revenue;
  final int transactionCount;

  // Computed: averageTransactionValue
  const DailySales({...});
}
```

---

## SQL Queries

### Sales Summary
```sql
-- Query 1: Get total revenue and transaction count
SELECT
  COALESCE(SUM(total), 0) as total_revenue,
  COUNT(*) as transaction_count
FROM transactions
WHERE transaction_date >= ? AND transaction_date < ?
  AND payment_status != 'cancelled';

-- Query 2: Get profit and items sold
SELECT
  COALESCE(SUM((ti.selling_price - ti.cost_price) * ti.quantity), 0) as total_profit,
  COALESCE(SUM(ti.quantity), 0) as items_sold
FROM transaction_items ti
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE t.transaction_date >= ? AND t.transaction_date < ?
  AND t.payment_status != 'cancelled';
```

### Top Products (dynamic ORDER BY)
```sql
SELECT
  p.id,
  p.name,
  SUM(ti.quantity) as quantity_sold,
  SUM(ti.subtotal) as total_revenue,
  SUM((ti.selling_price - ti.cost_price) * ti.quantity) as total_profit
FROM transaction_items ti
INNER JOIN products p ON ti.product_id = p.id
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE t.transaction_date >= ? AND t.transaction_date < ?
  AND t.payment_status != 'cancelled'
GROUP BY p.id
HAVING {orderColumn} > 0
ORDER BY {orderColumn} DESC
LIMIT ?;
```

### Daily Sales for Chart
```sql
SELECT
  date(transaction_date / 1000, 'unixepoch', 'localtime') as sale_date,
  COALESCE(SUM(total), 0) as revenue,
  COUNT(*) as transaction_count
FROM transactions
WHERE transaction_date >= ? AND transaction_date < ?
  AND payment_status != 'cancelled'
GROUP BY sale_date
ORDER BY sale_date ASC;
```

---

## Acceptance Criteria

- [x] Reports hub shows summary for current period
- [x] Can select date range (today, week, month)
- [x] Sales report shows total revenue, profit, transactions
- [x] Bar chart shows daily sales trend
- [x] Top products by quantity shows correctly
- [x] Top products by revenue shows correctly
- [x] Top products by profit shows correctly
- [x] Empty state when no data
- [x] Data refreshes when date range changes

---

## Files Created

### Domain Layer
- `lib/features/reports/domain/entities/sales_summary.dart`
- `lib/features/reports/domain/entities/product_report.dart`
- `lib/features/reports/domain/entities/daily_sales.dart`
- `lib/features/reports/domain/repositories/report_repository.dart`
- `lib/features/reports/domain/usecases/get_sales_summary.dart`
- `lib/features/reports/domain/usecases/get_top_products.dart`
- `lib/features/reports/domain/usecases/get_daily_sales.dart`

### Data Layer
- `lib/features/reports/data/models/sales_summary_model.dart`
- `lib/features/reports/data/models/product_report_model.dart`
- `lib/features/reports/data/models/daily_sales_model.dart`
- `lib/features/reports/data/datasources/report_local_datasource.dart`
- `lib/features/reports/data/repositories/report_repository_impl.dart`

### Presentation Layer
- `lib/features/reports/presentation/providers/date_range_provider.dart`
- `lib/features/reports/presentation/providers/report_provider.dart`
- `lib/features/reports/presentation/screens/reports_hub_screen.dart`
- `lib/features/reports/presentation/screens/sales_report_screen.dart`
- `lib/features/reports/presentation/screens/product_report_screen.dart`
- `lib/features/reports/presentation/widgets/date_range_selector.dart`
- `lib/features/reports/presentation/widgets/summary_stat_card.dart`
- `lib/features/reports/presentation/widgets/sales_bar_chart.dart`
- `lib/features/reports/presentation/widgets/top_product_tile.dart`
- `lib/features/reports/presentation/widgets/daily_sales_list.dart`

### Modified Files
- `lib/config/di/injection.dart` - Added new registrations
- `lib/config/routes/app_router.dart` - Added nested routes

---

## Notes

### Chart Library
Using `fl_chart` package - lightweight and customizable.
Keep charts simple for MVP (bar charts only).

### Performance
For date ranges > 30 days, consider pagination or summary only.
Load detailed data on demand.

### Export (Post-MVP)
Export to Excel/PDF will be added in v1.1 (TASK_019).

---

## Estimated Time

**4-5 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_013_SETTINGS.md](./TASK_013_SETTINGS.md)
