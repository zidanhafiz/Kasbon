# TASK_002: Database Setup

**Priority:** P0 (Critical)
**Complexity:** MEDIUM
**Phase:** MVP - Setup
**Status:** Completed (Dec 21, 2024)

---

## Objective

Set up SQLite database with all tables required for MVP features. Implement DatabaseHelper class, schema creation, and database constants.

---

## Prerequisites

- [x] TASK_001: Project Setup & Architecture

---

## Subtasks

### 1. Database Constants
- [x] Create `lib/core/constants/database_constants.dart`
  - Database name and version
  - Table names
  - Column names
  - Enum values

### 2. Database Helper
- [x] Create `lib/config/database/database_helper.dart`
  - Singleton pattern
  - Database initialization
  - Open/close database
  - Execute raw queries

### 3. Schema Creation
- [x] Create `lib/config/database/database_schema.dart`
  - shop_settings table
  - categories table
  - products table
  - transactions table
  - transaction_items table

### 4. Default Data
- [x] Insert default shop_settings row
- [x] Insert default categories (Makanan, Minuman, Kebutuhan Rumah, Lainnya)

### 5. Migrations
- [x] Create `lib/config/database/migrations.dart`
  - Version 1 migration
  - Migration runner

### 6. Integration
- [x] Initialize database in `main.dart`
- [x] Register DatabaseHelper in GetIt (injection.dart)

---

## Database Schema

### Table: shop_settings
```sql
CREATE TABLE IF NOT EXISTS shop_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  logo_url TEXT,
  receipt_header TEXT,
  receipt_footer TEXT,
  currency TEXT DEFAULT 'IDR',
  low_stock_threshold INTEGER DEFAULT 5,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Default row
INSERT OR IGNORE INTO shop_settings (id, name, created_at, updated_at)
VALUES (1, 'Toko Saya', strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000);
```

### Table: categories
```sql
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#FF6B35',
  icon TEXT DEFAULT 'category',
  sort_order INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Default categories
INSERT OR IGNORE INTO categories (id, name, color, created_at, updated_at) VALUES
  ('cat-1', 'Makanan', '#FF6B35', strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
  ('cat-2', 'Minuman', '#1E88E5', strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
  ('cat-3', 'Kebutuhan Rumah', '#43A047', strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
  ('cat-4', 'Lainnya', '#757575', strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000);
```

### Table: products
```sql
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  category_id TEXT,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  barcode TEXT UNIQUE,
  cost_price REAL NOT NULL DEFAULT 0,
  selling_price REAL NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  min_stock INTEGER DEFAULT 5,
  unit TEXT DEFAULT 'pcs',
  image_url TEXT,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,

  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
```

### Table: transactions
```sql
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  transaction_number TEXT NOT NULL UNIQUE,
  customer_name TEXT,
  subtotal REAL NOT NULL,
  discount_amount REAL DEFAULT 0,
  discount_percentage REAL DEFAULT 0,
  tax_amount REAL DEFAULT 0,
  total REAL NOT NULL,
  payment_method TEXT DEFAULT 'cash',
  payment_status TEXT DEFAULT 'paid',
  cash_received REAL,
  cash_change REAL,
  notes TEXT,
  cashier_name TEXT,
  transaction_date INTEGER NOT NULL,
  debt_paid_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_transactions_number ON transactions(transaction_number);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(payment_status);
CREATE INDEX IF NOT EXISTS idx_transactions_customer ON transactions(customer_name);
```

### Table: transaction_items
```sql
CREATE TABLE IF NOT EXISTS transaction_items (
  id TEXT PRIMARY KEY,
  transaction_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_sku TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  cost_price REAL NOT NULL,
  selling_price REAL NOT NULL,
  discount_amount REAL DEFAULT 0,
  subtotal REAL NOT NULL,
  created_at INTEGER NOT NULL,

  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX IF NOT EXISTS idx_transaction_items_txn ON transaction_items(transaction_id);
CREATE INDEX IF NOT EXISTS idx_transaction_items_product ON transaction_items(product_id);
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/core/constants/database_constants.dart` | Database constants |
| `lib/config/database/database_helper.dart` | Database singleton |
| `lib/config/database/database_schema.dart` | SQL schema |
| `lib/config/database/migrations.dart` | Migration system |

---

## Code Templates

### database_constants.dart
```dart
class DatabaseConstants {
  // Database
  static const String databaseName = 'kasbon.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableShopSettings = 'shop_settings';
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableTransactions = 'transactions';
  static const String tableTransactionItems = 'transaction_items';

  // Common columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Payment methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodTransfer = 'transfer';
  static const String paymentMethodQris = 'qris';
  static const String paymentMethodDebt = 'debt';

  // Payment status
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusDebt = 'debt';
}
```

### database_helper.dart (skeleton)
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
  }
}
```

---

## Acceptance Criteria

- [x] Database file `kasbon.db` is created on app launch
- [x] All 5 tables exist with correct schema
- [x] Default shop_settings row is inserted
- [x] Default categories are inserted
- [x] Indexes are created for performance
- [x] DatabaseHelper is registered in GetIt
- [x] No errors on fresh install (first launch)
- [x] No errors on subsequent launches (database exists)

---

## Notes

### Timestamps
All timestamps stored as INTEGER (milliseconds since epoch) for simplicity.

### UUIDs
Using TEXT type for UUIDs (generated with `uuid` package).

### Soft Delete
Products use `is_active` flag instead of actual deletion.

### Reference
- See `DOCS/TECHNICAL_REQUIREMENTS.md` Section 4.1 for full schema

---

## Estimated Time

**2-3 hours** for complete setup

---

## Next Task

After completing this task, proceed to:
- [TASK_003_CORE_INFRASTRUCTURE.md](./TASK_003_CORE_INFRASTRUCTURE.md)
