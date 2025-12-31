import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/modern/modern.dart';
import '../widgets/category_grid_card.dart';
import '../widgets/gradient_summary_card.dart';

/// Main dashboard/home screen for the KASBON POS app
///
/// Mobile layout:
/// - Banner section (promotional)
/// - Menu Kategori grid (2 columns)
/// - Quick stats summary cards
///
/// Tablet layout:
/// - Wider grid (3-4 columns)
/// - Summary stats in a row at top
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: 'Beranda',
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
        onProfileTap: () {
          // TODO: Navigate to profile
        },
      ),
      body: context.isMobile
          ? const _MobileDashboard()
          : const _TabletDashboard(),
    );
  }
}

/// Mobile dashboard layout
class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacing16,
        bottom: AppDimensions.bottomNavHeight + AppDimensions.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner section
          const _BannerSection(),
          const SizedBox(height: AppDimensions.spacing24),
          // Menu Kategori
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
            ),
            child: Text(
              'Menu Kategori',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          // Category Grid
          const _CategoryGrid(crossAxisCount: 2),
        ],
      ),
    );
  }
}

/// Tablet dashboard layout
class _TabletDashboard extends StatelessWidget {
  const _TabletDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats Row
          const _SummaryStatsRow(),
          const SizedBox(height: AppDimensions.spacing32),
          // Menu Kategori
          Text(
            'Menu Kategori',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          // Category Grid (more columns on tablet)
          _CategoryGrid(
            crossAxisCount: context.gridColumns(mobile: 2, tablet: 3, desktop: 4),
          ),
        ],
      ),
    );
  }
}

/// Banner section for promotions or quick info
class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selamat Datang!',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    'Kelola bisnis Anda dengan mudah\ndan efisien bersama KASBON',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary stats row for tablet layout
class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GradientSummaryCard.primary(
            value: '150',
            label: 'Total Produk',
            icon: Icons.inventory_2,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: GradientSummaryCard.success(
            value: 'Rp 2.5jt',
            label: 'Pendapatan Hari Ini',
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: GradientSummaryCard.warning(
            value: '12',
            label: 'Stok Rendah',
            icon: Icons.warning_amber,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: GradientSummaryCard.info(
            value: '45',
            label: 'Transaksi Hari Ini',
            icon: Icons.receipt_long,
          ),
        ),
      ],
    );
  }
}

/// Category menu grid
class _CategoryGrid extends StatelessWidget {
  final int crossAxisCount;

  const _CategoryGrid({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    const categories = DefaultMenuCategories.items;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.spacing12,
          mainAxisSpacing: AppDimensions.spacing12,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryGridCard(
            label: category.label,
            icon: category.icon,
            backgroundColor: category.backgroundColor,
            iconColor: category.iconColor,
            onTap: () {
              context.go(category.routePath);
            },
          );
        },
      ),
    );
  }
}
