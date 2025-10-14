import 'package:flutter/material.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';

/// Enum untuk status laporan kebersihan
///
/// Flow status:
/// 1. pending - Laporan baru dibuat oleh employee, menunggu petugas
/// 2. assigned - Sudah ditugaskan ke petugas tertentu
/// 3. inProgress - Petugas sedang mengerjakan
/// 4. completed - Petugas selesai, menunggu verifikasi admin
/// 5. verified - Admin sudah memverifikasi dan menyetujui
/// 6. rejected - Ditolak oleh admin, perlu dikerjakan ulang
enum ReportStatus {
  pending,
  assigned,
  inProgress,
  completed,
  verified,
  rejected;

  /// Mengkonversi string dari Firestore ke enum
  static ReportStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'assigned':
        return ReportStatus.assigned;
      case 'in_progress':
      case 'inprogress':
        return ReportStatus.inProgress;
      case 'completed':
        return ReportStatus.completed;
      case 'verified':
        return ReportStatus.verified;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  /// Mengkonversi enum ke string untuk Firestore
  String toFirestore() {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.assigned:
        return 'assigned';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.completed:
        return 'completed';
      case ReportStatus.verified:
        return 'verified';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  /// Display name untuk UI dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Menunggu';
      case ReportStatus.assigned:
        return 'Ditugaskan';
      case ReportStatus.inProgress:
        return 'Dikerjakan';
      case ReportStatus.completed:
        return 'Selesai';
      case ReportStatus.verified:
        return 'Terverifikasi';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  /// Warna untuk UI berdasarkan status
  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return AppTheme.warning;
      case ReportStatus.assigned:
        return AppTheme.secondary;
      case ReportStatus.inProgress:
        return AppTheme.info;
      case ReportStatus.completed:
        return AppTheme.success;
      case ReportStatus.verified:
        return AppTheme.success;
      case ReportStatus.rejected:
        return AppTheme.error;
    }
  }

  /// Icon untuk UI berdasarkan status
  IconData get icon {
    switch (this) {
      case ReportStatus.pending:
        return Icons.schedule;
      case ReportStatus.assigned:
        return Icons.assignment_ind;
      case ReportStatus.inProgress:
        return Icons.pending_actions;
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.verified:
        return Icons.verified;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }

  /// Check apakah status ini memerlukan action dari admin
  bool get needsAdminAction {
    return this == ReportStatus.completed;
  }

  /// Check apakah status ini sudah final (tidak bisa diubah lagi)
  bool get isFinal {
    return this == ReportStatus.verified;
  }

  /// Check apakah laporan masih aktif (belum selesai)
  bool get isActive {
    return this == ReportStatus.pending ||
        this == ReportStatus.assigned ||
        this == ReportStatus.inProgress ||
        this == ReportStatus.rejected;
  }
}