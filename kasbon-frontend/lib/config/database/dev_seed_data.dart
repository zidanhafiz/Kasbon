import 'package:sqflite/sqflite.dart';

import '../../core/constants/database_constants.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/transactions/data/models/transaction_item_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import 'database_helper.dart';

/// Development seed data utility for populating test data.
///
/// IMPORTANT: This is for development use only.
/// Do not include in production builds.
class DevSeedData {
  final DatabaseHelper _databaseHelper;

  DevSeedData(this._databaseHelper);

  /// Clear all seed data and reset to defaults.
  /// Preserves shop_settings and categories.
  Future<void> clearSeedData() async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Delete in correct order due to foreign key constraints
      await txn.delete(DatabaseConstants.tableTransactionItems);
      await txn.delete(DatabaseConstants.tableTransactions);
      await txn.delete(DatabaseConstants.tableProducts);
    });
  }

  /// Seed all sample data (products + transactions).
  /// Will clear existing data first.
  Future<void> seedAll() async {
    await clearSeedData();
    await _insertProducts();
    await _insertTransactions();
  }

  /// Seed only products (clears existing products first).
  Future<void> seedProducts() async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Clear transaction items and transactions first due to FK
      await txn.delete(DatabaseConstants.tableTransactionItems);
      await txn.delete(DatabaseConstants.tableTransactions);
      await txn.delete(DatabaseConstants.tableProducts);
    });
    await _insertProducts();
  }

  /// Seed only transactions (clears existing transactions first).
  /// Requires products to exist.
  Future<void> seedTransactions() async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableTransactionItems);
      await txn.delete(DatabaseConstants.tableTransactions);
    });
    await _insertTransactions();
  }

  /// Insert sample products into the database.
  Future<void> _insertProducts() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();

    for (final product in _sampleProducts(now)) {
      await db.insert(
        DatabaseConstants.tableProducts,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Insert sample transactions into the database.
  Future<void> _insertTransactions() async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (final entry in _sampleTransactions()) {
        final transaction = entry['transaction'] as TransactionModel;
        final items = entry['items'] as List<TransactionItemModel>;

        await txn.insert(
          DatabaseConstants.tableTransactions,
          transaction.toMap(),
        );

        for (final item in items) {
          await txn.insert(
            DatabaseConstants.tableTransactionItems,
            item.toMap(),
          );
        }
      }
    });
  }

  /// Generate sample products (25 total).
  List<ProductModel> _sampleProducts(DateTime baseTime) {
    final now = baseTime;

    return [
      // ===== MAKANAN (cat-1) - 8 products =====
      ProductModel(
        id: 'prod-001',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'MIE-00001',
        name: 'Mie Goreng Instan',
        description: 'Mie goreng kemasan 85g',
        costPrice: 2500,
        sellingPrice: 3500,
        stock: 50,
        minStock: 10,
        unit: 'pcs',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-002',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'NAS-00002',
        name: 'Nasi Goreng Frozen',
        description: 'Nasi goreng beku 200g',
        costPrice: 12000,
        sellingPrice: 18000,
        stock: 20,
        minStock: 5,
        unit: 'pcs',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-003',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'ROT-00003',
        name: 'Roti Tawar',
        description: 'Roti tawar gandum 400g',
        costPrice: 10000,
        sellingPrice: 14000,
        stock: 15,
        minStock: 5,
        unit: 'pcs',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-004',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'TEL-00004',
        name: 'Telur Ayam',
        description: 'Telur ayam kampung per butir',
        costPrice: 2000,
        sellingPrice: 2800,
        stock: 100,
        minStock: 20,
        unit: 'butir',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-005',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'GUL-00005',
        name: 'Gula Pasir 1kg',
        description: 'Gula pasir putih premium',
        costPrice: 12000,
        sellingPrice: 15000,
        stock: 3, // LOW STOCK
        minStock: 5,
        unit: 'kg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-006',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'BER-00006',
        name: 'Beras Premium 5kg',
        description: 'Beras pulen premium',
        costPrice: 60000,
        sellingPrice: 75000,
        stock: 0, // OUT OF STOCK
        minStock: 5,
        unit: 'karung',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-007',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'KEJ-00007',
        name: 'Keju Cheddar Slice',
        description: 'Keju cheddar potong 10 lembar',
        costPrice: 18000,
        sellingPrice: 25000,
        stock: 12,
        minStock: 3,
        unit: 'pack',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-008',
        categoryId: DatabaseConstants.categoryIdMakanan,
        sku: 'SAR-00008',
        name: 'Sarden Kaleng',
        description: 'Sarden dalam saus tomat 155g',
        costPrice: 10000,
        sellingPrice: 14000,
        stock: 25,
        minStock: 8,
        unit: 'kaleng',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // ===== MINUMAN (cat-2) - 7 products =====
      ProductModel(
        id: 'prod-009',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'AQU-00009',
        name: 'Air Mineral 600ml',
        description: 'Air mineral kemasan botol',
        costPrice: 2500,
        sellingPrice: 4000,
        stock: 48,
        minStock: 12,
        unit: 'botol',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-010',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'KOP-00010',
        name: 'Kopi Sachet',
        description: 'Kopi instan 3in1 sachet',
        costPrice: 1500,
        sellingPrice: 2500,
        stock: 80,
        minStock: 20,
        unit: 'sachet',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-011',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'TEH-00011',
        name: 'Teh Kotak 250ml',
        description: 'Teh manis kemasan kotak',
        costPrice: 3000,
        sellingPrice: 5000,
        stock: 36,
        minStock: 10,
        unit: 'kotak',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-012',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'SUS-00012',
        name: 'Susu UHT 1L',
        description: 'Susu UHT full cream',
        costPrice: 15000,
        sellingPrice: 19000,
        stock: 2, // LOW STOCK
        minStock: 5,
        unit: 'kotak',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-013',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'SIR-00013',
        name: 'Sirup Merah 630ml',
        description: 'Sirup rasa cocopandan',
        costPrice: 12000,
        sellingPrice: 18000,
        stock: 8,
        minStock: 3,
        unit: 'botol',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-014',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'MIN-00014',
        name: 'Minuman Soda 390ml',
        description: 'Minuman bersoda',
        costPrice: 5000,
        sellingPrice: 7500,
        stock: 24,
        minStock: 8,
        unit: 'kaleng',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-015',
        categoryId: DatabaseConstants.categoryIdMinuman,
        sku: 'YOG-00015',
        name: 'Yogurt Cup',
        description: 'Yogurt rasa stroberi',
        costPrice: 4000,
        sellingPrice: 6000,
        stock: 0, // OUT OF STOCK
        minStock: 6,
        unit: 'cup',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // ===== KEBUTUHAN RUMAH (cat-3) - 6 products =====
      ProductModel(
        id: 'prod-016',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'SAB-00016',
        name: 'Sabun Cuci Piring 800ml',
        description: 'Sabun cuci piring cair',
        costPrice: 8000,
        sellingPrice: 12000,
        stock: 18,
        minStock: 5,
        unit: 'botol',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-017',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'DET-00017',
        name: 'Deterjen Bubuk 900g',
        description: 'Deterjen bubuk wangi',
        costPrice: 20000,
        sellingPrice: 28000,
        stock: 10,
        minStock: 4,
        unit: 'pack',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-018',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'TIS-00018',
        name: 'Tisu Wajah 250 lembar',
        description: 'Tisu wajah lembut',
        costPrice: 10000,
        sellingPrice: 15000,
        stock: 4, // LOW STOCK
        minStock: 5,
        unit: 'box',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-019',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'PEM-00019',
        name: 'Pembalut Wanita',
        description: 'Pembalut wanita 10 pcs',
        costPrice: 8000,
        sellingPrice: 12000,
        stock: 20,
        minStock: 8,
        unit: 'pack',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-020',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'SAM-00020',
        name: 'Sampo Sachet',
        description: 'Sampo anti ketombe sachet',
        costPrice: 1000,
        sellingPrice: 1500,
        stock: 50,
        minStock: 15,
        unit: 'sachet',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-021',
        categoryId: DatabaseConstants.categoryIdKebutuhanRumah,
        sku: 'PAS-00021',
        name: 'Pasta Gigi 120g',
        description: 'Pasta gigi whitening',
        costPrice: 10000,
        sellingPrice: 14000,
        stock: 1, // LOW STOCK
        minStock: 5,
        unit: 'tube',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // ===== LAINNYA (cat-4) - 4 products =====
      ProductModel(
        id: 'prod-022',
        categoryId: DatabaseConstants.categoryIdLainnya,
        sku: 'ROK-00022',
        name: 'Rokok Filter',
        description: 'Rokok filter 16 batang',
        costPrice: 25000,
        sellingPrice: 30000,
        stock: 30,
        minStock: 10,
        unit: 'bungkus',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-023',
        categoryId: DatabaseConstants.categoryIdLainnya,
        sku: 'KOR-00023',
        name: 'Korek Api Gas',
        description: 'Korek api gas isi ulang',
        costPrice: 3000,
        sellingPrice: 5000,
        stock: 25,
        minStock: 8,
        unit: 'pcs',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-024',
        categoryId: DatabaseConstants.categoryIdLainnya,
        sku: 'PUL-00024',
        name: 'Pulsa Elektrik 50rb',
        description: 'Voucher pulsa 50.000',
        costPrice: 48000,
        sellingPrice: 51000,
        stock: 0, // OUT OF STOCK
        minStock: 5,
        unit: 'voucher',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod-025',
        categoryId: DatabaseConstants.categoryIdLainnya,
        sku: 'KAN-00025',
        name: 'Kantong Plastik 1kg',
        description: 'Kantong plastik ukuran sedang',
        costPrice: 15000,
        sellingPrice: 20000,
        stock: 5, // LOW STOCK (exactly at minStock)
        minStock: 5,
        unit: 'pak',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Generate sample transactions (20 total).
  List<Map<String, dynamic>> _sampleTransactions() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> transactions = [];

    // Helper function to generate transaction number
    String txnNum(DateTime date, int seq) {
      final dateStr =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      return 'TRX-$dateStr-${seq.toString().padLeft(4, '0')}';
    }

    // Transaction 1: Today, cash, no discount
    var date = now;
    var txnId = 'txn-001';
    var subtotal = (3500.0 * 3) + (4000.0 * 2); // 10500 + 8000 = 18500
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 20000,
        cashChange: 1500,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-001-1',
          transactionId: txnId,
          productId: 'prod-001',
          productName: 'Mie Goreng Instan',
          productSku: 'MIE-00001',
          quantity: 3,
          costPrice: 2500,
          sellingPrice: 3500,
          discountAmount: 0,
          subtotal: 10500,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-001-2',
          transactionId: txnId,
          productId: 'prod-009',
          productName: 'Air Mineral 600ml',
          productSku: 'AQU-00009',
          quantity: 2,
          costPrice: 2500,
          sellingPrice: 4000,
          discountAmount: 0,
          subtotal: 8000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 2: Yesterday, cash, 10% discount
    date = now.subtract(const Duration(days: 1));
    txnId = 'txn-002';
    subtotal = (30000.0 * 2) + (5000.0 * 1); // 65000
    var discountAmount = subtotal * 0.10; // 6500
    var total = subtotal - discountAmount; // 58500
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercentage: 10,
        taxAmount: 0,
        total: total,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 60000,
        cashChange: 1500,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-002-1',
          transactionId: txnId,
          productId: 'prod-022',
          productName: 'Rokok Filter',
          productSku: 'ROK-00022',
          quantity: 2,
          costPrice: 25000,
          sellingPrice: 30000,
          discountAmount: 0,
          subtotal: 60000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-002-2',
          transactionId: txnId,
          productId: 'prod-023',
          productName: 'Korek Api Gas',
          productSku: 'KOR-00023',
          quantity: 1,
          costPrice: 3000,
          sellingPrice: 5000,
          discountAmount: 0,
          subtotal: 5000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 3: 3 days ago, DEBT (unpaid)
    date = now.subtract(const Duration(days: 3));
    txnId = 'txn-003';
    subtotal = (75000.0 * 1) + (15000.0 * 2) + (2800.0 * 10); // 133000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        customerName: 'Bu Siti',
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'debt',
        paymentStatus: 'debt',
        notes: 'Bayar akhir bulan',
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-003-1',
          transactionId: txnId,
          productId: 'prod-006',
          productName: 'Beras Premium 5kg',
          productSku: 'BER-00006',
          quantity: 1,
          costPrice: 60000,
          sellingPrice: 75000,
          discountAmount: 0,
          subtotal: 75000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-003-2',
          transactionId: txnId,
          productId: 'prod-005',
          productName: 'Gula Pasir 1kg',
          productSku: 'GUL-00005',
          quantity: 2,
          costPrice: 12000,
          sellingPrice: 15000,
          discountAmount: 0,
          subtotal: 30000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-003-3',
          transactionId: txnId,
          productId: 'prod-004',
          productName: 'Telur Ayam',
          productSku: 'TEL-00004',
          quantity: 10,
          costPrice: 2000,
          sellingPrice: 2800,
          discountAmount: 0,
          subtotal: 28000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 4: 5 days ago, cash with Rp 5000 fixed discount
    date = now.subtract(const Duration(days: 5));
    txnId = 'txn-004';
    subtotal = (19000.0 * 2) + (14000.0 * 1); // 52000
    discountAmount = 5000.0;
    total = subtotal - discountAmount; // 47000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercentage: 0,
        taxAmount: 0,
        total: total,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 50000,
        cashChange: 3000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-004-1',
          transactionId: txnId,
          productId: 'prod-012',
          productName: 'Susu UHT 1L',
          productSku: 'SUS-00012',
          quantity: 2,
          costPrice: 15000,
          sellingPrice: 19000,
          discountAmount: 0,
          subtotal: 38000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-004-2',
          transactionId: txnId,
          productId: 'prod-003',
          productName: 'Roti Tawar',
          productSku: 'ROT-00003',
          quantity: 1,
          costPrice: 10000,
          sellingPrice: 14000,
          discountAmount: 0,
          subtotal: 14000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 5: 7 days ago, cash
    date = now.subtract(const Duration(days: 7));
    txnId = 'txn-005';
    subtotal = (2500.0 * 5) + (5000.0 * 3); // 12500 + 15000 = 27500
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 30000,
        cashChange: 2500,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-005-1',
          transactionId: txnId,
          productId: 'prod-010',
          productName: 'Kopi Sachet',
          productSku: 'KOP-00010',
          quantity: 5,
          costPrice: 1500,
          sellingPrice: 2500,
          discountAmount: 0,
          subtotal: 12500,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-005-2',
          transactionId: txnId,
          productId: 'prod-011',
          productName: 'Teh Kotak 250ml',
          productSku: 'TEH-00011',
          quantity: 3,
          costPrice: 3000,
          sellingPrice: 5000,
          discountAmount: 0,
          subtotal: 15000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 6: 10 days ago, DEBT (unpaid)
    date = now.subtract(const Duration(days: 10));
    txnId = 'txn-006';
    subtotal = (28000.0 * 1) + (12000.0 * 2); // 52000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        customerName: 'Pak Ahmad',
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'debt',
        paymentStatus: 'debt',
        notes: 'Hutang warung',
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-006-1',
          transactionId: txnId,
          productId: 'prod-017',
          productName: 'Deterjen Bubuk 900g',
          productSku: 'DET-00017',
          quantity: 1,
          costPrice: 20000,
          sellingPrice: 28000,
          discountAmount: 0,
          subtotal: 28000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-006-2',
          transactionId: txnId,
          productId: 'prod-016',
          productName: 'Sabun Cuci Piring 800ml',
          productSku: 'SAB-00016',
          quantity: 2,
          costPrice: 8000,
          sellingPrice: 12000,
          discountAmount: 0,
          subtotal: 24000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 7: 12 days ago, cash with 5% discount
    date = now.subtract(const Duration(days: 12));
    txnId = 'txn-007';
    subtotal = (25000.0 * 2) + (7500.0 * 4); // 50000 + 30000 = 80000
    discountAmount = subtotal * 0.05; // 4000
    total = subtotal - discountAmount; // 76000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercentage: 5,
        taxAmount: 0,
        total: total,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 80000,
        cashChange: 4000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-007-1',
          transactionId: txnId,
          productId: 'prod-007',
          productName: 'Keju Cheddar Slice',
          productSku: 'KEJ-00007',
          quantity: 2,
          costPrice: 18000,
          sellingPrice: 25000,
          discountAmount: 0,
          subtotal: 50000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-007-2',
          transactionId: txnId,
          productId: 'prod-014',
          productName: 'Minuman Soda 390ml',
          productSku: 'MIN-00014',
          quantity: 4,
          costPrice: 5000,
          sellingPrice: 7500,
          discountAmount: 0,
          subtotal: 30000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 8: 14 days ago, cash
    date = now.subtract(const Duration(days: 14));
    txnId = 'txn-008';
    subtotal = (14000.0 * 3) + (18000.0 * 1); // 42000 + 18000 = 60000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 60000,
        cashChange: 0,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-008-1',
          transactionId: txnId,
          productId: 'prod-008',
          productName: 'Sarden Kaleng',
          productSku: 'SAR-00008',
          quantity: 3,
          costPrice: 10000,
          sellingPrice: 14000,
          discountAmount: 0,
          subtotal: 42000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-008-2',
          transactionId: txnId,
          productId: 'prod-002',
          productName: 'Nasi Goreng Frozen',
          productSku: 'NAS-00002',
          quantity: 1,
          costPrice: 12000,
          sellingPrice: 18000,
          discountAmount: 0,
          subtotal: 18000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 9: 15 days ago, DEBT (paid)
    date = now.subtract(const Duration(days: 15));
    final paidDate = now.subtract(const Duration(days: 5));
    txnId = 'txn-009';
    subtotal = (15000.0 * 2) + (1500.0 * 10); // 30000 + 15000 = 45000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        customerName: 'Ibu Rina',
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'debt',
        paymentStatus: 'paid',
        notes: 'Sudah lunas',
        cashierName: 'Admin',
        transactionDate: date,
        debtPaidAt: paidDate,
        createdAt: date,
        updatedAt: paidDate,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-009-1',
          transactionId: txnId,
          productId: 'prod-018',
          productName: 'Tisu Wajah 250 lembar',
          productSku: 'TIS-00018',
          quantity: 2,
          costPrice: 10000,
          sellingPrice: 15000,
          discountAmount: 0,
          subtotal: 30000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-009-2',
          transactionId: txnId,
          productId: 'prod-020',
          productName: 'Sampo Sachet',
          productSku: 'SAM-00020',
          quantity: 10,
          costPrice: 1000,
          sellingPrice: 1500,
          discountAmount: 0,
          subtotal: 15000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 10: 17 days ago, cash
    date = now.subtract(const Duration(days: 17));
    txnId = 'txn-010';
    subtotal = (12000.0 * 2) + (14000.0 * 1); // 24000 + 14000 = 38000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 40000,
        cashChange: 2000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-010-1',
          transactionId: txnId,
          productId: 'prod-019',
          productName: 'Pembalut Wanita',
          productSku: 'PEM-00019',
          quantity: 2,
          costPrice: 8000,
          sellingPrice: 12000,
          discountAmount: 0,
          subtotal: 24000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-010-2',
          transactionId: txnId,
          productId: 'prod-021',
          productName: 'Pasta Gigi 120g',
          productSku: 'PAS-00021',
          quantity: 1,
          costPrice: 10000,
          sellingPrice: 14000,
          discountAmount: 0,
          subtotal: 14000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 11: 18 days ago, cash
    date = now.subtract(const Duration(days: 18));
    txnId = 'txn-011';
    subtotal = (4000.0 * 6) + (3500.0 * 4); // 24000 + 14000 = 38000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 40000,
        cashChange: 2000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-011-1',
          transactionId: txnId,
          productId: 'prod-009',
          productName: 'Air Mineral 600ml',
          productSku: 'AQU-00009',
          quantity: 6,
          costPrice: 2500,
          sellingPrice: 4000,
          discountAmount: 0,
          subtotal: 24000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-011-2',
          transactionId: txnId,
          productId: 'prod-001',
          productName: 'Mie Goreng Instan',
          productSku: 'MIE-00001',
          quantity: 4,
          costPrice: 2500,
          sellingPrice: 3500,
          discountAmount: 0,
          subtotal: 14000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 12: 20 days ago, cash with Rp 10000 discount
    date = now.subtract(const Duration(days: 20));
    txnId = 'txn-012';
    subtotal = (75000.0 * 2); // 150000
    discountAmount = 10000.0;
    total = subtotal - discountAmount; // 140000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercentage: 0,
        taxAmount: 0,
        total: total,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 150000,
        cashChange: 10000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-012-1',
          transactionId: txnId,
          productId: 'prod-006',
          productName: 'Beras Premium 5kg',
          productSku: 'BER-00006',
          quantity: 2,
          costPrice: 60000,
          sellingPrice: 75000,
          discountAmount: 0,
          subtotal: 150000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 13: 22 days ago, DEBT (unpaid)
    date = now.subtract(const Duration(days: 22));
    txnId = 'txn-013';
    subtotal = (30000.0 * 3) + (20000.0 * 1); // 90000 + 20000 = 110000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        customerName: 'Mas Budi',
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'debt',
        paymentStatus: 'debt',
        notes: 'Janji bayar minggu depan',
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-013-1',
          transactionId: txnId,
          productId: 'prod-022',
          productName: 'Rokok Filter',
          productSku: 'ROK-00022',
          quantity: 3,
          costPrice: 25000,
          sellingPrice: 30000,
          discountAmount: 0,
          subtotal: 90000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-013-2',
          transactionId: txnId,
          productId: 'prod-025',
          productName: 'Kantong Plastik 1kg',
          productSku: 'KAN-00025',
          quantity: 1,
          costPrice: 15000,
          sellingPrice: 20000,
          discountAmount: 0,
          subtotal: 20000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 14: 23 days ago, cash
    date = now.subtract(const Duration(days: 23));
    txnId = 'txn-014';
    subtotal = (18000.0 * 2) + (2800.0 * 15); // 36000 + 42000 = 78000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 80000,
        cashChange: 2000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-014-1',
          transactionId: txnId,
          productId: 'prod-013',
          productName: 'Sirup Merah 630ml',
          productSku: 'SIR-00013',
          quantity: 2,
          costPrice: 12000,
          sellingPrice: 18000,
          discountAmount: 0,
          subtotal: 36000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-014-2',
          transactionId: txnId,
          productId: 'prod-004',
          productName: 'Telur Ayam',
          productSku: 'TEL-00004',
          quantity: 15,
          costPrice: 2000,
          sellingPrice: 2800,
          discountAmount: 0,
          subtotal: 42000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 15: 25 days ago, cash
    date = now.subtract(const Duration(days: 25));
    txnId = 'txn-015';
    subtotal = (5000.0 * 5) + (2500.0 * 8); // 25000 + 20000 = 45000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 50000,
        cashChange: 5000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-015-1',
          transactionId: txnId,
          productId: 'prod-023',
          productName: 'Korek Api Gas',
          productSku: 'KOR-00023',
          quantity: 5,
          costPrice: 3000,
          sellingPrice: 5000,
          discountAmount: 0,
          subtotal: 25000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-015-2',
          transactionId: txnId,
          productId: 'prod-010',
          productName: 'Kopi Sachet',
          productSku: 'KOP-00010',
          quantity: 8,
          costPrice: 1500,
          sellingPrice: 2500,
          discountAmount: 0,
          subtotal: 20000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 16: 26 days ago, DEBT (paid)
    date = now.subtract(const Duration(days: 26));
    final paidDate2 = now.subtract(const Duration(days: 10));
    txnId = 'txn-016';
    subtotal = (15000.0 * 3) + (12000.0 * 1); // 45000 + 12000 = 57000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        customerName: 'Mbak Dewi',
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'debt',
        paymentStatus: 'paid',
        notes: 'Lunas',
        cashierName: 'Admin',
        transactionDate: date,
        debtPaidAt: paidDate2,
        createdAt: date,
        updatedAt: paidDate2,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-016-1',
          transactionId: txnId,
          productId: 'prod-005',
          productName: 'Gula Pasir 1kg',
          productSku: 'GUL-00005',
          quantity: 3,
          costPrice: 12000,
          sellingPrice: 15000,
          discountAmount: 0,
          subtotal: 45000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-016-2',
          transactionId: txnId,
          productId: 'prod-016',
          productName: 'Sabun Cuci Piring 800ml',
          productSku: 'SAB-00016',
          quantity: 1,
          costPrice: 8000,
          sellingPrice: 12000,
          discountAmount: 0,
          subtotal: 12000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 17: 27 days ago, cash
    date = now.subtract(const Duration(days: 27));
    txnId = 'txn-017';
    subtotal = (14000.0 * 2) + (5000.0 * 6); // 28000 + 30000 = 58000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 60000,
        cashChange: 2000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-017-1',
          transactionId: txnId,
          productId: 'prod-003',
          productName: 'Roti Tawar',
          productSku: 'ROT-00003',
          quantity: 2,
          costPrice: 10000,
          sellingPrice: 14000,
          discountAmount: 0,
          subtotal: 28000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-017-2',
          transactionId: txnId,
          productId: 'prod-011',
          productName: 'Teh Kotak 250ml',
          productSku: 'TEH-00011',
          quantity: 6,
          costPrice: 3000,
          sellingPrice: 5000,
          discountAmount: 0,
          subtotal: 30000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 18: 28 days ago, cash with 15% discount
    date = now.subtract(const Duration(days: 28));
    txnId = 'txn-018';
    subtotal = (28000.0 * 2) + (19000.0 * 2); // 56000 + 38000 = 94000
    discountAmount = subtotal * 0.15; // 14100
    total = subtotal - discountAmount; // 79900
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountPercentage: 15,
        taxAmount: 0,
        total: total,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 80000,
        cashChange: 100,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-018-1',
          transactionId: txnId,
          productId: 'prod-017',
          productName: 'Deterjen Bubuk 900g',
          productSku: 'DET-00017',
          quantity: 2,
          costPrice: 20000,
          sellingPrice: 28000,
          discountAmount: 0,
          subtotal: 56000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-018-2',
          transactionId: txnId,
          productId: 'prod-012',
          productName: 'Susu UHT 1L',
          productSku: 'SUS-00012',
          quantity: 2,
          costPrice: 15000,
          sellingPrice: 19000,
          discountAmount: 0,
          subtotal: 38000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 19: 29 days ago, cash
    date = now.subtract(const Duration(days: 29));
    txnId = 'txn-019';
    subtotal = (3500.0 * 10) + (4000.0 * 5); // 35000 + 20000 = 55000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 55000,
        cashChange: 0,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-019-1',
          transactionId: txnId,
          productId: 'prod-001',
          productName: 'Mie Goreng Instan',
          productSku: 'MIE-00001',
          quantity: 10,
          costPrice: 2500,
          sellingPrice: 3500,
          discountAmount: 0,
          subtotal: 35000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-019-2',
          transactionId: txnId,
          productId: 'prod-009',
          productName: 'Air Mineral 600ml',
          productSku: 'AQU-00009',
          quantity: 5,
          costPrice: 2500,
          sellingPrice: 4000,
          discountAmount: 0,
          subtotal: 20000,
          createdAt: date,
        ),
      ],
    });

    // Transaction 20: 30 days ago, cash
    date = now.subtract(const Duration(days: 30));
    txnId = 'txn-020';
    subtotal = (2800.0 * 20) + (15000.0 * 1); // 56000 + 15000 = 71000
    transactions.add({
      'transaction': TransactionModel(
        id: txnId,
        transactionNumber: txnNum(date, 1),
        subtotal: subtotal,
        discountAmount: 0,
        discountPercentage: 0,
        taxAmount: 0,
        total: subtotal,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        cashReceived: 75000,
        cashChange: 4000,
        cashierName: 'Admin',
        transactionDate: date,
        createdAt: date,
        updatedAt: date,
      ),
      'items': [
        TransactionItemModel(
          id: 'item-020-1',
          transactionId: txnId,
          productId: 'prod-004',
          productName: 'Telur Ayam',
          productSku: 'TEL-00004',
          quantity: 20,
          costPrice: 2000,
          sellingPrice: 2800,
          discountAmount: 0,
          subtotal: 56000,
          createdAt: date,
        ),
        TransactionItemModel(
          id: 'item-020-2',
          transactionId: txnId,
          productId: 'prod-005',
          productName: 'Gula Pasir 1kg',
          productSku: 'GUL-00005',
          quantity: 1,
          costPrice: 12000,
          sellingPrice: 15000,
          discountAmount: 0,
          subtotal: 15000,
          createdAt: date,
        ),
      ],
    });

    return transactions;
  }
}
