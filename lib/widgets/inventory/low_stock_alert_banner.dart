// lib/widgets/inventory/low_stock_alert_banner.dart
// Alert banner for low stock items

import 'package:flutter/material.dart';
import '../../core/design/inventory_design_tokens.dart';
import '../../models/inventory_item.dart';

/// Alert banner for low stock warnings
/// Displays a prominent warning when items are running low
class LowStockAlertBanner extends StatelessWidget {
  final List<InventoryItem> lowStockItems;
  final VoidCallback? onViewAll;

  const LowStockAlertBanner({
    super.key,
    required this.lowStockItems,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: InventoryDesignTokens.cardMarginHorizontal,
        vertical: InventoryDesignTokens.cardMarginVertical,
      ),
      padding: const EdgeInsets.all(InventoryDesignTokens.alertPadding),
      decoration: BoxDecoration(
        color: InventoryDesignTokens.alertBackground,
        borderRadius: BorderRadius.circular(InventoryDesignTokens.alertBorderRadius),
        border: Border.all(
          color: InventoryDesignTokens.alertBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Alert Icon
          Icon(
            Icons.warning_amber_rounded,
            size: InventoryDesignTokens.alertIconSize,
            color: InventoryDesignTokens.alertIcon,
          ),

          const SizedBox(width: InventoryDesignTokens.spaceMD),

          // Alert Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Peringatan Stok Rendah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: InventoryDesignTokens.alertText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lowStockItems.length} item perlu segera diisi ulang',
                  style: TextStyle(
                    fontSize: 12,
                    color: InventoryDesignTokens.alertText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: InventoryDesignTokens.spaceSM),

          // View All Button
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: InventoryDesignTokens.alertIcon,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

