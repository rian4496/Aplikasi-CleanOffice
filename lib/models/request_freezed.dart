// lib/models/request_freezed.dart
// ✅ REQUEST MODEL - Freezed Version
//
// DIFFERENCE FROM REPORT:
// - Report: Institutional issues (toilet kotor, AC rusak) - Public visibility
// - Request: Personal services (bersihkan mobil, angkat galon) - Private visibility
//
// VISIBILITY RULES:
// - Requester: See own requests only
// - Assigned Cleaner: See assigned requests only
// - Admin: See ALL requests
// - Other employees: CANNOT see others' requests

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/firestore_converters.dart';

part 'request_freezed.freezed.dart';
part 'request_freezed.g.dart';

// ==================== REQUEST STATUS ENUM ====================

/// Enum untuk status request layanan personal
///
/// Flow status:
/// 1. pending - Request baru dibuat, menunggu cleaner (self-assign atau admin assign)
/// 2. assigned - Sudah ditugaskan ke cleaner tertentu (by employee atau self-assign)
/// 3. in_progress - Cleaner sedang mengerjakan
/// 4. completed - Cleaner sudah selesai
/// 5. cancelled - Request dibatalkan (by requester atau admin)
enum RequestStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled;

  /// Mengkonversi string dari Firestore ke enum
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

  /// Mengkonversi enum ke string untuk Firestore
  String toFirestore() {
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

  /// Display name untuk UI dalam Bahasa Indonesia
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

  /// Warna untuk UI berdasarkan status
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

  /// Icon untuk UI berdasarkan status
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

  /// Check apakah status ini masih aktif (belum selesai/cancelled)
  bool get isActive {
    return this == RequestStatus.pending ||
        this == RequestStatus.assigned ||
        this == RequestStatus.inProgress;
  }

  /// Check apakah status ini sudah final (tidak bisa diubah lagi)
  bool get isFinal {
    return this == RequestStatus.completed ||
        this == RequestStatus.cancelled;
  }

  /// Check apakah cleaner bisa self-assign
  bool get canSelfAssign {
    return this == RequestStatus.pending;
  }
}

// ==================== REQUEST MODEL ====================

/// Model untuk request layanan personal (bukan laporan institusional)
///
/// Use Cases:
/// - Employee request: "Tolong bersihkan mobil saya"
/// - Employee request: "Tolong angkat galon ke pantry"
/// - Admin request: "Setup ruang meeting untuk event" (future)
///
/// Key Features:
/// - Private visibility (only requester, assigned cleaner, and admin can see)
/// - Employee can select cleaner when creating (optional)
/// - Cleaner can self-assign from pending requests
/// - Max 3 active requests per employee
/// - Optional photo upload
@freezed
class Request with _$Request {
  const Request._(); // Private constructor for custom methods

  const factory Request({
    required String id,

    // ==================== REQUEST INFO ====================
    required String location,                     // "Parkiran Depan", "Pantry Lt 2", etc
    required String description,                  // Detail request
    @Default(false) bool isUrgent,                // Urgent flag
    @NullableTimestampConverter() DateTime? preferredDateTime, // When user wants service (optional)

    // ==================== REQUESTER INFO ====================
    required String requestedBy,                  // userId (employee/admin)
    required String requestedByName,              // User's name
    required String requestedByRole,              // 'employee' (future: 'admin')

    // ==================== ASSIGNMENT INFO ====================
    String? assignedTo,                           // cleanerId (null if pending)
    String? assignedToName,                       // Cleaner's name
    @NullableTimestampConverter() DateTime? assignedAt,        // When assigned
    String? assignedBy,                           // 'employee' | 'self' | 'admin' (tracking)

    // ==================== STATUS & COMPLETION ====================
    required RequestStatus status,                // Current status
    String? imageUrl,                             // Initial photo (optional)
    String? completionImageUrl,                   // Completion proof (optional)
    String? completionNotes,                      // Notes from cleaner when completing

    // ==================== TIMESTAMPS ====================
    @TimestampConverter() required DateTime createdAt,         // When request created
    @NullableTimestampConverter() DateTime? startedAt,         // When cleaner started
    @NullableTimestampConverter() DateTime? completedAt,       // When cleaner completed

    // ==================== SOFT DELETE ====================
    @NullableTimestampConverter() DateTime? deletedAt,         // Soft delete timestamp
    String? deletedBy,                            // Who deleted (userId)
  }) = _Request;

