# TASK_007: Dashboard

**Priority:** P0 (Critical)
**Complexity:** LOW
**Phase:** MVP
**Status:** Completed

---

## Objective

Build the main dashboard screen showing sales summary, comparison with previous day, and quick action buttons.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture
- [x] TASK_002: Database Setup
- [x] TASK_003: Core Infrastructure
- [x] TASK_004: Product Management
- [x] TASK_005: POS System
- [x] TASK_006: Transaction Management

---

## Subtasks

### 1. Domain Layer

#### Use Cases
- [x] Create `lib/features/dashboard/domain/usecases/get_dashboard_summary.dart` (combined use case)
- [x] Create `lib/features/dashboard/domain/entities/dashboard_summary.dart`
- [x] Create `lib/features/dashboard/domain/repositories/dashboard_repository.dart`

### 2. Data Layer

#### Repository
- [x] Create `lib/features/dashboard/data/datasources/dashboard_local_datasource.dart`
  - getTodaySales()
  - getTodayTransactionCount()
  - getTodayProfit()
  - getYesterdaySales()
  - getLowStockProductCount()
  - getDashboardSummary() (combined query)
- [x] Create `lib/features/dashboard/data/models/dashboard_summary_model.dart`
- [x] Create `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

### 3. Presentation Layer

#### Providers
- [x] Create `lib/features/dashboard/presentation/providers/dashboard_provider.dart`
  - dashboardSummaryProvider (main provider)
  - todaySalesProvider
  - transactionCountProvider
  - todayProfitProvider
  - yesterdaySalesProvider
  - comparisonPercentageProvider
  - lowStockCountProvider
  - hasLowStockProvider

#### Screen
- [x] Update `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  - Welcome banner
  - Sales summary card (real data)
  - Low stock alert (conditional)
  - Menu Kategori grid (kept)
  - Pull-to-refresh
  - Loading/error/empty states

#### Widgets
- [x] Create `lib/features/dashboard/presentation/widgets/sales_summary_card.dart`
  - Sales amount (large, prominent)
  - Profit amount with percentage
  - Transaction count
  - Comparison with yesterday (% up/down)

- [x] Create `lib/features/dashboard/presentation/widgets/low_stock_alert.dart`
  - Warning banner
  - Count of low stock products
  - Tap to navigate to products

- [x] Create `lib/features/dashboard/presentation/widgets/comparison_badge.dart`
  - Green up arrow for increase
  - Red down arrow for decrease
  - Percentage change

### 4. Navigation
- [x] Dashboard already set as home route in GoRouter
- [x] Bottom navigation already implemented (kept current 4 items)

---

## UI Specifications

### Dashboard Screen
```
┌─────────────────────────────────────┐
│  KASBON                              │
│  Selamat datang! 👋                  │
├─────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 💰 Penjualan Hari Ini          │ │
│  │                                │ │
│  │    Rp 1.250.000                │ │
│  │    ▲ +15% dari kemarin         │ │
│  │                                │ │
│  │ ─────────────────────────────  │ │
│  │ 💵 Laba: Rp 250.000 (20%)     │ │
│  │ 📦 Transaksi: 45              │ │
│  └────────────────────────────────┘ │
│                                      │
│  ⚠️ 5 produk stok menipis!          │
│  [Lihat Detail]                      │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  AKSI CEPAT                          │
│                                      │
│  ┌──────────────┐ ┌──────────────┐  │
│  │    🛒        │ │    📦        │  │
│  │ Mulai Kasir  │ │Tambah Produk │  │
│  └──────────────┘ └──────────────┘  │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  TRANSAKSI TERAKHIR                  │
│  [Lihat Semua →]                     │
│                                      │
│  TRX-001 • 14:30 • Rp 45.000        │
│  TRX-002 • 12:15 • Rp 78.500        │
│  TRX-003 • 09:00 • Rp 25.000        │
│                                      │
├─────────────────────────────────────┤
│  [🏠] [🛒] [📦] [📊] [⚙️]           │
│  Home  Kasir Produk Laporan Lainnya │
└─────────────────────────────────────┘
```

---

## Dashboard Data Calculations

### Sales Today
```sql
SELECT COALESCE(SUM(total), 0) as total
FROM transactions
WHERE date(transaction_date / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
  AND payment_status != 'cancelled';
```

### Transaction Count Today
```sql
SELECT COUNT(*) as count
FROM transactions
WHERE date(transaction_date / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
  AND payment_status != 'cancelled';
```

### Profit Today
```sql
SELECT COALESCE(SUM(
  (ti.selling_price - ti.cost_price) * ti.quantity
), 0) as profit
FROM transaction_items ti
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE date(t.transaction_date / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
  AND t.payment_status != 'cancelled';
```

### Yesterday's Sales (for comparison)
```sql
SELECT COALESCE(SUM(total), 0) as total
FROM transactions
WHERE date(transaction_date / 1000, 'unixepoch', 'localtime') = date('now', '-1 day', 'localtime')
  AND payment_status != 'cancelled';
```

### Comparison Percentage
```dart
double getComparisonPercentage(double today, double yesterday) {
  if (yesterday == 0) {
    return today > 0 ? 100 : 0; // 100% increase if there was no sales yesterday
  }
  return ((today - yesterday) / yesterday) * 100;
}
```

### Low Stock Count
```sql
SELECT COUNT(*) as count
FROM products
WHERE stock <= min_stock AND is_active = 1;
```

---

## Bottom Navigation Setup

```dart
// Bottom navigation items
final bottomNavItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.point_of_sale_outlined),
    activeIcon: Icon(Icons.point_of_sale),
    label: 'Kasir',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.inventory_2_outlined),
    activeIcon: Icon(Icons.inventory_2),
    label: 'Produk',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.bar_chart_outlined),
    activeIcon: Icon(Icons.bar_chart),
    label: 'Laporan',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.more_horiz),
    activeIcon: Icon(Icons.more_horiz),
    label: 'Lainnya',
  ),
];
```

---

## Acceptance Criteria

- [x] Dashboard shows today's sales total
- [x] Dashboard shows today's transaction count
- [x] Dashboard shows today's profit
- [x] Shows comparison with yesterday (% increase/decrease)
- [x] Green indicator for increase, red for decrease
- [x] Low stock alert shows when products are low
- [x] Quick action buttons navigate correctly (via Menu Kategori)
- [x] Recent transactions - skipped per user preference
- [x] Bottom navigation works correctly (kept existing 4 items)
- [x] Data refreshes on pull-to-refresh
- [x] Handles zero sales gracefully

---

## Notes

### Auto Refresh
Dashboard should refresh data when:
- Screen comes into focus
- Pull to refresh
- After completing a transaction (navigate back)

### First Launch
When no transactions exist:
- Show Rp 0 for sales
- Show "Belum ada transaksi hari ini"
- Emphasize quick action buttons

### Performance
Cache dashboard data in provider.
Refresh only when needed.

---

## Estimated Time

**2-3 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_008_RECEIPT_GENERATION.md](./TASK_008_RECEIPT_GENERATION.md)
