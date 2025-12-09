import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

part 'request_freezed.freezed.dart';
part 'request_freezed.g.dart';

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



enum RequestStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled;

  static RequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'assigned':
        return RequestStatus.assigned;
      case 'in_progress':
      case 'inprogress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  String toDatabase() {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.assigned:
        return 'assigned';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }

  // Keep for compatibility
  String toFirestore() => toDatabase();

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Menunggu';
      case RequestStatus.assigned:
        return 'Ditugaskan';
      case RequestStatus.inProgress:
        return 'Dikerjakan';
      case RequestStatus.completed:
        return 'Selesai';
      case RequestStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return AppTheme.warning;
      case RequestStatus.assigned:
        return AppTheme.secondary;
      case RequestStatus.inProgress:
        return AppTheme.info;
      case RequestStatus.completed:
        return AppTheme.success;
      case RequestStatus.cancelled:
        return AppTheme.error;
    }
  }

  IconData get icon {
    switch (this) {
      case RequestStatus.pending:
        return Icons.schedule;
      case RequestStatus.assigned:
        return Icons.assignment_ind;
      case RequestStatus.inProgress:
        return Icons.pending_actions;
      case RequestStatus.completed:
        return Icons.check_circle;
      case RequestStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool get isActive {
    return this == RequestStatus.pending ||
        this == RequestStatus.assigned ||
        this == RequestStatus.inProgress;
  }

  bool get isFinal {
    return this == RequestStatus.completed ||
        this == RequestStatus.cancelled;
  }

  bool get canSelfAssign => this == RequestStatus.pending;
}

// ==================== REQUEST MODEL ====================

@freezed
class Request with _$Request {
  const Request._(); // Added constructor for custom methods

  const factory Request({
    required String id,
    required String location,
    required String description,
    required String requestedBy,
    required String requestedByName,
    required String requestedByRole,
    required RequestStatus status,
    @TimestampConverter() required DateTime createdAt,
    @Default(false) bool isUrgent,
    @NullableTimestampConverter() DateTime? preferredDateTime,
    String? assignedTo,
    String? assignedToName,
    @NullableTimestampConverter() DateTime? assignedAt,
    String? assignedBy,
    String? imageUrl,
    String? completionImageUrl,
    String? completionNotes,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? completedAt,
    @NullableTimestampConverter() DateTime? deletedAt,
    String? deletedBy,
  }) = _Request;

  // Custom fromJson with Firestore support
  factory Request.fromJson(Map<String, dynamic> json) => _$RequestFromJson(json);


  // Appwrite factory (compatibility)
  factory Request.fromAppwrite(Map<String, dynamic> data) {
    // Handle potential ID mismatch ($id vs id)
    final id = data['\$id'] as String? ?? data['id'] as String? ?? '';
    
    // Create a mutable map to normalize data
    final normalizedData = Map<String, dynamic>.from(data);
    normalizedData['id'] = id;

    // Map Appwrite specific fields to model fields if they exist
    if (data.containsKey('requesterId')) normalizedData['requestedBy'] = data['requesterId'];
    if (data.containsKey('requesterName')) normalizedData['requestedByName'] = data['requesterName'];
    if (data.containsKey('preferredTime')) normalizedData['preferredDateTime'] = data['preferredTime'];
    if (data.containsKey('cleanerId')) normalizedData['assignedTo'] = data['cleanerId'];
    if (data.containsKey('cleanerName')) normalizedData['assignedToName'] = data['cleanerName'];
    if (data.containsKey('\$createdAt')) normalizedData['createdAt'] = data['\$createdAt'];

    // Ensure status is string for fromJson to handle (if it's not already)
    if (normalizedData['status'] is RequestStatus) {
      normalizedData['status'] = (normalizedData['status'] as RequestStatus).toDatabase();
    }

    return Request.fromJson(normalizedData);
  }

  // Legacy fromMap support
  factory Request.fromMap(String id, Map<String, dynamic> data) {
    return Request.fromJson({'id': id, ...data});
  }

  // Custom toFirestore
  Map<String, dynamic> toFirestore() {
    return toJson()..remove('id'); // Remove ID as it's the document ID
  }

  // Legacy toMap support
  Map<String, dynamic> toMap() => toJson();
  
  // Appwrite compatibility
  Map<String, dynamic> toAppwrite() {
    final json = toJson();
    
    // Map model fields back to Appwrite specific fields
    return {
      'requesterId': requestedBy,
      'requesterName': requestedByName,
      'location': location,
      'description': description,
      'isUrgent': isUrgent,
      'preferredTime': preferredDateTime?.toIso8601String(),
      'status': status.toDatabase(),
      'cleanerId': assignedTo,
      'cleanerName': assignedToName,
      'assignedAt': assignedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'completionImageUrl': completionImageUrl,
      'completionNotes': completionNotes,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      // Add other fields if necessary, ensuring they match Appwrite schema
    };
  }

  // ==================== COMPUTED PROPERTIES ====================

  bool get isAssigned => assignedTo != null;
  bool get isCompleted => status == RequestStatus.completed;
  bool get isCancelled => status == RequestStatus.cancelled;
  bool get isDeleted => deletedAt != null;
  bool get isActive => status.isActive;

  Duration? get workDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  Duration? get responseTime {
    if (assignedAt != null) {
      return assignedAt!.difference(createdAt);
    }
    return null;
  }

  Duration? get totalTime {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }

  bool isOwnedBy(String userId) => requestedBy == userId;
  bool isAssignedTo(String cleanerId) => assignedTo == cleanerId;

  bool canBeCancelledBy(String userId) {
    return requestedBy == userId &&
        (status == RequestStatus.pending || status == RequestStatus.assigned);
  }

  bool canBeSelfAssigned() => status == RequestStatus.pending && !isDeleted;

  bool canBeStartedBy(String cleanerId) {
    return assignedTo == cleanerId && status == RequestStatus.assigned;
  }

  bool canBeCompletedBy(String cleanerId) {
    return assignedTo == cleanerId && status == RequestStatus.inProgress;
  }
}
