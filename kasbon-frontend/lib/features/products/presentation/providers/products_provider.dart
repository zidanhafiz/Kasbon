import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/update_product.dart';

/// Provider for all products
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = getIt<GetAllProducts>();
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

/// Provider for a single product by ID
final productProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final useCase = getIt<GetProduct>();
  final result = await useCase(GetProductParams(id: id));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});

/// Provider for search query state
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for category filter state (null = all categories)
final categoryFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Provider for stock filter state
final stockFilterProvider =
    StateProvider.autoDispose<StockFilter>((ref) => StockFilter.all);

/// Provider for sort option state
final sortOptionProvider = StateProvider.autoDispose<ProductSortOption>(
    (ref) => ProductSortOption.nameAsc);

/// Provider for search results
final productSearchProvider =
    FutureProvider.autoDispose.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final useCase = getIt<SearchProducts>();
  final result = await useCase(SearchProductsParams(query: query));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

/// Provider for filtered products (combines search, category, stock, and sort filters)
final filteredProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final categoryId = ref.watch(categoryFilterProvider);
  final stockFilter = ref.watch(stockFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);

  // Get base product list (from search or all products)
  List<Product> products;
  if (query.isNotEmpty) {
    products = ref.watch(productSearchProvider(query)).maybeWhen(
          data: (p) => p,
          orElse: () => [],
        );
  } else {
    products = ref.watch(productsProvider).maybeWhen(
          data: (p) => p,
          orElse: () => [],
        );
  }

  // Apply category filter
  if (categoryId != null) {
    products = products.where((p) => p.categoryId == categoryId).toList();
  }

  // Apply stock filter
  switch (stockFilter) {
    case StockFilter.available:
      products = products.where((p) => p.stock > p.minStock).toList();
      break;
    case StockFilter.lowStock:
      products = products.where((p) => p.isLowStock).toList();
      break;
    case StockFilter.outOfStock:
      products = products.where((p) => p.isOutOfStock).toList();
      break;
    case StockFilter.all:
      // No filter
      break;
  }

  // Apply sorting
  switch (sortOption) {
    case ProductSortOption.nameAsc:
      products.sort((a, b) => a.name.compareTo(b.name));
      break;
    case ProductSortOption.nameDesc:
      products.sort((a, b) => b.name.compareTo(a.name));
      break;
    case ProductSortOption.priceAsc:
      products.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
      break;
    case ProductSortOption.priceDesc:
      products.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
      break;
    case ProductSortOption.stockAsc:
      products.sort((a, b) => a.stock.compareTo(b.stock));
      break;
    case ProductSortOption.stockDesc:
      products.sort((a, b) => b.stock.compareTo(a.stock));
      break;
  }

  return products;
});

/// Form state for creating/updating products
class ProductFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ProductFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProductFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for product form operations
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier() : super(const ProductFormState());

  Future<void> createProduct(CreateProductParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = getIt<CreateProduct>();
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (product) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = getIt<UpdateProduct>();
    final result = await useCase(product);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (updatedProduct) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = getIt<DeleteProduct>();
    final result = await useCase(DeleteProductParams(id: id));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  void resetState() {
    state = const ProductFormState();
  }
}

/// Provider for product form state
final productFormProvider =
    StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
  (ref) => ProductFormNotifier(),
);
