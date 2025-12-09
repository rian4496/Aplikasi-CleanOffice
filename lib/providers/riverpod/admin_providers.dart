// lib/providers/riverpod/admin_providers.dart
// ✅ MIGRATED TO SUPABASE
//
// FEATURES:
// - Dashboard summary providers
// - Report verification actions
// - Urgent reports tracking
// - Department-based filtering
// - Account verification

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../models/user_profile.dart';
import '../../services/supabase_database_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';
import './report_providers.dart';
import './request_providers.dart' show availableCleanersProvider;

final _logger = AppLogger('AdminProviders');

// ==================== AUTH PROVIDERS ====================
// Note: Auth providers are now in auth_providers.dart
// Re-export for backward compatibility
// - currentUserProfileProvider is in auth_providers.dart

/// Provider untuk department ID dari current user
final currentUserDepartmentProvider = Provider<String?>((ref) {
  final userProfileAsync = ref.watch(currentUserProfileProvider);
  return userProfileAsync.whenData((profile) => profile?.departmentId).value;
});

// ==================== ADMIN DASHBOARD PROVIDERS ====================

/// Provider untuk laporan yang perlu verifikasi (status: completed)
final needsVerificationReportsProvider = Provider<AsyncValue<List<Report>>>((
  ref,
) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final query = ReportStatusQuery(
    status: ReportStatus.completed,
    departmentId: departmentId,
  );
  return ref.watch(reportsByStatusProvider(query));
});

/// Provider untuk jumlah laporan yang perlu verifikasi
final needsVerificationCountProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(needsVerificationReportsProvider);
  return reportsAsync.whenData((reports) => reports.length).value ?? 0;
});

/// Provider untuk laporan pending (belum ada yang handle)
final pendingReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final query = ReportStatusQuery(
    status: ReportStatus.pending,
    departmentId: departmentId,
  );
  return ref.watch(reportsByStatusProvider(query));
});

/// Provider untuk jumlah laporan pending
final pendingReportsCountProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(pendingReportsProvider);
  return reportsAsync.whenData((reports) => reports.length).value ?? 0;
});

/// Provider untuk laporan hari ini
final todayReportsCountProvider = Provider<int>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final reportsAsync = ref.watch(todayCompletedReportsProvider(departmentId));
  return reportsAsync.whenData((reports) => reports.length).value ?? 0;
});

/// Provider untuk laporan terverifikasi hari ini
final todayVerifiedReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final allReportsAsync = ref.watch(allReportsProvider(departmentId));

  return allReportsAsync.whenData((reports) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return reports.where((report) {
      if (report.status != ReportStatus.verified) return false;
      if (report.verifiedAt == null) return false;

      return report.verifiedAt!.isAfter(startOfDay) &&
          report.verifiedAt!.isBefore(endOfDay);
    }).toList();
  });
});

final todayVerifiedCountProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(todayVerifiedReportsProvider);
  return reportsAsync.whenData((reports) => reports.length).value ?? 0;
});

// ==================== DASHBOARD SUMMARY PROVIDER ====================

/// Combined provider untuk dashboard summary
class DashboardSummary {
  final int pendingCount;
  final int needsVerificationCount;
  final int completedTodayCount;
  final int verifiedTodayCount;
  final Map<ReportStatus, int> statusBreakdown;

  const DashboardSummary({
    required this.pendingCount,
    required this.needsVerificationCount,
    required this.completedTodayCount,
    required this.verifiedTodayCount,
    required this.statusBreakdown,
  });

  int get totalActive =>
      statusBreakdown[ReportStatus.pending]! +
      statusBreakdown[ReportStatus.assigned]! +
      statusBreakdown[ReportStatus.inProgress]!;

  double get completionRate {
    final total = statusBreakdown.values.reduce((a, b) => a + b);
    if (total == 0) return 0.0;
    final completed = statusBreakdown[ReportStatus.verified]!;
    return (completed / total * 100);
  }
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final summaryAsync = ref.watch(reportSummaryProvider(departmentId));

  final pendingCount = ref.watch(pendingReportsCountProvider);
  final needsVerificationCount = ref.watch(needsVerificationCountProvider);
  final completedTodayCount = ref.watch(todayReportsCountProvider);
  final verifiedTodayCount = ref.watch(todayVerifiedCountProvider);

  return summaryAsync.whenData((statusBreakdown) {
    return DashboardSummary(
      pendingCount: pendingCount,
      needsVerificationCount: needsVerificationCount,
      completedTodayCount: completedTodayCount,
      verifiedTodayCount: verifiedTodayCount,
      statusBreakdown: statusBreakdown,
    );
  });
});

// ==================== VERIFICATION ACTION PROVIDERS ====================

/// Provider untuk handle verification actions
final verificationActionsProvider = Provider<VerificationActions>((ref) {
  return VerificationActions(ref);
});

