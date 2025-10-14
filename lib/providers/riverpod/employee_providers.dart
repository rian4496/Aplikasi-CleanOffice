import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_model.dart';
import '../../models/report_status_enum.dart';
import './report_providers.dart';

// ==================== EMPLOYEE AUTH PROVIDERS ====================

/// Provider untuk current employee user
final currentEmployeeProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider untuk employee user ID
final currentEmployeeIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentEmployeeProvider);
  return userAsync.whenData((user) => user?.uid).value;
});

// ==================== EMPLOYEE REPORTS PROVIDERS ====================

/// Provider untuk semua laporan employee
final employeeReportsProvider = StreamProvider<List<Report>>((ref) {
  final userId = ref.watch(currentEmployeeIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(firestoreServiceProvider);
  return service.getReportsByUser(userId);
});

/// Provider untuk summary laporan employee berdasarkan status
class EmployeeReportsSummary {
  final int pending;
  final int inProgress;
  final int completed;
  final int total;

  const EmployeeReportsSummary({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.total,
  });
}

final employeeReportsSummaryProvider =
    Provider<AsyncValue<EmployeeReportsSummary>>((ref) {
      final reportsAsync = ref.watch(employeeReportsProvider);

      return reportsAsync.whenData((reports) {
        final pending = reports
            .where((r) => r.status == ReportStatus.pending)
            .length;
        final inProgress = reports
            .where(
              (r) =>
                  r.status == ReportStatus.assigned ||
                  r.status == ReportStatus.inProgress,
            )
            .length;
        final completed = reports
            .where(
              (r) =>
                  r.status == ReportStatus.completed ||
                  r.status == ReportStatus.verified,
            )
            .length;

        return EmployeeReportsSummary(
          pending: pending,
          inProgress: inProgress,
          completed: completed,
          total: reports.length,
        );
      });
    });

/// Provider untuk laporan employee berdasarkan status
final employeeReportsByStatusProvider =
    Provider.family<AsyncValue<List<Report>>, ReportStatus>((ref, status) {
      final reportsAsync = ref.watch(employeeReportsProvider);

      return reportsAsync.whenData((reports) {
        return reports.where((r) => r.status == status).toList();
      });
    });

/// Provider untuk laporan urgent employee
final employeeUrgentReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.whenData((reports) {
    // FIXED: Ganti r.isFinal dengan kondisi langsung
    return reports.where((r) {
      return r.isUrgent &&
          r.status != ReportStatus.verified &&
          r.status != ReportStatus.rejected;
    }).toList();
  });
});

/// Provider untuk laporan terbaru employee (5 terakhir)
final employeeRecentReportsProvider = Provider<AsyncValue<List<Report>>>((ref) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.whenData((reports) {
    final sortedReports = List<Report>.from(reports)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedReports.take(5).toList();
  });
});

// ==================== EMPLOYEE ACTIONS ====================

/// Provider untuk employee actions (create, delete report)
final employeeActionsProvider = Provider<EmployeeActions>((ref) {
  return EmployeeActions(ref);
});

class EmployeeActions {
  final Ref ref;

  EmployeeActions(this.ref);

  /// Create new report
  Future<void> createReport({
    required String location,
    required String description,
    String? imageUrl,
    bool isUrgent = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final service = ref.read(firestoreServiceProvider);

    final report = Report(
      id: '', // Will be set by Firestore
      title: location, // Using location as title
      location: location,
      date: DateTime.now(),
      status: ReportStatus.pending,
      userId: user.uid,
      userName: user.displayName ?? 'Unknown',
      userEmail: user.email,
      description: description,
      imageUrl: imageUrl,
      isUrgent: isUrgent,
    );

    await service.createReport(report);
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    final service = ref.read(firestoreServiceProvider);
    await service.deleteReport(reportId);
  }

  /// Get report by ID
  Future<Report?> getReportById(String reportId) async {
    final service = ref.read(firestoreServiceProvider);
    return await service.getReportById(reportId);
  }
}
