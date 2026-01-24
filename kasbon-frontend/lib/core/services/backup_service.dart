import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

import '../../config/database/database_helper.dart';
import '../constants/database_constants.dart';
import '../errors/exceptions.dart';

/// Backup metadata structure
class BackupMetadataDto {
  final String backupVersion;
  final String backupDate;
  final String appVersion;
  final String deviceInfo;
  final Map<String, int> counts;

  const BackupMetadataDto({
    required this.backupVersion,
    required this.backupDate,
    required this.appVersion,
    required this.deviceInfo,
    required this.counts,
  });

  factory BackupMetadataDto.fromJson(Map<String, dynamic> json) {
    return BackupMetadataDto(
      backupVersion: json['backup_version'] as String? ?? '1.0',
      backupDate: json['backup_date'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '',
      deviceInfo: json['device_info'] as String? ?? '',
      counts: Map<String, int>.from(json['counts'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backup_version': backupVersion,
      'backup_date': backupDate,
      'app_version': appVersion,
      'device_info': deviceInfo,
      'counts': counts,
    };
  }
}

/// Data counts for current database state
class DataCountsDto {
  final int products;
  final int transactions;
  final int categories;
  final int transactionItems;

  const DataCountsDto({
    required this.products,
    required this.transactions,
    required this.categories,
    required this.transactionItems,
  });
}

/// Progress callback for restore operations
typedef RestoreProgressCallback = void Function(String step, double progress);

/// Core backup/restore service
class BackupService {
  final DatabaseHelper _databaseHelper;

  static const String _currentBackupVersion = '1.0';

  BackupService(this._databaseHelper);

  /// Exports all data to JSON string with metadata
  Future<String> exportToJson() async {
    try {
      // Get app info
      final packageInfo = await PackageInfo.fromPlatform();

      // Export all tables
      final shopSettings = await _exportTable(DatabaseConstants.tableShopSettings);
      final categories = await _exportTable(DatabaseConstants.tableCategories);
      final products = await _exportTable(DatabaseConstants.tableProducts);
      final transactions = await _exportTable(DatabaseConstants.tableTransactions);
      final transactionItems = await _exportTable(DatabaseConstants.tableTransactionItems);

      // Build backup structure
      final backup = {
        'metadata': {
          'backup_version': _currentBackupVersion,
          'backup_date': DateTime.now().toIso8601String(),
          'app_version': packageInfo.version,
          'device_info': 'Android', // TODO: Get actual device info
          'counts': {
            'shop_settings': shopSettings.length,
            'categories': categories.length,
            'products': products.length,
            'transactions': transactions.length,
            'transaction_items': transactionItems.length,
          },
        },
        'data': {
          'shop_settings': shopSettings,
          'categories': categories,
          'products': products,
          'transactions': transactions,
          'transaction_items': transactionItems,
        },
      };

      return jsonEncode(backup);
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException(
        message: 'Gagal membuat backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Helper to update progress with UI yield
  Future<void> _updateProgress(
    RestoreProgressCallback? onProgress,
    String step,
    double progress,
  ) async {
    onProgress?.call(step, progress);
    // Yield to allow UI to update
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Imports data from JSON string with progress callback
  Future<void> importFromJson(
    String jsonString, {
    RestoreProgressCallback? onProgress,
  }) async {
    try {
      // Parse JSON
      await _updateProgress(onProgress, 'Membaca file backup...', 0.1);
      final Map<String, dynamic> backup = jsonDecode(jsonString);

      // Validate backup structure
      await _updateProgress(onProgress, 'Memvalidasi backup...', 0.2);
      _validateBackup(backup);

      // Extract data
      final data = backup['data'] as Map<String, dynamic>;

      await _updateProgress(onProgress, 'Menghapus data lama...', 0.3);

      // Use transaction for atomicity
      await _databaseHelper.transaction((txn) async {
        // Clear existing data (in reverse dependency order)
        await txn.delete(DatabaseConstants.tableTransactionItems);
        await txn.delete(DatabaseConstants.tableTransactions);
        await txn.delete(DatabaseConstants.tableProducts);
        await txn.delete(DatabaseConstants.tableCategories);
        await txn.delete(DatabaseConstants.tableShopSettings);
      });

      await _updateProgress(onProgress, 'Mengimpor pengaturan toko...', 0.4);

      // Import each table in separate transactions to allow UI updates
      await _databaseHelper.transaction((txn) async {
        await _importTableData(
          txn,
          DatabaseConstants.tableShopSettings,
          data['shop_settings'] as List<dynamic>? ?? [],
        );
      });

      await _updateProgress(onProgress, 'Mengimpor kategori...', 0.5);

      await _databaseHelper.transaction((txn) async {
        await _importTableData(
          txn,
          DatabaseConstants.tableCategories,
          data['categories'] as List<dynamic>? ?? [],
        );
      });

      await _updateProgress(onProgress, 'Mengimpor produk...', 0.6);

      await _databaseHelper.transaction((txn) async {
        await _importTableData(
          txn,
          DatabaseConstants.tableProducts,
          data['products'] as List<dynamic>? ?? [],
        );
      });

      await _updateProgress(onProgress, 'Mengimpor transaksi...', 0.8);

      await _databaseHelper.transaction((txn) async {
        await _importTableData(
          txn,
          DatabaseConstants.tableTransactions,
          data['transactions'] as List<dynamic>? ?? [],
        );
      });

      await _updateProgress(onProgress, 'Mengimpor item transaksi...', 0.9);

      await _databaseHelper.transaction((txn) async {
        await _importTableData(
          txn,
          DatabaseConstants.tableTransactionItems,
          data['transaction_items'] as List<dynamic>? ?? [],
        );
      });

      onProgress?.call('Selesai!', 1.0);
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException(
        message: 'Gagal restore backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Parses backup metadata for preview without importing
  BackupMetadataDto parseBackupInfo(String jsonString) {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);

      if (!backup.containsKey('metadata')) {
        throw const BackupException(
          message: 'File backup tidak valid: metadata tidak ditemukan',
          code: 'INVALID_BACKUP',
        );
      }

      return BackupMetadataDto.fromJson(backup['metadata']);
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException(
        message: 'Gagal membaca info backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets current data counts from database
  Future<DataCountsDto> getDataCounts() async {
    return _getCounts();
  }

  /// Clears all data from the database
  Future<void> clearAllData({RestoreProgressCallback? onProgress}) async {
    try {
      await _updateProgress(onProgress, 'Menghapus item transaksi...', 0.1);
      await _databaseHelper.transaction((txn) async {
        await txn.delete(DatabaseConstants.tableTransactionItems);
      });

      await _updateProgress(onProgress, 'Menghapus transaksi...', 0.3);
      await _databaseHelper.transaction((txn) async {
        await txn.delete(DatabaseConstants.tableTransactions);
      });

      await _updateProgress(onProgress, 'Menghapus produk...', 0.5);
      await _databaseHelper.transaction((txn) async {
        await txn.delete(DatabaseConstants.tableProducts);
      });

      await _updateProgress(onProgress, 'Menghapus kategori...', 0.7);
      await _databaseHelper.transaction((txn) async {
        await txn.delete(DatabaseConstants.tableCategories);
      });

      await _updateProgress(onProgress, 'Menghapus pengaturan...', 0.9);
      await _databaseHelper.transaction((txn) async {
        await txn.delete(DatabaseConstants.tableShopSettings);
      });

      onProgress?.call('Selesai!', 1.0);
    } catch (e) {
      throw BackupException(
        message: 'Gagal menghapus data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Validates backup structure and version
  void _validateBackup(Map<String, dynamic> backup) {
    // Check required sections
    if (!backup.containsKey('metadata')) {
      throw const BackupException(
        message: 'File backup tidak valid: metadata tidak ditemukan',
        code: 'INVALID_BACKUP',
      );
    }

    if (!backup.containsKey('data')) {
      throw const BackupException(
        message: 'File backup tidak valid: data tidak ditemukan',
        code: 'INVALID_BACKUP',
      );
    }

    // Check backup version
    final metadata = backup['metadata'] as Map<String, dynamic>;
    final version = metadata['backup_version'] as String?;

    if (version == null || version.isEmpty) {
      throw const BackupException(
        message: 'Versi backup tidak diketahui',
        code: 'UNKNOWN_VERSION',
      );
    }

    // For now, only support version 1.0
    if (version != _currentBackupVersion) {
      throw BackupException(
        message: 'Versi backup tidak didukung: $version',
        code: 'UNSUPPORTED_VERSION',
      );
    }
  }

  /// Exports a single table to list of maps
  Future<List<Map<String, dynamic>>> _exportTable(String tableName) async {
    return await _databaseHelper.query(tableName);
  }

  /// Imports data into a table within a transaction
  Future<void> _importTableData(
    dynamic txn,
    String tableName,
    List<dynamic> data,
  ) async {
    for (final row in data) {
      await txn.insert(
        tableName,
        Map<String, dynamic>.from(row as Map),
      );
    }
  }

  /// Gets counts for all tables
  Future<DataCountsDto> _getCounts() async {
    final products = await _databaseHelper.count(DatabaseConstants.tableProducts);
    final transactions = await _databaseHelper.count(DatabaseConstants.tableTransactions);
    final categories = await _databaseHelper.count(DatabaseConstants.tableCategories);
    final transactionItems = await _databaseHelper.count(DatabaseConstants.tableTransactionItems);

    return DataCountsDto(
      products: products,
      transactions: transactions,
      categories: categories,
      transactionItems: transactionItems,
    );
  }
}
