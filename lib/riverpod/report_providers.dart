// lib/riverpod/report_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import './supabase_service_providers.dart';

// ==================== STREAM/FUTURE PROVIDERS ====================

/// Provider untuk stream semua laporan
/// Digunakan oleh supervisor untuk melihat semua laporan
/// Note: Converted from Stream to FutureProvider for Supabase compatibility
final allReportsProvider = FutureProvider.family<List<Report>, String?>((
  ref,
  departmentId,
) async {
  // Keep provider alive for caching
  ref.keepAlive();

  final service = ref.watch(supabaseDatabaseServiceProvider);
  final reports = await service.getAllReports();
  
  // Filter by department if specified
  if (departmentId != null && departmentId.isNotEmpty) {
    return reports.where((r) => r.departmentId == departmentId).toList();
  }
  return reports;
});

/// Provider untuk stream laporan berdasarkan user ID
final userReportsProvider = FutureProvider.autoDispose.family<List<Report>, String>((
  ref,
  userId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportsByUserId(userId);
});

/// Provider untuk stream laporan berdasarkan cleaner ID
final cleanerReportsProvider = FutureProvider.autoDispose.family<List<Report>, String>((
  ref,
  cleanerId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportsByCleanerId(cleanerId);
});

/// Provider untuk stream laporan berdasarkan status
final reportsByStatusProvider =
    FutureProvider.autoDispose.family<List<Report>, ReportStatusQuery>((ref, query) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      final reports = await service.getReportsByStatus(query.status.toDatabase());
      
      // Filter by department if specified
      if (query.departmentId != null && query.departmentId!.isNotEmpty) {
        return reports.where((r) => r.departmentId == query.departmentId).toList();
      }
      return reports;
    });

/// Helper class untuk query dengan status dan departmentId
class ReportStatusQuery {
  final ReportStatus status;
  final String? departmentId;

  const ReportStatusQuery({required this.status, this.departmentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportStatusQuery &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          departmentId == other.departmentId;

  @override
  int get hashCode => status.hashCode ^ departmentId.hashCode;
}

/// Provider untuk summary report berdasarkan status
final reportSummaryProvider =
    FutureProvider.autoDispose.family<Map<ReportStatus, int>, String?>((ref, departmentId) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      final allReports = await service.getAllReports();
      
      // Filter by department if specified
      final reports = departmentId != null && departmentId.isNotEmpty
          ? allReports.where((r) => r.departmentId == departmentId).toList()
          : allReports;
      
      // Build summary map
      final summary = <ReportStatus, int>{};
      for (final status in ReportStatus.values) {
        summary[status] = reports.where((r) => r.status == status).length;
      }
      return summary;
    });

/// Provider untuk laporan yang selesai hari ini
final todayCompletedReportsProvider =
    FutureProvider.autoDispose.family<List<Report>, String?>((ref, departmentId) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      final allReports = await service.getAllReports();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      return allReports.where((r) {
        // Check if completed or verified today
        if (r.status != ReportStatus.completed && r.status != ReportStatus.verified) {
          return false;
        }
        
        // Check department filter
        if (departmentId != null && r.departmentId != departmentId) {
          return false;
        }
        
        // Check if completed today
        final completedAt = r.completedAt;
        if (completedAt == null) return false;
        
        return completedAt.isAfter(today) && completedAt.isBefore(tomorrow);
      }).toList();
    });

// ==================== FUTURE PROVIDERS ====================

/// Provider untuk mendapatkan single report by ID
final reportByIdProvider = FutureProvider.family<Report?, String>((
  ref,
  reportId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportById(reportId);
});

/// Provider untuk average completion time
final averageCompletionTimeProvider = FutureProvider.family<Duration?, String?>(
  (ref, departmentId) async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    final allReports = await service.getAllReports();
    
    // Filter verified reports
    final reports = allReports.where((r) {
      if (r.status != ReportStatus.verified) return false;
      if (departmentId != null && r.departmentId != departmentId) return false;
      return r.completedAt != null;
    }).toList();
    
    if (reports.isEmpty) return null;
    
    // Calculate average completion time
    int totalMinutes = 0;
    int count = 0;
    
    for (final report in reports) {
      if (report.completedAt != null) {
        final duration = report.completedAt!.difference(report.date);
        totalMinutes += duration.inMinutes;
        count++;
      }
    }
    
    if (count == 0) return null;
    
    return Duration(minutes: totalMinutes ~/ count);
  },
);

/// Provider untuk cleaner statistics
final cleanerStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, cleanerId) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      final reports = await service.getReportsByCleanerId(cleanerId);
      
      return {
        'totalAssigned': reports.length,
        'completed': reports.where((r) => r.status == ReportStatus.completed).length,
        'verified': reports.where((r) => r.status == ReportStatus.verified).length,
        'inProgress': reports.where((r) => r.status == ReportStatus.inProgress).length,
        'pending': reports.where((r) => r.status == ReportStatus.assigned).length,
      };
    });

// ==================== NOTIFIER PROVIDERS (Riverpod 3.0+) ====================

