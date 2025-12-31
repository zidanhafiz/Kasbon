# TASK_012: Basic Reports

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Not Started

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
- [ ] Create `lib/features/reports/data/datasources/report_local_datasource.dart`
  - getSalesByDateRange(from, to)
  - getSalesByDay(date)
  - getTopProductsByQuantity(limit, from, to)
  - getTopProductsByRevenue(limit, from, to)
  - getTopProductsByProfit(limit, from, to)
  - getDailySalesForRange(from, to) - for chart

#### Repository
- [ ] Create `lib/features/reports/data/repositories/report_repository_impl.dart`

### 2. Domain Layer

#### Entities
- [ ] Create `lib/features/reports/domain/entities/sales_summary.dart`
- [ ] Create `lib/features/reports/domain/entities/product_report.dart`
- [ ] Create `lib/features/reports/domain/entities/daily_sales.dart`

#### Use Cases
- [ ] Create `lib/features/reports/domain/usecases/get_sales_summary.dart`
- [ ] Create `lib/features/reports/domain/usecases/get_top_products.dart`
- [ ] Create `lib/features/reports/domain/usecases/get_daily_sales.dart`

### 3. Presentation Layer

#### Providers
- [ ] Create `lib/features/reports/presentation/providers/report_provider.dart`
  - salesSummaryProvider(dateRange)
  - topProductsProvider(type, dateRange)
  - dailySalesProvider(dateRange)

#### Screens
- [ ] Create `lib/features/reports/presentation/screens/reports_screen.dart`
  - Main reports hub
  - Quick summary cards
  - Navigation to detailed reports

- [ ] Create `lib/features/reports/presentation/screens/sales_report_screen.dart`
  - Date range selector
  - Summary stats
  - Daily breakdown
  - Simple bar chart

- [ ] Create `lib/features/reports/presentation/screens/product_report_screen.dart`
  - Top products by quantity
  - Top products by revenue
  - Top products by profit
  - Tabs to switch

#### Widgets
- [ ] Create `lib/features/reports/presentation/widgets/date_range_selector.dart`
  - Predefined: Hari Ini, Minggu Ini, Bulan Ini
  - Custom date picker

- [ ] Create `lib/features/reports/presentation/widgets/summary_stat_card.dart`
  - Value (large)
  - Label
  - Comparison (optional)

- [ ] Create `lib/features/reports/presentation/widgets/simple_bar_chart.dart`
  - Using fl_chart
  - Daily sales bars

- [ ] Create `lib/features/reports/presentation/widgets/top_product_tile.dart`
  - Rank number
  - Product name
  - Value (qty/revenue/profit)

### 4. Navigation

- [ ] Add reports routes to GoRouter
  - /reports (hub)
  - /reports/sales
  - /reports/products

- [ ] Connect reports to bottom navigation

---

## Report Entities

```dart
class SalesSummary extends Equatable {
  final double totalRevenue;
  final double totalProfit;
  final double profitMargin;
  final int transactionCount;
  final int itemsSold;
  final double averageTransaction;

  const SalesSummary({...});
}

class ProductReport extends Equatable {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;
  final double totalProfit;
  final double profitMargin;

  const ProductReport({...});
}

class DailySales extends Equatable {
  final DateTime date;
  final double revenue;
  final double profit;
  final int transactionCount;

  const DailySales({...});
}
```

---

## SQL Queries

### Sales Summary
```sql
SELECT
  COALESCE(SUM(total), 0) as total_revenue,
  COUNT(*) as transaction_count
FROM transactions
WHERE transaction_date >= ? AND transaction_date <= ?
  AND payment_status != 'cancelled';

-- Profit (separate query)
SELECT
  COALESCE(SUM((ti.selling_price - ti.cost_price) * ti.quantity), 0) as total_profit,
  SUM(ti.quantity) as items_sold
FROM transaction_items ti
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE t.transaction_date >= ? AND t.transaction_date <= ?
  AND t.payment_status != 'cancelled';
```

### Top Products by Quantity
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
WHERE t.transaction_date >= ? AND t.transaction_date <= ?
  AND t.payment_status != 'cancelled'
GROUP BY p.id
ORDER BY quantity_sold DESC
LIMIT 5;
```

### Daily Sales for Chart
```sql
SELECT
  date(transaction_date / 1000, 'unixepoch', 'localtime') as sale_date,
  COALESCE(SUM(total), 0) as revenue,
  COUNT(*) as transaction_count
