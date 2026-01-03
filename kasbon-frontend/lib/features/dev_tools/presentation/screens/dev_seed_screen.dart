import 'package:flutter/material.dart';

import '../../../../config/database/database_helper.dart';
import '../../../../config/database/dev_seed_data.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../shared/modern/modern.dart';

/// Dev Tools screen for seeding sample data.
///
/// IMPORTANT: This is for development use only.
class DevSeedScreen extends StatefulWidget {
  const DevSeedScreen({super.key});

  @override
  State<DevSeedScreen> createState() => _DevSeedScreenState();
}

class _DevSeedScreenState extends State<DevSeedScreen> {
  bool _isLoading = false;
  String? _loadingAction;

  Future<void> _seedAllData() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'Seeding all data...';
    });
    try {
      final seeder = DevSeedData(DatabaseHelper());
      await seeder.seedAll();
      if (mounted) {
        ModernToast.success(context, 'Data berhasil di-seed (25 produk, 20 transaksi)');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.error(context, 'Gagal seed data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  Future<void> _seedProductsOnly() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'Seeding products...';
    });
    try {
      final seeder = DevSeedData(DatabaseHelper());
      await seeder.seedProducts();
      if (mounted) {
        ModernToast.success(context, 'Produk berhasil di-seed (25 produk)');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.error(context, 'Gagal seed produk: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  Future<void> _seedTransactionsOnly() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'Seeding transactions...';
    });
    try {
      final seeder = DevSeedData(DatabaseHelper());
      await seeder.seedTransactions();
      if (mounted) {
        ModernToast.success(context, 'Transaksi berhasil di-seed (20 transaksi)');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.error(context, 'Gagal seed transaksi: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await ModernDialog.confirm(
      context,
      title: 'Hapus Semua Data?',
      message:
          'Semua produk dan transaksi akan dihapus. Kategori dan pengaturan toko tetap dipertahankan.',
      confirmLabel: 'Hapus',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _loadingAction = 'Clearing data...';
    });
    try {
      final seeder = DevSeedData(DatabaseHelper());
      await seeder.clearSeedData();
      if (mounted) {
        ModernToast.success(context, 'Data berhasil dihapus');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.error(context, 'Gagal hapus data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar.backWithActions(
        title: 'Dev Seed Data',
        onBack: () => Navigator.of(context).maybePop(),
        onNotificationTap: () {},
        onProfileTap: () {},
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ModernLoading(),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    _loadingAction ?? 'Loading...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  ModernCard.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppDimensions.spacing8),
                              Text(
                                'Database Seeding',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacing12),
                          Text(
                            'Seed data untuk development dan testing. '
                            'Semua operasi akan menghapus data existing terlebih dahulu.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Seed All Data
                  ModernCard.elevated(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.rocket_launch,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seed All Data',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      '25 produk + 20 transaksi',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton.primary(
                              onPressed: _seedAllData,
                              child: const Text('Seed All Data'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Seed Products Only
                  ModernCard.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seed Products Only',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      '25 produk sample',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton.outline(
                              onPressed: _seedProductsOnly,
                              child: const Text('Seed Products'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Seed Transactions Only
                  ModernCard.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seed Transactions Only',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      '20 transaksi sample (memerlukan produk)',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton.outline(
                              onPressed: _seedTransactionsOnly,
                              child: const Text('Seed Transactions'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Danger Zone
                  ModernCard.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.warning_amber,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Danger Zone',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.red),
                                    ),
                                    Text(
                                      'Hapus semua data produk dan transaksi',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton.destructive(
                              onPressed: _clearAllData,
                              child: const Text('Clear All Data'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Sample Data Info
                  ModernCard.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sample Data Info',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppDimensions.spacing12),
                          _buildInfoRow(
                              context, 'Produk', '25 (berbagai kategori)'),
                          _buildInfoRow(context, 'Transaksi', '20'),
                          _buildInfoRow(context, 'Cash', '15 transaksi'),
                          _buildInfoRow(context, 'Hutang', '5 transaksi'),
                          _buildInfoRow(context, 'Dengan diskon', '5 transaksi'),
                          _buildInfoRow(context, 'Range tanggal', '30 hari terakhir'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
