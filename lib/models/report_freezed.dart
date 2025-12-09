import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

part 'report_freezed.freezed.dart';
part 'report_freezed.g.dart';

// Local DateTime converters (replacing Firestore ones)
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();
  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();
  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    return null;
  }
  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}



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

@freezed
class Report with _$Report {
  const Report._(); // Added constructor for custom methods

  const factory Report({
    required String id,
    required String title,
    required String location,
    @TimestampConverter() required DateTime date,
    required ReportStatus status,
    required String userId,
    required String userName,
    String? userEmail,
    String? cleanerId,
    String? cleanerName,
    String? verifiedBy,
    String? verifiedByName,
    @NullableTimestampConverter() DateTime? verifiedAt,
    String? verificationNotes,
    String? imageUrl,
    String? completionImageUrl,
    String? description,
    @Default(false) bool isUrgent,
    @NullableTimestampConverter() DateTime? assignedAt,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? completedAt,
    String? departmentId,
    @NullableTimestampConverter() DateTime? deletedAt,
    String? deletedBy,
  }) = _Report;

  // Custom fromJson
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);


  // Appwrite factory (compatibility)
  factory Report.fromAppwrite(Map<String, dynamic> data) {
    // Handle potential ID mismatch ($id vs id)
    final id = data['\$id'] as String? ?? data['id'] as String? ?? '';
    
    // Create a mutable map to normalize data
    final normalizedData = Map<String, dynamic>.from(data);
    normalizedData['id'] = id;
    
    // Ensure status is string for fromJson to handle (if it's not already)
    if (normalizedData['status'] is ReportStatus) {
      normalizedData['status'] = (normalizedData['status'] as ReportStatus).toDatabase();
    }

    return Report.fromJson(normalizedData);
  }

  // Legacy fromMap support
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report.fromJson({'id': id, ...data});
  }

  // Custom toFirestore
  Map<String, dynamic> toFirestore() {
    // toJson handles the conversion, including TimestampConverter
    return toJson()..remove('id'); // Remove ID as it's the document ID
  }

  // Legacy toMap support
  Map<String, dynamic> toMap() => toJson();
  
  // Appwrite compatibility
  Map<String, dynamic> toAppwrite() {
    final json = toJson();
    json.remove('id'); // Appwrite doesn't need ID in body
    return json;
  }

  // ==================== COMPUTED PROPERTIES ====================

  bool get isAssigned => cleanerId != null;
  bool get isVerified => status == ReportStatus.verified;
  bool get needsVerification => status == ReportStatus.completed;
  bool get isDeleted => deletedAt != null;

  // ==================== COMPATIBILITY GETTERS ====================
  
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
