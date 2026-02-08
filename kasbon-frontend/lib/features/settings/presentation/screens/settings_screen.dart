import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/modern/modern.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// Main settings hub screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(shopSettingsProvider);
    final authState = ref.watch(authProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: ModernAppBar.withActions(
        title: 'Pengaturan',
        onNotificationTap: () {},
        onProfileTap: () {},
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: ModernLoading()),
        error: (error, _) => ModernErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(shopSettingsProvider),
        ),
        data: (settings) {
          // Calculate bottom padding based on device type to account for bottom nav
          final bottomPadding = context.isMobile
              ? AppDimensions.bottomNavHeight + AppDimensions.spacing16
              : AppDimensions.spacing16;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing16),

                // AKUN Section
                SettingsSection(
                  title: 'Akun',
                  children: [
                    _buildAccountTile(context, ref, authState, currentUser),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // TOKO Section
                SettingsSection(
                  title: 'Toko',
                  children: [
                    SettingsTile.navigation(
                      icon: Icons.store_rounded,
                      iconColor: AppColors.primary,
                      title: 'Profil Toko',
                      subtitle: settings.name,
                      onTap: () => context.push('/settings/shop-profile'),
                    ),
                    SettingsTile.navigation(
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.info,
                      title: 'Pengaturan Struk',
                      subtitle: 'Header & footer struk',
                      onTap: () => context.push('/settings/receipt'),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // APLIKASI Section
                SettingsSection(
                  title: 'Aplikasi',
                  children: [
                    SettingsTile.navigation(
                      icon: Icons.tune_rounded,
                      iconColor: AppColors.warning,
                      title: 'Pengaturan Aplikasi',
                      subtitle: 'Batas stok rendah: ${settings.lowStockThreshold}',
                      onTap: () => context.push('/settings/app'),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // LAINNYA Section
                SettingsSection(
                  title: 'Lainnya',
                  children: [
                    SettingsTile.navigation(
                      icon: Icons.backup_rounded,
                      iconColor: AppColors.success,
                      title: 'Backup & Restore',
                      subtitle: 'Cadangkan dan pulihkan data',
                      onTap: () => context.push('/settings/backup'),
                    ),
                    SettingsTile.navigation(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textSecondary,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi & informasi',
                      onTap: () => context.push('/settings/about'),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    AppUser? currentUser,
  ) {
    // Check if user is authenticated
    final isAuthenticated = authState is AuthAuthenticated;

    if (isAuthenticated && currentUser != null) {
      // Show user info with logout option
      return ModernCard.outlined(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      currentUser.initials,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.displayName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        currentUser.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sync indicator
                ModernBadge.success(label: 'Tersinkron'),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.spacing12),
            // Logout button
            ModernButton.outline(
              onPressed: () => _handleLogout(context, ref),
              fullWidth: true,
              leadingIcon: Icons.logout,
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
    }

    // Show login prompt for unauthenticated users
    return ModernCard.outlined(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.primary,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinkronkan Data',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      'Login untuk backup data ke cloud',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          // Login button
          ModernButton.primary(
            onPressed: () => context.push('/auth/login'),
            fullWidth: true,
            leadingIcon: Icons.login,
            child: const Text('Masuk / Daftar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ModernDialog.confirm(
      context,
      title: 'Keluar dari Akun?',
      message: 'Anda akan keluar dari akun. Data lokal tetap tersimpan.',
      confirmLabel: 'Keluar',
      cancelLabel: 'Batal',
    );

    if (confirmed == true) {
      final success = await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        if (success) {
          ModernToast.success(context, 'Berhasil keluar');
        } else {
          ModernToast.error(context, 'Gagal keluar');
        }
      }
    }
  }
}
