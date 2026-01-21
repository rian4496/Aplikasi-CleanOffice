// lib/riverpod/filter_state_provider.dart
// Filter state management with Riverpod 3.0 code generation

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/filter_model.dart';
import '../../models/report.dart';
import 'admin_providers.dart';

part 'filter_state_provider.g.dart';

// ==================== FILTER STATE ====================

/// Filter state class
class FilterState {
  final ReportFilter reportFilter;
  final QuickFilter quickFilter;
  
  const FilterState({
    this.reportFilter = const ReportFilter(),
    this.quickFilter = QuickFilter.all,
  });
  
  FilterState copyWith({
    ReportFilter? reportFilter,
    QuickFilter? quickFilter,
  }) {
    return FilterState(
      reportFilter: reportFilter ?? this.reportFilter,
      quickFilter: quickFilter ?? this.quickFilter,
    );
  }
  
  int get activeFilterCount => reportFilter.activeFilterCount;
  
  bool get hasActiveFilters => activeFilterCount > 0;
}

// ==================== FILTER NOTIFIER ====================

/// Filter state notifier
@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() => const FilterState();
  
  /// Update report filter
  void updateFilter(ReportFilter filter) {
    state = state.copyWith(reportFilter: filter);
  }
  
  /// Set quick filter
  void setQuickFilter(QuickFilter filter) {
    state = state.copyWith(quickFilter: filter);
    
    // Apply quick filter logic
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    
    ReportFilter newFilter;
    
    switch (filter) {
      case QuickFilter.all:
        newFilter = const ReportFilter(); // Clear all
        break;
        
      case QuickFilter.today:
        newFilter = ReportFilter(
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        );
        break;
        
      case QuickFilter.thisWeek:
        newFilter = ReportFilter(
          startDate: weekStart,
          endDate: weekStart.add(const Duration(days: 7)),
        );
        break;
        
      case QuickFilter.urgent:
        newFilter = const ReportFilter(isUrgent: true);
        break;
        
      case QuickFilter.overdue:
        // Overdue = completed more than 24h ago, not verified
        newFilter = ReportFilter(
          statuses: ['completed'],
          startDate: DateTime(2000, 1, 1), // Very old start
          endDate: now.subtract(const Duration(hours: 24)),
        );
        break;
    }
    
    state = state.copyWith(reportFilter: newFilter);
  }
  
  /// Update search query
  void updateSearchQuery(String query) {
    final currentFilter = state.reportFilter;
    final updatedFilter = currentFilter.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    state = state.copyWith(reportFilter: updatedFilter);
  }
  
  /// Clear all filters
  void clearFilters() {
    state = const FilterState();
  }
}

// ==================== FILTERED REPORTS PROVIDER ====================

/// Filtered reports based on current filter state
@riverpod
Future<List<Report>> filteredReports(Ref ref) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  final filterState = ref.watch(filterProvider);
  
  return allReportsAsync.when(
    data: (reports) => _applyFilters(reports, filterState),
    loading: () => <Report>[],
    error: (_, _) => <Report>[],
  );
}

/// Count of filtered reports
@riverpod
int filteredCount(Ref ref) {
  final reportsAsync = ref.watch(filteredReportsProvider);
  
  return reportsAsync.when(
    data: (reports) => reports.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
}

// ==================== FILTERING LOGIC ====================

/// Apply filters to reports list
List<Report> _applyFilters(List<Report> reports, FilterState filterState) {
  final filter = filterState.reportFilter;
  var filtered = reports;
  
  // 1. Search query
  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    final query = filter.searchQuery!.toLowerCase();
    filtered = filtered.where((r) {
      final location = r.location.toLowerCase();
      final description = (r.description ?? '').toLowerCase();
      final userName = r.userName.toLowerCase();
      return location.contains(query) || 
             description.contains(query) || 
             userName.contains(query);
    }).toList();
  }
  
  // 2. Status filter
  if (filter.statuses != null && filter.statuses!.isNotEmpty) {
    filtered = filtered.where((r) {
      return filter.statuses!.contains(r.status.name);
    }).toList();
  }
  
  // 3. Location filter
  if (filter.locations != null && filter.locations!.isNotEmpty) {
    filtered = filtered.where((r) {
      return filter.locations!.contains(r.location);
    }).toList();
  }
  
  // 4. Date range filter
  if (filter.startDate != null && filter.endDate != null) {
    filtered = filtered.where((r) {
      final reportDate = r.date;
      return reportDate.isAfter(filter.startDate!) &&
             reportDate.isBefore(filter.endDate!);
    }).toList();
  }
  
  // 5. Urgent filter
  if (filter.isUrgent != null) {
    filtered = filtered.where((r) => r.isUrgent == filter.isUrgent).toList();
  }
  
  // 6. Assigned to filter
  if (filter.assignedTo != null) {
    filtered = filtered.where((r) => r.cleanerId == filter.assignedTo).toList();
  }
  
  return filtered;
}