/// State class untuk filter dan sorting laporan
class ReportFilterState {
  final String? searchQuery;
  final List<ReportStatus>? statusFilter; // Changed to List for multiple selection
  final List<String>? locationFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showUrgentOnly;
  final String? departmentFilter;
  final String? assignedToFilter;
  final ReportSortBy sortBy;

  const ReportFilterState({
    this.searchQuery,
    this.statusFilter,
    this.locationFilter,
    this.startDate,
    this.endDate,
    this.showUrgentOnly = false,
    this.departmentFilter,
    this.assignedToFilter,
    this.sortBy = ReportSortBy.newest,
  });

  ReportFilterState copyWith({
    String? searchQuery,
    List<ReportStatus>? statusFilter,
    List<String>? locationFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool? showUrgentOnly,
    String? departmentFilter,
    String? assignedToFilter,
    ReportSortBy? sortBy,
  }) {
    return ReportFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      locationFilter: locationFilter ?? this.locationFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      showUrgentOnly: showUrgentOnly ?? this.showUrgentOnly,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      assignedToFilter: assignedToFilter ?? this.assignedToFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
  
  bool get isEmpty => 
      searchQuery == null && 
      (statusFilter == null || statusFilter!.isEmpty) &&
      (locationFilter == null || locationFilter!.isEmpty) &&
      startDate == null &&
      endDate == null &&
      !showUrgentOnly &&
      assignedToFilter == null;
      
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (statusFilter != null && statusFilter!.isNotEmpty) count++;
    if (locationFilter != null && locationFilter!.isNotEmpty) count++;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (showUrgentOnly) count++;
    if (assignedToFilter != null) count++;
    return count;
  }
}

enum ReportSortBy { newest, oldest, urgent, location }

/// Notifier untuk mengelola filter dan sorting laporan (Riverpod 3.0+)
class ReportFilterNotifier extends Notifier<ReportFilterState> {
  @override
  ReportFilterState build() {
    return const ReportFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(List<ReportStatus>? statuses) {
    state = state.copyWith(statusFilter: statuses);
  }
  
  void setLocationFilter(List<String>? locations) {
    state = state.copyWith(locationFilter: locations);
  }
  
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void toggleUrgentFilter() {
    state = state.copyWith(showUrgentOnly: !state.showUrgentOnly);
  }

  void setDepartmentFilter(String? departmentId) {
    state = state.copyWith(departmentFilter: departmentId);
  }
  
  void setAssignedToFilter(String? cleanerId) {
    state = state.copyWith(assignedToFilter: cleanerId);
  }

  void setSortBy(ReportSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const ReportFilterState();
  }
}

final reportFilterProvider =
    NotifierProvider<ReportFilterNotifier, ReportFilterState>(() {
      return ReportFilterNotifier();
    });

/// Provider untuk filtered reports berdasarkan filter state
final filteredReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final filterState = ref.watch(reportFilterProvider);
  final allReportsAsync = ref.watch(
    allReportsProvider(filterState.departmentFilter),
  );

  return allReportsAsync.whenData((reports) {
    var filtered = reports;

    // 1. Search Query
    if (filterState.searchQuery != null && filterState.searchQuery!.isNotEmpty) {
      final query = filterState.searchQuery!.toLowerCase();
      filtered = filtered.where((r) =>
        r.location.toLowerCase().contains(query) ||
        (r.description?.toLowerCase().contains(query) ?? false) ||
        r.userName.toLowerCase().contains(query)
      ).toList();
    }

    // 2. Status Filter
    if (filterState.statusFilter != null && filterState.statusFilter!.isNotEmpty) {
      filtered = filtered
          .where((r) => filterState.statusFilter!.contains(r.status))
          .toList();
    }
    
    // 3. Location Filter
    if (filterState.locationFilter != null && filterState.locationFilter!.isNotEmpty) {
      filtered = filtered
          .where((r) => filterState.locationFilter!.contains(r.location))
          .toList();
    }
    
    // 4. Date Range
    if (filterState.startDate != null) {
      filtered = filtered.where((r) => 
        r.date.isAfter(filterState.startDate!)
      ).toList();
    }
    
    if (filterState.endDate != null) {
      // Add 1 day to include the end date fully
      final end = filterState.endDate!.add(const Duration(days: 1));
      filtered = filtered.where((r) => 
        r.date.isBefore(end)
      ).toList();
    }

    // 5. Urgent Filter
    if (filterState.showUrgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }
    
    // 6. Assigned To Filter
    if (filterState.assignedToFilter != null) {
      // Note: This assumes we have assignedToId in Report, or we filter by cleanerName if ID not available
      // Checking Report model... assuming cleanerId exists or similar
      filtered = filtered.where((r) => r.cleanerId == filterState.assignedToFilter).toList();
    }

    // Apply sorting
    switch (filterState.sortBy) {
      case ReportSortBy.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ReportSortBy.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ReportSortBy.urgent:
        filtered.sort((a, b) {
          if (a.isUrgent == b.isUrgent) return b.date.compareTo(a.date);
          return a.isUrgent ? -1 : 1;
        });
        break;
      case ReportSortBy.location:
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
    }

    return filtered;
  });
});
