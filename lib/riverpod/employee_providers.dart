// lib/providers/riverpod/employee_providers.dart - USING EXISTING STORAGE SERVICE
// ✅ UPDATED: Support imageBytes for web compatibility

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
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

final employeeReportsSummaryProvider = Provider<EmployeeReportsSummary>((ref) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.when(
    data: (reports) {
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
    },
    loading: () => const EmployeeReportsSummary(
      pending: 0,
      inProgress: 0,
      completed: 0,
      total: 0,
    ),
    error: (error, stackTrace) => const EmployeeReportsSummary(
      pending: 0,
      inProgress: 0,
      completed: 0,
      total: 0,
    ),
  );
});

/// Provider untuk laporan employee berdasarkan status
final employeeReportsByStatusProvider =
    Provider.family<List<Report>, ReportStatus>((ref, status) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.when(
    data: (reports) => reports.where((r) => r.status == status).toList(),
    loading: () => [],
    error: (error, stackTrace) => [],
  );
});

/// Provider untuk laporan urgent employee
final employeeUrgentReportsProvider = Provider<List<Report>>((ref) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.when(
    data: (reports) {
      return reports.where((r) {
        return r.isUrgent &&
            r.status != ReportStatus.verified &&
            r.status != ReportStatus.rejected;
      }).toList();
    },
    loading: () => [],
    error: (error, stackTrace) => [],
  );
});

/// Provider untuk laporan terbaru employee (5 terakhir)
final employeeRecentReportsProvider = Provider<List<Report>>((ref) {
  final reportsAsync = ref.watch(employeeReportsProvider);

  return reportsAsync.when(
    data: (reports) {
      final sortedReports = List<Report>.from(reports)
        ..sort((a, b) => b.date.compareTo(a.date));
      return sortedReports.take(5).toList();
    },
    loading: () => [],
    error: (error, stackTrace) => [],
  );
});

// ==================== EMPLOYEE ACTIONS ====================

/// Provider untuk employee actions (create, update, delete report)
final employeeActionsProvider = Provider<EmployeeActions>((ref) {
  return EmployeeActions(ref);
});

class EmployeeActions {
  final Ref ref;

  EmployeeActions(this.ref);

  /// Create new report with notification
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
      title: location,
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

    // Create report
    await service.createReport(report);

    // Get the created report ID
    final createdReports = await service.getReportsByUser(user.uid).first;
    final createdReport = createdReports.firstWhere(
      (r) => r.location == location && r.description == description,
    );

    // Send notifications to admins
    try {
      if (isUrgent) {
        // Send urgent notification
        await NotificationService().notifyUrgentReport(createdReport);
      } else {
        // Send regular notification
        await NotificationService().notifyReportCreated(createdReport);
      }
    } catch (e) {
      // Log error but don't fail the report creation
      debugPrint('Failed to send notification: $e');
    }
  }

  /// Update existing report
  /// ✅ UPDATED: Support imageBytes for web compatibility
  Future<void> updateReport({
    required String reportId,
    String? title,
    String? location,
    String? description,
    bool? isUrgent,
    dynamic imageFile,       // DEPRECATED: Use imageBytes instead
    Uint8List? imageBytes,   // ✅ NEW: Web-compatible bytes
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final firestoreService = ref.read(firestoreServiceProvider);

    // Get existing report
    final existingReport = await firestoreService.getReportById(reportId);
    if (existingReport == null) {
      throw Exception('Report not found');
    }

    // Check if user owns this report
    if (existingReport.userId != user.uid) {
      throw Exception('Unauthorized: You can only edit your own reports');
    }

    // Check if report can be edited (only Pending)
    if (existingReport.status != ReportStatus.pending) {
      throw Exception('Cannot edit report with status: ${existingReport.status.displayName}');
    }

    // Handle image upload
    String? newImageUrl = existingReport.imageUrl;
    Uint8List? bytes;
    
    // ✅ UPDATED: Support both File (mobile) and Uint8List (web)
    if (imageBytes != null) {
      // Web or explicitly provided bytes
      bytes = imageBytes;
    } else if (imageFile != null && imageFile is File) {
      // Mobile: File from image_picker
      try {
        bytes = await imageFile.readAsBytes();
      } catch (e) {
        debugPrint('❌ Error reading file: $e');
      }
    }
    
    // Upload if we have bytes
    if (bytes != null) {
      try {
        final storageService = ref.read(storageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: bytes,
          folder: 'reports',
          userId: user.uid,
        );

        if (result.isSuccess && result.data != null) {
          newImageUrl = result.data;
          debugPrint('✅ New image uploaded: $newImageUrl');
        } else {
          debugPrint('❌ Failed to upload image: ${result.error}');
        }
      } catch (e) {
        debugPrint('❌ Image upload error: $e');
      }
    }

    // Create updated report
    final updatedReport = Report(
      id: reportId,
      title: title ?? existingReport.title,
      location: location ?? existingReport.location,
      date: existingReport.date,
      status: existingReport.status,
      userId: existingReport.userId,
      userName: existingReport.userName,
      userEmail: existingReport.userEmail,
      cleanerId: existingReport.cleanerId,
      cleanerName: existingReport.cleanerName,
      verifiedBy: existingReport.verifiedBy,
      verifiedByName: existingReport.verifiedByName,
      verifiedAt: existingReport.verifiedAt,
      verificationNotes: existingReport.verificationNotes,
      description: description ?? existingReport.description,
      imageUrl: newImageUrl,
      isUrgent: isUrgent ?? existingReport.isUrgent,
      assignedAt: existingReport.assignedAt,
      startedAt: existingReport.startedAt,
      completedAt: existingReport.completedAt,
      departmentId: existingReport.departmentId,
    );

    // Update in Firestore
    await firestoreService.updateReport(
      reportId,
      updatedReport.toFirestore(),
    );
  }

  /// Delete report (soft delete)
  /// 🆕 UPDATED: Now uses soft delete instead of permanent delete
  Future<void> deleteReport(String reportId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    final service = ref.read(firestoreServiceProvider);
    await service.softDeleteReport(reportId, user.uid);
  }

  /// 🆕 NEW: Restore deleted report
  Future<void> restoreReport(String reportId) async {
    final service = ref.read(firestoreServiceProvider);
    await service.restoreReport(reportId);
  }

  /// Get report by ID
  Future<Report?> getReportById(String reportId) async {
    final service = ref.read(firestoreServiceProvider);
    return await service.getReportById(reportId);
  }
}