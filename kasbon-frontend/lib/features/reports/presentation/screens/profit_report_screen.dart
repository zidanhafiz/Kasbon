import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../shared/modern/modern.dart';
import '../providers/profit_report_provider.dart';
import '../widgets/profit_summary_card.dart';
import '../widgets/top_profitable_products_list.dart';

/// Screen displaying profit reports
class ProfitReportScreen extends ConsumerWidget {
  const ProfitReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyProfitAsync = ref.watch(monthlyProfitSummaryProvider);
    final topProductsAsync = ref.watch(topProfitableProductsProvider);

    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: 'Laporan Laba',
        onNotificationTap: () {},
        onProfileTap: () {},
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlyProfitSummaryProvider);
          ref.invalidate(topProfitableProductsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Profit Summary Card
              monthlyProfitAsync.when(
                data: (summary) => ProfitSummaryCard(
                  summary: summary,
                  title: 'Total Laba Bulan Ini',
                ),
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: ModernLoading()),
                ),
                error: (error, _) => ModernErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(monthlyProfitSummaryProvider),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Section Header
              const ModernSectionHeader(
                title: 'Produk Paling Menguntungkan',
                actionLabel: null,
              ),

              const SizedBox(height: AppDimensions.spacing12),

              // Top Profitable Products List
              topProductsAsync.when(
                data: (products) => TopProfitableProductsList(
                  products: products,
                  onProductTap: (productId) =>
                      context.push('/products/$productId'),
                ),
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: ModernLoading()),
                ),
                error: (error, _) => ModernErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(topProfitableProductsProvider),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing32),
            ],
          ),
        ),
      ),
    );
  }
}