FROM transactions
WHERE transaction_date >= ? AND transaction_date <= ?
  AND payment_status != 'cancelled'
GROUP BY sale_date
ORDER BY sale_date ASC;
```

---

## UI Specifications

### Reports Hub Screen
```
┌─────────────────────────────────────┐
│  [<]  Laporan                       │
├─────────────────────────────────────┤
│                                      │
│  📅 Bulan Ini: Desember 2024        │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 💰 Total Penjualan             │ │
│  │    Rp 12.500.000               │ │
│  │    +15% dari bulan lalu        │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌──────────────┐ ┌──────────────┐  │
│  │ 💵 Laba      │ │ 📦 Transaksi │  │
│  │ Rp 2.5jt    │ │ 450 kali     │  │
│  │ margin 20%  │ │              │  │
│  └──────────────┘ └──────────────┘  │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  LAPORAN DETAIL                      │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 📊 Laporan Penjualan        →  │ │
│  │    Trend harian & mingguan     │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 🏆 Produk Terlaris          →  │ │
│  │    Top 5 produk                │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 💵 Produk Paling Untung     →  │ │
│  │    Profit margin tertinggi     │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Sales Report Screen
```
┌─────────────────────────────────────┐
│  [<]  Laporan Penjualan             │
├─────────────────────────────────────┤
│                                      │
│  [Hari Ini] [Minggu] [Bulan] [▼]    │
│                                      │
│  ┌────────────────────────────────┐ │
│  │        CHART AREA              │ │
│  │   ▄                            │ │
│  │   █  ▄     ▄                   │ │
│  │   █  █  ▄  █  ▄                │ │
│  │   █  █  █  █  █  ▄  ▄          │ │
│  │   S  S  R  K  J  S  M          │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  RINGKASAN MINGGU INI               │
│                                      │
│  Total Penjualan:  Rp 3.250.000     │
│  Total Laba:       Rp   650.000     │
│  Transaksi:        89 kali          │
│  Rata-rata:        Rp    36.500     │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  DETAIL HARIAN                       │
│                                      │
│  Minggu, 15 Des                     │
│  Rp 520.000 • 15 transaksi          │
│                                      │
│  Sabtu, 14 Des                      │
│  Rp 680.000 • 18 transaksi          │
│                                      │
│  Jumat, 13 Des                      │
│  Rp 450.000 • 12 transaksi          │
│                                      │
└─────────────────────────────────────┘
```

### Top Products Screen
```
┌─────────────────────────────────────┐
│  [<]  Produk Terlaris               │
├─────────────────────────────────────┤
│                                      │
│  [Qty] [Revenue] [Profit]           │
│                                      │
│  📅 Bulan Ini                       │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  🥇 1. Indomie Goreng               │
│       Terjual: 250 pcs              │
│       Revenue: Rp 875.000           │
│                                      │
│  🥈 2. Aqua 600ml                   │
│       Terjual: 200 pcs              │
│       Revenue: Rp 800.000           │
│                                      │
│  🥉 3. Rokok Surya                  │
│       Terjual: 180 pcs              │
│       Revenue: Rp 3.600.000         │
│                                      │
│  4. Teh Botol                       │
│     Terjual: 150 pcs                │
│     Revenue: Rp 750.000             │
│                                      │
│  5. Kopi Sachet                     │
│     Terjual: 120 pcs                │
│     Revenue: Rp 240.000             │
│                                      │
└─────────────────────────────────────┘
```

---

## Chart Implementation

```dart
// Using fl_chart package
import 'package:fl_chart/fl_chart.dart';

class SalesBarChart extends StatelessWidget {
  final List<DailySales> data;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.revenue / 1000, // In thousands
                color: AppColors.primary,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = data[value.toInt()].date;
                return Text(DateFormatter.dayShort(date));
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Acceptance Criteria

- [ ] Reports hub shows summary for current period
- [ ] Can select date range (today, week, month, custom)
- [ ] Sales report shows total revenue, profit, transactions
- [ ] Bar chart shows daily sales trend
- [ ] Top products by quantity shows correctly
- [ ] Top products by revenue shows correctly
- [ ] Top products by profit shows correctly
- [ ] Empty state when no data
- [ ] Data refreshes when date range changes

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
