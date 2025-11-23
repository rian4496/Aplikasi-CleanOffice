// lib/providers/riverpod/cleaner_providers.dart
// Cleaner providers - Migrated to Appwrite

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../services/appwrite_database_service.dart';
import './auth_providers.dart';
import './inventory_providers.dart';

final _logger = AppLogger('CleanerProviders');

// ==================== CLEANER REPORTS PROVIDERS ====================

/// Provider untuk pending reports (belum diambil siapa-siapa)
final pendingReportsProvider = StreamProvider<List<Report>>((ref) {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getReportsByStatus(ReportStatus.pending);
});

/// Provider untuk cleaner's active reports (assigned & in_progress)
final cleanerActiveReportsProvider = StreamProvider<List<Report>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getReportsByCleaner(userId);
});

/// Provider untuk single report by ID
final reportDetailProvider =
    StreamProvider.family<Report?, String>((ref, reportId) {
  final service = ref.watch(appwriteDatabaseServiceProvider);

  // Use a stream that emits the report once and listens for changes
  return Stream.fromFuture(service.getReportById(reportId));
});

// ==================== CLEANER REQUESTS PROVIDERS ====================

/// Provider untuk available requests (pending & not assigned)
final availableRequestsProvider = StreamProvider<List<Request>>((ref) {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getPendingServiceRequests();
});

/// Provider untuk cleaner's assigned requests
final cleanerAssignedRequestsProvider = StreamProvider<List<Request>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getServiceRequestsByCleaner(userId);
});

// ==================== CLEANER STATISTICS ====================

/// Provider untuk cleaner statistics
final cleanerStatsProvider = Provider<Map<String, int>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    };
  }

  final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);

  return activeReportsAsync.when(
    data: (activeReports) {
      final assigned =
          activeReports.where((r) => r.status == ReportStatus.assigned).length;
      final inProgress = activeReports
          .where((r) => r.status == ReportStatus.inProgress)
          .length;
      final completed = activeReports
          .where((r) =>
              r.status == ReportStatus.completed ||
              r.status == ReportStatus.verified)
          .length;

      return {
        'assigned': assigned,
        'inProgress': inProgress,
        'completed': completed,
        'total': assigned + inProgress + completed,
      };
    },
    loading: () => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    },
    error: (error, stack) => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    },
  );
});

// ==================== CLEANER ACTIONS ====================

/// Notifier untuk cleaner actions
class CleanerActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AppwriteDatabaseService get _service =>
      ref.read(appwriteDatabaseServiceProvider);

  // ==================== REPORT ACTIONS ====================

  /// Accept a report (pending → assigned)
  Future<void> acceptReport(String reportId) async {
    state = const AsyncValue.loading();

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Accepting report: $reportId by user: ${profile.uid}');

      await _service.assignReportToCleaner(
        reportId,
        profile.uid,
        profile.displayName,
      );

      _logger.info('Report accepted successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Accept report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Start working on a report (assigned → in_progress)
  Future<void> startReport(String reportId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Starting report: $reportId');

      await _service.updateReportStatus(reportId, ReportStatus.inProgress);

      _logger.info('Report started successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Start report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a report (in_progress → completed) - TANPA FOTO
  Future<void> completeReport(String reportId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing report: $reportId');

      await _service.updateReportStatus(reportId, ReportStatus.completed);

      _logger.info('Report completed successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Complete report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a report WITH PROOF PHOTO (in_progress → completed)
  Future<void> completeReportWithProof(
    String reportId,
    String completionImageUrl,
  ) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing report with proof: $reportId');

      await _service.completeReportWithProof(reportId, completionImageUrl);

      _logger.info('Report completed with proof successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Complete report with proof error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // ==================== REQUEST ACTIONS ====================

  /// Accept a cleaning request
  Future<void> acceptRequest(String requestId) async {
    state = const AsyncValue.loading();

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Accepting request: $requestId by user: ${profile.uid}');

      await _service.selfAssignServiceRequest(
        requestId,
        profile.uid,
        profile.displayName,
      );

      _logger.info('Request accepted successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Accept request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Start working on a request
  Future<void> startRequest(String requestId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Starting request: $requestId');

      await _service.startServiceRequest(requestId);

      _logger.info('Request started successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Start request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a request - TANPA FOTO
  Future<void> completeRequest(String requestId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing request: $requestId');

      await _service.completeServiceRequest(requestId);

      _logger.info('Request completed successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Complete request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a request WITH PROOF PHOTO (in_progress → completed)
  Future<void> completeRequestWithProof(
    String requestId,
    String completionImageUrl,
  ) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing request with proof: $requestId');

      await _service.completeServiceRequest(
        requestId,
        completionImageUrl: completionImageUrl,
      );

      _logger.info('Request completed with proof successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Complete request with proof error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Create a new cleaning report
  Future<void> createCleaningReport({
    required String title,
    required String location,
    required String description,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Creating cleaning report');

      final report = Report(
        id: '',
        title: title,
        location: location,
        description: description,
        date: DateTime.now(),
        status: ReportStatus.completed,
        userId: profile.uid,
        userName: profile.displayName,
        userEmail: profile.email,
        cleanerId: profile.uid,
        cleanerName: profile.displayName,
        imageUrl: imageUrl,
        isUrgent: false,
        assignedAt: DateTime.now(),
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        departmentId: profile.departmentId,
      );

      await _service.createReport(report);

      _logger.info('Cleaning report created successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Create cleaning report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final cleanerActionsProvider =
    NotifierProvider<CleanerActionsNotifier, AsyncValue<void>>(
  () => CleanerActionsNotifier(),
);
