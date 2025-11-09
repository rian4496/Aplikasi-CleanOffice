// lib/providers/riverpod/filter_providers.dart
// Filter providers with actual filtering logic

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/filter_model.dart';
import '../../models/report.dart';
import 'admin_providers.dart';

// ==================== FILTER STATE (Read-only for now) ====================

/// Current filter - Empty by default (read-only)
final reportFilterProvider = Provider<ReportFilter>((ref) {
  return const ReportFilter();
});

/// Current quick filter (read-only)
final quickFilterProvider = Provider<QuickFilter>((ref) {
  return QuickFilter.all;
});

// ==================== FILTERED REPORTS ====================

/// Provider that returns filtered reports based on filter criteria
final filteredReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  final filter = ref.watch(reportFilterProvider);
  final quickFilter = ref.watch(quickFilterProvider);

  return allReportsAsync.when(
    data: (reports) {
      var filtered = reports;

      // Apply quick filter first
      filtered = _applyQuickFilter(filtered, quickFilter);

      // Apply advanced filters
      filtered = _applyAdvancedFilter(filtered, filter);

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Count of filtered reports
final filteredCountProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(filteredReportsProvider);
  return reportsAsync.when(
    data: (reports) => reports.length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

// ==================== FILTER HELPER FUNCTIONS ====================

/// Apply quick filter to reports
List<Report> _applyQuickFilter(List<Report> reports, QuickFilter quickFilter) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekAgo = today.subtract(const Duration(days: 7));

  switch (quickFilter) {
    case QuickFilter.all:
      return reports;

    case QuickFilter.today:
      return reports.where((r) {
        final reportDate = DateTime(r.date.year, r.date.month, r.date.day);
        return reportDate.isAtSameMomentAs(today);
      }).toList();

    case QuickFilter.thisWeek:
      return reports.where((r) {
        final reportDate = DateTime(r.date.year, r.date.month, r.date.day);
        return reportDate.isAfter(weekAgo) || reportDate.isAtSameMomentAs(weekAgo);
      }).toList();

    case QuickFilter.urgent:
      return reports.where((r) => r.isUrgent == true).toList();

    case QuickFilter.overdue:
      final oneDayAgo = now.subtract(const Duration(hours: 24));
      return reports.where((r) {
        return r.status == ReportStatus.pending && r.date.isBefore(oneDayAgo);
      }).toList();
  }
}

/// Apply advanced filter criteria to reports
List<Report> _applyAdvancedFilter(List<Report> reports, ReportFilter filter) {
  if (filter.isEmpty) return reports;

  var filtered = reports;

  // Search query (title, description, location, userName)
  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    final query = filter.searchQuery!.toLowerCase();
    filtered = filtered.where((r) {
      return (r.title.toLowerCase().contains(query)) ||
          (r.description?.toLowerCase().contains(query) ?? false) ||
          r.location.toLowerCase().contains(query) ||
          r.userName.toLowerCase().contains(query);
    }).toList();
  }

  // Filter by statuses
  if (filter.statuses != null && filter.statuses!.isNotEmpty) {
    filtered = filtered.where((r) {
      return filter.statuses!.contains(r.status.toFirestore());
    }).toList();
  }

  // Filter by locations
  if (filter.locations != null && filter.locations!.isNotEmpty) {
    filtered = filtered.where((r) {
      return filter.locations!.any((loc) => 
        r.location.toLowerCase().contains(loc.toLowerCase())
      );
    }).toList();
  }

  // Filter by date range
  if (filter.startDate != null) {
    filtered = filtered.where((r) {
      return r.date.isAfter(filter.startDate!) || 
             r.date.isAtSameMomentAs(filter.startDate!);
    }).toList();
  }

  if (filter.endDate != null) {
    final endOfDay = DateTime(
      filter.endDate!.year,
      filter.endDate!.month,
      filter.endDate!.day,
      23,
      59,
      59,
    );
    filtered = filtered.where((r) {
      return r.date.isBefore(endOfDay) || 
             r.date.isAtSameMomentAs(endOfDay);
    }).toList();
  }

  // Filter by urgent status
  if (filter.isUrgent != null) {
    filtered = filtered.where((r) => r.isUrgent == filter.isUrgent).toList();
  }

  // Filter by assigned to (cleanerId or cleanerName)
  if (filter.assignedTo != null && filter.assignedTo!.isNotEmpty) {
    final assignedQuery = filter.assignedTo!.toLowerCase();
    filtered = filtered.where((r) {
      final cleanerId = r.cleanerId;
      final cleanerName = r.cleanerName;
      return (cleanerId != null && cleanerId.toLowerCase().contains(assignedQuery)) ||
          (cleanerName != null && cleanerName.toLowerCase().contains(assignedQuery));
    }).toList();
  }

  return filtered;
}
