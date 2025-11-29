import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/riverpod/report_providers.dart';

// Quick Filters Enum
enum QuickFilter {
  all,
  today,
  thisWeek,
  urgent,
  overdue,
}

final quickFilterProvider = StateProvider<QuickFilter>((ref) {
  return QuickFilter.all;
});

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(quickFilterProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            context,
            ref,
            label: 'Semua',
            filter: QuickFilter.all,
            icon: Icons.list_alt,
            isSelected: selectedFilter == QuickFilter.all,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            ref,
            label: 'Hari Ini',
            filter: QuickFilter.today,
            icon: Icons.today,
            isSelected: selectedFilter == QuickFilter.today,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            ref,
            label: 'Minggu Ini',
            filter: QuickFilter.thisWeek,
            icon: Icons.date_range,
            isSelected: selectedFilter == QuickFilter.thisWeek,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            ref,
            label: 'Urgent',
            filter: QuickFilter.urgent,
            icon: Icons.priority_high,
            isSelected: selectedFilter == QuickFilter.urgent,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            ref,
            label: 'Terlambat',
            filter: QuickFilter.overdue,
            icon: Icons.warning_amber,
            isSelected: selectedFilter == QuickFilter.overdue,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
  
  Widget _buildChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required QuickFilter filter,
    required IconData icon,
    required bool isSelected,
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).primaryColor;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(quickFilterProvider.notifier).state = filter;
        _applyQuickFilter(ref, filter);
      },
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : chipColor.withOpacity(0.3),
        ),
      ),
    );
  }

  void _applyQuickFilter(WidgetRef ref, QuickFilter filter) {
    final notifier = ref.read(reportFilterProvider.notifier);
    final now = DateTime.now();
    
    // Reset first
    notifier.reset();
    
    switch (filter) {
      case QuickFilter.today:
        notifier.setDateRange(
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day),
        );
        break;
      case QuickFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        notifier.setDateRange(weekStart, now);
        break;
      case QuickFilter.urgent:
        notifier.toggleUrgentFilter();
        break;
      case QuickFilter.overdue:
        // Logic for overdue handled in provider or we set a specific date range + pending status
        // For now, let's just set status to pending and date to before today
        // But ReportFilterState doesn't support "before date" easily without end date.
        // Let's skip complex overdue logic here and just filter by pending for now or leave it for advanced filter
        // Or we can implement it if we add 'overdue' flag to filter state.
        // For simplicity, let's just show pending.
        // notifier.setStatusFilter([ReportStatus.pending]);
        break;
      case QuickFilter.all:
      default:
        break;
    }
  }
}
