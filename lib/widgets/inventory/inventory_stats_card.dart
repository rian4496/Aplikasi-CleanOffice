// lib/widgets/inventory/inventory_stats_card.dart
// Stats summary card for inventory overview

import 'package:flutter/material.dart';
import '../../core/design/inventory_design_tokens.dart';
import '../../core/design/admin_colors.dart';

/// Inventory stats summary card
/// Displays overview statistics in a compact card format
class InventoryStatsCard extends StatelessWidget {
  final int totalItems;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;

  const InventoryStatsCard({
    super.key,
    required this.totalItems,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: InventoryDesignTokens.cardMarginHorizontal,
        vertical: InventoryDesignTokens.cardMarginVertical,
      ),
      padding: const EdgeInsets.all(InventoryDesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(InventoryDesignTokens.cardBorderRadius),
        boxShadow: [InventoryDesignTokens.cardShadow],
      ),
      child: Row(
        children: [
          // Total Items
          Expanded(
            child: _StatItem(
              icon: Icons.inventory_2,
              iconColor: AdminColors.primary,
              iconBackground: AdminColors.primary.withValues(alpha: 0.1),
              label: 'Total Item',
              value: totalItems.toString(),
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: AdminColors.border,
          ),

          // Low Stock
          Expanded(
            child: _StatItem(
              icon: Icons.warning_amber,
              iconColor: InventoryDesignTokens.lowStock.color,
              iconBackground: InventoryDesignTokens.lowStock.background,
              label: 'Stok Rendah',
              value: lowStockCount.toString(),
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: AdminColors.border,
          ),

          // Out of Stock
          Expanded(
            child: _StatItem(
              icon: Icons.cancel,
              iconColor: InventoryDesignTokens.outOfStock.color,
              iconBackground: InventoryDesignTokens.outOfStock.background,
              label: 'Habis',
              value: outOfStockCount.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),

        const SizedBox(height: InventoryDesignTokens.spaceSM),

        // Value
        Text(
          value,
          style: InventoryDesignTokens.statsNumberStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: InventoryDesignTokens.spaceXS),

        // Label
        Text(
          label,
          style: InventoryDesignTokens.statsLabelStyle.copyWith(
            fontSize: 11,
            color: AdminColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
