// lib/widgets/inventory/inventory_card.dart
// Modern inventory item card with pastel design

import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../core/design/inventory_design_tokens.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final int index; // For pastel background rotation
  final VoidCallback? onTap;
  final VoidCallback? onAddStock;
  final VoidCallback? onEdit;
  final VoidCallback? onMore;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const InventoryCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
    this.onAddStock,
    this.onEdit,
    this.onMore,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Get colors from design tokens
    final categoryColors = InventoryDesignTokens.getCategoryColors(item.category);
    final statusColors = InventoryDesignTokens.getStatusColors(
      item.currentStock,
      item.maxStock,
      item.minStock,
    );
    final cardBackground = InventoryDesignTokens.getCardBackground(index);
    final cardForeground = InventoryDesignTokens.getCardForeground(index);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: InventoryDesignTokens.cardMarginHorizontal,
        vertical: InventoryDesignTokens.cardMarginVertical,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(InventoryDesignTokens.cardBorderRadius),
        boxShadow: isSelected
            ? [InventoryDesignTokens.cardShadowElevated]
            : [InventoryDesignTokens.cardShadow],
        border: isSelected
            ? Border.all(color: cardForeground, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(InventoryDesignTokens.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(InventoryDesignTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Info + Status Badge
                Row(
                  children: [
                    // Selection checkbox (only in selection mode)
                    if (isSelectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onTap?.call(),
                        activeColor: cardForeground,
                      ),
                      const SizedBox(width: InventoryDesignTokens.spaceSM),
                    ],

                    // Icon container with category color
                    Container(
                      width: InventoryDesignTokens.iconContainerSize,
                      height: InventoryDesignTokens.iconContainerSize,
                      decoration: BoxDecoration(
                        color: InventoryDesignTokens.iconContainerBackground,
                        borderRadius: BorderRadius.circular(
                          InventoryDesignTokens.iconContainerRadius,
                        ),
                      ),
                      child: Icon(
                        categoryColors.icon,
                        size: InventoryDesignTokens.iconSize,
                        color: categoryColors.primary,
                      ),
                    ),

                    const SizedBox(width: InventoryDesignTokens.spaceMD),

                    // Item name and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: InventoryDesignTokens.itemNameStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: InventoryDesignTokens.spaceXS),
                          Text(
                            categoryColors.label,
                            style: InventoryDesignTokens.categoryLabelStyle,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: InventoryDesignTokens.spaceSM),

                    // Status badge
                    _buildStatusBadge(statusColors),
                  ],
                ),

                const SizedBox(height: InventoryDesignTokens.spaceMD),

                // Stock information
                _buildStockInfo(statusColors),

                const SizedBox(height: InventoryDesignTokens.spaceMD),

                // Progress bar
                _buildProgressBar(statusColors),

                // Action buttons (only when not in selection mode)
                if (!isSelectionMode) ...[
                  const SizedBox(height: InventoryDesignTokens.spaceMD),
                  _buildActionButtons(context, cardForeground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status badge with icon
  Widget _buildStatusBadge(StatusColors statusColors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InventoryDesignTokens.badgePaddingHorizontal,
        vertical: InventoryDesignTokens.badgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: statusColors.background,
        borderRadius: BorderRadius.circular(InventoryDesignTokens.badgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusColors.icon,
            size: InventoryDesignTokens.badgeIconSize,
            color: statusColors.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusColors.label,
            style: InventoryDesignTokens.badgeTextStyle.copyWith(
              color: statusColors.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stock information row
  Widget _buildStockInfo(StatusColors statusColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Stok: ${item.currentStock}/${item.maxStock} ${item.unit}',
          style: InventoryDesignTokens.stockNumberStyle,
        ),
        Text(
          '${item.stockPercentage.toStringAsFixed(0)}%',
          style: InventoryDesignTokens.stockPercentageStyle.copyWith(
            color: statusColors.color,
          ),
        ),
      ],
    );
  }

  /// Build progress bar with gradient
  Widget _buildProgressBar(StatusColors statusColors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(InventoryDesignTokens.progressBarRadius),
      child: LinearProgressIndicator(
        value: item.stockPercentage / 100,
        minHeight: InventoryDesignTokens.progressBarHeight,
        backgroundColor: InventoryDesignTokens.progressBarBackground,
        valueColor: AlwaysStoppedAnimation(statusColors.color),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        // Add Stock button
        if (onAddStock != null)
          Expanded(
            child: _ActionButton(
              label: 'Tambah',
              icon: Icons.add,
              color: primaryColor,
              onPressed: onAddStock!,
            ),
          ),

        if (onAddStock != null && onEdit != null)
          const SizedBox(width: InventoryDesignTokens.spaceSM),

        // Edit button
        if (onEdit != null)
          Expanded(
            child: _ActionButton(
              label: 'Edit',
              icon: Icons.edit,
              color: primaryColor,
              onPressed: onEdit!,
            ),
          ),

        if ((onAddStock != null || onEdit != null) && onMore != null)
          const SizedBox(width: InventoryDesignTokens.spaceSM),

        // More button
        if (onMore != null)
          _ActionButton(
            label: '',
            icon: Icons.more_vert,
            color: primaryColor,
            onPressed: onMore!,
            isIconOnly: true,
          ),
      ],
    );
  }

}

/// Action button widget for inventory card
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isIconOnly;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconOnly) {
      return IconButton(
        icon: Icon(icon),
        color: color,
        onPressed: onPressed,
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
