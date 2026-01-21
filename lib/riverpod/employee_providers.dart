// lib/riverpod/employee_providers.dart
// ✅ MIGRATED TO SUPABASE
//
// FEATURES:
// - Employee reports via FutureProvider
// - Report summary by status
// - Report actions (create, update, delete)

// import 'dart:io'; // REMOVED for Web Compatibility
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../services/supabase_database_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';

final _logger = AppLogger('EmployeeProviders');

// ==================== EMPLOYEE AUTH PROVIDERS ====================
// Note: Using auth_providers.dart for auth state (currentUserIdProvider, currentUserProfileProvider)

// ==================== EMPLOYEE REPORTS PROVIDERS ====================

/// Provider untuk semua laporan employee
/// OPTIMIZED: dengan keepAlive untuk caching
final employeeReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return [];
  }

  // AutoDispose handles lifecycle better for dashboard
  final service = ref.watch(supabaseDatabaseServiceProvider);
  
  // Add timeout to prevent infinite loading
  try {
    return await service.getReportsByUserId(userId).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _logger.warning('Timeout fetching employee reports');
        throw const DatabaseException(message: 'Koneksi lambat. Silakan coba lagi.');
      },
    );
  } catch (e) {
    _logger.error('Error fetching employee reports', e);
    // Rethrow to let UI show error state instead of infinite loading
    rethrow;
  }
});

/// Provider untuk summary laporan employee berdasarkan status
class EmployeeReportsSummary {
  final int pending;
  final int inProgress;
  final int completed;
  final int verified;
  final int urgent;
  final int total;

  const EmployeeReportsSummary({
    required this.pending,
    required this.inProgress,
    required this.completed,
    this.verified = 0,
    this.urgent = 0,
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

  SupabaseDatabaseService get _service =>
      ref.read(supabaseDatabaseServiceProvider);

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
        final storageService = ref.read(supabaseStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes,
          bucket: 'report-images',
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
        id: '', // Will be generated by Supabase
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
      final createdReport = await _service.createReport(report);

      _logger.info('Report created successfully: ${createdReport.id}');

      return createdReport.id;
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
      } else if (imageFile != null) {
         // File logic removed for web compatibility. Pass imageBytes instead.
         _logger.warning('Passing File object is deprecated. Use imageBytes.');
      }

      // Upload if we have bytes
      if (bytes != null) {
        _logger.info('Uploading new report image...');
        final storageService = ref.read(supabaseStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: bytes,
          bucket: 'report-images',
          userId: userProfile.uid,
        );

        if (result.isSuccess && result.data != null) {
          newImageUrl = result.data;
          _logger.info('New image uploaded: $newImageUrl');
        } else {
          _logger.warning('Failed to upload image: ${result.error}');
        }
      }

      // Build updates map (snake_case for Supabase)
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (location != null) updates['location'] = location;
      if (description != null) updates['description'] = description;
      if (isUrgent != null) updates['is_urgent'] = isUrgent;
      if (newImageUrl != existingReport.imageUrl) {
        updates['image_url'] = newImageUrl;
      }

      // Update in Supabase
      await _service.updateReport(reportId, updates);

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

      await _service.deleteReport(reportId, userProfile.uid);
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

  /// Restore deleted report (not supported in current Supabase implementation)
  Future<void> restoreReport(String reportId) async {
    try {
      // Supabase uses soft delete with deleted_at field
      // To restore, set deleted_at back to null
      await _service.updateReport(reportId, {
        'deleted_at': null,
        'deleted_by': null,
      });
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
