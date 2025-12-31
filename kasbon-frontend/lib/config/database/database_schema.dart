/// SQL schema definitions for KASBON POS database
class DatabaseSchema {
  DatabaseSchema._();

  // ===========================================
  // SHOP SETTINGS TABLE
  // ===========================================
  static const String createShopSettingsTable = '''
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
    )
  ''';

  // ===========================================
  // CATEGORIES TABLE
  // ===========================================
  static const String createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      color TEXT DEFAULT '#FF6B35',
      icon TEXT DEFAULT 'category',
      sort_order INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  // ===========================================
  // PRODUCTS TABLE
  // ===========================================
  static const String createProductsTable = '''
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
    )
  ''';

  // ===========================================
  // TRANSACTIONS TABLE
  // ===========================================
  static const String createTransactionsTable = '''
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
    )
  ''';

  // ===========================================
  // TRANSACTION ITEMS TABLE
  // ===========================================
  static const String createTransactionItemsTable = '''
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
    )
  ''';

  // ===========================================
  // INDEXES
  // ===========================================
  static const String createProductsNameIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)
  ''';

  static const String createProductsBarcodeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)
  ''';

  static const String createProductsCategoryIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id)
  ''';

  static const String createProductsActiveIndex = '''
    CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active)
  ''';

  static const String createTransactionsDateIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date)
  ''';

  static const String createTransactionsNumberIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transactions_number ON transactions(transaction_number)
  ''';

  static const String createTransactionsStatusIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(payment_status)
  ''';

  static const String createTransactionsCustomerIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transactions_customer ON transactions(customer_name)
  ''';

  static const String createTransactionItemsTxnIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transaction_items_txn ON transaction_items(transaction_id)
  ''';

  static const String createTransactionItemsProductIndex = '''
    CREATE INDEX IF NOT EXISTS idx_transaction_items_product ON transaction_items(product_id)
  ''';

  // ===========================================
  // ALL CREATE TABLE STATEMENTS
  // ===========================================
  static List<String> get createTableStatements => [
        createShopSettingsTable,
        createCategoriesTable,
        createProductsTable,
        createTransactionsTable,
        createTransactionItemsTable,
      ];

  // ===========================================
  // ALL INDEX STATEMENTS
  // ===========================================
  static List<String> get createIndexStatements => [
        createProductsNameIndex,
        createProductsBarcodeIndex,
        createProductsCategoryIndex,
        createProductsActiveIndex,
        createTransactionsDateIndex,
        createTransactionsNumberIndex,
        createTransactionsStatusIndex,
        createTransactionsCustomerIndex,
        createTransactionItemsTxnIndex,
        createTransactionItemsProductIndex,
      ];
}
