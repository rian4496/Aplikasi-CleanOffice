// lib/providers/riverpod/employee_providers.dart
// ✅ EMPLOYEE PROVIDERS - Migrated to Appwrite
//
// FEATURES:
// - Employee reports stream
// - Report summary by status
// - Report actions (create, update, delete)

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../services/appwrite_database_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './inventory_providers.dart';
import './request_providers.dart' show appwriteStorageServiceProvider;

final _logger = AppLogger('EmployeeProviders');

// ==================== EMPLOYEE AUTH PROVIDERS ====================
// Note: Using auth_providers.dart for auth state (currentUserIdProvider, currentUserProfileProvider)

// ==================== EMPLOYEE REPORTS PROVIDERS ====================

/// Provider untuk semua laporan employee
/// OPTIMIZED: dengan autoDispose dan keepAlive untuk caching
final employeeReportsProvider = StreamProvider<List<Report>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  // Keep provider alive for caching
  ref.keepAlive();

  final service = ref.watch(appwriteDatabaseServiceProvider);
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

  AppwriteDatabaseService get _service =>
      ref.read(appwriteDatabaseServiceProvider);

  /// Create new report with notification
  Future<String> createReport({
    required String location,
    required String description,
    String? imageUrl,
    Uint8List? imageBytes,
    bool isUrgent = false,
  }) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      // Upload image if provided
      String? uploadedImageUrl = imageUrl;
      if (imageBytes != null) {
        _logger.info('Uploading report image...');
        final storageService = ref.read(appwriteStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes,
          folder: 'reports',
          userId: userProfile.uid,
        );
        if (result.isSuccess && result.data != null) {
          uploadedImageUrl = result.data;
          _logger.info('Image uploaded: $uploadedImageUrl');
        } else {
          _logger.warning('Image upload failed: ${result.error}');
        }
      }

      final report = Report(
        id: '', // Will be generated by Appwrite
        title: location,
        location: location,
        date: DateTime.now(),
        status: ReportStatus.pending,
        userId: userProfile.uid,
        userName: userProfile.displayName,
        userEmail: userProfile.email,
        description: description,
        imageUrl: uploadedImageUrl,
        isUrgent: isUrgent,
      );

      // Create report
      final reportId = await _service.createReport(report);
      if (reportId == null) {
        throw const DatabaseException(message: 'Gagal membuat laporan.');
      }

      _logger.info('Report created successfully: $reportId');

      // TODO: Send notifications to admins (implement with Appwrite Functions later)

      return reportId;
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error creating report', e);
      throw const DatabaseException(
        message: 'Gagal membuat laporan. Silakan coba lagi.',
      );
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
    dynamic imageFile, // DEPRECATED: Use imageBytes instead
    Uint8List? imageBytes, // ✅ NEW: Web-compatible bytes
  }) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      // Get existing report
      final existingReport = await _service.getReportById(reportId);
      if (existingReport == null) {
        throw const ValidationException(message: 'Laporan tidak ditemukan');
      }

      // Check if user owns this report
      if (existingReport.userId != userProfile.uid) {
        throw const ValidationException(
          message: 'Anda hanya dapat mengedit laporan Anda sendiri',
        );
      }

      // Check if report can be edited (only Pending)
      if (existingReport.status != ReportStatus.pending) {
        throw ValidationException(
          message:
              'Tidak dapat mengedit laporan dengan status: ${existingReport.status.displayName}',
        );
      }

      // Handle image upload
      String? newImageUrl = existingReport.imageUrl;
      Uint8List? bytes;

      // Support both File (mobile) and Uint8List (web)
      if (imageBytes != null) {
        bytes = imageBytes;
      } else if (imageFile != null && imageFile is File) {
        try {
          bytes = await imageFile.readAsBytes();
        } catch (e) {
          _logger.warning('Error reading file: $e');
        }
      }

      // Upload if we have bytes
      if (bytes != null) {
        _logger.info('Uploading new report image...');
        final storageService = ref.read(appwriteStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: bytes,
          folder: 'reports',
          userId: userProfile.uid,
        );

        if (result.isSuccess && result.data != null) {
          newImageUrl = result.data;
          _logger.info('New image uploaded: $newImageUrl');
        } else {
          _logger.warning('Failed to upload image: ${result.error}');
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

      // Update in Appwrite
      await _service.updateReport(reportId, updatedReport.toAppwrite());

      _logger.info('Report updated successfully: $reportId');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error updating report', e);
      throw const DatabaseException(
        message: 'Gagal mengupdate laporan. Silakan coba lagi.',
      );
    }
  }

  /// Delete report (soft delete)
  Future<void> deleteReport(String reportId) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      await _service.softDeleteReport(reportId, userProfile.uid);
      _logger.info('Report deleted successfully: $reportId');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error deleting report', e);
      throw const DatabaseException(
        message: 'Gagal menghapus laporan. Silakan coba lagi.',
      );
    }
  }

  /// Restore deleted report
  Future<void> restoreReport(String reportId) async {
    try {
      await _service.restoreReport(reportId);
      _logger.info('Report restored successfully: $reportId');
    } catch (e) {
      _logger.error('Error restoring report', e);
      throw const DatabaseException(
        message: 'Gagal mengembalikan laporan. Silakan coba lagi.',
      );
    }
  }

  /// Get report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      return await _service.getReportById(reportId);
    } catch (e) {
      _logger.error('Error getting report', e);
      return null;
    }
  }
}