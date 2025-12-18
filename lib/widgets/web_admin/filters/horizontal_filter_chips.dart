// lib/widgets/web_admin/filters/horizontal_filter_chips.dart
// 🎯 Horizontal Filter Chips
// Scrollable filter chips for quick filtering

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class HorizontalFilterChips extends StatelessWidget {
  final List<FilterChipData> chips;
  final String? selectedChipId;
  final ValueChanged<String> onSelected;

  const HorizontalFilterChips({
    super.key,
    required this.chips,
    this.selectedChipId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.screenPaddingHorizontal,
        ),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AdminConstants.spaceSm),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = chip.id == selectedChipId;

          return FilterChip(
            label: Text(chip.label),
            selected: isSelected,
            onSelected: (_) => onSelected(chip.id),
            backgroundColor: AdminColors.surface,
            selectedColor: AdminColors.primaryLight.withOpacity(0.2),
            checkmarkColor: AdminColors.primary,
            labelStyle: AdminTypography.body2.copyWith(
              color: isSelected ? AdminColors.primary : AdminColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminConstants.chipRadius),
              side: BorderSide(
                color: isSelected ? AdminColors.primary : AdminColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
              vertical: AdminConstants.spaceSm,
            ),
          );
        },
      ),
    );
  }
}

/// Filter chip data class
class FilterChipData {
  final String id;
  final String label;
  final int? count;

  const FilterChipData({
    required this.id,
    required this.label,
    this.count,
  });
}

