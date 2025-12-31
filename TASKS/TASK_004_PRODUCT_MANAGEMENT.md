# TASK_004: Product Management

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP
**Status:** Not Started

---

## Objective

Build complete product management feature including CRUD operations, product listing with search, and low stock indicators.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture
- [x] TASK_002: Database Setup
- [x] TASK_003: Core Infrastructure

---

## Subtasks

### 1. Data Layer

#### Models
- [ ] Create `lib/features/products/data/models/product_model.dart`
  - ProductModel class with JSON serialization
  - toEntity() and fromEntity() methods
  - fromMap() and toMap() for SQLite

#### Data Sources
- [ ] Create `lib/features/products/data/datasources/product_local_datasource.dart`
  - getAllProducts()
  - getProductById()
  - searchProducts()
  - createProduct()
  - updateProduct()
  - deleteProduct() (soft delete)
  - getProductsByCategory()
  - getLowStockProducts()

#### Repository Implementation
- [ ] Create `lib/features/products/data/repositories/product_repository_impl.dart`

### 2. Domain Layer

#### Entities
- [ ] Create `lib/features/products/domain/entities/product.dart`
  - Product entity with Equatable

#### Repository Interface
- [ ] Create `lib/features/products/domain/repositories/product_repository.dart`

#### Use Cases
- [ ] Create `lib/features/products/domain/usecases/get_all_products.dart`
- [ ] Create `lib/features/products/domain/usecases/get_product.dart`
- [ ] Create `lib/features/products/domain/usecases/search_products.dart`
- [ ] Create `lib/features/products/domain/usecases/create_product.dart`
- [ ] Create `lib/features/products/domain/usecases/update_product.dart`
- [ ] Create `lib/features/products/domain/usecases/delete_product.dart`

### 3. Presentation Layer

#### Providers (Riverpod)
- [ ] Create `lib/features/products/presentation/providers/products_provider.dart`
  - productsProvider (all products)
  - productSearchProvider (search results)
  - lowStockProductsProvider

#### Screens
- [ ] Create `lib/features/products/presentation/screens/product_list_screen.dart`
  - AppBar with search toggle
  - Search bar (when active)
  - ListView of products
  - FAB to add product
  - Empty state widget

- [ ] Create `lib/features/products/presentation/screens/product_form_screen.dart`
  - Form for add/edit product
  - Name field (required)
  - Cost price field (required)
  - Selling price field (required)
  - Stock field
  - Min stock field
  - Unit field (dropdown: pcs, kg, liter, etc.)
  - Category dropdown
  - Save/Update button

- [ ] Create `lib/features/products/presentation/screens/product_detail_screen.dart`
  - Product info display
  - Edit button
  - Delete button (with confirmation)

#### Widgets
- [ ] Create `lib/features/products/presentation/widgets/product_card.dart`
  - Product image placeholder
  - Name
  - Price
  - Stock indicator
  - Low stock badge

- [ ] Create `lib/features/products/presentation/widgets/product_search_bar.dart`

- [ ] Create `lib/features/products/presentation/widgets/stock_indicator.dart`
  - Green: Stock OK
  - Yellow: Low stock
  - Red: Out of stock

### 4. Navigation
- [ ] Add product routes to GoRouter
  - /products (list)
  - /products/add
  - /products/:id (detail)
  - /products/:id/edit

### 5. Dependency Injection
- [ ] Register ProductLocalDatasource in GetIt
- [ ] Register ProductRepository in GetIt

---

## Product Entity

```dart
class Product extends Equatable {
  final String id;
  final String? categoryId;
  final String sku;
  final String name;
  final String? description;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String unit;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties
  double get profit => sellingPrice - costPrice;
  double get profitMargin => costPrice > 0
      ? ((sellingPrice - costPrice) / costPrice) * 100
      : 0;
  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;

  const Product({
    required this.id,
    this.categoryId,
    required this.sku,
    required this.name,
    this.description,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    this.minStock = 5,
    this.unit = 'pcs',
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, sku, stock];
}
```

---

## UI Specifications

### Product List Screen
```
┌─────────────────────────────────────┐
│  [<]  Produk          [🔍] [➕]     │
├─────────────────────────────────────┤
│  ┌────────────────────────────────┐ │
│  │ 🔍 Cari produk...              │ │
│  └────────────────────────────────┘ │
├─────────────────────────────────────┤
│  ┌─────────┐                        │
│  │  📦     │  Indomie Goreng        │
│  │         │  Rp 3.500              │
│  └─────────┘  Stok: 50 pcs          │
│  ─────────────────────────────────  │
│  ┌─────────┐                        │
│  │  📦     │  Aqua 600ml   ⚠️       │
│  │         │  Rp 4.000              │
│  └─────────┘  Stok: 3 pcs           │
│  ─────────────────────────────────  │
│                                      │
│               [+ Tambah Produk]      │
└─────────────────────────────────────┘
```

### Product Form Screen
```
┌─────────────────────────────────────┐
│  [<]  Tambah Produk        [Simpan] │
├─────────────────────────────────────┤
│                                      │
│  Nama Produk *                       │
│  ┌────────────────────────────────┐ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  Harga Modal *          Harga Jual * │
│  ┌──────────────┐  ┌──────────────┐ │
│  │ Rp           │  │ Rp           │ │
│  └──────────────┘  └──────────────┘ │
│                                      │
│  Stok Awal              Min. Stok    │
│  ┌──────────────┐  ┌──────────────┐ │
│  │ 0            │  │ 5            │ │
│  └──────────────┘  └──────────────┘ │
│                                      │
│  Satuan                              │
│  ┌────────────────────────────────┐ │
│  │ pcs                          ▼ │ │
│  └────────────────────────────────┘ │
│                                      │
│  Kategori                            │
│  ┌────────────────────────────────┐ │
│  │ Lainnya                      ▼ │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] Can view list of all products
- [ ] Can search products by name (real-time)
- [ ] Can add new product with required fields
- [ ] SKU is auto-generated
- [ ] Can edit existing product
- [ ] Can delete product (soft delete with confirmation)
- [ ] Low stock products show warning indicator
- [ ] Out of stock products show red indicator
- [ ] Form validation works (required fields)
- [ ] Empty state shown when no products
- [ ] Search shows "not found" when no results

---

## Notes

### Auto-generate SKU
Use first 3 letters of name + timestamp:
- "Indomie Goreng" → "IND-12345"

### Soft Delete
Set `is_active = false` instead of deleting row.
Filtered products only show `is_active = true`.

### Category (MVP)
For MVP, category is optional. Default to "Lainnya".
Category management will be added in v1.1.

---

## Estimated Time

**1 week** (5-7 days)

---

## Next Task

After completing this task, proceed to:
- [TASK_005_POS_SYSTEM.md](./TASK_005_POS_SYSTEM.md)
