import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/modern/components/data_display/modern_badge.dart';
import '../../../../shared/modern/components/data_display/modern_data_table.dart';
import '../../../../shared/modern/components/data_display/modern_table_column.dart';
import '../../domain/entities/product.dart';
import '../providers/product_selection_provider.dart';

/// Table view widget for product list
/// Displays products in a tabular format with selection support
class ProductTableView extends ConsumerWidget {
  const ProductTableView({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(productSelectionProvider);

    return ModernDataTable<Product>(
      columns: _buildColumns(context, ref),
      items: products,
      idGetter: (product) => product.id,
      selectedIds: selectedIds,
      onSelectionChanged: (id, selected) {
        if (selected) {
          ref.read(productSelectionProvider.notifier).select(id);
        } else {
          ref.read(productSelectionProvider.notifier).deselect(id);
        }
      },
      onSelectAll: (selectAll) {
        if (selectAll) {
          ref
              .read(productSelectionProvider.notifier)
              .selectAll(products.map((p) => p.id).toList());
        } else {
          ref.read(productSelectionProvider.notifier).clearSelection();
        }
      },
      onRowTap: (product) {
        context.push('${AppRoutes.products}/${product.id}');
      },
      rowHeight: 64.0,
      headerHeight: 48.0,
    );
  }

  List<ModernTableColumn<Product>> _buildColumns(
      BuildContext context, WidgetRef ref) {
    return [
      // Image column
      ModernTableColumn<Product>(
        id: 'image',
        header: const SizedBox.shrink(),
        width: 64,
        alignment: Alignment.center,
        cellBuilder: (product) => _buildProductImage(product),
      ),
      // Name column
      ModernTableColumn<Product>(
        id: 'name',
        header: Text(
          'Nama Produk',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        flex: 2,
        minWidth: 150,
        cellBuilder: (product) => Text(
          product.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // SKU column
      ModernTableColumn<Product>(
        id: 'sku',
        header: Text(
          'SKU',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        width: 120,
        cellBuilder: (product) => Text(
          product.sku,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontFamily: AppTextStyles.fontFamilyMono,
          ),
        ),
      ),
      // Price column
      ModernTableColumn<Product>(
        id: 'price',
        header: Text(
          'Harga Jual',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        width: 130,
        alignment: Alignment.centerRight,
        cellBuilder: (product) => Text(
          CurrencyFormatter.format(product.sellingPrice),
          style: AppTextStyles.priceSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      // Stock column
      ModernTableColumn<Product>(
        id: 'stock',
        header: Text(
          'Stok',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        width: 80,
        alignment: Alignment.center,
        cellBuilder: (product) => Text(
          '${product.stock}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: _getStockColor(product),
          ),
        ),
      ),
      // Status column
      ModernTableColumn<Product>(
        id: 'status',
        header: Text(
          'Status',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        width: 100,
        alignment: Alignment.center,
        cellBuilder: (product) => _buildStatusBadge(product),
      ),
      // Actions column
      ModernTableColumn<Product>(
        id: 'actions',
        header: const SizedBox.shrink(),
        width: 56,
        alignment: Alignment.center,
        cellBuilder: (product) => _buildActionButtons(context, product),
      ),
    ];
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.surfaceVariant,
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 24,
        color: AppColors.textTertiary,
      ),
    );
  }

  Color _getStockColor(Product product) {
    if (product.isOutOfStock) {
      return AppColors.error;
    }
    if (product.isLowStock) {
      return AppColors.warning;
    }
    return AppColors.textPrimary;
  }

  Widget _buildStatusBadge(Product product) {
    if (!product.isActive) {
      return const ModernBadge.neutral(label: 'Nonaktif');
    }
    if (product.isOutOfStock) {
      return const ModernBadge.error(label: 'Habis');
    }
    if (product.isLowStock) {
      return const ModernBadge.warning(label: 'Rendah');
    }
    return const ModernBadge.success(label: 'Aktif');
  }

  Widget _buildActionButtons(BuildContext context, Product product) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: const Icon(Icons.edit_outlined),
        iconSize: 20,
        color: AppColors.textSecondary,
        onPressed: () {
          context.push('${AppRoutes.products}/${product.id}/edit');
        },
        tooltip: 'Edit',
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
