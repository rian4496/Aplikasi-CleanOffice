// lib/models/report.dart
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// ==================== REPORT STATUS ENUM ====================

enum ReportStatus {
  pending,
  assigned,
  inProgress,
  completed,
  verified,
  rejected;

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

  String toDatabase() {
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

  // Keep for compatibility
  String toFirestore() => toDatabase();

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

  // Alias for displayName
  String get label => displayName;

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

  bool get needsAdminAction => this == ReportStatus.completed;
  bool get isFinal => this == ReportStatus.verified;
  bool get isActive {
    return this == ReportStatus.pending ||
        this == ReportStatus.assigned ||
        this == ReportStatus.inProgress ||
        this == ReportStatus.rejected;
  }
}

// ==================== REPORT MODEL ====================

class Report {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final ReportStatus status;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? cleanerId;
  final String? cleanerName;
  final String? verifiedBy;
  final String? verifiedByName;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final String? imageUrl;
  final String? completionImageUrl;
  final String? description;
  final bool isUrgent;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? departmentId;
  final DateTime? deletedAt;
  final String? deletedBy;

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
    this.completionImageUrl,
    this.description,
    this.isUrgent = false,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.departmentId,
    this.deletedAt,
    this.deletedBy,
  });

  // Helper to parse dates from various formats
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Convert dari Map ke Report object (Appwrite compatible)
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: _parseDate(data['date']) ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: _parseDate(data['verifiedAt']),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: _parseDate(data['assignedAt']),
      startedAt: _parseDate(data['startedAt']),
      completedAt: _parseDate(data['completedAt']),
      departmentId: data['departmentId'] as String?,
      deletedAt: _parseDate(data['deletedAt']),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert dari Appwrite document ke Report object
  factory Report.fromAppwrite(Map<String, dynamic> data) {
    return Report(
      id: data['\$id'] as String? ?? data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: _parseDate(data['date']) ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: _parseDate(data['verifiedAt']),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: _parseDate(data['assignedAt']),
      startedAt: _parseDate(data['startedAt']),
      completedAt: _parseDate(data['completedAt']),
      departmentId: data['departmentId'] as String?,
      deletedAt: _parseDate(data['deletedAt']),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert dari Supabase database ke Report object (snake_case)
  factory Report.fromSupabase(Map<String, dynamic> data) {
    return Report(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: _parseDate(data['date']) ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['user_id'] as String? ?? '',
      userName: data['user_name'] as String? ?? '',
      userEmail: data['user_email'] as String?,
      cleanerId: data['cleaner_id'] as String?,
      cleanerName: data['cleaner_name'] as String?,
      verifiedBy: data['verified_by'] as String?,
      verifiedByName: data['verified_by_name'] as String?,
      verifiedAt: _parseDate(data['verified_at']),
      verificationNotes: data['verification_notes'] as String?,
      imageUrl: data['image_url'] as String?,
      completionImageUrl: data['completion_image_url'] as String?,
      description: data['description'] as String?,
      isUrgent: data['is_urgent'] as bool? ?? false,
      assignedAt: _parseDate(data['assigned_at']),
      startedAt: _parseDate(data['started_at']),
      completedAt: _parseDate(data['completed_at']),
      departmentId: data['department_id'] as String?,
      deletedAt: _parseDate(data['deleted_at']),
      deletedBy: data['deleted_by'] as String?,
    );
  }

  /// Convert Report object ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'status': status.toDatabase(),
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'cleanerId': cleanerId,
      'cleanerName': cleanerName,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'imageUrl': imageUrl,
      'completionImageUrl': completionImageUrl,
      'description': description,
      'isUrgent': isUrgent,
      'assignedAt': assignedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'departmentId': departmentId,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
    };
  }

  /// Convert Report object ke Map untuk Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'status': status.toDatabase(),
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'cleanerId': cleanerId,
      'cleanerName': cleanerName,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'imageUrl': imageUrl,
      'completionImageUrl': completionImageUrl,
      'description': description,
      'isUrgent': isUrgent,
      'assignedAt': assignedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'departmentId': departmentId,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
    };
  }

  /// Convert Report object ke Map untuk Supabase (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'status': status.toDatabase(),
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'cleaner_id': cleanerId,
      'cleaner_name': cleanerName,
      'verified_by': verifiedBy,
      'verified_by_name': verifiedByName,
      'verified_at': verifiedAt?.toIso8601String(),
      'verification_notes': verificationNotes,
      'image_url': imageUrl,
      'completion_image_url': completionImageUrl,
      'description': description,
      'is_urgent': isUrgent,
      'assigned_at': assignedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'department_id': departmentId,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  // Keep for compatibility
  Map<String, dynamic> toFirestore() => toAppwrite();

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
    String? completionImageUrl,
    String? description,
    bool? isUrgent,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? departmentId,
    DateTime? deletedAt,
    String? deletedBy,
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
      completionImageUrl: completionImageUrl ?? this.completionImageUrl,
      description: description ?? this.description,
      isUrgent: isUrgent ?? this.isUrgent,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      departmentId: departmentId ?? this.departmentId,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  bool get isAssigned => cleanerId != null;
  bool get isVerified => status == ReportStatus.verified;
  bool get needsVerification => status == ReportStatus.completed;
  bool get isDeleted => deletedAt != null;

  // ==================== COMPATIBILITY GETTERS ====================
  // These provide compatibility with new admin screens expecting different field names
  
  /// Alias for date (new screens expect createdAt)
  DateTime get createdAt => date;
  
  /// Alias for departmentId (new screens expect department string)
  String get department => departmentId ?? 'Unknown';
  
  /// Images as list (new screens expect List<String>)
  List<String> get images => imageUrl != null ? [imageUrl!] : [];
  
  /// Completion images as list
  List<String> get completionImages => 
      completionImageUrl != null ? [completionImageUrl!] : [];
  
  /// Alias for verificationNotes
  String? get completionNotes => verificationNotes;

  Duration? get workDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  Duration? get responseTime {
    if (assignedAt != null) {
      return assignedAt!.difference(date);
    }
    return null;
  }
}
