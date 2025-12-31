# TASK_006: Transaction Management

**Priority:** P0 (Critical)
**Complexity:** LOW
**Phase:** MVP
**Status:** Not Started

---

## Objective

Build transaction history screen with list view, filtering, and transaction detail view.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture
- [x] TASK_002: Database Setup
- [x] TASK_003: Core Infrastructure
- [x] TASK_005: POS System (transaction creation)

---

## Subtasks

### 1. Domain Layer

#### Entities
- [ ] Create `lib/features/transactions/domain/entities/transaction.dart`
- [ ] Create `lib/features/transactions/domain/entities/transaction_item.dart`

#### Repository Interface
- [ ] Create `lib/features/transactions/domain/repositories/transaction_repository.dart`

#### Use Cases
- [ ] Create `lib/features/transactions/domain/usecases/get_transactions.dart`
- [ ] Create `lib/features/transactions/domain/usecases/get_transaction_detail.dart`
- [ ] Create `lib/features/transactions/domain/usecases/get_transactions_by_date.dart`

### 2. Data Layer

#### Data Sources
- [ ] Update `transaction_local_datasource.dart`
  - getTransactions(dateFrom, dateTo)
  - getTransactionById(id) with items
  - getTransactionsToday()
  - searchTransactions(query)

### 3. Presentation Layer

#### Providers
- [ ] Create `lib/features/transactions/presentation/providers/transactions_provider.dart`
  - transactionsProvider (filtered list)
  - transactionDetailProvider
  - dateRangeFilterProvider

#### Screens
- [ ] Create `lib/features/transactions/presentation/screens/transaction_list_screen.dart`
  - Date range filter (tabs or dropdown)
  - Transaction list (newest first)
  - Pull to refresh
  - Empty state

- [ ] Create `lib/features/transactions/presentation/screens/transaction_detail_screen.dart`
  - Transaction header info
  - List of items
  - Payment info
  - Receipt view/share button

#### Widgets
- [ ] Create `lib/features/transactions/presentation/widgets/transaction_card.dart`
  - Transaction number
  - Date and time
  - Total amount
  - Item count summary
  - Payment status badge

- [ ] Create `lib/features/transactions/presentation/widgets/date_filter_chips.dart`
  - Hari Ini
  - Kemarin
  - 7 Hari
  - 30 Hari
  - Kustom (date picker)

- [ ] Create `lib/features/transactions/presentation/widgets/transaction_item_tile.dart`
  - Product name
  - Quantity × Price
  - Subtotal

### 4. Navigation
- [ ] Add transaction routes to GoRouter
  - /transactions (list)
  - /transactions/:id (detail)

---

## Transaction Entity

```dart
class Transaction extends Equatable {
  final String id;
  final String transactionNumber;
  final String? customerName;
  final double subtotal;
  final double discountAmount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final double? cashReceived;
  final double? cashChange;
  final String? notes;
  final DateTime transactionDate;
  final DateTime createdAt;
  final List<TransactionItem> items;

  // Computed
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get profit => items.fold(0.0, (sum, item) => sum + item.profit);

  const Transaction({...});
}

class TransactionItem extends Equatable {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final double subtotal;

  double get profit => (sellingPrice - costPrice) * quantity;

  const TransactionItem({...});
}
```

---

## UI Specifications

### Transaction List Screen
```
┌─────────────────────────────────────┐
│  [<]  Riwayat Transaksi      [🔍]   │
├─────────────────────────────────────┤
│  [Hari Ini] [Kemarin] [7 Hari] [▼]  │
├─────────────────────────────────────┤
│                                      │
│  📅 Hari Ini - 15 Desember 2024      │
│  ─────────────────────────────────  │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241215-0003              │ │
│  │ 14:30 • 3 item                 │ │
│  │ Rp 45.000          [LUNAS]    │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241215-0002              │ │
│  │ 12:15 • 5 item                 │ │
│  │ Rp 78.500          [LUNAS]    │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241215-0001              │ │
│  │ 09:00 • 2 item                 │ │
│  │ Rp 25.000          [HUTANG]   │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Transaction Detail Screen
```
┌─────────────────────────────────────┐
│  [<]  Detail Transaksi              │
├─────────────────────────────────────┤
│                                      │
│  TRX-20241215-0003                   │
│  15 Desember 2024, 14:30             │
│  Status: LUNAS                       │
│                                      │
├─────────────────────────────────────┤
│  ITEM PEMBELIAN                      │
│  ─────────────────────────────────  │
│  Indomie Goreng                      │
│  2 × Rp 3.500         =   Rp  7.000 │
│                                      │
│  Aqua 600ml                          │
│  3 × Rp 4.000         =   Rp 12.000 │
│                                      │
│  Teh Botol                           │
│  5 × Rp 5.000         =   Rp 25.000 │
│                                      │
├─────────────────────────────────────┤
│                Subtotal: Rp 44.000  │
│                Diskon:   Rp      0  │
│                TOTAL:    Rp 44.000  │
│  ─────────────────────────────────  │
│  Uang Diterima:          Rp 50.000  │
│  Kembalian:              Rp  6.000  │
│                                      │
├─────────────────────────────────────┤
│  ┌────────────────────────────────┐ │
│  │      📝 Lihat Struk            │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │      📤 Bagikan Struk          │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

---

## Date Filtering Logic

```dart
enum DateFilter {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}

extension DateFilterExtension on DateFilter {
  DateTimeRange get range {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateFilter.today:
        return DateTimeRange(
          start: startOfToday,
          end: now,
        );
      case DateFilter.yesterday:
        final yesterday = startOfToday.subtract(Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: startOfToday,
        );
      case DateFilter.last7Days:
        return DateTimeRange(
          start: startOfToday.subtract(Duration(days: 6)),
          end: now,
        );
      case DateFilter.last30Days:
        return DateTimeRange(
          start: startOfToday.subtract(Duration(days: 29)),
          end: now,
        );
      case DateFilter.custom:
        // Handle separately with date picker
        return DateTimeRange(start: now, end: now);
    }
  }
}
```

---

## Acceptance Criteria

- [ ] Can view list of all transactions
- [ ] Transactions sorted newest first
- [ ] Can filter by date range (today, yesterday, 7 days, 30 days)
- [ ] Can select custom date range
- [ ] Can view transaction detail
- [ ] Detail shows all items with quantities and prices
- [ ] Detail shows payment information
- [ ] Can navigate to receipt from detail
- [ ] Empty state shown when no transactions
- [ ] Pull to refresh works

---

## Notes

### Pagination
For MVP, load all transactions for selected date range.
If performance issues occur with 1000+ transactions, add pagination.

### Search
Optional for MVP. Can search by transaction number.

### Grouping
Transactions are grouped by date in the list view.
Use sticky headers if possible.

---

## Estimated Time

**3-4 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_007_DASHBOARD.md](./TASK_007_DASHBOARD.md)
