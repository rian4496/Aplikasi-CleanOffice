// lib/models/report.dart
// ✅ UNIFIED: Report model + ReportStatus enum dalam 1 file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

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

// ==================== REPORT MODEL ====================

/// Model untuk laporan kebersihan yang diperluas dengan field-field tambahan
/// untuk mendukung workflow lengkap dari pembuatan hingga verifikasi
class Report {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final ReportStatus status;

  // Informasi Pembuat Laporan (Employee)
  final String userId;
  final String userName;
  final String? userEmail;

  // Informasi Petugas Kebersihan (Cleaner)
  final String? cleanerId;
  final String? cleanerName;

  // Informasi Supervisor
  final String? verifiedBy;
  final String? verifiedByName;
  final DateTime? verifiedAt;
  final String? verificationNotes;

  // Detail Laporan
  final String? imageUrl;
  final String? description;
  final bool isUrgent;

  // Timestamp
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Department (untuk filtering supervisor)
  final String? departmentId;

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.cleanerId,
    this.cleanerName,
    this.verifiedBy,
    this.verifiedByName,
    this.verifiedAt,
    this.verificationNotes,
    this.imageUrl,
    this.description,
    this.isUrgent = false,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.departmentId,
  });

  /// Convert dari Firestore document ke Report object
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Report(
      id: doc.id,
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      departmentId: data['departmentId'] as String?,
    );
  }

  /// Convert dari Map ke Report object (untuk compatibility)
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      departmentId: data['departmentId'] as String?,
    );
  }

  /// Convert Report object ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': status.toFirestore(),
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'cleanerId': cleanerId,
      'cleanerName': cleanerName,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationNotes': verificationNotes,
      'imageUrl': imageUrl,
      'description': description,
      'isUrgent': isUrgent,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'departmentId': departmentId,
    };
  }

  /// Copy with method untuk immutability
  Report copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? date,
    ReportStatus? status,
    String? userId,
    String? userName,
    String? userEmail,
    String? cleanerId,
    String? cleanerName,
    String? verifiedBy,
    String? verifiedByName,
    DateTime? verifiedAt,
    String? verificationNotes,
    String? imageUrl,
    String? description,
    bool? isUrgent,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? departmentId,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      cleanerId: cleanerId ?? this.cleanerId,
      cleanerName: cleanerName ?? this.cleanerName,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedByName: verifiedByName ?? this.verifiedByName,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isUrgent: isUrgent ?? this.isUrgent,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  /// Helper methods
  bool get isAssigned => cleanerId != null;
  bool get isVerified => status == ReportStatus.verified;
  bool get needsVerification => status == ReportStatus.completed;

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