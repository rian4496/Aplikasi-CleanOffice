// lib/widgets/inventory/category_filter_chips.dart
// Category filter chips for inventory module

import 'package:flutter/material.dart';
import '../../core/design/inventory_design_tokens.dart';

/// Filter options for inventory categories
enum InventoryCategory {
  all,
  alat,
  consumable,
  ppe,
}

/// Category filter chips widget
/// Displays horizontal scrollable chips for filtering inventory by category
class CategoryFilterChips extends StatelessWidget {
  final InventoryCategory selectedCategory;
  final ValueChanged<InventoryCategory> onCategoryChanged;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: InventoryDesignTokens.chipHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: InventoryDesignTokens.cardMarginHorizontal,
        ),
        children: [
          _buildChip(
            category: InventoryCategory.all,
            label: 'Semua',
            icon: Icons.apps,
          ),
          const SizedBox(width: InventoryDesignTokens.chipSpacing),
          _buildChip(
            category: InventoryCategory.alat,
            label: InventoryDesignTokens.alat.label,
            icon: InventoryDesignTokens.alat.icon,
            color: InventoryDesignTokens.alat.primary,
          ),
          const SizedBox(width: InventoryDesignTokens.chipSpacing),
          _buildChip(
            category: InventoryCategory.consumable,
            label: InventoryDesignTokens.consumable.label,
            icon: InventoryDesignTokens.consumable.icon,
            color: InventoryDesignTokens.consumable.primary,
          ),
          const SizedBox(width: InventoryDesignTokens.chipSpacing),
          _buildChip(
            category: InventoryCategory.ppe,
            label: InventoryDesignTokens.ppe.label,
            icon: InventoryDesignTokens.ppe.icon,
            color: InventoryDesignTokens.ppe.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required InventoryCategory category,
    required String label,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = selectedCategory == category;
    final chipColor = color ?? InventoryDesignTokens.chipActiveBackground;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: InventoryDesignTokens.chipIconSize,
            color: isSelected
                ? InventoryDesignTokens.chipActiveText
                : chipColor,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onCategoryChanged(category),
      selectedColor: chipColor,
      checkmarkColor: InventoryDesignTokens.chipActiveText,
      labelStyle: TextStyle(
        color: isSelected
            ? InventoryDesignTokens.chipActiveText
            : chipColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 14,
      ),
      backgroundColor: InventoryDesignTokens.chipInactiveBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(InventoryDesignTokens.chipBorderRadius),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : InventoryDesignTokens.chipInactiveBorder,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: InventoryDesignTokens.chipPaddingHorizontal,
      ),
      elevation: isSelected ? 2 : 0,
      shadowColor: chipColor.withValues(alpha: 0.3),
    );
  }
}