  /// Convert dari JSON ke Request object (auto-generated by Freezed)
  factory Request.fromJson(Map<String, dynamic> json) => _$RequestFromJson(json);

  /// Convert dari Firestore document ke Request object (backward compatibility)
  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Request.fromJson({
      'id': doc.id,
      'location': data['location'] ?? '',
      'description': data['description'] ?? '',
      'requestedBy': data['requestedBy'] ?? '',
      'requestedByName': data['requestedByName'] ?? '',
      'requestedByRole': data['requestedByRole'] ?? 'employee',
      'status': data['status'] ?? 'pending',
      'createdAt': data['createdAt'], // TimestampConverter handles this
      'isUrgent': data['isUrgent'] ?? false,
      'preferredDateTime': data['preferredDateTime'],
      'assignedTo': data['assignedTo'],
      'assignedToName': data['assignedToName'],
      'assignedAt': data['assignedAt'],
      'assignedBy': data['assignedBy'],
      'imageUrl': data['imageUrl'],
      'completionImageUrl': data['completionImageUrl'],
      'completionNotes': data['completionNotes'],
      'startedAt': data['startedAt'],
      'completedAt': data['completedAt'],
      'deletedAt': data['deletedAt'],
      'deletedBy': data['deletedBy'],
    });
  }

  /// Convert dari Map ke Request object (legacy compatibility)
  factory Request.fromMap(String id, Map<String, dynamic> data) {
    return Request.fromJson({
      'id': id,
      ...data,
    });
  }

  /// Convert Request object ke Map untuk Firestore (backward compatibility)
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    return {
      'location': json['location'],
      'description': json['description'],
      'requestedBy': json['requestedBy'],
      'requestedByName': json['requestedByName'],
      'requestedByRole': json['requestedByRole'],
      'status': status.toFirestore(),
      'createdAt': json['createdAt'], // Already Timestamp from converter
      'isUrgent': json['isUrgent'],
      'preferredDateTime': json['preferredDateTime'],
      'assignedTo': json['assignedTo'],
      'assignedToName': json['assignedToName'],
      'assignedAt': json['assignedAt'],
      'assignedBy': json['assignedBy'],
      'imageUrl': json['imageUrl'],
      'completionImageUrl': json['completionImageUrl'],
      'completionNotes': json['completionNotes'],
      'startedAt': json['startedAt'],
      'completedAt': json['completedAt'],
      'deletedAt': json['deletedAt'],
      'deletedBy': json['deletedBy'],
    };
  }
}

// ==================== REQUEST EXTENSION METHODS ====================

extension RequestExtension on Request {
  /// Check apakah request sudah diassign ke cleaner
  bool get isAssigned => assignedTo != null;

  /// Check apakah request sudah selesai
  bool get isCompleted => status == RequestStatus.completed;

  /// Check apakah request dibatalkan
  bool get isCancelled => status == RequestStatus.cancelled;

  /// Check apakah request soft deleted
  bool get isDeleted => deletedAt != null;

  /// Check apakah request masih aktif (not completed/cancelled)
  bool get isActive => status.isActive;

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
      return assignedAt!.difference(createdAt);
    }
    return null;
  }

  /// Total time (dari dibuat hingga selesai)
  Duration? get totalTime {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }

  /// Check apakah request ini milik user tertentu
  bool isOwnedBy(String userId) {
    return requestedBy == userId;
  }

  /// Check apakah request ini diassign ke cleaner tertentu
  bool isAssignedTo(String cleanerId) {
    return assignedTo == cleanerId;
  }

  /// Check apakah user ini bisa cancel request
  /// Rules: Only requester can cancel, and only if status is pending or assigned
  bool canBeCancelledBy(String userId) {
    return requestedBy == userId &&
           (status == RequestStatus.pending || status == RequestStatus.assigned);
  }

  /// Check apakah cleaner ini bisa self-assign
  /// Rules: Status must be pending and not deleted
  bool canBeSelfAssigned() {
    return status == RequestStatus.pending && !isDeleted;
  }

  /// Check apakah cleaner ini bisa start
  /// Rules: Must be assigned to this cleaner and status is assigned
  bool canBeStartedBy(String cleanerId) {
    return assignedTo == cleanerId && status == RequestStatus.assigned;
  }

  /// Check apakah cleaner ini bisa complete
  /// Rules: Must be assigned to this cleaner and status is in_progress
  bool canBeCompletedBy(String cleanerId) {
    return assignedTo == cleanerId && status == RequestStatus.inProgress;
  }
}
