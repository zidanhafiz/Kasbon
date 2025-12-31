import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../utils/modern_variants.dart';

/// A Modern-styled toast/snackbar notification system
///
/// Example:
/// ```dart
/// ModernToast.success(context, 'Produk berhasil disimpan!');
/// ModernToast.error(context, 'Gagal menyimpan produk');
/// ```
class ModernToast {
  ModernToast._();

  /// Shows a toast with the specified variant
  static void show(
    BuildContext context, {
    required String message,
    ModernToastVariant variant = ModernToastVariant.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showCloseIcon = false,
    VoidCallback? onClosed,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: _ToastContent(
        message: message,
        variant: variant,
        showCloseIcon: showCloseIcon,
        onClose: () => messenger.hideCurrentSnackBar(),
      ),
      duration: duration,
      action: action,
      backgroundColor: _getBackgroundColor(variant),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      margin: const EdgeInsets.all(AppDimensions.spacing16),
      padding: EdgeInsets.zero,
      elevation: 4,
    );

    messenger.showSnackBar(snackBar).closed.then((_) {
      onClosed?.call();
    });
  }

  /// Shows a success toast
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      variant: ModernToastVariant.success,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error toast
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      variant: ModernToastVariant.error,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning toast
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      variant: ModernToastVariant.warning,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info toast
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      variant: ModernToastVariant.info,
      duration: duration,
      action: action,
    );
  }

  /// Hides the current toast
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static Color _getBackgroundColor(ModernToastVariant variant) {
    switch (variant) {
      case ModernToastVariant.success:
        return AppColors.success;
      case ModernToastVariant.error:
        return AppColors.error;
      case ModernToastVariant.warning:
        return AppColors.warning;
      case ModernToastVariant.info:
        return AppColors.info;
    }
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.message,
    required this.variant,
    required this.showCloseIcon,
    this.onClose,
  });

  final String message;
  final ModernToastVariant variant;
  final bool showCloseIcon;
  final VoidCallback? onClose;

  IconData get _icon {
    switch (variant) {
      case ModernToastVariant.success:
        return Icons.check_circle_outline;
      case ModernToastVariant.error:
        return Icons.error_outline;
      case ModernToastVariant.warning:
        return Icons.warning_amber_outlined;
      case ModernToastVariant.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: Colors.white,
            size: AppDimensions.iconLarge,
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          if (showCloseIcon)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: Colors.white,
              iconSize: AppDimensions.iconMedium,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
