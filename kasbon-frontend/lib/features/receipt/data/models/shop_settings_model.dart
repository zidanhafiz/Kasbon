import '../../domain/entities/shop_settings.dart';

/// Data model for ShopSettings with SQLite serialization
///
/// Handles conversion between SQLite map format and entity.
class ShopSettingsModel extends ShopSettings {
  const ShopSettingsModel({
    required super.id,
    required super.name,
    super.address,
    super.phone,
    super.logoUrl,
    super.receiptHeader,
    super.receiptFooter,
    super.currency,
    super.lowStockThreshold,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from SQLite map
  factory ShopSettingsModel.fromMap(Map<String, dynamic> map) {
    return ShopSettingsModel(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      logoUrl: map['logo_url'] as String?,
      receiptHeader: map['receipt_header'] as String?,
      receiptFooter: map['receipt_footer'] as String?,
      currency: map['currency'] as String? ?? 'IDR',
      lowStockThreshold: map['low_stock_threshold'] as int? ?? 5,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'logo_url': logoUrl,
      'receipt_header': receiptHeader,
      'receipt_footer': receiptFooter,
      'currency': currency,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create from entity
  factory ShopSettingsModel.fromEntity(ShopSettings entity) {
    return ShopSettingsModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      logoUrl: entity.logoUrl,
      receiptHeader: entity.receiptHeader,
      receiptFooter: entity.receiptFooter,
      currency: entity.currency,
      lowStockThreshold: entity.lowStockThreshold,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  ShopSettings toEntity() {
    return ShopSettings(
      id: id,
      name: name,
      address: address,
      phone: phone,
      logoUrl: logoUrl,
      receiptHeader: receiptHeader,
      receiptFooter: receiptFooter,
      currency: currency,
      lowStockThreshold: lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
