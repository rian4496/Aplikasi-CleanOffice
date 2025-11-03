// lib/models/request.dart
// ✅ REQUEST MODEL - For personal service requests (NOT institutional reports)
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
import '../core/theme/app_theme.dart';

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
class Request {
  final String id;
  
  // ==================== REQUEST INFO ====================
  final String location;                 // "Parkiran Depan", "Pantry Lt 2", etc
  final String description;              // Detail request
  final bool isUrgent;                   // Urgent flag
  final DateTime? preferredDateTime;     // When user wants service (optional)
  
  // ==================== REQUESTER INFO ====================
  final String requestedBy;              // userId (employee/admin)
  final String requestedByName;          // User's name
  final String requestedByRole;          // 'employee' (future: 'admin')
  
  // ==================== ASSIGNMENT INFO ====================
  final String? assignedTo;              // cleanerId (null if pending)
  final String? assignedToName;          // Cleaner's name
  final DateTime? assignedAt;            // When assigned
  final String? assignedBy;              // 'employee' | 'self' | 'admin' (tracking)
  
  // ==================== STATUS & COMPLETION ====================
  final RequestStatus status;            // Current status
  final String? imageUrl;                // Initial photo (optional)
  final String? completionImageUrl;      // Completion proof (optional)
  final String? completionNotes;         // Notes from cleaner when completing
  
  // ==================== TIMESTAMPS ====================
  final DateTime createdAt;              // When request created
  final DateTime? startedAt;             // When cleaner started
  final DateTime? completedAt;           // When cleaner completed
  
  // ==================== SOFT DELETE ====================
  final DateTime? deletedAt;             // Soft delete timestamp
  final String? deletedBy;               // Who deleted (userId)

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

  /// Convert dari Firestore document ke Request object
  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Request(
      id: doc.id,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requestedBy: data['requestedBy'] as String? ?? '',
      requestedByName: data['requestedByName'] as String? ?? '',
      requestedByRole: data['requestedByRole'] as String? ?? 'employee',
      status: RequestStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUrgent: data['isUrgent'] as bool? ?? false,
      preferredDateTime: (data['preferredDateTime'] as Timestamp?)?.toDate(),
      assignedTo: data['assignedTo'] as String?,
      assignedToName: data['assignedToName'] as String?,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      assignedBy: data['assignedBy'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      completionNotes: data['completionNotes'] as String?,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert dari Map ke Request object (untuk compatibility)
  factory Request.fromMap(String id, Map<String, dynamic> data) {
    return Request(
      id: id,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requestedBy: data['requestedBy'] as String? ?? '',
      requestedByName: data['requestedByName'] as String? ?? '',
      requestedByRole: data['requestedByRole'] as String? ?? 'employee',
      status: RequestStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUrgent: data['isUrgent'] as bool? ?? false,
      preferredDateTime: (data['preferredDateTime'] as Timestamp?)?.toDate(),
      assignedTo: data['assignedTo'] as String?,
      assignedToName: data['assignedToName'] as String?,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      assignedBy: data['assignedBy'] as String?,
      imageUrl: data['imageUrl'] as String?,
      completionImageUrl: data['completionImageUrl'] as String?,
      completionNotes: data['completionNotes'] as String?,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'] as String?,
    );
  }

  /// Convert Request object ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'location': location,
      'description': description,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'requestedByRole': requestedByRole,
      'status': status.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isUrgent': isUrgent,
      'preferredDateTime': preferredDateTime != null 
          ? Timestamp.fromDate(preferredDateTime!) 
          : null,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedAt': assignedAt != null 
          ? Timestamp.fromDate(assignedAt!) 
          : null,
      'assignedBy': assignedBy,
      'imageUrl': imageUrl,
      'completionImageUrl': completionImageUrl,
      'completionNotes': completionNotes,
      'startedAt': startedAt != null 
          ? Timestamp.fromDate(startedAt!) 
          : null,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
      'deletedAt': deletedAt != null 
          ? Timestamp.fromDate(deletedAt!) 
          : null,
      'deletedBy': deletedBy,
    };
  }

  /// Copy with method untuk immutability
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

  // ==================== HELPER METHODS ====================

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

  @override
  String toString() {
    return 'Request(id: $id, location: $location, status: ${status.displayName}, '
           'requestedBy: $requestedByName, assignedTo: $assignedToName)';
  }
}