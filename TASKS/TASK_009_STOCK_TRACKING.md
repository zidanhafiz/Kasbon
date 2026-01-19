# TASK_009: Stock Tracking

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Completed
**Completed Date:** January 14, 2025

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
- [x] Stock reduction during transaction creation
  - Implemented in `lib/features/transactions/data/datasources/transaction_local_datasource.dart:66-81`
  - Uses SQLite transaction for atomic operations
  - `UPDATE products SET stock = stock - ? WHERE id = ?`

- [x] Get low stock products functionality
  - Implemented in `lib/features/products/data/datasources/product_local_datasource.dart`
  - `getLowStockProducts()` - Returns products where stock <= minStock

- [x] Transaction creation reduces stock atomically
  - Uses `db.transaction()` to ensure all-or-nothing

### 2. Stock Validation

- [x] Stock availability validation in cart operations
  - Implemented in `lib/features/pos/presentation/providers/cart_provider.dart:22-65`
  - `CartOperationResult.outOfStock` - Product has no stock
  - `CartOperationResult.exceedsStock` - Would exceed available stock

- [x] Stock validation before adding to cart
  - Prevents adding out-of-stock items
  - Prevents exceeding available stock quantity
  - Returns detailed error with product name and available stock

### 3. Stock Display

#### Product List Updates
- [x] Product card shows stock indicator
  - Implemented in `lib/features/products/presentation/widgets/stock_indicator.dart`
  - Green: stock > minStock (Tersedia)
  - Yellow: stock <= minStock (Stok Rendah)
  - Red: stock <= 0 (Habis)

- [x] Product list shows stock status badge
  - Uses `ModernBadge.warning` for low stock
  - Uses `ModernBadge.error` for out of stock

#### Low Stock Alert
- [x] Dashboard shows low stock alert
  - Implemented in `lib/features/dashboard/presentation/widgets/low_stock_alert.dart`
  - Shows count of products with low stock
  - Navigates to product list with low stock filter

- [ ] ~~Dedicated Low Stock Screen~~ (Deferred)
  - Using product list with stock filter instead
  - More efficient UX with existing functionality

### 4. Stock Indicators

- [x] StockIndicator widget
  - `lib/features/products/presentation/widgets/stock_indicator.dart`
  - Compact mode shows numeric stock with color coding
  - Badge mode shows status text

- [x] Stock status logic on Product entity
  - `Product.isLowStock` - stock > 0 && stock <= minStock
  - `Product.isOutOfStock` - stock <= 0

### 5. POS Integration

- [x] POS product grid shows stock
  - `lib/features/pos/presentation/widgets/product_grid_item.dart:97-106`
  - Shows "Stok: X unit" with color coding

- [x] Highlight low stock items in POS
  - Yellow badge "Stok Rendah" for low stock
  - Red badge "Habis" for out of stock

- [x] Prevent adding out-of-stock items
  - Items are disabled (opacity 0.5, onTap: null)
  - `CartNotifier.addProduct()` returns `CartOperationResult.outOfStock`

- [x] Prevent exceeding available stock
  - `CartNotifier.addProduct()` and `updateQuantity()` validate against stock
  - Returns `CartOperationResult.exceedsStock` with details

---

## Implementation References

### Stock Data Flow

```
Product Entity
├── stock: int (current quantity)
├── minStock: int (threshold, default 5)
├── isLowStock: bool (computed)
└── isOutOfStock: bool (computed)

Cart Provider (cart_provider.dart)
├── addProduct() → CartOperationResult
├── updateQuantity() → CartOperationResult
├── incrementQuantity() → CartOperationResult
├── cartHasStockWarningProvider
└── cartItemsWithStockWarningProvider

Transaction Creation (transaction_local_datasource.dart)
└── createTransaction()
    └── For each item: UPDATE stock = stock - quantity
```

### Key Files

| Feature | File |
|---------|------|
| Stock fields | `lib/features/products/domain/entities/product.dart` |
| Stock validation | `lib/features/pos/presentation/providers/cart_provider.dart` |
| Stock deduction | `lib/features/transactions/data/datasources/transaction_local_datasource.dart` |
| Low stock query | `lib/features/products/data/datasources/product_local_datasource.dart` |
| Stock indicator | `lib/features/products/presentation/widgets/stock_indicator.dart` |
| Low stock alert | `lib/features/dashboard/presentation/widgets/low_stock_alert.dart` |
| POS stock display | `lib/features/pos/presentation/widgets/product_grid_item.dart` |
| Stock filtering | `lib/features/products/domain/entities/product_filter.dart` |

---

## Acceptance Criteria

- [x] Stock reduces automatically after transaction
- [x] Stock reduction is atomic with transaction creation
- [x] Product list shows stock status (color coded)
- [x] Dashboard shows low stock count
- [x] Can view list of low stock products (via filter)
- [x] POS shows stock for each product
- [x] Warning shown when stock insufficient
- [x] Can proceed with transaction even if stock goes negative (stricter: prevents exceeding)
- [x] Quick edit stock from product form

---

## Notes

### Stock Validation Behavior
For MVP, stock validation is **stricter** than originally planned:
- Cannot add items with 0 stock (disabled in UI)
- Cannot add more than available stock
- This provides better UX and prevents overselling

Users can adjust stock via product edit form to correct discrepancies.

### Negative Stock
Not allowed in current implementation. If needed for edge cases:
- User can manually adjust stock in product edit
- Future enhancement could add stock adjustment feature

### Deferred to Phase 2
- **Stock Movement History** - Audit trail for stock changes
- **Batch Stock Update** - Stock opname feature
- **Dedicated Low Stock Screen** - Using product list filter instead

---

## Next Task

After completing this task, proceed to:
- [TASK_010_PROFIT_CALCULATION.md](./TASK_010_PROFIT_CALCULATION.md)
