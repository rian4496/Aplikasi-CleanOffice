import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../services/firestore_service.dart';

// ==================== SERVICE PROVIDER ====================

/// Provider untuk FirestoreService singleton instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ==================== STREAM PROVIDERS ====================

/// Provider untuk stream semua laporan
/// Digunakan oleh supervisor untuk melihat semua laporan
final allReportsProvider = StreamProvider.family<List<Report>, String?>((
  ref,
  departmentId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllReports(departmentId: departmentId);
});

/// Provider untuk stream laporan berdasarkan user ID
final userReportsProvider = StreamProvider.family<List<Report>, String>((
  ref,
  userId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getReportsByUser(userId);
});

/// Provider untuk stream laporan berdasarkan cleaner ID
final cleanerReportsProvider = StreamProvider.family<List<Report>, String>((
  ref,
  cleanerId,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getReportsByCleaner(cleanerId);
});

/// Provider untuk stream laporan berdasarkan status
final reportsByStatusProvider =
    StreamProvider.family<List<Report>, ReportStatusQuery>((ref, query) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getReportsByStatus(
        query.status,
        departmentId: query.departmentId,
      );
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
    StreamProvider.family<Map<ReportStatus, int>, String?>((ref, departmentId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getReportSummary(departmentId: departmentId);
    });

/// Provider untuk laporan yang selesai hari ini
final todayCompletedReportsProvider =
    StreamProvider.family<List<Report>, String?>((ref, departmentId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getTodayCompletedReports(departmentId: departmentId);
    });

// ==================== FUTURE PROVIDERS ====================

/// Provider untuk mendapatkan single report by ID
final reportByIdProvider = FutureProvider.family<Report?, String>((
  ref,
  reportId,
) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getReportById(reportId);
});

/// Provider untuk average completion time
final averageCompletionTimeProvider = FutureProvider.family<Duration?, String?>(
  (ref, departmentId) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getAverageCompletionTime(departmentId: departmentId);
  },
);

/// Provider untuk cleaner statistics
final cleanerStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, cleanerId) async {
      final service = ref.watch(firestoreServiceProvider);
      return service.getCleanerStats(cleanerId);
    });

// ==================== NOTIFIER PROVIDERS (Riverpod 3.0+) ====================

/// State class untuk filter dan sorting laporan
class ReportFilterState {
  final ReportStatus? statusFilter;
  final bool showUrgentOnly;
  final String? departmentFilter;
  final ReportSortBy sortBy;

  const ReportFilterState({
    this.statusFilter,
    this.showUrgentOnly = false,
    this.departmentFilter,
    this.sortBy = ReportSortBy.newest,
  });

  ReportFilterState copyWith({
    ReportStatus? statusFilter,
    bool? showUrgentOnly,
    String? departmentFilter,
    ReportSortBy? sortBy,
  }) {
    return ReportFilterState(
      statusFilter: statusFilter ?? this.statusFilter,
      showUrgentOnly: showUrgentOnly ?? this.showUrgentOnly,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

enum ReportSortBy { newest, oldest, urgent, location }

/// Notifier untuk mengelola filter dan sorting laporan (Riverpod 3.0+)
class ReportFilterNotifier extends Notifier<ReportFilterState> {
  @override
  ReportFilterState build() {
    return const ReportFilterState();
  }

  void setStatusFilter(ReportStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void toggleUrgentFilter() {
    state = state.copyWith(showUrgentOnly: !state.showUrgentOnly);
  }

  void setDepartmentFilter(String? departmentId) {
    state = state.copyWith(departmentFilter: departmentId);
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

    // Apply status filter
    if (filterState.statusFilter != null) {
      filtered = filtered
          .where((r) => r.status == filterState.statusFilter)
          .toList();
    }

    // Apply urgent filter
    if (filterState.showUrgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
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
