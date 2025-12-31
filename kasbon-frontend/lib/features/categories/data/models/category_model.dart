import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/category.dart';

/// Data Transfer Object for Category
/// Handles conversion between SQLite Map and Category entity
class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create CategoryModel from SQLite Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseConstants.colId] as String,
      name: map[DatabaseConstants.colName] as String,
      color: map[DatabaseConstants.colColor] as String? ?? '#FF6B35',
      icon: map[DatabaseConstants.colIcon] as String? ?? 'category',
      sortOrder: map[DatabaseConstants.colSortOrder] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colCreatedAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseConstants.colUpdatedAt] as int,
      ),
    );
  }

  /// Convert CategoryModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colColor: color,
      DatabaseConstants.colIcon: icon,
      DatabaseConstants.colSortOrder: sortOrder,
      DatabaseConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
      DatabaseConstants.colUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Convert CategoryModel to Category entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      color: color,
      icon: icon,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create CategoryModel from Category entity
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      color: category.color,
      icon: category.icon,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
