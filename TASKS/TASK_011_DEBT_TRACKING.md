# TASK_011: Debt Tracking (Hutang Piutang)

**Priority:** P1 (Core)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** ✅ Completed (Jan 21, 2025)

---

## Objective

Enable businesses to track customer debts (hutang) by marking transactions as unpaid, adding customer names and notes, and providing a list of outstanding debts with payment tracking.

---

## Prerequisites

- [x] TASK_005: POS System
- [x] TASK_006: Transaction Management

---

## Subtasks

### 1. Database Updates

- [x] Verify columns exist in transactions table:
  - payment_status (TEXT: 'paid' | 'debt')
  - customer_name (TEXT, nullable)
  - notes (TEXT, nullable)
  - debt_paid_at (INTEGER, nullable - timestamp)

### 2. POS Payment Flow Update

- [x] Update payment dialog to include "Hutang" option
- [x] When "Hutang" selected:
  - Require customer name
  - Optional notes field (e.g., "Bayar akhir bulan")
  - Set payment_status = 'debt'
  - No cash_received needed

- [x] Create `lib/features/pos/presentation/widgets/debt_payment_dialog.dart`

### 3. Debt List Screen

- [x] Create `lib/features/debt/presentation/screens/debt_list_screen.dart`
  - List all unpaid transactions (payment_status = 'debt')
  - Group by customer name
  - Show total debt per customer
  - Show transaction details

- [x] Create `lib/features/debt/presentation/widgets/debt_card.dart`
  - Customer name
  - Transaction number and date
  - Amount owed
  - Notes
  - "Tandai Lunas" button

### 4. Debt Summary

- [x] Create `lib/features/debt/presentation/widgets/debt_summary_card.dart`
  - Total outstanding debt
  - Number of debtors
  - Oldest debt

- [x] Create `lib/features/debt/presentation/providers/debt_provider.dart`
  - unpaidDebtsProvider
  - totalDebtProvider
  - debtByCustomerProvider

### 5. Mark Debt as Paid

- [x] Create `lib/features/debt/domain/usecases/mark_debt_paid.dart`
  - Updates payment_status to 'paid'
  - Sets debt_paid_at timestamp

- [x] Confirmation dialog before marking paid
- [x] Success feedback

### 6. Navigation & Integration

- [x] Add debt routes to GoRouter
  - /debts (list)
  - /debts/:transactionId (detail)

- [x] Add "Hutang" menu item to bottom nav "Lainnya"
- [x] Show debt count badge if unpaid debts exist

---

## Database Schema Reference

```sql
-- Existing columns in transactions table
payment_status TEXT DEFAULT 'paid',  -- 'paid' or 'debt'
customer_name TEXT,                   -- Customer name for debt tracking
notes TEXT,                           -- e.g., "Bayar tanggal 30"
debt_paid_at INTEGER,                -- Timestamp when debt was paid
```

---

## UI Specifications

