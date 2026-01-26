# TASK_015: Testing

**Priority:** P1 (Core)
**Complexity:** HIGH
**Phase:** MVP - Quality
**Status:** COMPLETED
**Completed:** 2026-01-26

---

## Objective

Implement comprehensive testing including unit tests, widget tests, and integration tests to ensure app quality before beta release.

---

## Prerequisites

- [x] All MVP features completed (001-014)

---

## Subtasks

### 1. Unit Tests

#### Core Utilities
- [x] Test `currency_formatter.dart` (95.2% coverage)
- [x] Test `date_formatter.dart` (97.6% coverage)
- [x] Test `validators.dart` (97.6% coverage)
- [x] Test `sku_generator.dart` (100% coverage)
- [x] Test `receipt_generator.dart` (97.0% coverage)

#### Data Layer
- [x] Test ProductModel (JSON serialization) (100% coverage)
- [x] Test TransactionModel (entity tests)
- [x] Test CartItem calculations (100% coverage)

#### Domain Layer
- [x] Test Product entity (profit, profitMargin, isLowStock, isOutOfStock) (100% coverage)
- [x] Test Transaction entity (totalProfit, totalQuantity, isPaid, isDebt) (100% coverage)
- [x] Test profit calculations
- [x] Test stock calculations

#### Business Logic
- [x] Test cart operations (add, remove, update) - CartProvider (100% coverage)
- [x] Test derived cart providers (subtotal, total, profit, isEmpty, stockWarnings)
- [ ] Test backup/restore JSON format (deferred to future)

### 2. Widget Tests

#### Shared Widgets (Modern Widget Library)
- [x] Test ModernButton (variants, interaction, loading, icons)
- [x] Test ModernTextField (input, validation, disabled state, prefixes/suffixes)
- [x] Test ModernQuantityStepper (increment/decrement, min/max bounds)
- [x] Test ModernPasswordField (visibility toggle)

#### Feature Widgets
- [ ] Test ProductCard (deferred - requires more setup)
- [ ] Test CartItemTile (deferred)
- [ ] Test TransactionCard (deferred)
- [ ] Test StockIndicator (deferred)

#### Forms
- [ ] Test ProductForm validation (deferred)
- [ ] Test PaymentDialog (deferred)
- [ ] Test DebtDialog (deferred)

### 3. Integration Tests

#### Critical User Flows
- [ ] Test complete transaction flow (deferred to Phase 2)
- [ ] Test product CRUD flow (deferred to Phase 2)
- [ ] Test debt creation and payment (deferred to Phase 2)
- [ ] Test backup and restore (deferred to Phase 2)

#### Navigation
- [ ] Test bottom navigation (deferred to Phase 2)
- [ ] Test deep linking (deferred to Phase 2)

### 4. Test Infrastructure

- [x] Setup test directory structure
- [x] Create test utilities and helpers (`test/helpers/test_helpers.dart`)
- [x] Create mock data factories (`test/fixtures/mock_data.dart`)
- [x] Create mock repositories (`test/fixtures/mock_repositories.dart`)

---

## Test Directory Structure

```
test/
├── unit/
│   ├── core/
│   │   ├── utils/
│   │   │   ├── currency_formatter_test.dart
│   │   │   ├── date_formatter_test.dart
│   │   │   └── validators_test.dart
│   │   └── services/
│   │       └── backup_service_test.dart
│   │
│   ├── features/
│   │   ├── products/
│   │   │   ├── data/
│   │   │   │   └── models/
│   │   │   │       └── product_model_test.dart
│   │   │   └── domain/
│   │   │       └── usecases/
│   │   │           └── create_product_test.dart
│   │   │
│   │   ├── pos/
│   │   │   └── presentation/
│   │   │       └── providers/
│   │   │           └── cart_provider_test.dart
│   │   │
│   │   └── transactions/
│   │       └── domain/
│   │           └── usecases/
│   │               └── create_transaction_test.dart
│   │
│   └── helpers/
│       ├── test_helpers.dart
│       └── mock_data.dart
│
├── widget/
│   ├── shared/
│   │   ├── app_button_test.dart
│   │   └── app_text_field_test.dart
│   │
│   └── features/
│       ├── products/
│       │   ├── product_card_test.dart
│       │   └── product_form_test.dart
│       │
│       └── pos/
│           └── cart_item_tile_test.dart
│
└── integration/
    ├── transaction_flow_test.dart
    ├── product_crud_test.dart
    └── backup_restore_test.dart
```

