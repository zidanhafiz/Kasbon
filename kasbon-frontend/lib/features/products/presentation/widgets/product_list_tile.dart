import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';
import 'stock_indicator.dart';

/// List tile widget for displaying a product in a list
class ProductListTile extends StatelessWidget {
  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Product Image Placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                      ),
                    )
                  : _buildPlaceholderIcon(),
            ),
            const SizedBox(width: AppDimensions.spacing12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacing2),

                  // Price
                  Text(
                    CurrencyFormatter.format(product.sellingPrice),
                    style: AppTextStyles.priceSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),

                  // Stock Info Row
                  Row(
                    children: [
                      Text(
                        'Stok: ${product.stock} ${product.unit}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: AppDimensions.spacing8),
                      StockIndicator(
                        stock: product.stock,
                        minStock: product.minStock,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing widget (chevron, menu, etc.)
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
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
        color: AppColors.textTertiary,
        size: AppDimensions.iconLarge,
      ),
    );
  }
}