### Payment Dialog - Debt Option
```
┌─────────────────────────────────────┐
│         Metode Pembayaran           │
├─────────────────────────────────────┤
│                                      │
│  Total: Rp 45.000                    │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  💵 Cash                       │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  💳 Transfer                   │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  📝 Hutang                     │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Debt Input Dialog
```
┌─────────────────────────────────────┐
│         Catat Hutang                │
├─────────────────────────────────────┤
│                                      │
│  Total: Rp 45.000                    │
│                                      │
│  Nama Pembeli *                      │
│  ┌────────────────────────────────┐ │
│  │ Pak Budi                       │ │
│  └────────────────────────────────┘ │
│                                      │
│  Catatan (opsional)                  │
│  ┌────────────────────────────────┐ │
│  │ Bayar akhir bulan              │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │          SIMPAN                │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Debt List Screen
```
┌─────────────────────────────────────┐
│  [<]  Daftar Hutang                 │
├─────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Total Hutang: Rp 350.000       │ │
│  │ 5 pelanggan • 8 transaksi      │ │
│  └────────────────────────────────┘ │
│                                      │
│  ─────────────────────────────────  │
│                                      │
│  👤 Pak Budi                        │
│     Total: Rp 125.000               │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241215-0003              │ │
│  │ 15 Des 2024 • Rp 45.000        │ │
│  │ "Bayar akhir bulan"            │ │
│  │ [Tandai Lunas]                 │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241210-0015              │ │
│  │ 10 Des 2024 • Rp 80.000        │ │
│  │ [Tandai Lunas]                 │ │
│  └────────────────────────────────┘ │
│                                      │
│  👤 Bu Siti                         │
│     Total: Rp 75.000                │
│  ┌────────────────────────────────┐ │
│  │ TRX-20241214-0008              │ │
│  │ 14 Des 2024 • Rp 75.000        │ │
│  │ [Tandai Lunas]                 │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Mark as Paid Confirmation
```
┌─────────────────────────────────────┐
│         Konfirmasi                  │
├─────────────────────────────────────┤
│                                      │
│  Tandai hutang Pak Budi sebagai     │
│  LUNAS?                              │
│                                      │
│  TRX-20241215-0003                   │
│  Jumlah: Rp 45.000                   │
│                                      │
│  [Batal]              [Ya, Lunas]   │
│                                      │
└─────────────────────────────────────┘
```

---

## Code Examples

### Debt Provider
```dart
@riverpod
Future<List<Transaction>> unpaidDebts(UnpaidDebtsRef ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactionsByStatus('debt');
}

@riverpod
Future<double> totalDebt(TotalDebtRef ref) async {
  final debts = await ref.watch(unpaidDebtsProvider.future);
  return debts.fold(0.0, (sum, t) => sum + t.total);
}

@riverpod
Future<Map<String, List<Transaction>>> debtsByCustomer(
  DebtsByCustomerRef ref,
) async {
  final debts = await ref.watch(unpaidDebtsProvider.future);
  final grouped = <String, List<Transaction>>{};

  for (final debt in debts) {
    final name = debt.customerName ?? 'Tanpa Nama';
    grouped.putIfAbsent(name, () => []).add(debt);
  }

  return grouped;
}
```

### Mark Debt Paid
```dart
class MarkDebtPaid {
  final TransactionRepository repository;

  MarkDebtPaid(this.repository);

  Future<Either<Failure, void>> call(String transactionId) async {
    try {
      await repository.updateTransaction(
        transactionId,
        paymentStatus: 'paid',
        debtPaidAt: DateTime.now().millisecondsSinceEpoch,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

---

## Acceptance Criteria

- [x] Can select "Hutang" as payment method in POS
- [x] Customer name required for debt transactions
- [x] Notes field available (optional)
- [x] Debt transactions saved with payment_status = 'debt'
- [x] Can view list of all unpaid debts
- [x] Debts grouped by customer name
- [x] Shows total debt per customer
- [x] Shows total outstanding debt
- [x] Can mark individual debt as paid
- [x] Paid debts no longer appear in debt list
- [x] Debt badge shown in navigation

---

## Notes

### Culture-Specific Feature
This is a **UNIQUE SELLING POINT** for Indonesian market!

Indonesian warung culture heavily relies on "bon" (credit/debt) for regular customers. Most competitors don't have this feature in free tier.

Marketing angle:
- "Catat hutang pelanggan, tidak pernah lupa lagi!"
- "Fitur kasbon digital untuk warung Anda"

### Simple Implementation
For MVP, no separate customer database. Just store customer name as text.
Full customer management will be added in Phase 2.

### No Partial Payment
MVP doesn't support partial payment. Debt is either fully paid or not.
Partial payment tracking can be added later.

### Receipt for Debt
When transaction is debt:
- Receipt shows "BELUM LUNAS" status
- Can share receipt to customer as reminder

---

## Estimated Time

**3-4 days**

---

## Next Task

After completing this task, proceed to:
- [TASK_012_BASIC_REPORTS.md](./TASK_012_BASIC_REPORTS.md)
