import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../shared/modern/components/card/modern_card.dart';
import '../../../../shared/modern/components/input/modern_search_field.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../domain/entities/product_filter.dart';
import '../providers/product_selection_provider.dart';
import '../providers/products_provider.dart';

/// Filter card widget for product list
/// Contains search field, category filter chips, stock filter chips, and sort dropdown
class ProductFilterCard extends ConsumerStatefulWidget {
  const ProductFilterCard({super.key});

  @override
  ConsumerState<ProductFilterCard> createState() => _ProductFilterCardState();
}

class _ProductFilterCardState extends ConsumerState<ProductFilterCard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(categoryFilterProvider);
    final selectedStockFilter = ref.watch(stockFilterProvider);
    final selectedSortOption = ref.watch(sortOptionProvider);
    final viewMode = ref.watch(productViewModeProvider);

    return ModernCard.outlined(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field, View Toggle, and Sort Dropdown in one row
          Row(
            children: [
              // Search Field
              Expanded(
                child: ModernSearchField(
                  controller: _searchController,
                  hint: 'Cari produk...',
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  onClear: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              // View Toggle
              _buildViewToggle(viewMode),
              const SizedBox(width: AppDimensions.spacing12),
              // Sort Dropdown
              SizedBox(
                width: 150,
                child: _buildSortDropdown(selectedSortOption),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Category Filter
          Text(
            'Kategori',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          SizedBox(
            height: 36,
            child: categoriesAsync.when(
              data: (categories) => _buildCategoryChips(
                categories,
                selectedCategoryId,
              ),
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => _buildCategoryChips([], selectedCategoryId),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Stock Filter
          Text(
            'Stok',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          SizedBox(
            height: 36,
            child: _buildStockFilterChips(selectedStockFilter),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(
    List<Category> categories,
    String? selectedCategoryId,
  ) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // "Semua" chip
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: ChoiceChip(
            label: const Text('Semua'),
            selected: selectedCategoryId == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(categoryFilterProvider.notifier).state = null;
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color:
                  selectedCategoryId == null ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.surfaceVariant,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
          ),
        ),
        // Category chips from database
        ...categories.map((category) {
          final isSelected = selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacing8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(categoryFilterProvider.notifier).state =
                    selected ? category.id : null;
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: AppColors.surfaceVariant,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStockFilterChips(StockFilter selectedFilter) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: StockFilter.values.map((filter) {
        final isSelected = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacing8),
          child: ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(stockFilterProvider.notifier).state = filter;
              }
            },
            selectedColor: _getStockFilterColor(filter),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.surfaceVariant,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
          ),
        );
      }).toList(),
    );
  }

  Color _getStockFilterColor(StockFilter filter) {
    switch (filter) {
      case StockFilter.all:
        return AppColors.primary;
      case StockFilter.available:
        return AppColors.success;
      case StockFilter.lowStock:
        return AppColors.warning;
      case StockFilter.outOfStock:
        return AppColors.error;
    }
  }

  Widget _buildSortDropdown(ProductSortOption selectedOption) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductSortOption>(
          value: selectedOption,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
          ),
          items: ProductSortOption.values.map((option) {
            return DropdownMenuItem<ProductSortOption>(
              value: option,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(sortOptionProvider.notifier).state = value;
            }
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle(ProductViewMode currentMode) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: Icons.grid_view,
            isSelected: currentMode == ProductViewMode.grid,
            onTap: () {
              ref.read(productViewModeProvider.notifier).state =
                  ProductViewMode.grid;
              // Clear selection when switching to grid
              ref.read(productSelectionProvider.notifier).clearSelection();
            },
            tooltip: 'Tampilan Grid',
          ),
          _buildToggleButton(
            icon: Icons.table_rows,
            isSelected: currentMode == ProductViewMode.table,
            onTap: () {
              ref.read(productViewModeProvider.notifier).state =
                  ProductViewMode.table;
            },
            tooltip: 'Tampilan Tabel',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
