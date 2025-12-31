# TASK_010: Profit Calculation

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Not Started

---

## Objective

Track cost price (harga modal) per product and calculate profit for transactions, daily summaries, and product performance reports.

---

## Prerequisites

- [x] TASK_002: Database Setup (cost_price column exists)
- [x] TASK_004: Product Management (cost_price input)
- [x] TASK_005: POS System (transaction items store cost_price)
- [x] TASK_007: Dashboard (shows profit)

---

## Subtasks

### 1. Profit Calculation Logic

#### Use Cases
- [ ] Create `lib/features/reports/domain/usecases/get_profit_summary.dart`
  - getTodayProfit()
  - getProfitByDateRange(from, to)
  - getProfitByProduct(productId)

- [ ] Create `lib/features/reports/domain/usecases/get_product_profitability.dart`
  - getTopProfitableProducts(limit)
  - getProfitMarginByProduct(productId)

### 2. Data Layer

#### Repository
- [ ] Create `lib/features/reports/data/datasources/profit_local_datasource.dart`
  - calculateProfit(transactionId)
  - calculateDailyProfit(date)
  - calculateProfitByDateRange(from, to)
  - getTopProfitableProducts(limit)

### 3. Dashboard Integration

- [ ] Update dashboard to show:
  - Today's profit
  - Profit margin percentage
  - Comparison with yesterday

- [ ] Update `sales_summary_card.dart` to include profit

### 4. Product Profit Display

- [ ] Update product detail to show:
  - Profit per unit
  - Profit margin %
  - Total profit generated (all time)

- [ ] Create profit indicator on product card (optional)

### 5. Basic Profit Report

- [ ] Create `lib/features/reports/presentation/screens/profit_report_screen.dart`
  - Daily profit summary
  - Top 5 most profitable products
  - Profit trend (simple list, charts in TASK_012)

---

## Profit Calculations

### Per Transaction Item
```dart
class TransactionItem {
  // ...
  double get profit => (sellingPrice - costPrice) * quantity;
  double get profitMargin => costPrice > 0
      ? ((sellingPrice - costPrice) / costPrice) * 100
      : 0;
}
```

### Per Transaction
```dart
class Transaction {
  // ...
  double get profit => items.fold(0.0, (sum, item) => sum + item.profit);
  double get profitMargin => subtotal > 0
      ? (profit / subtotal) * 100
      : 0;
}
```

### Daily Summary
```sql
-- Total Profit for Today
SELECT
  COALESCE(SUM((ti.selling_price - ti.cost_price) * ti.quantity), 0) as profit
FROM transaction_items ti
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE date(t.transaction_date / 1000, 'unixepoch', 'localtime') = date('now', 'localtime')
  AND t.payment_status != 'cancelled';
```

### Top Profitable Products
```sql
-- Top 5 Most Profitable Products (all time)
SELECT
  p.id,
  p.name,
  SUM((ti.selling_price - ti.cost_price) * ti.quantity) as total_profit,
  SUM(ti.quantity) as total_sold,
  AVG((ti.selling_price - ti.cost_price) / ti.cost_price * 100) as avg_margin
FROM transaction_items ti
INNER JOIN products p ON ti.product_id = p.id
INNER JOIN transactions t ON ti.transaction_id = t.id
WHERE t.payment_status != 'cancelled'
GROUP BY p.id
ORDER BY total_profit DESC
LIMIT 5;
```

### Profit Margin
```dart
double calculateProfitMargin(double costPrice, double sellingPrice) {
  if (costPrice <= 0) return 0;
  return ((sellingPrice - costPrice) / costPrice) * 100;
}

String formatProfitMargin(double margin) {
  if (margin >= 100) {
    return '+${margin.toStringAsFixed(0)}%';
  } else if (margin > 0) {
    return '+${margin.toStringAsFixed(1)}%';
  } else {
    return '${margin.toStringAsFixed(1)}%';
  }
}
```

---

## UI Specifications

### Dashboard Profit Display
```
┌─────────────────────────────────────┐
│  💰 Penjualan Hari Ini              │
│                                      │
│     Rp 1.250.000                     │
│     ▲ +15% dari kemarin             │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  💵 Laba Bersih                     │
│     Rp 250.000                       │
│     Margin: 20%                      │
│     ▲ +25% dari kemarin             │
│                                      │
│  📦 Transaksi: 45                   │
│                                      │
└─────────────────────────────────────┘
```

### Product Detail - Profit Section
```
┌─────────────────────────────────────┐
│  INFORMASI PROFIT                    │
│  ─────────────────────────────────  │
│                                      │
│  Harga Modal:      Rp  2.500        │
│  Harga Jual:       Rp  3.500        │
│  ─────────────────────────────────  │
│  Profit per unit:  Rp  1.000        │
│  Profit margin:    +40%              │
│                                      │
│  Total terjual:    150 pcs          │
│  Total profit:     Rp 150.000       │
│                                      │
└─────────────────────────────────────┘
```

### Top Profitable Products Report
```
┌─────────────────────────────────────┐
│  [<]  Produk Paling Untung          │
├─────────────────────────────────────┤
│                                      │
│  Total Profit Bulan Ini: Rp 2.5jt   │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  1. Kopi Sachet                     │
│     Profit: Rp 450.000              │
│     Margin: +60% • Terjual: 300 pcs │
│                                      │
│  2. Rokok Filter                    │
│     Profit: Rp 380.000              │
│     Margin: +15% • Terjual: 250 pcs │
│                                      │
│  3. Indomie Goreng                  │
│     Profit: Rp 320.000              │
│     Margin: +40% • Terjual: 200 pcs │
│                                      │
│  4. Aqua 600ml                      │
│     Profit: Rp 280.000              │
│     Margin: +33% • Terjual: 180 pcs │
│                                      │
│  5. Teh Botol                       │
│     Profit: Rp 250.000              │
│     Margin: +25% • Terjual: 150 pcs │
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] Every product has cost_price (required field)
- [ ] Transaction items store cost_price snapshot
- [ ] Profit calculates correctly per transaction
- [ ] Dashboard shows daily profit
- [ ] Dashboard shows profit margin percentage
- [ ] Dashboard shows profit comparison with yesterday
- [ ] Can view top profitable products
- [ ] Product detail shows profit info
- [ ] Profit calculations handle edge cases (zero cost)

---

## Notes

### Cost Price Required
For MVP, cost_price is required. If user doesn't know, they can enter same as selling price (0 profit).

### Historical Accuracy
Transaction items store cost_price at time of sale. This ensures profit calculations remain accurate even if product cost changes later.

### Negative Profit
If selling_price < cost_price, profit will be negative. This is valid (selling at a loss for clearance).

### KILLER FEATURE
This is a differentiator! Most free POS apps only show revenue, not profit. Emphasize this in marketing:
- "Tahu untung Anda, bukan cuma omzet!"
- "Profit tracking gratis!"

---

## Estimated Time

**2-3 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_011_DEBT_TRACKING.md](./TASK_011_DEBT_TRACKING.md)
