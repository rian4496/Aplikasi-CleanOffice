import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';
import '../../models/report_status_enum.dart';
import '../../models/user_profile.dart';
import './report_providers.dart';

// ==================== AUTH PROVIDERS ====================

/// Provider untuk current Firebase user
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider untuk current user profile
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return null;
    } else {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (docSnapshot.exists) {
        return UserProfile.fromMap(docSnapshot.data()!..['uid'] = user.uid);
      } else {
        return null;
      }
    }
  });
});

/// Provider untuk department ID dari current user
final currentUserDepartmentProvider = Provider<String?>((ref) {
  final userProfileAsync = ref.watch(currentUserProfileProvider);
  return userProfileAsync.whenData((profile) => profile?.departmentId).value;
});

// ==================== ADMIN DASHBOARD PROVIDERS ====================

/// Provider untuk laporan yang perlu verifikasi (status: completed)
final needsVerificationReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
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

  Future<void> approveReport(Report report, {String? notes}) async {
    final userProfile = await ref.read(currentUserProfileProvider.future);
    if (userProfile == null) throw Exception('User not logged in');

    final service = ref.read(firestoreServiceProvider);
    await service.verifyReport(
      report.id,
      userProfile.uid,
      userProfile.displayName,
      notes: notes,
      approved: true,
    );
  }

  Future<void> rejectReport(Report report, {required String reason}) async {
    final userProfile = await ref.read(currentUserProfileProvider.future);
    if (userProfile == null) throw Exception('User not logged in');

    final service = ref.read(firestoreServiceProvider);
    await service.verifyReport(
      report.id,
      userProfile.uid,
      userProfile.displayName,
      notes: reason,
      approved: false,
    );
  }

  Future<void> assignToCleaner(Report report, String cleanerId, String cleanerName) async {
    final service = ref.read(firestoreServiceProvider);
    await service.assignReportToCleaner(report.id, cleanerId, cleanerName);
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