import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../services/supabase_database_service.dart';

// ==================== SERVICE PROVIDER ====================

/// Provider untuk SupabaseDatabaseService singleton instance
final supabaseDatabaseServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  return SupabaseDatabaseService();
});

// ==================== FUTURE PROVIDERS ====================

/// Provider untuk semua laporan
/// Digunakan oleh supervisor untuk melihat semua laporan
final allReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getAllReports();
});

/// Provider untuk laporan berdasarkan user ID
final userReportsProvider = FutureProvider.autoDispose.family<List<Report>, String>((
  ref,
  userId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportsByUserId(userId);
});

/// Provider untuk laporan berdasarkan cleaner ID
final cleanerReportsProvider = FutureProvider.autoDispose.family<List<Report>, String>((
  ref,
  cleanerId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportsByCleanerId(cleanerId);
});

/// Provider untuk laporan berdasarkan status
final reportsByStatusProvider =
    FutureProvider.autoDispose.family<List<Report>, String>((ref, status) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      return service.getReportsByStatus(status);
    });

/// Provider untuk mendapatkan single report by ID
final reportByIdProvider = FutureProvider.autoDispose.family<Report?, String>((
  ref,
  reportId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportById(reportId);
});

// ==================== NOTIFIER PROVIDERS (Riverpod 3.0+) ====================

/// State class untuk filter dan sorting laporan
class ReportFilterState {
  final String? searchQuery;
  final List<ReportStatus>? statusFilter; // Multiple status selection
  final List<String>? locationFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showUrgentOnly;
  final String? assignedToFilter;
  final ReportSortBy sortBy;

  const ReportFilterState({
    this.searchQuery,
    this.statusFilter,
    this.locationFilter,
    this.startDate,
    this.endDate,
    this.showUrgentOnly = false,
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
final filteredReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  final filterState = ref.watch(reportFilterProvider);
  final allReportsAsync = await ref.watch(allReportsProvider.future);

  var filtered = allReportsAsync;

  // 1. Search Query
  if (filterState.searchQuery != null && filterState.searchQuery!.isNotEmpty) {
    final query = filterState.searchQuery!.toLowerCase();
    filtered = filtered.where((r) =>
      r.location.toLowerCase().contains(query) ||
      (r.description?.toLowerCase().contains(query) ?? false) ||
      r.userName.toLowerCase().contains(query) ||
      (r.title.toLowerCase().contains(query))
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
      r.date.isAfter(filterState.startDate!) ||
      r.date.isAtSameMomentAs(filterState.startDate!)
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

// ==================== STATISTICS PROVIDERS ====================

/// Provider untuk report summary by status
final reportSummaryProvider = FutureProvider.autoDispose<Map<ReportStatus, int>>((ref) async {
  final reports = await ref.watch(allReportsProvider.future);

  final summary = <ReportStatus, int>{};
  for (final status in ReportStatus.values) {
    summary[status] = reports.where((r) => r.status == status).length;
  }

  return summary;
});

/// Provider untuk laporan yang selesai hari ini
final todayCompletedReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  final reports = await ref.watch(allReportsProvider.future);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return reports.where((r) {
    return r.status == ReportStatus.completed &&
           r.completedAt != null &&
           r.completedAt!.isAfter(today) &&
           r.completedAt!.isBefore(tomorrow);
  }).toList();
});

/// Provider untuk average completion time
final averageCompletionTimeProvider = FutureProvider.autoDispose<Duration?>((ref) async {
  final reports = await ref.watch(allReportsProvider.future);

  final completedReports = reports.where((r) =>
    r.status == ReportStatus.completed &&
    r.startedAt != null &&
    r.completedAt != null
  ).toList();

  if (completedReports.isEmpty) return null;

  final totalDuration = completedReports.fold<Duration>(
    Duration.zero,
    (sum, r) => sum + r.completedAt!.difference(r.startedAt!),
  );

  return Duration(
    milliseconds: totalDuration.inMilliseconds ~/ completedReports.length,
  );
});

/// Provider untuk cleaner statistics
final cleanerStatsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, cleanerId) async {
      final reports = await ref.watch(cleanerReportsProvider(cleanerId).future);

      final completed = reports.where((r) => r.status == ReportStatus.completed).length;
      final inProgress = reports.where((r) => r.status == ReportStatus.inProgress).length;
      final pending = reports.where((r) => r.status == ReportStatus.pending).length;

      // Calculate average completion time
      final completedReports = reports.where((r) =>
        r.status == ReportStatus.completed &&
        r.startedAt != null &&
        r.completedAt != null
      ).toList();

      Duration? avgTime;
      if (completedReports.isNotEmpty) {
        final totalDuration = completedReports.fold<Duration>(
          Duration.zero,
          (sum, r) => sum + r.completedAt!.difference(r.startedAt!),
        );
        avgTime = Duration(
          milliseconds: totalDuration.inMilliseconds ~/ completedReports.length,
        );
      }

      return {
        'total': reports.length,
        'completed': completed,
        'inProgress': inProgress,
        'pending': pending,
        'averageCompletionTime': avgTime,
        'completionRate': reports.isEmpty ? 0.0 : (completed / reports.length) * 100,
      };
    });

// ==================== MUTATION PROVIDERS ====================

/// Provider untuk create report
final createReportProvider = Provider<Future<Report> Function(Report)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (Report report) async {
    final created = await service.createReport(report);

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(userReportsProvider);
    ref.invalidate(reportSummaryProvider);

    return created;
  };
});

