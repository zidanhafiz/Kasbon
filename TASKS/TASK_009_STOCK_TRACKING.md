# TASK_009: Stock Tracking

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Not Started

---

## Objective

Implement automatic stock reduction when transactions are completed, display stock indicators on product lists, and show low stock alerts.

---

## Prerequisites

- [x] TASK_004: Product Management
- [x] TASK_005: POS System
- [x] TASK_007: Dashboard (low stock count)

---

## Subtasks

### 1. Stock Management Logic

#### Stock Operations
- [ ] Create `lib/features/products/domain/usecases/reduce_stock.dart`
  - reduceStock(productId, quantity)
  - Called during transaction creation

- [ ] Create `lib/features/products/domain/usecases/get_low_stock_products.dart`
  - Returns products where stock <= minStock

- [ ] Update transaction creation to reduce stock atomically

### 2. Stock Validation

- [ ] Create `lib/features/products/domain/usecases/check_stock_availability.dart`
  - Validates if enough stock for transaction
  - Returns warning if stock insufficient

- [ ] Add stock validation before transaction completion
  - Show warning dialog if stock will go negative
  - Allow user to proceed (for MVP) or cancel

### 3. Stock Display

#### Product List Updates
- [ ] Update `product_card.dart` with stock indicator
  - Green: stock > minStock
  - Yellow: stock <= minStock (low stock)
  - Red: stock <= 0 (out of stock)

- [ ] Update product list to show stock status badge

#### Low Stock Screen
- [ ] Create `lib/features/products/presentation/screens/low_stock_screen.dart`
  - List of products where stock <= minStock
  - Quick edit button to update stock
  - Navigate from dashboard alert

### 4. Stock Indicators

- [ ] Update `lib/features/products/presentation/widgets/stock_indicator.dart`
  ```dart
  enum StockStatus { ok, low, outOfStock }

  class StockIndicator extends StatelessWidget {
    final int stock;
    final int minStock;
  }
  ```

- [ ] Create `lib/features/products/presentation/widgets/stock_badge.dart`
  - Compact badge for list items
  - "Stok: 50" / "Stok Rendah" / "Habis"

### 5. POS Integration

- [ ] Update POS product search to show stock
- [ ] Highlight low stock items in POS
- [ ] Show warning when adding out-of-stock item to cart
- [ ] Optional: Prevent adding if stock = 0 (configurable)

---

## Stock Status Logic

```dart
enum StockStatus {
  ok,
  low,
  outOfStock,
}

extension StockStatusExtension on StockStatus {
  Color get color {
    switch (this) {
      case StockStatus.ok:
        return AppColors.success;
      case StockStatus.low:
        return AppColors.warning;
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  String get label {
    switch (this) {
      case StockStatus.ok:
        return 'Tersedia';
      case StockStatus.low:
        return 'Stok Rendah';
      case StockStatus.outOfStock:
        return 'Habis';
    }
  }
}

StockStatus getStockStatus(int stock, int minStock) {
  if (stock <= 0) return StockStatus.outOfStock;
  if (stock <= minStock) return StockStatus.low;
  return StockStatus.ok;
}
```

---

## UI Specifications

### Product Card with Stock Indicator
```
┌─────────────────────────────────────┐
│  ┌─────────┐                        │
│  │  📦     │  Indomie Goreng        │
│  │         │  Rp 3.500              │
│  └─────────┘  ● Stok: 50 pcs        │  <- Green dot
│                                      │
│  ┌─────────┐                        │
│  │  📦     │  Aqua 600ml   ⚠️       │
│  │         │  Rp 4.000              │
│  └─────────┘  ● Stok: 3 pcs         │  <- Yellow dot, warning icon
│                                      │
│  ┌─────────┐                        │
│  │  📦     │  Teh Botol Habis       │
│  │         │  Rp 5.000              │
│  └─────────┘  ● Stok: 0 pcs         │  <- Red dot, "Habis" badge
└─────────────────────────────────────┘
```

### Low Stock Alert on Dashboard
```
┌─────────────────────────────────────┐
│  ⚠️  PERHATIAN                      │
│  5 produk stok menipis!             │
│                                      │
│  • Aqua 600ml (3 pcs)               │
│  • Teh Botol (0 pcs)                │
│  • Indomie Ayam Bawang (2 pcs)      │
│                                      │
│  [Lihat Semua]    [Tutup]           │
└─────────────────────────────────────┘
```

### Low Stock Screen
```
┌─────────────────────────────────────┐
│  [<]  Stok Menipis                  │
├─────────────────────────────────────┤
│                                      │
│  5 produk perlu restock             │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 🔴 Teh Botol                   │ │
│  │    Stok: 0 pcs (min: 5)        │ │
│  │    [Edit Stok]                 │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 🟡 Aqua 600ml                  │ │
│  │    Stok: 3 pcs (min: 5)        │ │
│  │    [Edit Stok]                 │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ 🟡 Indomie Ayam Bawang         │ │
│  │    Stok: 2 pcs (min: 10)       │ │
│  │    [Edit Stok]                 │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Stock Warning Dialog (in POS)
```
┌─────────────────────────────────────┐
│         ⚠️  Peringatan Stok         │
├─────────────────────────────────────┤
│                                      │
│  Stok tidak cukup untuk beberapa    │
│  produk:                             │
│                                      │
│  • Teh Botol                        │
│    Stok: 2, Pesan: 5                │
│    Akan menjadi: -3                 │
│                                      │
│  Lanjutkan transaksi?               │
│                                      │
│  [Batal]              [Lanjutkan]   │
│                                      │
└─────────────────────────────────────┘
```

---

## Stock Reduction Flow

```
Transaction Completion
        │
        ▼
Check Stock Availability
        │
        ├─── All OK ───────────────────┐
        │                               │
        ▼                               │
Has Insufficient Stock?                 │
        │                               │
        ├─── Yes                        │
        │      │                        │
        │      ▼                        │
        │  Show Warning Dialog          │
        │      │                        │
        │      ├─── Cancel ─────────────┼─── Stop
        │      │                        │
        │      ▼                        │
        │  User Confirms                │
        │                               │
        ▼                               │
┌───────────────────────────────────────┘
│
▼
BEGIN TRANSACTION
│
├── Create transaction record
├── Create transaction items
├── For each item:
│   └── UPDATE products SET stock = stock - quantity
│       WHERE id = product_id
│
COMMIT TRANSACTION
```

---

## Acceptance Criteria

- [ ] Stock reduces automatically after transaction
- [ ] Stock reduction is atomic with transaction creation
- [ ] Product list shows stock status (color coded)
- [ ] Dashboard shows low stock count
- [ ] Can view list of low stock products
- [ ] POS shows stock for each product
- [ ] Warning shown when stock insufficient
- [ ] Can proceed with transaction even if stock goes negative (MVP)
- [ ] Stock can go negative (for later adjustment)
- [ ] Quick edit stock from low stock screen

---

## Notes

### Negative Stock
For MVP, allow negative stock. This happens when:
- User forgets to update stock
- Selling faster than tracking

Business owners can adjust stock manually via product edit.

### Stock Movement History
Not included in MVP. Will be added in Phase 2 for audit trail.

### Batch Stock Update
Not included in MVP. Will be added for stock opname feature.

---

## Estimated Time

**2-3 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_010_PROFIT_CALCULATION.md](./TASK_010_PROFIT_CALCULATION.md)
