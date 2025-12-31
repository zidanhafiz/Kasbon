import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/modern/modern.dart';
import '../../domain/entities/product_filter.dart';
import '../providers/product_selection_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_bulk_actions_bar.dart';
import '../widgets/product_filter_card.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/product_table_view.dart';

/// Screen displaying list of all products with search and filter functionality
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(productViewModeProvider);
    final hasSelection = ref.watch(productSelectionProvider).isNotEmpty;

    // On mobile, FAB needs to be above bottom nav; on tablet, standard position
    final fabBottomOffset = context.isMobile
        ? AppDimensions.bottomNavHeight + AppDimensions.spacing16
        : AppDimensions.spacing16;

    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: 'Daftar Produk',
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
        onProfileTap: () {
          // TODO: Navigate to profile
        },
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
            },
            child: _buildContent(context, ref, viewMode, hasSelection),
          ),
          // FAB positioned based on device type
          Positioned(
            right: AppDimensions.spacing16,
            bottom: fabBottomOffset,
            child: FloatingActionButton(
              onPressed: () => context.push(AppRoutes.productAdd),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ProductViewMode viewMode, bool hasSelection) {
    if (viewMode == ProductViewMode.table) {
      return _buildTableContent(context, ref, hasSelection);
    }
    return _buildGridContent(context, ref, hasSelection);
  }

  Widget _buildGridContent(BuildContext context, WidgetRef ref, bool hasSelection) {
    final padding = context.horizontalPadding;

    return CustomScrollView(
      slivers: [
        // Filter Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: const ProductFilterCard(),
          ),
        ),
        // Bulk Actions Bar (shown when items are selected)
        if (hasSelection)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: const ProductBulkActionsBar(),
            ),
          ),
        // Product Grid with bottom padding for FAB clearance
        _buildProductGrid(context, ref, hasSelection),
      ],
    );
  }

  Widget _buildTableContent(BuildContext context, WidgetRef ref, bool hasSelection) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final padding = context.horizontalPadding;

    return Column(
      children: [
        // Filter Card
        Padding(
          padding: EdgeInsets.all(padding),
          child: const ProductFilterCard(),
        ),
        // Bulk Actions Bar (shown when items are selected)
        if (hasSelection)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: const ProductBulkActionsBar(),
          ),
        // Table View with bottom padding for FAB clearance
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                final searchQuery = ref.watch(searchQueryProvider);
                if (searchQuery.isNotEmpty ||
                    ref.watch(categoryFilterProvider) != null ||
                    ref.watch(stockFilterProvider) != StockFilter.all) {
                  return ModernEmptyState.search(
                    message: 'Tidak ada produk yang cocok dengan filter',
                  );
                }
                return ModernEmptyState.list(
                  title: 'Belum Ada Produk',
                  message: 'Tambahkan produk pertama Anda',
                  actionLabel: 'Tambah Produk',
                  onAction: () => context.push(AppRoutes.productAdd),
                );
              }
              return Padding(
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  bottom: 100, // FAB clearance
                ),
                child: ProductTableView(products: products),
              );
            },
            loading: () => const Center(child: ModernLoading()),
            error: (error, _) => ModernErrorState.generic(
              message: 'Gagal memuat produk. ${error.toString()}',
              onRetry: () => ref.invalidate(productsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref, bool hasSelection) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedIds = ref.watch(productSelectionProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          // Check if it's a search/filter result or truly empty
          if (searchQuery.isNotEmpty ||
              ref.watch(categoryFilterProvider) != null ||
              ref.watch(stockFilterProvider) != StockFilter.all) {
            return SliverFillRemaining(
              child: ModernEmptyState.search(
                message: 'Tidak ada produk yang cocok dengan filter',
              ),
            );
          }

          return SliverFillRemaining(
            child: ModernEmptyState.list(
              title: 'Belum Ada Produk',
              message: 'Tambahkan produk pertama Anda',
              actionLabel: 'Tambah Produk',
              onAction: () => context.push(AppRoutes.productAdd),
            ),
          );
        }

        // Calculate responsive grid columns
        final columns = _getGridColumns(context);
        final padding = context.horizontalPadding;

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, 100), // 100dp bottom for FAB clearance
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppDimensions.spacing12,
              crossAxisSpacing: AppDimensions.spacing12,
              childAspectRatio: 0.7, // Taller cards for product info
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];
                final isSelected = selectedIds.contains(product.id);

                return ProductGridItem(
                  product: product,
                  isSelectionMode: hasSelection,
                  isSelected: isSelected,
                  onTap: hasSelection
                      ? () => _toggleSelection(ref, product.id, isSelected)
                      : () => context.push('/products/${product.id}'),
                  onLongPress: () => _enterSelectionMode(ref, product.id),
                );
              },
              childCount: products.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: ModernLoading()),
      ),
      error: (error, _) => SliverFillRemaining(
        child: ModernErrorState.generic(
          message: 'Gagal memuat produk. ${error.toString()}',
          onRetry: () => ref.invalidate(productsProvider),
        ),
      ),
    );
  }

  /// Toggle selection for a product
  void _toggleSelection(WidgetRef ref, String productId, bool isCurrentlySelected) {
    if (isCurrentlySelected) {
      ref.read(productSelectionProvider.notifier).deselect(productId);
    } else {
      ref.read(productSelectionProvider.notifier).select(productId);
    }
  }

  /// Enter selection mode by selecting a product
  void _enterSelectionMode(WidgetRef ref, String productId) {
    ref.read(productSelectionProvider.notifier).select(productId);
  }

  /// Get responsive grid columns based on screen width
  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return 2; // Small mobile
    } else if (width < 900) {
      return 2; // Large mobile
    } else if (width < 1100) {
      return 3; // Tablet
    } else if (width < 1300) {
      return 4; // Small desktop
    } else {
      return 5; // Large desktop
    }
  }
}
