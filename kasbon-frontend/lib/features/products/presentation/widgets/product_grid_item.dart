import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/modern/components/card/modern_card.dart';
import '../../domain/entities/product.dart';
import 'stock_indicator.dart';

/// Grid item widget for product list
/// Displays product image, name, price, and stock indicator in a card format
/// Supports selection mode with long-press to enter selection and tap to toggle
class ProductGridItem extends StatelessWidget {
  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  final Product product;
  final VoidCallback onTap;

  /// Callback when item is long-pressed (used to enter selection mode)
  final VoidCallback? onLongPress;

  /// Whether selection mode is active (shows checkbox overlay)
  final bool isSelectionMode;

  /// Whether this item is currently selected
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ModernCard.outlined(
        onTap: onTap,
        padding: EdgeInsets.zero,
        borderColor: isSelected ? AppColors.primary : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with selection checkbox overlay
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top:
                                      Radius.circular(AppDimensions.radiusMedium),
                                ),
                                child: Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderIcon();
                                  },
                                ),
                              )
                            : _buildPlaceholderIcon(),
                  ),
                  // Selection checkbox overlay
                  if (isSelectionMode)
                    Positioned(
                      top: AppDimensions.spacing8,
                      right: AppDimensions.spacing8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.onPrimary,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            // Product Info - wrapped in Expanded to prevent overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name - takes remaining space
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    // Price
                    Text(
                      CurrencyFormatter.format(product.sellingPrice),
                      style: AppTextStyles.priceSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    // Stock Indicator
                    StockIndicator(
                      stock: product.stock,
                      minStock: product.minStock,
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

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: AppDimensions.iconXLarge,
        color: AppColors.textTertiary,
      ),
    );
  }
}