/// Provider untuk update report
final updateReportProvider = Provider<Future<void> Function(String, Map<String, dynamic>)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String reportId, Map<String, dynamic> updates) async {
    await service.updateReport(reportId, updates);

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(reportByIdProvider(reportId));
    ref.invalidate(userReportsProvider);
    ref.invalidate(cleanerReportsProvider);
    ref.invalidate(reportSummaryProvider);
  };
});

/// Provider untuk update report status
final updateReportStatusProvider = Provider<Future<void> Function(String, String)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String reportId, String status) async {
    await service.updateReportStatus(reportId, status);

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(reportByIdProvider(reportId));
    ref.invalidate(reportsByStatusProvider);
    ref.invalidate(userReportsProvider);
    ref.invalidate(cleanerReportsProvider);
    ref.invalidate(reportSummaryProvider);
  };
});

/// Provider untuk verify report
final verifyReportProvider = Provider<Future<void> Function({
  required String reportId,
  required String status,
  required String verifiedBy,
  required String verifiedByName,
  String? verificationNotes,
})>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return ({
    required String reportId,
    required String status,
    required String verifiedBy,
    required String verifiedByName,
    String? verificationNotes,
  }) async {
    await service.verifyReport(
      reportId: reportId,
      status: status,
      verifiedBy: verifiedBy,
      verifiedByName: verifiedByName,
      verificationNotes: verificationNotes,
    );

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(reportByIdProvider(reportId));
    ref.invalidate(reportsByStatusProvider);
    ref.invalidate(reportSummaryProvider);
  };
});

/// Provider untuk assign report to cleaner
final assignReportProvider = Provider<Future<void> Function({
  required String reportId,
  required String cleanerId,
  required String cleanerName,
})>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return ({
    required String reportId,
    required String cleanerId,
    required String cleanerName,
  }) async {
    await service.assignReportToCleaner(
      reportId: reportId,
      cleanerId: cleanerId,
      cleanerName: cleanerName,
    );

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(reportByIdProvider(reportId));
    ref.invalidate(cleanerReportsProvider(cleanerId));
    ref.invalidate(reportsByStatusProvider);
  };
});

/// Provider untuk delete report
final deleteReportProvider = Provider<Future<void> Function(String, String)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String reportId, String deletedBy) async {
    await service.deleteReport(reportId, deletedBy);

    // Invalidate providers to refresh data
    ref.invalidate(allReportsProvider);
    ref.invalidate(reportByIdProvider(reportId));
    ref.invalidate(userReportsProvider);
    ref.invalidate(cleanerReportsProvider);
    ref.invalidate(reportSummaryProvider);
  };
});