---

## Example Unit Tests

### currency_formatter_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kasbon_pos/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format', () {
      test('formats positive number correctly', () {
        expect(CurrencyFormatter.format(10000), 'Rp 10.000');
      });

      test('formats zero correctly', () {
        expect(CurrencyFormatter.format(0), 'Rp 0');
      });

      test('formats large number correctly', () {
        expect(CurrencyFormatter.format(1000000), 'Rp 1.000.000');
      });

      test('formats decimal by rounding', () {
        expect(CurrencyFormatter.format(10000.5), 'Rp 10.001');
      });
    });

    group('formatCompact', () {
      test('formats millions as jt', () {
        expect(CurrencyFormatter.formatCompact(5000000), 'Rp 5.0jt');
      });

      test('formats thousands as rb', () {
        expect(CurrencyFormatter.formatCompact(50000), 'Rp 50rb');
      });
    });

    group('parse', () {
      test('parses formatted string correctly', () {
        expect(CurrencyFormatter.parse('Rp 10.000'), 10000);
      });

      test('handles invalid input', () {
        expect(CurrencyFormatter.parse('invalid'), 0);
      });
    });
  });
}
```

### cart_provider_test.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasbon_pos/features/pos/presentation/providers/cart_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CartProvider', () {
    test('starts with empty cart', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('adds product to cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addProduct(mockProduct);

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.product.id, mockProduct.id);
      expect(cart.first.quantity, 1);
    });

    test('increments quantity when adding same product', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addProduct(mockProduct);
      notifier.addProduct(mockProduct);

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 2);
    });

    test('calculates total correctly', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addProduct(mockProduct); // price: 10000
      notifier.addProduct(mockProduct2); // price: 5000

      final total = container.read(cartTotalProvider);
      expect(total, 15000);
    });

    test('removes product from cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addProduct(mockProduct);
      notifier.removeProduct(mockProduct.id);

      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('clears cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addProduct(mockProduct);
      notifier.addProduct(mockProduct2);
      notifier.clear();

      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });
  });
}
```

---

## Example Widget Tests

### product_card_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasbon_pos/features/products/presentation/widgets/product_card.dart';

void main() {
  group('ProductCard', () {
    testWidgets('displays product name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: mockProduct),
          ),
        ),
      );

      expect(find.text('Indomie Goreng'), findsOneWidget);
    });

    testWidgets('displays formatted price', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: mockProduct),
          ),
        ),
      );

      expect(find.text('Rp 3.500'), findsOneWidget);
    });

    testWidgets('shows low stock indicator when stock is low', (tester) async {
      final lowStockProduct = mockProduct.copyWith(stock: 2, minStock: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: lowStockProduct),
          ),
        ),
      );

      expect(find.byType(StockIndicator), findsOneWidget);
      // Check for warning color
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: mockProduct,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });
  });
}
```

---

## Example Integration Test

### transaction_flow_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kasbon_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction Flow', () {
    testWidgets('complete transaction from search to success', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS
      await tester.tap(find.byIcon(Icons.point_of_sale));
      await tester.pumpAndSettle();

      // Search for product
      await tester.enterText(find.byType(TextField), 'Indomie');
      await tester.pumpAndSettle();

      // Add to cart
      await tester.tap(find.text('Indomie Goreng').first);
      await tester.pumpAndSettle();

      // Verify cart has item
      expect(find.text('1 item'), findsOneWidget);

      // Tap Pay button
      await tester.tap(find.text('BAYAR'));
      await tester.pumpAndSettle();

      // Enter cash received
      await tester.tap(find.text('50rb'));
      await tester.pumpAndSettle();

      // Complete payment
      await tester.tap(find.text('SELESAI'));
      await tester.pumpAndSettle();

      // Verify success screen
      expect(find.text('Transaksi Berhasil'), findsOneWidget);
    });
  });
}
```

---

## Mock Data Factory