class VerificationActions {
  final Ref ref;

  VerificationActions(this.ref);

  SupabaseDatabaseService get _service =>
      ref.read(supabaseDatabaseServiceProvider);

  Future<void> approveReport(Report report, {String? notes}) async {
    try {
      final userProfile = await ref.read(currentUserProfileProvider.future);
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      await _service.verifyReport(
        reportId: report.id,
        status: 'verified',
        verifiedBy: userProfile.uid,
        verifiedByName: userProfile.displayName,
        verificationNotes: notes,
      );

      _logger.info('Report approved: ${report.id}');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error approving report', e);
      throw const DatabaseException(
        message: 'Gagal menyetujui laporan. Silakan coba lagi.',
      );
    }
  }

  Future<void> rejectReport(Report report, {required String reason}) async {
    try {
      final userProfile = await ref.read(currentUserProfileProvider.future);
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      await _service.verifyReport(
        reportId: report.id,
        status: 'rejected',
        verifiedBy: userProfile.uid,
        verifiedByName: userProfile.displayName,
        verificationNotes: reason,
      );

      _logger.info('Report rejected: ${report.id}');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error rejecting report', e);
      throw const DatabaseException(
        message: 'Gagal menolak laporan. Silakan coba lagi.',
      );
    }
  }

  Future<void> assignToCleaner(
    Report report,
    String cleanerId,
    String cleanerName,
  ) async {
    try {
      await _service.assignReportToCleaner(
        reportId: report.id, 
        cleanerId: cleanerId, 
        cleanerName: cleanerName,
      );
      _logger.info('Report assigned to cleaner: ${report.id} -> $cleanerName');
    } catch (e) {
      _logger.error('Error assigning report to cleaner', e);
      throw const DatabaseException(
        message: 'Gagal menugaskan laporan ke cleaner. Silakan coba lagi.',
      );
    }
  }
}

// ==================== URGENT REPORTS PROVIDER ====================

/// Provider untuk laporan urgent yang belum selesai
final urgentReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final allReportsAsync = ref.watch(allReportsProvider(departmentId));

  return allReportsAsync.whenData((reports) {
    return reports.where((report) {
      return report.isUrgent &&
          report.status != ReportStatus.verified &&
          report.status != ReportStatus.rejected;
    }).toList();
  });
});

final urgentReportsCountProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(urgentReportsProvider);
  return reportsAsync.whenData((reports) => reports.length).value ?? 0;
});

// ==================== ACCOUNT VERIFICATION PROVIDERS ====================

/// Provider untuk mendapatkan semua user (untuk verifikasi akun)
final pendingVerificationUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.read(supabaseDatabaseServiceProvider);
  try {
    // Ambil semua user profiles dari Supabase
    final users = await service.getAllUserProfiles();
    _logger.info('✅ Loaded ${users.length} users for verification from Supabase');
    return users;
  } catch (e) {
    _logger.error('❌ Error loading users for verification', e);
    rethrow;
  }
});

/// Provider untuk verifikasi user (approve/reject)
final verifyUserProvider = FutureProvider.family<void, (String, String)>((ref, params) async {
  final (userId, action) = params;  // action: 'approve' or 'reject'
  final service = ref.read(supabaseDatabaseServiceProvider);

  try {
    if (action == 'approve' || action == 'approved') {
      // Update verification status to 'approved' (also sets status to 'active')
      await service.updateUserVerificationStatus(
        userId: userId,
        status: 'approved',
      );
      _logger.info('✅ User $userId approved via Supabase');
    } else if (action == 'reject' || action == 'rejected') {
      // Update verification status to 'rejected' (sets status to 'inactive')
      await service.updateUserVerificationStatus(
        userId: userId,
        status: 'rejected',
      );
      _logger.info('✅ User $userId rejected via Supabase');
    }
  } catch (e) {
    _logger.error('❌ Error updating user verification', e);
    rethrow;
  }
});

/// Provider untuk update user role (admin only)
final updateUserRoleProvider = FutureProvider.family<void, (String, String)>((ref, params) async {
  final (userId, newRole) = params;
  final service = ref.read(supabaseDatabaseServiceProvider);

  try {
    _logger.info('📝 Updating role for user: $userId to $newRole');

    await service.updateUserProfile(
      userId: userId,
      role: newRole,
    );

    _logger.info('✅ User role updated successfully');

    // Refresh user lists
    ref.invalidate(pendingVerificationUsersProvider);
    ref.invalidate(availableCleanersProvider);
  } catch (e) {
    _logger.error('❌ Error updating user role', e);
    rethrow;
  }
});

// ==================== LEGACY COMPATIBILITY ====================
// NOTE: supabaseDatabaseServiceProvider is now imported from supabase_service_providers.dart
// The import at the top of this file handles this.
