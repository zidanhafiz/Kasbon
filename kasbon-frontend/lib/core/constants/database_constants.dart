/// Database constants for KASBON POS SQLite database
class DatabaseConstants {
  DatabaseConstants._();

  // ===========================================
  // DATABASE INFO
  // ===========================================
  static const String databaseName = 'kasbon.db';
  static const int databaseVersion = 1;

  // ===========================================
  // TABLE NAMES
  // ===========================================
  static const String tableShopSettings = 'shop_settings';
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableTransactions = 'transactions';
  static const String tableTransactionItems = 'transaction_items';

  // ===========================================
  // COMMON COLUMN NAMES
  // ===========================================
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // ===========================================
  // SHOP SETTINGS COLUMNS
  // ===========================================
  static const String colAddress = 'address';
  static const String colPhone = 'phone';
  static const String colLogoUrl = 'logo_url';
  static const String colReceiptHeader = 'receipt_header';
  static const String colReceiptFooter = 'receipt_footer';
  static const String colCurrency = 'currency';
  static const String colLowStockThreshold = 'low_stock_threshold';

  // ===========================================
  // CATEGORY COLUMNS
  // ===========================================
  static const String colColor = 'color';
  static const String colIcon = 'icon';
  static const String colSortOrder = 'sort_order';

  // ===========================================
  // PRODUCT COLUMNS
  // ===========================================
  static const String colCategoryId = 'category_id';
  static const String colSku = 'sku';
  static const String colDescription = 'description';
  static const String colBarcode = 'barcode';
  static const String colCostPrice = 'cost_price';
  static const String colSellingPrice = 'selling_price';
  static const String colStock = 'stock';
  static const String colMinStock = 'min_stock';
  static const String colUnit = 'unit';
  static const String colImageUrl = 'image_url';
  static const String colIsActive = 'is_active';

  // ===========================================
  // TRANSACTION COLUMNS
  // ===========================================
  static const String colTransactionNumber = 'transaction_number';
  static const String colCustomerName = 'customer_name';
  static const String colSubtotal = 'subtotal';
  static const String colDiscountAmount = 'discount_amount';
  static const String colDiscountPercentage = 'discount_percentage';
  static const String colTaxAmount = 'tax_amount';
  static const String colTotal = 'total';
  static const String colPaymentMethod = 'payment_method';
  static const String colPaymentStatus = 'payment_status';
  static const String colCashReceived = 'cash_received';
  static const String colCashChange = 'cash_change';
  static const String colNotes = 'notes';
  static const String colCashierName = 'cashier_name';
  static const String colTransactionDate = 'transaction_date';
  static const String colDebtPaidAt = 'debt_paid_at';

  // ===========================================
  // TRANSACTION ITEM COLUMNS
  // ===========================================
  static const String colTransactionId = 'transaction_id';
  static const String colProductId = 'product_id';
  static const String colProductName = 'product_name';
  static const String colProductSku = 'product_sku';
  static const String colQuantity = 'quantity';

  // ===========================================
  // PAYMENT METHODS
  // ===========================================
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodTransfer = 'transfer';
  static const String paymentMethodQris = 'qris';
  static const String paymentMethodDebt = 'debt';

  // ===========================================
  // PAYMENT STATUS
  // ===========================================
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusDebt = 'debt';

  // ===========================================
  // DEFAULT CATEGORY IDS
  // ===========================================
  static const String categoryIdMakanan = 'cat-1';
  static const String categoryIdMinuman = 'cat-2';
  static const String categoryIdKebutuhanRumah = 'cat-3';
  static const String categoryIdLainnya = 'cat-4';
}
