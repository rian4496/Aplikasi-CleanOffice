// lib/models/request.dart
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// ==================== REQUEST STATUS ENUM ====================

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

class Request {
  final String id;
  final String location;
  final String description;
  final bool isUrgent;
  final DateTime? preferredDateTime;
  final String requestedBy;
  final String requestedByName;
  final String requestedByRole;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? assignedAt;
  final String? assignedBy;
  final RequestStatus status;
  final String? imageUrl;
  final String? completionImageUrl;
  final String? completionNotes;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final String? deletedBy;

  Request({
    required this.id,
    required this.location,
    required this.description,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedByRole,
    required this.status,
    required this.createdAt,
    this.isUrgent = false,
    this.preferredDateTime,
    this.assignedTo,
    this.assignedToName,
    this.assignedAt,
    this.assignedBy,
    this.imageUrl,
    this.completionImageUrl,
    this.completionNotes,
    this.startedAt,
    this.completedAt,
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

  /// Convert dari Map ke Request object (Appwrite compatible)
  factory Request.fromMap(String id, Map<String, dynamic> data) {
    return Request(
      id: id,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requestedBy: data['requestedBy'] as String? ?? '',
      requestedByName: data['requestedByName'] as String? ?? '',
      requestedByRole: data['requestedByRole'] as String? ?? 'employee',
      status: RequestStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
      isUrgent: data['isUrgent'] as bool? ?? false,
      preferredDateTime: _parseDate(data['preferredDateTime']),
      assignedTo: data['assignedTo'] as String?,
      assignedToName: data['assignedToName'] as String?,
      assignedAt: _parseDate(data['assignedAt']),
      assignedBy: data['assignedBy'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      completionNotes: data['completionNotes'] as String?,
      startedAt: _parseDate(data['startedAt']),
      completedAt: _parseDate(data['completedAt']),
      deletedAt: _parseDate(data['deletedAt']),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert dari Appwrite document ke Request object
  factory Request.fromAppwrite(Map<String, dynamic> data) {
    return Request(
      id: data['\$id'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requestedBy: data['requesterId'] as String? ?? data['requestedBy'] as String? ?? '',
      requestedByName: data['requesterName'] as String? ?? data['requestedByName'] as String? ?? '',
      requestedByRole: data['requestedByRole'] as String? ?? 'employee',
      status: RequestStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: _parseDate(data['\$createdAt']) ?? _parseDate(data['createdAt']) ?? DateTime.now(),
      isUrgent: data['isUrgent'] as bool? ?? false,
      preferredDateTime: _parseDate(data['preferredTime'] ?? data['preferredDateTime']),
      assignedTo: data['cleanerId'] as String? ?? data['assignedTo'] as String?,
      assignedToName: data['cleanerName'] as String? ?? data['assignedToName'] as String?,
      assignedAt: _parseDate(data['assignedAt']),
      assignedBy: data['assignedBy'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      completionNotes: data['completionNotes'] as String?,
      startedAt: _parseDate(data['startedAt']),
      completedAt: _parseDate(data['completedAt']),
      deletedAt: _parseDate(data['deletedAt']),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert Request object ke Map untuk Appwrite
  Map<String, dynamic> toAppwrite() {
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
    };
  }

  // Keep for compatibility
  Map<String, dynamic> toFirestore() => toAppwrite();

  Request copyWith({
    String? id,
    String? location,
    String? description,
    String? requestedBy,
    String? requestedByName,
    String? requestedByRole,
    RequestStatus? status,
    DateTime? createdAt,
    bool? isUrgent,
    DateTime? preferredDateTime,
    String? assignedTo,
    String? assignedToName,
    DateTime? assignedAt,
    String? assignedBy,
    String? imageUrl,
    String? completionImageUrl,
    String? completionNotes,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? deletedAt,
    String? deletedBy,
  }) {
    return Request(
      id: id ?? this.id,
      location: location ?? this.location,
      description: description ?? this.description,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedByName: requestedByName ?? this.requestedByName,
      requestedByRole: requestedByRole ?? this.requestedByRole,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isUrgent: isUrgent ?? this.isUrgent,
      preferredDateTime: preferredDateTime ?? this.preferredDateTime,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      imageUrl: imageUrl ?? this.imageUrl,
      completionImageUrl: completionImageUrl ?? this.completionImageUrl,
      completionNotes: completionNotes ?? this.completionNotes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

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

  @override
  String toString() {
    return 'Request(id: $id, location: $location, status: ${status.displayName}, '
        'requestedBy: $requestedByName, assignedTo: $assignedToName)';
  }
}
