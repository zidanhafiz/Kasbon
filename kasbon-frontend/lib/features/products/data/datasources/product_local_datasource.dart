import '../../../../config/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

/// Abstract interface for Product local data source
abstract class ProductLocalDataSource {
  /// Get all active products
  Future<List<ProductModel>> getAllProducts();

  /// Get a single product by ID
  Future<ProductModel> getProductById(String id);

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query);

  /// Create a new product
  Future<ProductModel> createProduct(ProductModel product);

  /// Update an existing product
  Future<ProductModel> updateProduct(ProductModel product);

  /// Soft delete a product (set is_active = false)
  Future<void> deleteProduct(String id);

  /// Get all products with low stock
  Future<List<ProductModel>> getLowStockProducts();

  /// Get products by category ID
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
}

/// Implementation of ProductLocalDataSource using SQLite
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProductLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableProducts,
        where: '${DatabaseConstants.colIsActive} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseConstants.colName} ASC',
      );
      return results.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil daftar produk',
        originalError: e,
      );
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final result = await _databaseHelper.getById(
        DatabaseConstants.tableProducts,
        id,
      );
      if (result == null) {
        throw const NotFoundException(message: 'Produk tidak ditemukan');
      }
      return ProductModel.fromMap(result);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil produk',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableProducts,
        where:
            '${DatabaseConstants.colName} LIKE ? AND ${DatabaseConstants.colIsActive} = ?',
        whereArgs: ['%$query%', 1],
        orderBy: '${DatabaseConstants.colName} ASC',
      );
      return results.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mencari produk',
        originalError: e,
      );
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      await _databaseHelper.insert(
        DatabaseConstants.tableProducts,
        product.toMap(),
      );
      return product;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menambahkan produk',
        originalError: e,
      );
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        DatabaseConstants.tableProducts,
        product.toMap(),
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [product.id],
      );
      if (rowsAffected == 0) {
        throw const NotFoundException(message: 'Produk tidak ditemukan');
      }
      return product;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengupdate produk',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        DatabaseConstants.tableProducts,
        {
          DatabaseConstants.colIsActive: 0,
          DatabaseConstants.colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
      if (rowsAffected == 0) {
        throw const NotFoundException(message: 'Produk tidak ditemukan');
      }
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menghapus produk',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableProducts,
        where:
            '${DatabaseConstants.colStock} <= ${DatabaseConstants.colMinStock} AND ${DatabaseConstants.colIsActive} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseConstants.colStock} ASC',
      );
      return results.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil produk stok rendah',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final results = await _databaseHelper.query(
        DatabaseConstants.tableProducts,
        where:
            '${DatabaseConstants.colCategoryId} = ? AND ${DatabaseConstants.colIsActive} = ?',
        whereArgs: [categoryId, 1],
        orderBy: '${DatabaseConstants.colName} ASC',
      );
      return results.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil produk berdasarkan kategori',
        originalError: e,
      );
    }
  }
}
