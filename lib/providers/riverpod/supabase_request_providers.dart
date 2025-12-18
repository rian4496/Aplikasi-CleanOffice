import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../services/supabase_database_service.dart';

// ==================== SERVICE PROVIDER ====================

/// Provider untuk SupabaseDatabaseService singleton instance
/// (Reuse dari supabase_report_providers)
final supabaseDatabaseServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  return SupabaseDatabaseService();
});

// ==================== FUTURE PROVIDERS ====================

/// Provider untuk semua requests
final allRequestsProvider = FutureProvider.autoDispose<List<Request>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getAllRequests();
});

/// Provider untuk request berdasarkan user ID
final userRequestsProvider = FutureProvider.autoDispose.family<List<Request>, String>((
  ref,
  userId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByUserId(userId);
});

/// Provider untuk request berdasarkan cleaner ID
final cleanerRequestsProvider = FutureProvider.autoDispose.family<List<Request>, String>((
  ref,
  cleanerId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByCleanerId(cleanerId);
});

/// Provider untuk request berdasarkan status
final requestsByStatusProvider =
    FutureProvider.autoDispose.family<List<Request>, String>((ref, status) async {
      final service = ref.watch(supabaseDatabaseServiceProvider);
      return service.getRequestsByStatus(status);
    });

/// Provider untuk mendapatkan single request by ID
final requestByIdProvider = FutureProvider.autoDispose.family<Request?, String>((
  ref,
  requestId,
) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestById(requestId);
});

// ==================== NOTIFIER PROVIDERS (Riverpod 3.0+) ====================

/// State class untuk filter dan sorting requests
class RequestFilterState {
  final String? searchQuery;
  final List<RequestStatus>? statusFilter; // Multiple status selection
  final List<String>? locationFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showUrgentOnly;
  final String? assignedToFilter;
  final RequestSortBy sortBy;

  const RequestFilterState({
    this.searchQuery,
    this.statusFilter,
    this.locationFilter,
    this.startDate,
    this.endDate,
    this.showUrgentOnly = false,
    this.assignedToFilter,
    this.sortBy = RequestSortBy.newest,
  });

