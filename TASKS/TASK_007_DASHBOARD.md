# TASK_007: Dashboard

**Priority:** P0 (Critical)
**Complexity:** LOW
**Phase:** MVP
**Status:** Not Started

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
- [ ] Create `lib/features/dashboard/domain/usecases/get_today_summary.dart`
- [ ] Create `lib/features/dashboard/domain/usecases/get_yesterday_summary.dart`
- [ ] Create `lib/features/dashboard/domain/usecases/get_low_stock_count.dart`

### 2. Data Layer

#### Repository
- [ ] Create `lib/features/dashboard/data/datasources/dashboard_local_datasource.dart`
  - getTodaySales()
  - getTodayTransactionCount()
  - getTodayProfit()
  - getYesterdaySales()
  - getLowStockProductCount()

### 3. Presentation Layer

#### Providers
- [ ] Create `lib/features/dashboard/presentation/providers/dashboard_provider.dart`
  - todaySalesProvider
  - todayTransactionCountProvider
  - todayProfitProvider
  - yesterdaySalesProvider
  - comparisonPercentageProvider
  - lowStockCountProvider

#### Screen
- [ ] Create `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  - Welcome header
  - Sales summary card
  - Quick action buttons
  - Low stock alert (if any)
  - Recent transactions (optional)

#### Widgets
- [ ] Create `lib/features/dashboard/presentation/widgets/sales_summary_card.dart`
  - Sales amount (large, prominent)
  - Profit amount
  - Transaction count
  - Comparison with yesterday (% up/down)

- [ ] Create `lib/features/dashboard/presentation/widgets/quick_action_buttons.dart`
  - "Mulai Kasir" button
  - "Tambah Produk" button

- [ ] Create `lib/features/dashboard/presentation/widgets/low_stock_alert.dart`
  - Warning banner
  - Count of low stock products
  - Tap to view list

- [ ] Create `lib/features/dashboard/presentation/widgets/comparison_badge.dart`
  - Green up arrow for increase
  - Red down arrow for decrease
  - Percentage change

### 4. Navigation
- [ ] Set dashboard as home route in GoRouter
- [ ] Setup bottom navigation (Dashboard, Kasir, Produk, Laporan, Lainnya)

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

- [ ] Dashboard shows today's sales total
- [ ] Dashboard shows today's transaction count
- [ ] Dashboard shows today's profit
- [ ] Shows comparison with yesterday (% increase/decrease)
- [ ] Green indicator for increase, red for decrease
- [ ] Low stock alert shows when products are low
- [ ] Quick action buttons navigate correctly
- [ ] Recent transactions show (optional)
- [ ] Bottom navigation works correctly
- [ ] Data refreshes when returning to dashboard
- [ ] Handles zero sales gracefully

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
