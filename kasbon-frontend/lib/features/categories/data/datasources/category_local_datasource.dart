import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

/// Abstract interface for Category local data source
abstract class CategoryLocalDataSource {
  /// Get all categories ordered by sort_order
  Future<List<CategoryModel>> getAllCategories();

  /// Get a single category by ID
  Future<CategoryModel> getCategoryById(String id);
}

/// Implementation of CategoryLocalDataSource using SQLite
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CategoryLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableCategories,
        orderBy: '${DatabaseConstants.colSortOrder} ASC',
      );
      return results.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil daftar kategori',
        originalError: e,
      );
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final result = await _databaseHelper.getById(
        DatabaseConstants.tableCategories,
        id,
      );
      if (result == null) {
        throw const NotFoundException(message: 'Kategori tidak ditemukan');
      }
      return CategoryModel.fromMap(result);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil kategori',
        originalError: e,
      );
    }
  }
}
