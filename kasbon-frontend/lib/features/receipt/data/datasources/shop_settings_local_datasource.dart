import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/shop_settings_model.dart';

/// Abstract interface for ShopSettings local data source
abstract class ShopSettingsLocalDataSource {
  /// Get the shop settings (single row with id=1)
  Future<ShopSettingsModel> getShopSettings();

  /// Update shop settings
  Future<void> updateShopSettings(ShopSettingsModel settings);
}

/// Implementation of ShopSettingsLocalDataSource using SQLite
class ShopSettingsLocalDataSourceImpl implements ShopSettingsLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ShopSettingsLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<ShopSettingsModel> getShopSettings() async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableShopSettings,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (results.isEmpty) {
        throw const NotFoundException(
          message: 'Pengaturan toko tidak ditemukan',
        );
      }

      return ShopSettingsModel.fromMap(results.first);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil pengaturan toko',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateShopSettings(ShopSettingsModel settings) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final map = settings.toMap();
      map[DatabaseConstants.colUpdatedAt] = now;

      await _databaseHelper.update(
        DatabaseConstants.tableShopSettings,
        map,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal memperbarui pengaturan toko',
        originalError: e,
      );
    }
  }
}
