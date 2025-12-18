// lib/providers/riverpod/cleaner_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../services/supabase_database_service.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';

final _logger = AppLogger('CleanerProviders');

// ==================== CLEANER LIST PROVIDER ====================

/// Model for cleaner list display
class CleanerInfo {
  final String id;
  final String? name;
  final String? department;
  
  CleanerInfo({required this.id, this.name, this.department});
}

/// Provider untuk semua daftar cleaner
final allCleanersProvider = FutureProvider<List<CleanerInfo>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  try {
    final profiles = await service.getAllUserProfiles();
    return profiles
        .where((p) => p.role == 'cleaner')
        .map((p) => CleanerInfo(
              id: p.uid,
              name: p.displayName,
              department: p.departmentId,
            ))
        .toList();
  } catch (e) {
    _logger.warning('Could not fetch cleaners: $e');
    return [];
  }
});

// ==================== CLEANER REPORTS PROVIDERS ====================

/// Provider untuk pending reports (belum diambil siapa-siapa)
final pendingReportsProvider = FutureProvider<List<Report>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportsByStatus('pending');
});

/// Provider untuk cleaner's active reports (assigned & in_progress)
/// NOTE: Returns empty list if cleaner_id column doesn't exist in DB
final cleanerActiveReportsProvider = FutureProvider<List<Report>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  try {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return await service.getReportsByCleanerId(userId);
  } catch (e) {
    // If cleaner_id column doesn't exist, return empty list silently
    _logger.warning('Could not fetch cleaner reports: $e');
    return [];
  }
});

/// Provider untuk single report by ID
final reportDetailProvider =
    FutureProvider.family<Report?, String>((ref, reportId) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getReportById(reportId);
});

// ==================== CLEANER REQUESTS PROVIDERS ====================

/// Provider untuk available requests (pending & not assigned)
final availableRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByStatus('pending');
});

/// Provider untuk cleaner's assigned requests
final cleanerAssignedRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByCleanerId(userId);
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
      'avgWorkTimeMinutes': 0,
      'completedToday': 0,
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
      final completedReports = activeReports
          .where((r) =>
              r.status == ReportStatus.completed ||
              r.status == ReportStatus.verified)
          .toList();
      final completed = completedReports.length;
      
      // Calculate average work time from completed reports
      int avgWorkTimeMinutes = 0;
      final reportsWithTime = completedReports.where((r) => 
          r.startedAt != null && r.completedAt != null).toList();
      if (reportsWithTime.isNotEmpty) {
        final totalMinutes = reportsWithTime.fold<int>(0, (sum, r) {
          final duration = r.completedAt!.difference(r.startedAt!);
          return sum + duration.inMinutes;
        });
        avgWorkTimeMinutes = (totalMinutes / reportsWithTime.length).round();
      }
      
      // Count completed today
      final today = DateTime.now();
      final completedToday = completedReports.where((r) => 
          r.completedAt != null &&
          r.completedAt!.year == today.year &&
          r.completedAt!.month == today.month &&
          r.completedAt!.day == today.day).length;
      
      // Count completed this month
      final completedThisMonth = completedReports.where((r) => 
          r.completedAt != null &&
          r.completedAt!.year == today.year &&
          r.completedAt!.month == today.month).length;

      return {
        'assigned': assigned,
        'inProgress': inProgress,
        'completed': completed,
        'total': assigned + inProgress + completed,
        'avgWorkTimeMinutes': avgWorkTimeMinutes,
        'completedToday': completedToday,
        'completedThisMonth': completedThisMonth,
      };
    },
    loading: () => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
      'avgWorkTimeMinutes': 0,
      'completedToday': 0,
      'completedThisMonth': 0,
    },
    error: (error, stack) => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
      'avgWorkTimeMinutes': 0,
      'completedToday': 0,
      'completedThisMonth': 0,
    },
  );
});

/// Provider for cleaner's completed reports (for statistics history)
final cleanerCompletedReportsProvider = FutureProvider<List<Report>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  try {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    final allReports = await service.getReportsByCleanerId(userId);
    // Filter only completed reports and sort by completedAt descending
    final completedReports = allReports
        .where((r) => r.status == ReportStatus.completed && r.completedAt != null)
        .toList()
      ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));
    return completedReports;
  } catch (e) {
    _logger.warning('Could not fetch completed reports: $e');
    return [];
  }
});

// ==================== CLEANER ACTIONS ====================

/// Notifier untuk cleaner actions
class CleanerActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  SupabaseDatabaseService get _service =>
      ref.read(supabaseDatabaseServiceProvider);

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
        reportId: reportId,
        cleanerId: profile.uid,
        cleanerName: profile.displayName,
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

      await _service.updateReportStatus(reportId, 'in_progress');

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

      await _service.updateReportStatus(reportId, 'completed');

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

      await _service.updateReport(reportId, {
        'status': 'completed',
        'completion_image_url': completionImageUrl,
        'completed_at': DateTime.now().toIso8601String(),
      });

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

      await _service.assignRequestToCleaner(
        requestId: requestId,
        cleanerId: profile.uid,
        cleanerName: profile.displayName,
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

      await _service.updateRequestStatus(requestId, 'in_progress');

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

      await _service.updateRequestStatus(requestId, 'completed');

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

      await _service.updateRequest(requestId, {
        'status': 'completed',
        'completion_image_url': completionImageUrl,
        'completed_at': DateTime.now().toIso8601String(),
      });

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