  RequestFilterState copyWith({
    String? searchQuery,
    List<RequestStatus>? statusFilter,
    List<String>? locationFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool? showUrgentOnly,
    String? assignedToFilter,
    RequestSortBy? sortBy,
  }) {
    return RequestFilterState(
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

enum RequestSortBy { newest, oldest, urgent, location }

/// Notifier untuk mengelola filter dan sorting requests (Riverpod 3.0+)
class RequestFilterNotifier extends Notifier<RequestFilterState> {
  @override
  RequestFilterState build() {
    return const RequestFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(List<RequestStatus>? statuses) {
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

  void setSortBy(RequestSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const RequestFilterState();
  }
}

final requestFilterProvider =
    NotifierProvider<RequestFilterNotifier, RequestFilterState>(() {
      return RequestFilterNotifier();
    });

/// Provider untuk filtered requests berdasarkan filter state
final filteredRequestsProvider = FutureProvider.autoDispose<List<Request>>((ref) async {
  final filterState = ref.watch(requestFilterProvider);
  final allRequestsAsync = await ref.watch(allRequestsProvider.future);

  var filtered = allRequestsAsync;

  // 1. Search Query
  if (filterState.searchQuery != null && filterState.searchQuery!.isNotEmpty) {
    final query = filterState.searchQuery!.toLowerCase();
    filtered = filtered.where((r) =>
      r.location.toLowerCase().contains(query) ||
      r.description.toLowerCase().contains(query) ||
      r.requestedByName.toLowerCase().contains(query)
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
      r.createdAt.isAfter(filterState.startDate!) ||
      r.createdAt.isAtSameMomentAs(filterState.startDate!)
    ).toList();
  }

  if (filterState.endDate != null) {
    // Add 1 day to include the end date fully
    final end = filterState.endDate!.add(const Duration(days: 1));
    filtered = filtered.where((r) =>
      r.createdAt.isBefore(end)
    ).toList();
  }

  // 5. Urgent Filter
  if (filterState.showUrgentOnly) {
    filtered = filtered.where((r) => r.isUrgent).toList();
  }

  // 6. Assigned To Filter
  if (filterState.assignedToFilter != null) {
    filtered = filtered.where((r) => r.assignedTo == filterState.assignedToFilter).toList();
  }

  // Apply sorting
  switch (filterState.sortBy) {
    case RequestSortBy.newest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case RequestSortBy.oldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case RequestSortBy.urgent:
      filtered.sort((a, b) {
        if (a.isUrgent == b.isUrgent) return b.createdAt.compareTo(a.createdAt);
        return a.isUrgent ? -1 : 1;
      });
      break;
    case RequestSortBy.location:
      filtered.sort((a, b) => a.location.compareTo(b.location));
      break;
  }

  return filtered;
});

// ==================== STATISTICS PROVIDERS ====================

/// Provider untuk request summary by status
final requestSummaryProvider = FutureProvider.autoDispose<Map<RequestStatus, int>>((ref) async {
  final requests = await ref.watch(allRequestsProvider.future);

  final summary = <RequestStatus, int>{};
  for (final status in RequestStatus.values) {
    summary[status] = requests.where((r) => r.status == status).length;
  }

  return summary;
});

/// Provider untuk requests yang selesai hari ini
final todayCompletedRequestsProvider = FutureProvider.autoDispose<List<Request>>((ref) async {
  final requests = await ref.watch(allRequestsProvider.future);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return requests.where((r) {
    return r.status == RequestStatus.completed &&
           r.completedAt != null &&
           r.completedAt!.isAfter(today) &&
           r.completedAt!.isBefore(tomorrow);
  }).toList();
});

/// Provider untuk average completion time
final averageCompletionTimeProvider = FutureProvider.autoDispose<Duration?>((ref) async {
  final requests = await ref.watch(allRequestsProvider.future);

  final completedRequests = requests.where((r) =>
    r.status == RequestStatus.completed &&
    r.startedAt != null &&
    r.completedAt != null
  ).toList();

  if (completedRequests.isEmpty) return null;

  final totalDuration = completedRequests.fold<Duration>(
    Duration.zero,
    (sum, r) => sum + r.completedAt!.difference(r.startedAt!),
  );

  return Duration(
    milliseconds: totalDuration.inMilliseconds ~/ completedRequests.length,
  );
});

/// Provider untuk cleaner statistics
final cleanerRequestStatsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, cleanerId) async {
      final requests = await ref.watch(cleanerRequestsProvider(cleanerId).future);

      final completed = requests.where((r) => r.status == RequestStatus.completed).length;
      final inProgress = requests.where((r) => r.status == RequestStatus.inProgress).length;
      final pending = requests.where((r) => r.status == RequestStatus.pending).length;

      // Calculate average completion time
      final completedRequests = requests.where((r) =>
        r.status == RequestStatus.completed &&
        r.startedAt != null &&
        r.completedAt != null
      ).toList();

      Duration? avgTime;
      if (completedRequests.isNotEmpty) {
        final totalDuration = completedRequests.fold<Duration>(
          Duration.zero,
          (sum, r) => sum + r.completedAt!.difference(r.startedAt!),
        );
        avgTime = Duration(
          milliseconds: totalDuration.inMilliseconds ~/ completedRequests.length,
        );
      }

      return {
        'total': requests.length,
        'completed': completed,
        'inProgress': inProgress,
        'pending': pending,
        'averageCompletionTime': avgTime,
        'completionRate': requests.isEmpty ? 0.0 : (completed / requests.length) * 100,
      };
    });

// ==================== MUTATION PROVIDERS ====================

/// Provider untuk create request
final createRequestProvider = Provider<Future<Request> Function(Request)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (Request request) async {
    final created = await service.createRequest(request);

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(userRequestsProvider);
    ref.invalidate(requestSummaryProvider);

    return created;
  };
});

/// Provider untuk update request
final updateRequestProvider = Provider<Future<void> Function(String, Map<String, dynamic>)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String requestId, Map<String, dynamic> updates) async {
    await service.updateRequest(requestId, updates);

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(requestByIdProvider(requestId));
    ref.invalidate(userRequestsProvider);
    ref.invalidate(cleanerRequestsProvider);
    ref.invalidate(requestSummaryProvider);
  };
});

/// Provider untuk update request status
final updateRequestStatusProvider = Provider<Future<void> Function(String, String)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String requestId, String status) async {
    await service.updateRequestStatus(requestId, status);

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(requestByIdProvider(requestId));
    ref.invalidate(requestsByStatusProvider);
    ref.invalidate(userRequestsProvider);
    ref.invalidate(cleanerRequestsProvider);
    ref.invalidate(requestSummaryProvider);
  };
});

/// Provider untuk assign request to cleaner
final assignRequestProvider = Provider<Future<void> Function({
  required String requestId,
  required String cleanerId,
  required String cleanerName,
  String? assignedBy,
})>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return ({
    required String requestId,
    required String cleanerId,
    required String cleanerName,
    String? assignedBy,
  }) async {
    await service.assignRequestToCleaner(
      requestId: requestId,
      cleanerId: cleanerId,
      cleanerName: cleanerName,
      assignedBy: assignedBy,
    );

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(requestByIdProvider(requestId));
    ref.invalidate(cleanerRequestsProvider(cleanerId));
    ref.invalidate(requestsByStatusProvider);
  };
});

/// Provider untuk cancel request
final cancelRequestProvider = Provider<Future<void> Function(String, String)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String requestId, String cancelledBy) async {
    await service.cancelRequest(requestId, cancelledBy);

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(requestByIdProvider(requestId));
    ref.invalidate(userRequestsProvider);
    ref.invalidate(cleanerRequestsProvider);
    ref.invalidate(requestSummaryProvider);
  };
});

/// Provider untuk delete request
final deleteRequestProvider = Provider<Future<void> Function(String, String)>((ref) {
  final service = ref.read(supabaseDatabaseServiceProvider);

  return (String requestId, String deletedBy) async {
    await service.deleteRequest(requestId, deletedBy);

    // Invalidate providers to refresh data
    ref.invalidate(allRequestsProvider);
    ref.invalidate(requestByIdProvider(requestId));
    ref.invalidate(userRequestsProvider);
    ref.invalidate(cleanerRequestsProvider);
    ref.invalidate(requestSummaryProvider);
  };
});

