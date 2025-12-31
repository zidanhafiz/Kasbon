import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/product.dart';

/// Data Transfer Object for Product
/// Handles conversion between SQLite Map and Product entity
class ProductModel {
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

  const ProductModel({
    required this.id,
    this.categoryId,
    required this.sku,
    required this.name,
    this.description,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    required this.minStock,
    required this.unit,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ProductModel from SQLite Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[DatabaseConstants.colId] as String,
      categoryId: map[DatabaseConstants.colCategoryId] as String?,
      sku: map[DatabaseConstants.colSku] as String,
      name: map[DatabaseConstants.colName] as String,
      description: map[DatabaseConstants.colDescription] as String?,
      barcode: map[DatabaseConstants.colBarcode] as String?,
      costPrice: (map[DatabaseConstants.colCostPrice] as num).toDouble(),
      sellingPrice: (map[DatabaseConstants.colSellingPrice] as num).toDouble(),
      stock: map[DatabaseConstants.colStock] as int,
      minStock: map[DatabaseConstants.colMinStock] as int,
      unit: map[DatabaseConstants.colUnit] as String,
      imageUrl: map[DatabaseConstants.colImageUrl] as String?,
      isActive: (map[DatabaseConstants.colIsActive] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colCreatedAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colUpdatedAt] as int,
      ),
    );
  }

  /// Convert ProductModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colCategoryId: categoryId,
      DatabaseConstants.colSku: sku,
      DatabaseConstants.colName: name,
      DatabaseConstants.colDescription: description,
      DatabaseConstants.colBarcode: barcode,
      DatabaseConstants.colCostPrice: costPrice,
      DatabaseConstants.colSellingPrice: sellingPrice,
      DatabaseConstants.colStock: stock,
      DatabaseConstants.colMinStock: minStock,
      DatabaseConstants.colUnit: unit,
      DatabaseConstants.colImageUrl: imageUrl,
      DatabaseConstants.colIsActive: isActive ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
      DatabaseConstants.colUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convert ProductModel to Product entity
  Product toEntity() {
    return Product(
      id: id,
      categoryId: categoryId,
      sku: sku,
      name: name,
      description: description,
      barcode: barcode,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      stock: stock,
      minStock: minStock,
      unit: unit,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create ProductModel from Product entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      categoryId: product.categoryId,
      sku: product.sku,
      name: product.name,
      description: product.description,
      barcode: product.barcode,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      stock: product.stock,
      minStock: product.minStock,
      unit: product.unit,
      imageUrl: product.imageUrl,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
