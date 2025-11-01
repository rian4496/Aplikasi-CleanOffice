// lib/services/request_service.dart
// ✅ REQUEST SERVICE - Business Logic Layer for Personal Service Requests
//
// FEATURES:
// - Validation: Max 3 active requests per employee
// - Create: With optional cleaner assignment
// - Read: Role-based queries (my requests, pending, assigned)
// - Update: Self-assign, start, complete, cancel
// - Delete: Soft delete with restore capability
// - Notification: Integration with NotificationService
//
// VISIBILITY RULES:
// - Employee: See only own requests
// - Cleaner: See pending requests (for self-assign) + assigned requests
// - Admin: See ALL requests

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/request.dart';
import '../core/logging/app_logger.dart';
import '../core/error/exceptions.dart';
import 'notification_service.dart';

final _logger = AppLogger('RequestService');

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Collection reference
  static const String _collectionName = 'requests';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // ==================== VALIDATION ====================

  /// Check if user can create new request
  /// Rules: Max 3 active requests per employee
  /// 
  /// Active = pending, assigned, or in_progress (not completed/cancelled)
  Future<bool> canCreateRequest(String userId) async {
    try {
      _logger.info('Checking request limit for user: $userId');

      final snapshot = await _collection
          .where('requestedBy', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'assigned', 'in_progress'])
          .where('deletedAt', isNull: true)
          .get();

      final activeCount = snapshot.docs.length;
      _logger.info('User has $activeCount active requests (limit: 3)');

      return activeCount < 3;
    } catch (e) {
      _logger.error('Error checking request limit', e);
      return false;
    }
  }

  /// Get active request count for user
  Future<int> getActiveRequestCount(String userId) async {
    try {
      final snapshot = await _collection
          .where('requestedBy', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'assigned', 'in_progress'])
          .where('deletedAt', isNull: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      _logger.error('Error getting active request count', e);
      return 0;
    }
  }

  // ==================== CREATE ====================

  /// Create new request with optional cleaner assignment
  /// 
  /// If assignedTo is provided:
  /// - Status: assigned (skip pending)
  /// - AssignedBy: 'employee'
  /// - Notification: Send to cleaner + requester
  /// 
  /// If assignedTo is null:
  /// - Status: pending
  /// - AssignedBy: null
  /// - Notification: Send to admins only (NOT all cleaners for privacy)
  Future<String> createRequest({
    required String userId,
    required String userName,
    required String userRole,
    required String location,
    required String description,
    String? assignedTo,              // Optional cleaner selection
    String? assignedToName,          // Cleaner name if assigned
    bool isUrgent = false,
    DateTime? preferredDateTime,
    String? imageUrl,
  }) async {
    try {
      _logger.info('Creating request for user: $userId');

      // Validate request limit
      final canCreate = await canCreateRequest(userId);
      if (!canCreate) {
        throw ValidationException(
          'Anda sudah memiliki 3 permintaan aktif. '
          'Tunggu hingga salah satu selesai untuk membuat permintaan baru.',
        );
      }

      // Determine status and assignment
      final status = assignedTo != null 
          ? RequestStatus.assigned 
          : RequestStatus.pending;
      
      final assignedBy = assignedTo != null ? 'employee' : null;
      final assignedAt = assignedTo != null ? DateTime.now() : null;

      // Create request
      final request = Request(
        id: '', // Will be set by Firestore
        location: location,
        description: description,
        requestedBy: userId,
        requestedByName: userName,
        requestedByRole: userRole,
        status: status,
        createdAt: DateTime.now(),
        isUrgent: isUrgent,
        preferredDateTime: preferredDateTime,
        imageUrl: imageUrl,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        assignedAt: assignedAt,
        assignedBy: assignedBy,
      );

      // Save to Firestore
      final docRef = await _collection.add(request.toFirestore());
      _logger.info('Request created with ID: ${docRef.id}');

      // Send notifications
      try {
        if (assignedTo != null) {
          // Employee selected cleaner → Notify cleaner + requester
          await _notificationService.notifyRequestAssigned(
            requestId: docRef.id,
            requesterId: userId,
            cleanerId: assignedTo,
            cleanerName: assignedToName ?? 'Petugas',
            location: location,
          );
        } else {
          // No cleaner selected → Notify admins only (for privacy)
          await _notificationService.notifyNewRequest(
            requestId: docRef.id,
            location: location,
            isUrgent: isUrgent,
            description: description,
            imageUrl: imageUrl,
            preferredDateTime: preferredDateTime,
          );
        }
      } catch (e) {
        _logger.error('Failed to send notification (non-critical)', e);
        // Don't fail request creation if notification fails
      }

      return docRef.id;
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error creating request', e);
      throw FirestoreException(
        'Gagal membuat permintaan. Silakan coba lagi.',
        code: e.toString(),
      );
    }
  }

  // ==================== READ ====================

  /// Get requests by user (for employee to see own requests)
  Stream<List<Request>> getRequestsByUser(String userId) {
    try {
      return _collection
          .where('requestedBy', isEqualTo: userId)
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Request.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error getting requests by user', e);
      return Stream.value([]);
    }
  }

  /// Get pending requests (for cleaner to self-assign)
  Stream<List<Request>> getPendingRequests() {
    try {
      return _collection
          .where('status', isEqualTo: 'pending')
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Request.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error getting pending requests', e);
      return Stream.value([]);
    }
  }

  /// Get requests assigned to cleaner
  Stream<List<Request>> getRequestsByAssignedCleaner(String cleanerId) {
    try {
      return _collection
          .where('assignedTo', isEqualTo: cleanerId)
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Request.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error getting requests by cleaner', e);
      return Stream.value([]);
    }
  }

  /// Get requests by status
  Stream<List<Request>> getRequestsByStatus(RequestStatus status) {
    try {
      return _collection
          .where('status', isEqualTo: status.toFirestore())
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Request.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error getting requests by status', e);
      return Stream.value([]);
    }
  }

  /// Get all requests (for admin)
  Stream<List<Request>> getAllRequests() {
    try {
      return _collection
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Request.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error getting all requests', e);
      return Stream.value([]);
    }
  }

  /// Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      final doc = await _collection.doc(requestId).get();
      if (!doc.exists) {
        _logger.warning('Request not found: $requestId');
        return null;
      }
      return Request.fromFirestore(doc);
    } catch (e) {
      _logger.error('Error getting request by ID', e);
      return null;
    }
  }

  // ==================== UPDATE ====================

  /// Self-assign request (cleaner picks from pending)
  Future<void> selfAssignRequest(String requestId, String cleanerId, String cleanerName) async {
    try {
      _logger.info('Self-assigning request $requestId to $cleanerId');

      // Get request to validate
      final request = await getRequestById(requestId);
      if (request == null) {
        throw FirestoreException('Permintaan tidak ditemukan');
      }

      // Validate can self-assign
      if (!request.canBeSelfAssigned()) {
        throw ValidationException(
          'Permintaan ini tidak dapat diambil. Status: ${request.status.displayName}',
        );
      }

      // Update request
      await _collection.doc(requestId).update({
        'status': RequestStatus.assigned.toFirestore(),
        'assignedTo': cleanerId,
        'assignedToName': cleanerName,
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedBy': 'self',
      });

      _logger.info('Request self-assigned successfully');

      // Send notification
      try {
        await _notificationService.notifyRequestAssigned(
          requestId: requestId,
          requesterId: request.requestedBy,
          cleanerId: cleanerId,
          cleanerName: cleanerName,
          location: request.location,
        );
      } catch (e) {
        _logger.error('Failed to send notification (non-critical)', e);
      }
    } catch (e) {
      _logger.error('Error self-assigning request', e);
      if (e is ValidationException || e is FirestoreException) {
        rethrow;
      }
      throw FirestoreException('Gagal mengambil permintaan. Silakan coba lagi.');
    }
  }

  /// Start request (cleaner starts working)
  Future<void> startRequest(String requestId, String cleanerId) async {
    try {
      _logger.info('Starting request $requestId by $cleanerId');

      // Get request to validate
      final request = await getRequestById(requestId);
      if (request == null) {
        throw FirestoreException('Permintaan tidak ditemukan');
      }

      // Validate can start
      if (!request.canBeStartedBy(cleanerId)) {
        throw ValidationException(
          'Anda tidak dapat memulai permintaan ini. '
          'Status: ${request.status.displayName}',
        );
      }

      // Update request
      await _collection.doc(requestId).update({
        'status': RequestStatus.inProgress.toFirestore(),
        'startedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Request started successfully');
    } catch (e) {
      _logger.error('Error starting request', e);
      if (e is ValidationException || e is FirestoreException) {
        rethrow;
      }
      throw FirestoreException('Gagal memulai permintaan. Silakan coba lagi.');
    }
  }

  /// Complete request (cleaner finishes work)
  Future<void> completeRequest({
    required String requestId,
    required String cleanerId,
    String? completionImageUrl,
    String? completionNotes,
  }) async {
    try {
      _logger.info('Completing request $requestId by $cleanerId');

      // Get request to validate
      final request = await getRequestById(requestId);
      if (request == null) {
        throw FirestoreException('Permintaan tidak ditemukan');
      }

      // Validate can complete
      if (!request.canBeCompletedBy(cleanerId)) {
        throw ValidationException(
          'Anda tidak dapat menyelesaikan permintaan ini. '
          'Status: ${request.status.displayName}',
        );
      }

      // Update request
      await _collection.doc(requestId).update({
        'status': RequestStatus.completed.toFirestore(),
        'completedAt': FieldValue.serverTimestamp(),
        'completionImageUrl': completionImageUrl,
        'completionNotes': completionNotes,
      });

      _logger.info('Request completed successfully');

      // Send notification
      try {
        await _notificationService.notifyRequestCompleted(
          requestId: requestId,
          requesterId: request.requestedBy,
          location: request.location,
          cleanerName: request.assignedToName ?? 'Petugas',
          completionImageUrl: completionImageUrl,
        );
      } catch (e) {
        _logger.error('Failed to send notification (non-critical)', e);
      }
    } catch (e) {
      _logger.error('Error completing request', e);
      if (e is ValidationException || e is FirestoreException) {
        rethrow;
      }
      throw FirestoreException('Gagal menyelesaikan permintaan. Silakan coba lagi.');
    }
  }

  /// Cancel request (by requester or admin)
  Future<void> cancelRequest(String requestId, String userId) async {
    try {
      _logger.info('Cancelling request $requestId by $userId');

      // Get request to validate
      final request = await getRequestById(requestId);
      if (request == null) {
        throw FirestoreException('Permintaan tidak ditemukan');
      }

      // Validate can cancel
      if (!request.canBeCancelledBy(userId)) {
        throw ValidationException(
          'Anda tidak dapat membatalkan permintaan ini. '
          'Status: ${request.status.displayName}',
        );
      }

      // Update request
      await _collection.doc(requestId).update({
        'status': RequestStatus.cancelled.toFirestore(),
      });

      _logger.info('Request cancelled successfully');
    } catch (e) {
      _logger.error('Error cancelling request', e);
      if (e is ValidationException || e is FirestoreException) {
        rethrow;
      }
      throw FirestoreException('Gagal membatalkan permintaan. Silakan coba lagi.');
    }
  }

  // ==================== DELETE ====================

  /// Soft delete request
  Future<void> softDeleteRequest(String requestId, String deletedBy) async {
    try {
      _logger.info('Soft deleting request $requestId by $deletedBy');

      await _collection.doc(requestId).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': deletedBy,
      });

      _logger.info('Request soft deleted successfully');
    } catch (e) {
      _logger.error('Error soft deleting request', e);
      throw FirestoreException('Gagal menghapus permintaan. Silakan coba lagi.');
    }
  }

  /// Restore soft deleted request
  Future<void> restoreRequest(String requestId) async {
    try {
      _logger.info('Restoring request $requestId');

      await _collection.doc(requestId).update({
        'deletedAt': FieldValue.delete(),
        'deletedBy': FieldValue.delete(),
      });

      _logger.info('Request restored successfully');
    } catch (e) {
      _logger.error('Error restoring request', e);
      throw FirestoreException('Gagal memulihkan permintaan. Silakan coba lagi.');
    }
  }

  // ==================== ANALYTICS ====================

  /// Get request statistics for user
  Future<Map<String, int>> getRequestStatsByUser(String userId) async {
    try {
      final snapshot = await _collection
          .where('requestedBy', isEqualTo: userId)
          .where('deletedAt', isNull: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => Request.fromFirestore(doc))
          .toList();

      return {
        'total': requests.length,
        'pending': requests.where((r) => r.status == RequestStatus.pending).length,
        'assigned': requests.where((r) => r.status == RequestStatus.assigned).length,
        'inProgress': requests.where((r) => r.status == RequestStatus.inProgress).length,
        'completed': requests.where((r) => r.status == RequestStatus.completed).length,
        'cancelled': requests.where((r) => r.status == RequestStatus.cancelled).length,
        'active': requests.where((r) => r.isActive).length,
      };
    } catch (e) {
      _logger.error('Error getting request stats', e);
      return {};
    }
  }

  /// Get request statistics for cleaner
  Future<Map<String, int>> getRequestStatsByCleaner(String cleanerId) async {
    try {
      final snapshot = await _collection
          .where('assignedTo', isEqualTo: cleanerId)
          .where('deletedAt', isNull: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => Request.fromFirestore(doc))
          .toList();

      return {
        'total': requests.length,
        'assigned': requests.where((r) => r.status == RequestStatus.assigned).length,
        'inProgress': requests.where((r) => r.status == RequestStatus.inProgress).length,
        'completed': requests.where((r) => r.status == RequestStatus.completed).length,
        'active': requests.where((r) => r.isActive).length,
      };
    } catch (e) {
      _logger.error('Error getting cleaner stats', e);
      return {};
    }
  }
}
