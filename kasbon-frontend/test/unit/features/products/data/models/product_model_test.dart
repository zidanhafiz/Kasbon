import 'package:flutter_test/flutter_test.dart';
import 'package:kasbon_pos/features/products/data/models/product_model.dart';
import 'package:kasbon_pos/features/products/domain/entities/product.dart';
import 'package:kasbon_pos/core/constants/database_constants.dart';

import '../../../../../fixtures/mock_data.dart';

void main() {
  group('ProductModel', () {
    late DateTime fixedDate;
    late Map<String, dynamic> validMap;

    setUp(() {
      fixedDate = DateTime(2026, 1, 26, 14, 30);
      validMap = {
        DatabaseConstants.colId: 'prod-1',
        DatabaseConstants.colCategoryId: 'cat-1',
        DatabaseConstants.colSku: 'SKU-12345',
        DatabaseConstants.colName: 'Test Product',
        DatabaseConstants.colDescription: 'Test description',
        DatabaseConstants.colBarcode: '1234567890123',
        DatabaseConstants.colCostPrice: 10000.0,
        DatabaseConstants.colSellingPrice: 15000.0,
        DatabaseConstants.colStock: 100,
        DatabaseConstants.colMinStock: 5,
        DatabaseConstants.colUnit: 'pcs',
        DatabaseConstants.colImageUrl: 'https://example.com/image.jpg',
        DatabaseConstants.colIsActive: 1,
        DatabaseConstants.colCreatedAt: fixedDate.millisecondsSinceEpoch,
        DatabaseConstants.colUpdatedAt: fixedDate.millisecondsSinceEpoch,
      };
    });

    group('fromMap', () {
      test('creates model from valid map', () {
        final model = ProductModel.fromMap(validMap);

        expect(model.id, 'prod-1');
        expect(model.categoryId, 'cat-1');
        expect(model.sku, 'SKU-12345');
        expect(model.name, 'Test Product');
        expect(model.description, 'Test description');
        expect(model.barcode, '1234567890123');
        expect(model.costPrice, 10000.0);
        expect(model.sellingPrice, 15000.0);
        expect(model.stock, 100);
        expect(model.minStock, 5);
        expect(model.unit, 'pcs');
        expect(model.imageUrl, 'https://example.com/image.jpg');
        expect(model.isActive, true);
        expect(model.createdAt, fixedDate);
        expect(model.updatedAt, fixedDate);
      });

      test('handles null optional fields', () {
        final mapWithNulls = {
          ...validMap,
          DatabaseConstants.colCategoryId: null,
          DatabaseConstants.colDescription: null,
          DatabaseConstants.colBarcode: null,
          DatabaseConstants.colImageUrl: null,
        };

        final model = ProductModel.fromMap(mapWithNulls);

        expect(model.categoryId, null);
        expect(model.description, null);
        expect(model.barcode, null);
        expect(model.imageUrl, null);
      });

      test('converts isActive from int (0) to bool (false)', () {
        final mapInactive = {
          ...validMap,
          DatabaseConstants.colIsActive: 0,
        };

        final model = ProductModel.fromMap(mapInactive);
        expect(model.isActive, false);
      });

      test('converts integer price to double', () {
        final mapIntPrices = {
          ...validMap,
          DatabaseConstants.colCostPrice: 10000,
          DatabaseConstants.colSellingPrice: 15000,
        };

        final model = ProductModel.fromMap(mapIntPrices);
        expect(model.costPrice, 10000.0);
        expect(model.sellingPrice, 15000.0);
      });
    });

    group('toMap', () {
      test('converts model to map with correct keys', () {
        final model = ProductModel(
          id: 'prod-1',
          categoryId: 'cat-1',
          sku: 'SKU-12345',
          name: 'Test Product',
          description: 'Test description',
          barcode: '1234567890123',
          costPrice: 10000.0,
          sellingPrice: 15000.0,
          stock: 100,
          minStock: 5,
          unit: 'pcs',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final map = model.toMap();

        expect(map[DatabaseConstants.colId], 'prod-1');
        expect(map[DatabaseConstants.colCategoryId], 'cat-1');
        expect(map[DatabaseConstants.colSku], 'SKU-12345');
        expect(map[DatabaseConstants.colName], 'Test Product');
        expect(map[DatabaseConstants.colDescription], 'Test description');
        expect(map[DatabaseConstants.colBarcode], '1234567890123');
        expect(map[DatabaseConstants.colCostPrice], 10000.0);
        expect(map[DatabaseConstants.colSellingPrice], 15000.0);
        expect(map[DatabaseConstants.colStock], 100);
        expect(map[DatabaseConstants.colMinStock], 5);
        expect(map[DatabaseConstants.colUnit], 'pcs');
        expect(map[DatabaseConstants.colImageUrl], 'https://example.com/image.jpg');
        expect(map[DatabaseConstants.colIsActive], 1);
        expect(map[DatabaseConstants.colCreatedAt], fixedDate.millisecondsSinceEpoch);
        expect(map[DatabaseConstants.colUpdatedAt], fixedDate.millisecondsSinceEpoch);
      });

      test('converts isActive false to 0', () {
        final model = ProductModel(
          id: 'prod-1',
          sku: 'SKU-12345',
          name: 'Test Product',
          costPrice: 10000.0,
          sellingPrice: 15000.0,
          stock: 100,
          minStock: 5,
          unit: 'pcs',
          isActive: false,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final map = model.toMap();
        expect(map[DatabaseConstants.colIsActive], 0);
      });

      test('includes null values for optional fields', () {
        final model = ProductModel(
          id: 'prod-1',
          categoryId: null,
          sku: 'SKU-12345',
          name: 'Test Product',
          description: null,
          barcode: null,
          costPrice: 10000.0,
          sellingPrice: 15000.0,
          stock: 100,
          minStock: 5,
          unit: 'pcs',
          imageUrl: null,
          isActive: true,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final map = model.toMap();
        expect(map.containsKey(DatabaseConstants.colCategoryId), true);
        expect(map[DatabaseConstants.colCategoryId], null);
        expect(map[DatabaseConstants.colDescription], null);
        expect(map[DatabaseConstants.colBarcode], null);
        expect(map[DatabaseConstants.colImageUrl], null);
      });
    });

    group('toEntity', () {
      test('converts model to Product entity', () {
        final model = ProductModel.fromMap(validMap);
        final entity = model.toEntity();

        expect(entity, isA<Product>());
        expect(entity.id, model.id);
        expect(entity.categoryId, model.categoryId);
        expect(entity.sku, model.sku);
        expect(entity.name, model.name);
        expect(entity.description, model.description);
        expect(entity.barcode, model.barcode);
        expect(entity.costPrice, model.costPrice);
        expect(entity.sellingPrice, model.sellingPrice);
        expect(entity.stock, model.stock);
        expect(entity.minStock, model.minStock);
        expect(entity.unit, model.unit);
        expect(entity.imageUrl, model.imageUrl);
        expect(entity.isActive, model.isActive);
        expect(entity.createdAt, model.createdAt);
        expect(entity.updatedAt, model.updatedAt);
      });

      test('preserves all values in conversion', () {
        final model = ProductModel(
          id: 'prod-special',
          categoryId: 'cat-special',
          sku: 'SKU-SPECIAL',
          name: 'Special Product',
          description: 'Special description',
          barcode: '9999999999999',
          costPrice: 25000.0,
          sellingPrice: 35000.0,
          stock: 50,
          minStock: 10,
          unit: 'kg',
          imageUrl: 'https://special.com/image.jpg',
          isActive: false,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final entity = model.toEntity();

        expect(entity.id, 'prod-special');
        expect(entity.unit, 'kg');
        expect(entity.isActive, false);
      });
    });

    group('fromEntity', () {
      test('creates model from Product entity', () {
        final entity = MockData.createProduct(
          id: 'prod-1',
          categoryId: 'cat-1',
          sku: 'SKU-12345',
          name: 'Test Product',
          description: 'Test description',
          barcode: '1234567890123',
          costPrice: 10000,
          sellingPrice: 15000,
          stock: 100,
          minStock: 5,
          unit: 'pcs',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final model = ProductModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.categoryId, entity.categoryId);
        expect(model.sku, entity.sku);
        expect(model.name, entity.name);
        expect(model.description, entity.description);
        expect(model.barcode, entity.barcode);
        expect(model.costPrice, entity.costPrice);
        expect(model.sellingPrice, entity.sellingPrice);
        expect(model.stock, entity.stock);
        expect(model.minStock, entity.minStock);
        expect(model.unit, entity.unit);
        expect(model.imageUrl, entity.imageUrl);
        expect(model.isActive, entity.isActive);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);
      });
    });

    group('round-trip conversion', () {
      test('entity -> model -> entity preserves all values', () {
        final originalEntity = MockData.createProduct(
          id: 'prod-roundtrip',
          categoryId: 'cat-roundtrip',
          sku: 'SKU-ROUNDTRIP',
          name: 'Roundtrip Product',
          description: 'Roundtrip description',
          barcode: '1111111111111',
          costPrice: 20000,
          sellingPrice: 30000,
          stock: 75,
          minStock: 8,
          unit: 'box',
          imageUrl: 'https://roundtrip.com/image.jpg',
          isActive: true,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );

        final model = ProductModel.fromEntity(originalEntity);
        final roundtripEntity = model.toEntity();

        expect(roundtripEntity.id, originalEntity.id);
        expect(roundtripEntity.categoryId, originalEntity.categoryId);
        expect(roundtripEntity.sku, originalEntity.sku);
        expect(roundtripEntity.name, originalEntity.name);
        expect(roundtripEntity.description, originalEntity.description);
        expect(roundtripEntity.barcode, originalEntity.barcode);
        expect(roundtripEntity.costPrice, originalEntity.costPrice);
        expect(roundtripEntity.sellingPrice, originalEntity.sellingPrice);
        expect(roundtripEntity.stock, originalEntity.stock);
        expect(roundtripEntity.minStock, originalEntity.minStock);
        expect(roundtripEntity.unit, originalEntity.unit);
        expect(roundtripEntity.imageUrl, originalEntity.imageUrl);
        expect(roundtripEntity.isActive, originalEntity.isActive);
        expect(roundtripEntity.createdAt, originalEntity.createdAt);
        expect(roundtripEntity.updatedAt, originalEntity.updatedAt);
      });

      test('map -> model -> map preserves all values', () {
        final originalMap = Map<String, dynamic>.from(validMap);

        final model = ProductModel.fromMap(originalMap);
        final roundtripMap = model.toMap();

        expect(roundtripMap[DatabaseConstants.colId], originalMap[DatabaseConstants.colId]);
        expect(roundtripMap[DatabaseConstants.colCategoryId], originalMap[DatabaseConstants.colCategoryId]);
        expect(roundtripMap[DatabaseConstants.colSku], originalMap[DatabaseConstants.colSku]);
        expect(roundtripMap[DatabaseConstants.colName], originalMap[DatabaseConstants.colName]);
        expect(roundtripMap[DatabaseConstants.colCostPrice], originalMap[DatabaseConstants.colCostPrice]);
        expect(roundtripMap[DatabaseConstants.colSellingPrice], originalMap[DatabaseConstants.colSellingPrice]);
        expect(roundtripMap[DatabaseConstants.colStock], originalMap[DatabaseConstants.colStock]);
        expect(roundtripMap[DatabaseConstants.colIsActive], originalMap[DatabaseConstants.colIsActive]);
      });
    });
  });
}
