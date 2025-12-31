import 'package:flutter/material.dart';

import '../../../../shared/modern/modern.dart';

/// Stock status indicator widget
/// Shows different badge based on stock level
class StockIndicator extends StatelessWidget {
  const StockIndicator({
    super.key,
    required this.stock,
    required this.minStock,
    this.showIcon = false,
  });

  final int stock;
  final int minStock;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    if (stock <= 0) {
      return ModernBadge.error(
        label: 'Habis',
        showDot: true,
        icon: showIcon ? Icons.warning_amber_rounded : null,
      );
    }

    if (stock <= minStock) {
      return ModernBadge.warning(
        label: 'Stok Rendah',
        showDot: true,
        icon: showIcon ? Icons.warning_amber_rounded : null,
      );
    }

    return ModernBadge.success(
      label: 'Tersedia',
      showDot: true,
      icon: showIcon ? Icons.check_circle_outline : null,
    );
  }
}
