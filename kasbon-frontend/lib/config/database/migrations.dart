import 'package:sqflite/sqflite.dart';

import '../../core/constants/database_constants.dart';
import 'database_schema.dart';

/// Database migrations for KASBON POS
class DatabaseMigrations {
  DatabaseMigrations._();

  /// Run initial migration (version 1)
  /// Creates all tables, indexes, and inserts default data
  static Future<void> migrateV1(Database db) async {
    // Create all tables
    for (final statement in DatabaseSchema.createTableStatements) {
      await db.execute(statement);
    }

    // Create all indexes
    for (final statement in DatabaseSchema.createIndexStatements) {
      await db.execute(statement);
    }

    // Insert default data
    await _insertDefaultData(db);
  }

  /// Insert default shop settings and categories
  static Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert default shop settings (single row with id = 1)
    await db.insert(
      DatabaseConstants.tableShopSettings,
      {
        DatabaseConstants.colId: 1,
        DatabaseConstants.colName: 'Toko Saya',
        DatabaseConstants.colCurrency: 'IDR',
        DatabaseConstants.colLowStockThreshold: 5,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Insert default categories
    final defaultCategories = [
      {
        DatabaseConstants.colId: DatabaseConstants.categoryIdMakanan,
        DatabaseConstants.colName: 'Makanan',
        DatabaseConstants.colColor: '#FF6B35',
        DatabaseConstants.colIcon: 'restaurant',
        DatabaseConstants.colSortOrder: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: DatabaseConstants.categoryIdMinuman,
        DatabaseConstants.colName: 'Minuman',
        DatabaseConstants.colColor: '#1E88E5',
        DatabaseConstants.colIcon: 'local_cafe',
        DatabaseConstants.colSortOrder: 2,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: DatabaseConstants.categoryIdKebutuhanRumah,
        DatabaseConstants.colName: 'Kebutuhan Rumah',
        DatabaseConstants.colColor: '#43A047',
        DatabaseConstants.colIcon: 'home',
        DatabaseConstants.colSortOrder: 3,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: DatabaseConstants.categoryIdLainnya,
        DatabaseConstants.colName: 'Lainnya',
        DatabaseConstants.colColor: '#757575',
        DatabaseConstants.colIcon: 'category',
        DatabaseConstants.colSortOrder: 4,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(
        DatabaseConstants.tableCategories,
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Run migrations from oldVersion to newVersion
  static Future<void> runMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations will be added here
    // Example:
    // if (oldVersion < 2) {
    //   await migrateV2(db);
    // }
    // if (oldVersion < 3) {
    //   await migrateV3(db);
    // }
  }
}
