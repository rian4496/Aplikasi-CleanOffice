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
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8, // Reduced vertical margin
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced Internal Padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Items
          Expanded(
            child: _StatItem(
              icon: Icons.inventory_2,
              iconColor: AdminColors.primary,
              iconBackground: AdminColors.primary.withValues(alpha: 0.1), // Fixed withValues to withOpacity for compatibility if needed, or stick to provided
              label: 'Total Item',
              value: totalItems.toString(),
            ),
          ),

          Container(
            width: 1,
            height: 32, // Reduced height
            color: Colors.grey.withValues(alpha: 0.2), // Lighter border
          ),

          // Low Stock
          Expanded(
            child: _StatItem(
              icon: Icons.warning_amber,
              iconColor: InventoryDesignTokens.lowStock.color,
              iconBackground: InventoryDesignTokens.lowStock.background,
              label: 'Stok Tipis',
              value: lowStockCount.toString(),
            ),
          ),

          Container(
            width: 1,
            height: 32,
            color: Colors.grey.withValues(alpha: 0.2),
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
        // Compact Layout: Row (Icon + Value) -> Label below
        // Or keep vertical but tighter
        
        Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             // Icon - Small
              Container(
                width: 28, // Reduced from 40
                height: 28,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16, // Reduced from 24
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              // Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18, // Reduced from 20
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3238),
                ),
              ),
           ],
        ),

        const SizedBox(height: 4),

        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

