import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';

/// A category card for the home screen menu grid
///
/// Displays an icon and label for navigation to different features.
/// Used in the "Menu Kategori" section of the dashboard.
class CategoryGridCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const CategoryGridCard({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  /// Creates a category card with primary color accent
  factory CategoryGridCard.primary({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return CategoryGridCard(
      label: label,
      icon: icon,
      backgroundColor: AppColors.primaryContainer,
      iconColor: AppColors.primary,
      onTap: onTap,
    );
  }

  /// Creates a category card with secondary color accent
  factory CategoryGridCard.secondary({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return CategoryGridCard(
      label: label,
      icon: icon,
      backgroundColor: AppColors.secondaryContainer,
      iconColor: AppColors.secondary,
      onTap: onTap,
    );
  }

  /// Creates a category card with success color accent
  factory CategoryGridCard.success({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return CategoryGridCard(
      label: label,
      icon: icon,
      backgroundColor: AppColors.successLight,
      iconColor: AppColors.success,
      onTap: onTap,
    );
  }

  /// Creates a category card with warning color accent
  factory CategoryGridCard.warning({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return CategoryGridCard(
      label: label,
      icon: icon,
      backgroundColor: AppColors.warningLight,
      iconColor: AppColors.warning,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surface;
    final icColor = iconColor ?? AppColors.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: icColor,
                  size: AppDimensions.iconLarge,
                ),
              ),
              const Spacer(),
              // Label
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu category item data model
class MenuCategory {
  final String label;
  final IconData icon;
  final String routePath;
  final Color? backgroundColor;
  final Color? iconColor;

  const MenuCategory({
    required this.label,
    required this.icon,
    required this.routePath,
    this.backgroundColor,
    this.iconColor,
  });
}

/// Default menu categories for the KASBON POS app
class DefaultMenuCategories {
  DefaultMenuCategories._();

  static const List<MenuCategory> items = [
    MenuCategory(
      label: 'Penjualan',
      icon: Icons.point_of_sale,
      routePath: '/pos',
      backgroundColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF2563EB),
    ),
    MenuCategory(
      label: 'Penyimpanan',
      icon: Icons.inventory_2,
      routePath: '/products',
      backgroundColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF10B981),
    ),
    MenuCategory(
      label: 'Pelanggan',
      icon: Icons.people,
      routePath: '/customers',
      backgroundColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFF59E0B),
    ),
    MenuCategory(
      label: 'Pegawai',
      icon: Icons.badge,
      routePath: '/employees',
      backgroundColor: Color(0xFFE0E7FF),
      iconColor: Color(0xFF6366F1),
    ),
    MenuCategory(
      label: 'Produk',
      icon: Icons.category,
      routePath: '/products',
      backgroundColor: Color(0xFFFCE7F3),
      iconColor: Color(0xFFEC4899),
    ),
    MenuCategory(
      label: 'Laporan',
      icon: Icons.bar_chart,
      routePath: '/reports',
      backgroundColor: Color(0xFFCFFAFE),
      iconColor: Color(0xFF06B6D4),
    ),
  ];
}
