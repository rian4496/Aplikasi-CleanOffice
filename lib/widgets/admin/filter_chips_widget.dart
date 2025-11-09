// lib/widgets/admin/filter_chips_widget.dart
// Quick filter chips for common filters - REFACTORED

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/filter_model.dart';
import '../../providers/riverpod/filter_state_provider.dart';

class FilterChips extends ConsumerWidget {
  final bool showCount;
  
  const FilterChips({
    this.showCount = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final filteredCount = ref.watch(filteredCountProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ...QuickFilter.values.map((filter) {
              final isSelected = filterState.quickFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  context,
                  ref,
                  filter: filter,
                  isSelected: isSelected,
                  count: isSelected && showCount 
                      ? filteredCount 
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChip(
    BuildContext context,
    WidgetRef ref, {
    required QuickFilter filter,
    required bool isSelected,
    int? count,
  }) {
    final chipColor = _getFilterColor(filter);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFilterIcon(filter),
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 6),
          Text(filter.label),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        // Apply quick filter
        ref.read(filterProvider.notifier).setQuickFilter(filter);
      },
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      tooltip: filter.description,
    );
  }
  
  IconData _getFilterIcon(QuickFilter filter) {
    switch (filter) {
      case QuickFilter.all:
        return Icons.list_alt;
      case QuickFilter.today:
        return Icons.today;
      case QuickFilter.thisWeek:
        return Icons.date_range;
      case QuickFilter.urgent:
        return Icons.priority_high;
      case QuickFilter.overdue:
        return Icons.warning_amber;
    }
  }
  
  Color _getFilterColor(QuickFilter filter) {
    switch (filter) {
      case QuickFilter.all:
        return AppTheme.primary;
      case QuickFilter.today:
        return Colors.blue;
      case QuickFilter.thisWeek:
        return Colors.teal;
      case QuickFilter.urgent:
        return AppTheme.error;
      case QuickFilter.overdue:
        return AppTheme.warning;
    }
  }
}

/// Active filter indicator showing current filter status
class ActiveFilterIndicator extends ConsumerWidget {
  const ActiveFilterIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final activeCount = filterState.activeFilterCount;
    
    if (activeCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$activeCount filter aktif',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              // Clear all filters
              ref.read(filterProvider.notifier).clearFilters();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
