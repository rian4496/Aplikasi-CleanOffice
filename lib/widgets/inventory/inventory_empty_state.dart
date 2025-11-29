// lib/widgets/inventory/inventory_empty_state.dart
// Modern empty state widget for inventory

import 'package:flutter/material.dart';
import '../../core/design/inventory_design_tokens.dart';
import '../../core/design/admin_colors.dart';

/// Modern empty state widget for inventory
/// Displays when no items match the current filters or when list is empty
class InventoryEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isFiltered;

  const InventoryEmptyState({
    super.key,
    this.title = 'Tidak Ada Item',
    this.message = 'Belum ada item inventaris yang tersedia',
    this.icon = Icons.inventory_2_outlined,
    this.actionLabel,
    this.onAction,
    this.isFiltered = false,
  });

  /// Factory constructor for filtered empty state
  factory InventoryEmptyState.filtered({
    VoidCallback? onClearFilter,
  }) {
    return InventoryEmptyState(
      title: 'Tidak Ditemukan',
      message: 'Tidak ada item yang sesuai dengan filter Anda',
      icon: Icons.search_off,
      actionLabel: 'Hapus Filter',
      onAction: onClearFilter,
      isFiltered: true,
    );
  }

  /// Factory constructor for no items empty state
  factory InventoryEmptyState.noItems({
    VoidCallback? onAddItem,
  }) {
    return InventoryEmptyState(
      title: 'Belum Ada Inventaris',
      message: 'Mulai tambahkan item inventaris pertama Anda',
      icon: Icons.add_box_outlined,
      actionLabel: 'Tambah Item',
      onAction: onAddItem,
      isFiltered: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(InventoryDesignTokens.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: InventoryDesignTokens.emptyIconContainerSize,
              height: InventoryDesignTokens.emptyIconContainerSize,
              decoration: BoxDecoration(
                color: InventoryDesignTokens.emptyIconBackground,
                borderRadius: BorderRadius.circular(
                  InventoryDesignTokens.emptyIconRadius,
                ),
              ),
              child: Icon(
                icon,
                size: InventoryDesignTokens.emptyIconSize,
                color: InventoryDesignTokens.emptyIconColor,
              ),
            ),

            const SizedBox(height: InventoryDesignTokens.spaceLG),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: InventoryDesignTokens.spaceSM),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AdminColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: InventoryDesignTokens.spaceLG),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  isFiltered ? Icons.clear : Icons.add,
                  size: 20,
                ),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFiltered
                      ? AdminColors.textSecondary
                      : InventoryDesignTokens.emptyCTABackground,
                  foregroundColor: InventoryDesignTokens.emptyCTAText,
                  padding: EdgeInsets.symmetric(
                    horizontal: InventoryDesignTokens.emptyCTAPaddingHorizontal,
                    vertical: InventoryDesignTokens.emptyCTAPaddingVertical,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      InventoryDesignTokens.cardBorderRadius,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
