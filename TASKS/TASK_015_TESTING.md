# TASK_015: Testing

**Priority:** P1 (Core)
**Complexity:** HIGH
**Phase:** MVP - Quality
**Status:** Not Started

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
- [ ] Test `currency_formatter.dart`
- [ ] Test `date_formatter.dart`
- [ ] Test `validators.dart`
- [ ] Test `sku_generator.dart`
- [ ] Test `receipt_generator.dart`

#### Data Layer
- [ ] Test ProductModel (JSON serialization)
- [ ] Test TransactionModel (JSON serialization)
- [ ] Test CartItem calculations

#### Domain Layer
- [ ] Test CreateProduct usecase
- [ ] Test CreateTransaction usecase
- [ ] Test profit calculations
- [ ] Test stock calculations

#### Business Logic
- [ ] Test cart operations (add, remove, update)
- [ ] Test transaction creation flow
- [ ] Test backup/restore JSON format

### 2. Widget Tests

#### Shared Widgets
- [ ] Test AppButton
- [ ] Test AppTextField
- [ ] Test LoadingWidget
- [ ] Test EmptyStateWidget

#### Feature Widgets
- [ ] Test ProductCard
- [ ] Test CartItemTile
- [ ] Test TransactionCard
- [ ] Test StockIndicator

#### Forms
- [ ] Test ProductForm validation
- [ ] Test PaymentDialog
- [ ] Test DebtDialog

### 3. Integration Tests

#### Critical User Flows
- [ ] Test complete transaction flow (search → cart → payment → success)
- [ ] Test product CRUD flow
- [ ] Test debt creation and payment
- [ ] Test backup and restore

#### Navigation
- [ ] Test bottom navigation
- [ ] Test deep linking (if applicable)

### 4. Test Infrastructure

- [ ] Setup test directory structure
- [ ] Create test utilities and helpers
- [ ] Create mock data factories
- [ ] Setup test database (in-memory SQLite)

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
- [ ] Unit tests: 70%+ coverage on business logic
- [ ] Widget tests: All shared widgets tested
- [ ] Integration tests: Critical flows covered

### Test Quality
- [ ] All tests pass (`flutter test`)
- [ ] No flaky tests
- [ ] Tests run in < 2 minutes

### Specific Tests
- [ ] Currency formatting tested
- [ ] Date formatting tested
- [ ] Cart calculations tested
- [ ] Transaction creation tested
- [ ] Product CRUD tested
- [ ] Profit calculation tested
- [ ] Backup/restore tested

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

## Next Task

After completing this task, proceed to:
- [TASK_016_BETA_PREPARATION.md](./TASK_016_BETA_PREPARATION.md)
