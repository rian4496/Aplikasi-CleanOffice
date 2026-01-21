// lib/riverpod/cleaner_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../models/ticket.dart';
import '../../services/supabase_database_service.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';
import './ticket_providers.dart';

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

/// Provider untuk cleaner's active reports (assigned & in_progress + all pending)
/// Shows all pending tickets so cleaner can pick them up
final cleanerActiveReportsProvider = FutureProvider<List<Report>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  _logger.info('cleanerActiveReportsProvider: userId = $userId');
  
  final service = ref.watch(supabaseDatabaseServiceProvider);
  
  try {
    // Always fetch pending reports (even if user is not logged in, we still want to show available tickets)
    final pendingReports = await service.getReportsByStatus('pending');
    _logger.info('cleanerActiveReportsProvider: fetched ${pendingReports.length} pending reports');
    
    List<Report> assignedReports = [];
    if (userId != null) {
      try {
        assignedReports = await service.getReportsByCleanerId(userId);
        _logger.info('cleanerActiveReportsProvider: fetched ${assignedReports.length} assigned reports for user $userId');
      } catch (e) {
        _logger.warning('Could not fetch assigned reports: $e');
        // Continue with just pending reports
      }
    }
    
    // Combine lists - use Map to deduplicate by ID
    final Map<String, Report> reportMap = {};
    for (final report in assignedReports) {
      reportMap[report.id] = report;
    }
    for (final report in pendingReports) {
      if (!reportMap.containsKey(report.id)) {
        reportMap[report.id] = report;
      }
    }
    
    final allReports = reportMap.values.toList();
    _logger.info('cleanerActiveReportsProvider: total ${allReports.length} reports after merge');
    
    // Sort: Urgent first, then newest
    allReports.sort((a, b) {
      if (a.isUrgent != b.isUrgent) {
        return a.isUrgent ? -1 : 1; 
      }
      return b.date.compareTo(a.date);
    });
    
    return allReports;
  } catch (e, stackTrace) {
    _logger.error('cleanerActiveReportsProvider error', e, stackTrace);
    throw e;
    // return [];
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
      final pending = activeReports
          .where((r) => r.status == ReportStatus.pending)
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
        'pending': pending,
        'total': assigned + inProgress + completed + pending,
        'avgWorkTimeMinutes': avgWorkTimeMinutes,
        'completedToday': completedToday,
        'completedThisMonth': completedThisMonth,
      };
    },
    loading: () => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'pending': 0,
      'total': 0,
      'avgWorkTimeMinutes': 0,
      'completedToday': 0,
      'completedThisMonth': 0,
    },
    error: (error, stack) => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'pending': 0,
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

  /// Create a new cleaning report/ticket
  /// This creates a TICKET (not Report) so it appears in Helpdesk Inbox
  Future<void> createCleaningReport({
    required String title,
    required String location,
    required String description,
    String? imageUrl,
    String? locationId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Creating cleaning ticket from cleaner report');

      // Create as a Ticket so it appears in Helpdesk Inbox
      final ticketRepo = ref.read(ticketRepositoryProvider);
      await ticketRepo.createTicket(
        title: title,
        description: description,
        type: TicketType.kebersihan,
        priority: TicketPriority.normal,
        createdBy: profile.uid,
        locationId: locationId,
        imageUrl: imageUrl,
      );

      _logger.info('Cleaning ticket created successfully - will appear in Helpdesk');
      state = const AsyncValue.data(null);
      
      // Invalidate inbox to refresh list
      ref.invalidate(cleanerInboxProvider);
    } catch (e, stackTrace) {
      _logger.error('Create cleaning ticket error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final cleanerActionsProvider =
    NotifierProvider<CleanerActionsNotifier, AsyncValue<void>>(
  () => CleanerActionsNotifier(),
);
