import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/modern/modern.dart';

/// Point of Sale (Kasir) screen
///
/// Mobile layout:
/// - Full-screen product grid
/// - Floating cart button with item count
/// - Bottom sheet for cart details
///
/// Tablet layout:
/// - Split panel: Product grid (left ~60%) + Cart sidebar (right ~40%)
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: 'Kasir',
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
        onProfileTap: () {
          // TODO: Navigate to profile
        },
      ),
      body: context.isMobile
          ? _buildMobileLayout()
          : _buildTabletLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Main content
        Column(
          children: [
            // Search bar
            _buildSearchBar(),
            // Category filter
            _buildCategoryFilter(),
            // Product grid
            Expanded(
              child: _buildProductGrid(crossAxisCount: 2),
            ),
          ],
        ),
        // Floating cart button
        if (_cartItemCount > 0)
          Positioned(
            bottom: AppDimensions.spacing16,
            left: AppDimensions.spacing16,
            right: AppDimensions.spacing16,
            child: _buildCartButton(),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Product grid section (left)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              // Search bar
              _buildSearchBar(),
              // Category filter
              _buildCategoryFilter(),
              // Product grid
              Expanded(
                child: _buildProductGrid(crossAxisCount: 3),
              ),
            ],
          ),
        ),
        // Cart sidebar (right)
        Container(
          width: 350,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: _buildCartSidebar(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: ModernSearchField(
        controller: _searchController,
        hint: 'Cari produk...',
        onChanged: (value) {
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Semua', 'Makanan', 'Minuman', 'Snack', 'Lainnya'];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.spacing8),
        itemBuilder: (context, index) {
          final isSelected = index == 0; // TODO: Implement category selection
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (_) {
              // TODO: Implement category filter
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildProductGrid({required int crossAxisCount}) {
    // Placeholder product grid
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.spacing12,
        mainAxisSpacing: AppDimensions.spacing12,
        childAspectRatio: 0.75,
      ),
      itemCount: 12, // Placeholder count
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _cartItemCount++;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produk ${index + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${(index + 1) * 10000}',
                      style: AppTextStyles.priceMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Show cart bottom sheet
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing24,
          vertical: AppDimensions.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: AppDimensions.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                  vertical: AppDimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                ),
                child: Text(
                  '$_cartItemCount item',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Rp ${_cartItemCount * 10000}',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart header
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Keranjang',
                style: AppTextStyles.h4,
              ),
              Text(
                '$_cartItemCount item',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Cart items
        Expanded(
          child: _cartItemCount == 0
              ? _buildEmptyCart()
              : _buildCartItems(),
        ),
        // Cart footer
        _buildCartFooter(),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            'Keranjang kosong',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Pilih produk untuk menambahkan',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: _cartItemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
          child: Row(
            children: [
              // Product image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: const Icon(
                  Icons.image,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produk ${index + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp ${(index + 1) * 10000}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                onPressed: () {
                  setState(() {
                    _cartItemCount--;
                  });
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartFooter() {
    final total = _cartItemCount * 10000;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rp $total',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItemCount > 0 ? () {
                // TODO: Navigate to checkout
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textTertiary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: const Text('Bayar'),
            ),
          ),
        ],
      ),
    );
  }
}
