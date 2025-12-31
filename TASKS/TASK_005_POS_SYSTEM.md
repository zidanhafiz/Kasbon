# TASK_005: Point of Sale (POS) System

**Priority:** P0 (Critical)
**Complexity:** HIGH
**Phase:** MVP
**Status:** ✅ COMPLETED (December 31, 2024)

---

## Objective

Build the main Point of Sale screen for processing sales transactions. Users can search products, add to cart, adjust quantities, and complete cash payments.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture
- [x] TASK_002: Database Setup
- [x] TASK_003: Core Infrastructure
- [x] TASK_004: Product Management

---

## Subtasks

### 1. Cart State Management

#### Cart Item Model
- [x] Create `lib/features/pos/domain/entities/cart_item.dart`
  ```dart
  class CartItem {
    final Product product;
    final int quantity;

    double get subtotal => product.sellingPrice * quantity;
    double get profit => (product.sellingPrice - product.costPrice) * quantity;
  }
  ```

#### Cart Provider (Riverpod)
- [x] Create `lib/features/pos/presentation/providers/cart_provider.dart`
  - cartProvider (list of CartItems)
  - cartSubtotalProvider
  - cartTotalProvider
  - cartItemCountProvider
  - cartProfitProvider

#### Cart Actions
- [x] addToCart(Product product)
- [x] updateQuantity(String productId, int quantity)
- [x] incrementQuantity(String productId)
- [x] decrementQuantity(String productId)
- [x] removeFromCart(String productId)
- [x] clearCart()

### 2. Transaction Processing

#### Transaction Model
- [x] Create `lib/features/transactions/data/models/transaction_model.dart`
- [x] Create `lib/features/transactions/data/models/transaction_item_model.dart`

#### Transaction Repository
- [x] Create `lib/features/transactions/data/datasources/transaction_local_datasource.dart`
  - createTransaction()
  - getTransactions()
  - getTransactionById()

- [x] Create `lib/features/transactions/data/repositories/transaction_repository_impl.dart`

#### Use Cases
- [x] Create `lib/features/transactions/domain/usecases/create_transaction.dart`
  - Validates cart is not empty
  - Creates transaction record
  - Creates transaction items
  - Reduces product stock
  - All in single database transaction

### 3. POS Screen UI

#### Main POS Screen
- [x] Create `lib/features/pos/presentation/screens/pos_screen.dart`
  - Search bar (top)
  - Product search results
  - Cart summary (bottom sheet or fixed bottom)
  - "BAYAR" button

#### Widgets
- [x] Create `lib/features/pos/presentation/widgets/product_grid_item.dart`
  - Grid/List of matching products
  - Tap to add to cart
  - Shows price and stock

- [x] Create `lib/features/pos/presentation/widgets/cart_bottom_sheet.dart`
  - List of cart items
  - Quantity controls per item
  - Swipe to remove
  - Subtotal and total display
  - "BAYAR" button

- [x] Create `lib/features/pos/presentation/widgets/cart_item_tile.dart`
  - Product name
  - Unit price
  - Quantity (+/- buttons)
  - Item subtotal
  - Remove button

- [x] Create `lib/features/pos/presentation/widgets/cart_summary_bar.dart`
  - Item count
  - Subtotal
  - Total (bold, large)

### 4. Payment Flow

#### Payment Dialog
- [x] Create `lib/features/pos/presentation/widgets/payment_dialog.dart`
  - Display total amount
  - Cash received input (number keyboard)
  - Quick cash buttons (Rp 10k, 20k, 50k, 100k)
  - Calculate change automatically
  - "Bayar" button (disabled if cash < total)

#### Transaction Success Screen
- [x] Create `lib/features/pos/presentation/screens/transaction_success_screen.dart`
  - Success animation/icon
  - Transaction number
  - Total amount
  - Change amount
  - "Lihat Struk" button
  - "Transaksi Baru" button

### 5. Navigation
- [x] Add POS routes to GoRouter
  - /pos (main POS screen)
  - /pos/payment (payment dialog - could be modal)
  - /pos/success/:transactionId

---

## Cart State Design

```dart
@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() => [];

  void addProduct(Product product) {
    final existing = state.indexWhere((item) => item.product.id == product.id);
    if (existing >= 0) {
      // Increment quantity
      final item = state[existing];
      state = [
        ...state.sublist(0, existing),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(existing + 1),
      ];
    } else {
      // Add new item
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() {
    state = [];
  }
}

@riverpod
double cartTotal(CartTotalRef ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
}
```

---

## UI Specifications

