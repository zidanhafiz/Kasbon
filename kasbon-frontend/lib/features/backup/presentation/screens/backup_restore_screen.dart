import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../shared/modern/modern.dart';
import '../providers/backup_provider.dart';
import '../widgets/backup_section.dart';
import '../widgets/backup_success_dialog.dart';
import '../widgets/clear_data_confirmation_dialog.dart';
import '../widgets/clear_progress_dialog.dart';
import '../widgets/danger_zone_section.dart';
import '../widgets/restore_confirmation_dialog.dart';
import '../widgets/restore_progress_dialog.dart';
import '../widgets/restore_section.dart';

/// Main backup and restore screen
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);

    return Scaffold(
      appBar: ModernAppBar.backWithActions(
        title: 'Backup & Restore',
        onNotificationTap: () => {},
        onProfileTap: () => {},
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Backup Section
              BackupSection(
                isCreatingBackup: backupState.isCreatingBackup,
                onCreateBackup: _handleCreateBackup,
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Restore Section
              RestoreSection(
                onSelectFile: _handleSelectFile,
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Danger Zone Section
              DangerZoneSection(
                onClearAllData: _handleClearAllData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateBackup() async {
    final notifier = ref.read(backupProvider.notifier);
    final metadata = await notifier.createBackup();

    if (metadata != null && mounted) {
      // Show success dialog
      final shouldShare = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackupSuccessDialog(metadata: metadata),
      );

      if (shouldShare == true && mounted) {
        // Share the backup file
        await Share.shareXFiles(
          [XFile(metadata.filePath)],
          subject: 'Backup KASBON - ${metadata.fileName}',
        );
      }

      // Refresh last backup info
      ref.invalidate(lastBackupProvider);
    } else if (mounted) {
      final error = ref.read(backupProvider).error;
      if (error != null) {
        ModernToast.error(context, error);
        notifier.clearError();
      }
    }
  }

  Future<void> _handleSelectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (mounted) {
          ModernToast.error(context, 'Gagal membaca file');
        }
        return;
      }

      // Load backup info
      final notifier = ref.read(backupProvider.notifier);
      final success = await notifier.loadBackupInfo(filePath);

      if (!success && mounted) {
        final error = ref.read(backupProvider).error;
        ModernToast.error(context, error ?? 'File backup tidak valid');
        notifier.clearError();
        return;
      }

      // Show confirmation dialog
      if (mounted) {
        final state = ref.read(backupProvider);
        if (state.selectedBackupInfo != null &&
            state.selectedFilePath != null) {
          final shouldRestore = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => RestoreConfirmationDialog(
              backupInfo: state.selectedBackupInfo!,
            ),
          );

          if (shouldRestore == true) {
            await _handleRestore(state.selectedFilePath!);
          } else {
            notifier.clearSelectedBackup();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ModernToast.error(context, 'Gagal memilih file');
      }
    }
  }

  Future<void> _handleRestore(String filePath) async {
    // Show progress dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const RestoreProgressDialog(),
    );

    // Wait a frame for dialog to mount
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Now start the restore
    final notifier = ref.read(backupProvider.notifier);
    final success = await notifier.restoreBackup(filePath);

    if (mounted) {
      // Close progress dialog using root navigator
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        ModernToast.success(context, 'Data berhasil di-restore!');
        // Refresh data counts and last backup
        ref.invalidate(dataCountsProvider);
        ref.invalidate(lastBackupProvider);
      } else {
        final error = ref.read(backupProvider).error;
        ModernToast.error(context, error ?? 'Gagal me-restore data');
        notifier.clearError();
      }
    }
  }

  Future<void> _handleClearAllData() async {
    // Show confirmation dialog
    final shouldClear = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClearDataConfirmationDialog(),
    );

    if (shouldClear != true || !mounted) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const ClearProgressDialog(),
    );

    // Wait a frame for dialog to mount
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Now start the clear operation
    final notifier = ref.read(backupProvider.notifier);
    final success = await notifier.clearAllData();

    if (mounted) {
      // Close progress dialog using root navigator
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        ModernToast.success(context, 'Semua data berhasil dihapus!');
        // Refresh data counts and last backup
        ref.invalidate(dataCountsProvider);
        ref.invalidate(lastBackupProvider);
      } else {
        final error = ref.read(backupProvider).error;
        ModernToast.error(context, error ?? 'Gagal menghapus data');
        notifier.clearError();
      }
    }
  }
}
