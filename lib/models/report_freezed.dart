// lib/models/report_freezed.dart
// ✅ FREEZED VERSION: Report model with auto-generated code
// ✅ Replaces manual copyWith, ==, hashCode, toString
// ✅ JSON serialization with Firestore Timestamp support

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/firestore_converters.dart';

part 'report_freezed.freezed.dart';
part 'report_freezed.g.dart';

// ==================== REPORT STATUS ENUM ====================

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

// ==================== REPORT MODEL (FREEZED) ====================

/// Model untuk laporan kebersihan dengan Freezed code generation
///
/// Features:
/// - ✅ Auto-generated copyWith, ==, hashCode, toString
/// - ✅ JSON serialization with Firestore Timestamp support
/// - ✅ Immutability guaranteed
/// - ✅ Backward compatible with existing Firestore structure
@freezed
class Report with _$Report {
  // Private constructor untuk custom methods
  const Report._();

  const factory Report({
    // Required fields
    required String id,
    required String title,
    required String location,
    @TimestampConverter() required DateTime date,
    required ReportStatus status,
    required String userId,
    required String userName,

    // Employee info (optional)
    String? userEmail,

    // Cleaner info (optional)
    String? cleanerId,
    String? cleanerName,

    // Verification info (optional)
    String? verifiedBy,
    String? verifiedByName,
    @NullableTimestampConverter() DateTime? verifiedAt,
    String? verificationNotes,

    // Images (optional)
    String? imageUrl,
    String? completionImageUrl,

    // Details (optional)
    String? description,
    @Default(false) bool isUrgent,

    // Timestamps (optional)
    @NullableTimestampConverter() DateTime? assignedAt,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? completedAt,

    // Department (optional)
    String? departmentId,

    // Soft delete (optional)
    @NullableTimestampConverter() DateTime? deletedAt,
    String? deletedBy,
  }) = _Report;

  /// Factory from JSON (auto-generated code will handle this)
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  /// Factory from Firestore DocumentSnapshot
  ///
  /// Maintains backward compatibility with existing Firestore structure
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Report.fromJson({
      'id': doc.id,
      'title': data['title'] ?? '',
      'location': data['location'] ?? '',
      'date': data['date'], // Converter will handle Timestamp
      'status': data['status'] ?? 'pending',
      'userId': data['userId'] ?? '',
      'userName': data['userName'] ?? '',
      'userEmail': data['userEmail'],
      'cleanerId': data['cleanerId'],
      'cleanerName': data['cleanerName'],
      'verifiedBy': data['verifiedBy'],
      'verifiedByName': data['verifiedByName'],
      'verifiedAt': data['verifiedAt'],
      'verificationNotes': data['verificationNotes'],
      'imageUrl': data['imageUrl'],
      'completionImageUrl': data['completionImageUrl'],
      'description': data['description'],
      'isUrgent': data['isUrgent'] ?? false,
      'assignedAt': data['assignedAt'],
      'startedAt': data['startedAt'],
      'completedAt': data['completedAt'],
      'departmentId': data['departmentId'],
      'deletedAt': data['deletedAt'],
      'deletedBy': data['deletedBy'],
    });
  }

  /// Convert to Firestore Map
  ///
  /// Custom method to ensure proper Firestore Timestamp conversion
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    return {
      'title': json['title'],
      'location': json['location'],
      'date': json['date'], // Already Timestamp from converter
      'status': status.toFirestore(),
      'userId': json['userId'],
      'userName': json['userName'],
      'userEmail': json['userEmail'],
      'cleanerId': json['cleanerId'],
      'cleanerName': json['cleanerName'],
      'verifiedBy': json['verifiedBy'],
      'verifiedByName': json['verifiedByName'],
      'verifiedAt': json['verifiedAt'],
      'verificationNotes': json['verificationNotes'],
      'imageUrl': json['imageUrl'],
      'completionImageUrl': json['completionImageUrl'],
      'description': json['description'],
      'isUrgent': json['isUrgent'],
      'assignedAt': json['assignedAt'],
      'startedAt': json['startedAt'],
      'completedAt': json['completedAt'],
      'departmentId': json['departmentId'],
      'deletedAt': json['deletedAt'],
      'deletedBy': json['deletedBy'],
    };
  }

  /// Backward compatibility: fromMap factory
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report.fromJson({...data, 'id': id});
  }

  /// Backward compatibility: toMap method
  Map<String, dynamic> toMap() => toJson();
}

// ==================== EXTENSIONS ====================

/// Extension methods untuk computed properties
extension ReportExtension on Report {
  /// Helper: Check if report is assigned
  bool get isAssigned => cleanerId != null;

  /// Helper: Check if report is verified
  bool get isVerified => status == ReportStatus.verified;

  /// Helper: Check if report needs verification
  bool get needsVerification => status == ReportStatus.completed;

  /// Helper: Check if report is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Durasi pengerjaan (jika ada)
  Duration? get workDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  /// Response time (dari dibuat hingga ditugaskan)
  Duration? get responseTime {
    if (assignedAt != null) {
      return assignedAt!.difference(date);
    }
    return null;
  }
}