```dart
// test/helpers/mock_data.dart

import 'package:kasbon_pos/features/products/domain/entities/product.dart';

final mockProduct = Product(
  id: 'prod-1',
  sku: 'IND-001',
  name: 'Indomie Goreng',
  costPrice: 2500,
  sellingPrice: 3500,
  stock: 50,
  minStock: 10,
  unit: 'pcs',
  isActive: true,
  createdAt: DateTime(2024, 12, 1),
  updatedAt: DateTime(2024, 12, 1),
);

final mockProduct2 = Product(
  id: 'prod-2',
  sku: 'AQU-001',
  name: 'Aqua 600ml',
  costPrice: 3000,
  sellingPrice: 4000,
  stock: 30,
  minStock: 5,
  unit: 'pcs',
  isActive: true,
  createdAt: DateTime(2024, 12, 1),
  updatedAt: DateTime(2024, 12, 1),
);

final mockTransaction = Transaction(
  id: 'txn-1',
  transactionNumber: 'TRX-20241215-0001',
  subtotal: 35000,
  total: 35000,
  paymentMethod: 'cash',
  paymentStatus: 'paid',
  cashReceived: 50000,
  cashChange: 15000,
  transactionDate: DateTime(2024, 12, 15, 14, 30),
  createdAt: DateTime(2024, 12, 15, 14, 30),
  items: [],
);
```

---

## Acceptance Criteria

### Code Coverage
- [x] Unit tests: 70%+ coverage on business logic (95-100% achieved on all tested files)
- [x] Widget tests: Core shared widgets tested (ModernButton, ModernTextField, ModernQuantityStepper)
- [ ] Integration tests: Critical flows covered (deferred to Phase 2)

### Test Quality
- [x] All tests pass (`flutter test`) - 358 tests passing
- [x] No flaky tests
- [x] Tests run in < 2 minutes (~6 seconds)

### Specific Tests
- [x] Currency formatting tested (95.2% coverage)
- [x] Date formatting tested (97.6% coverage)
- [x] Cart calculations tested (100% coverage)
- [x] Transaction entity tested (100% coverage)
- [x] Product entity tested (100% coverage)
- [x] Profit calculation tested
- [ ] Backup/restore tested (deferred)

---

## Notes

### Testing Philosophy
- Test business logic thoroughly (unit tests)
- Test critical UI components (widget tests)
- Test user flows sparingly (integration tests)

### Mocking
Use `mocktail` package for mocking repositories and data sources.

### CI/CD (Future)
After MVP launch, setup GitHub Actions for automated testing.

---

## Estimated Time

**1 week** (parallel with development)

---

## Completion Summary

### Test Results
- **Total Tests:** 358
- **Passing:** 358 (100%)
- **Failing:** 0

### Coverage by File (Business Logic)
| File | Lines | Coverage |
|------|-------|----------|
| `sku_generator.dart` | 10/10 | 100% |
| `product_model.dart` | 71/71 | 100% |
| `transaction.dart` | 52/52 | 100% |
| `cart_item.dart` | 15/15 | 100% |
| `product.dart` | 25/25 | 100% |
| `cart_provider.dart` | 82/82 | 100% |
| `date_formatter.dart` | 41/42 | 97.6% |
| `receipt_generator.dart` | 96/99 | 97.0% |
| `validators.dart` | 40/41 | 97.6% |
| `currency_formatter.dart` | 20/21 | 95.2% |

### Test Files Created
```
test/
├── fixtures/
│   ├── mock_data.dart           # Factory methods for test data
│   └── mock_repositories.dart   # Mocktail repository mocks
├── helpers/
│   └── test_helpers.dart        # Widget test wrapper utilities
├── unit/
│   ├── core/utils/
│   │   ├── currency_formatter_test.dart
│   │   ├── date_formatter_test.dart
│   │   ├── validators_test.dart
│   │   ├── sku_generator_test.dart
│   │   └── receipt_generator_test.dart
│   └── features/
│       ├── products/
│       │   ├── domain/entities/product_test.dart
│       │   └── data/models/product_model_test.dart
│       ├── pos/
│       │   ├── domain/entities/cart_item_test.dart
│       │   └── presentation/providers/cart_provider_test.dart
│       └── transactions/
│           └── domain/entities/transaction_test.dart
├── widget/
│   └── shared/modern/
│       ├── modern_button_test.dart
│       ├── modern_text_field_test.dart
│       └── modern_quantity_stepper_test.dart
└── widget_test.dart             # Basic app load test
```

### Notes
- Integration tests deferred to Phase 2 (post-MVP) as they require more complex test setup
- Additional widget tests for feature-specific components deferred
- BackupService tests deferred as it requires file system mocking

---

## Next Task

After completing this task, proceed to:
- [TASK_016_BETA_PREPARATION.md](./TASK_016_BETA_PREPARATION.md)