### POS Main Screen
```
┌─────────────────────────────────────┐
│  KASBON - Kasir                      │
├─────────────────────────────────────┤
│  ┌────────────────────────────────┐ │
│  │ 🔍 Cari produk...              │ │
│  └────────────────────────────────┘ │
├─────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │ Indomie │ │ Aqua    │ │ Teh Bot ││
│  │ Rp 3.5k │ │ Rp 4k   │ │ Rp 5k   ││
│  │ [+]     │ │ [+]     │ │ [+]     ││
│  └─────────┘ └─────────┘ └─────────┘│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │ Mie Sed │ │ Sprite  │ │ Kopi    ││
│  │ Rp 3k   │ │ Rp 6k   │ │ Rp 8k   ││
│  │ [+]     │ │ [+]     │ │ [+]     ││
│  └─────────┘ └─────────┘ └─────────┘│
│                                      │
├─────────────────────────────────────┤
│  🛒 3 item          Total: Rp 32.000│
│  ┌────────────────────────────────┐ │
│  │           BAYAR                │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Cart Bottom Sheet (Expanded)
```
┌─────────────────────────────────────┐
│  Keranjang (3 item)           [✕]   │
├─────────────────────────────────────┤
│  Indomie Goreng                      │
│  Rp 3.500 × 2        =    Rp  7.000 │
│  [-]  2  [+]                  [🗑️] │
│  ─────────────────────────────────  │
│  Aqua 600ml                          │
│  Rp 4.000 × 3        =    Rp 12.000 │
│  [-]  3  [+]                  [🗑️] │
│  ─────────────────────────────────  │
│  Teh Botol                           │
│  Rp 5.000 × 1        =    Rp  5.000 │
│  [-]  1  [+]                  [🗑️] │
├─────────────────────────────────────┤
│                   Subtotal: Rp 24.000│
│                      TOTAL: Rp 24.000│
│  ┌────────────────────────────────┐ │
│  │           BAYAR                │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Payment Dialog
```
┌─────────────────────────────────────┐
│         Pembayaran                   │
├─────────────────────────────────────┤
│                                      │
│        Total: Rp 24.000              │
│                                      │
│  Uang Diterima:                      │
│  ┌────────────────────────────────┐ │
│  │ Rp 50.000                      │ │
│  └────────────────────────────────┘ │
│                                      │
│  [10rb] [20rb] [50rb] [100rb]       │
│  [Uang Pas]                          │
│                                      │
│        Kembalian: Rp 26.000          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      SELESAI (Bayar)           │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## Transaction Creation Flow

```
User taps "BAYAR"
    │
    ▼
Show Payment Dialog
    │
    ▼
User enters cash received
    │
    ▼
User taps "Selesai"
    │
    ▼
┌─────────────────────────────────────┐
│ BEGIN TRANSACTION                    │
│                                      │
│ 1. Generate transaction number       │
│    Format: TRX-YYYYMMDD-XXXX         │
│                                      │
│ 2. Create transaction record         │
│    - subtotal, total                 │
│    - payment_method: 'cash'          │
│    - cash_received, cash_change      │
│    - transaction_date: now           │
│                                      │
│ 3. Create transaction_items          │
│    For each cart item:               │
│    - product_id, product_name        │
│    - quantity, cost_price, selling_price │
│    - subtotal                        │
│                                      │
│ 4. Update product stock              │
│    For each item:                    │
│    product.stock -= quantity         │
│                                      │
│ COMMIT TRANSACTION                   │
└─────────────────────────────────────┘
    │
    ▼
Clear cart
    │
    ▼
Navigate to Success Screen
```

---

## Acceptance Criteria

### Product Search
- [x] Search shows results as user types
- [x] Search matches product name (case-insensitive)
- [x] Empty results shows "Produk tidak ditemukan"
- [x] Tapping product adds to cart

### Cart Management
- [x] Can add product to cart
- [x] Adding same product increases quantity
- [x] Can increase/decrease quantity
- [x] Can remove item from cart
- [x] Cart shows correct subtotal per item
- [x] Cart shows correct total
- [x] Cart persists during POS session (not across app restart)

### Payment Flow
- [x] Payment dialog shows total
- [x] Can enter cash received amount
- [x] Quick buttons work (10k, 20k, etc)
- [x] "Uang Pas" button sets cash = total
- [x] Change calculates automatically
- [x] Cannot complete if cash < total
- [x] Completing payment creates transaction

### Transaction
- [x] Transaction number is unique (TRX-YYYYMMDD-XXXX)
- [x] All cart items saved as transaction_items
- [x] Product stock is reduced
- [x] Cart is cleared after success

### Success Screen
- [x] Shows transaction number
- [x] Shows total and change
- [x] Can view receipt
- [x] Can start new transaction

---

## Notes

### Stock Validation
For MVP, allow selling even if stock would go negative.
Show warning but don't block transaction.
Stock validation will be configurable in Settings.

### Performance
Use `debounce` on search input to avoid excessive queries.
Minimum 300ms delay before searching.

### Offline
All operations are local SQLite.
No network required.

---

## Estimated Time

**2 weeks** (10-14 days)

---

## Next Task

After completing this task, proceed to:
- [TASK_006_TRANSACTION_MANAGEMENT.md](./TASK_006_TRANSACTION_MANAGEMENT.md)
