// lib/providers/riverpod/request_providers.dart
// ✅ REQUEST PROVIDERS - Riverpod State Management for Requests
//
// FEATURES:
// - Stream providers for real-time request updates
// - Request validation (3 active limit)
// - Cleaner list provider (for selection)
// - Request actions (create, self-assign, start, complete, cancel)
// - Role-based data access

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../../services/storage_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';

final _logger = AppLogger('RequestProviders');

// ==================== SERVICE PROVIDER ====================

/// Request Service Provider
final requestServiceProvider = Provider<RequestService>((ref) {
  return RequestService();
});

// ==================== AUTH PROVIDERS ====================

/// Current Request User Provider
final currentRequestUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current Request User ID Provider
final currentRequestUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentRequestUserProvider);
  return userAsync.whenData((user) => user?.uid).value;
});

// ==================== REQUEST STREAM PROVIDERS ====================

/// My Requests Provider (for employee to see own requests)
final myRequestsProvider = StreamProvider<List<Request>>((ref) {
  final userId = ref.watch(currentRequestUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(requestServiceProvider);
  return service.getRequestsByUser(userId);
});

/// Pending Requests Provider (for cleaner to self-assign)
final pendingRequestsProvider = StreamProvider<List<Request>>((ref) {
  final service = ref.watch(requestServiceProvider);
  return service.getPendingRequests();
});

/// My Assigned Requests Provider (for cleaner to see assigned requests)
final myAssignedRequestsProvider = StreamProvider<List<Request>>((ref) {
  final userId = ref.watch(currentRequestUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(requestServiceProvider);
  return service.getRequestsByAssignedCleaner(userId);
});

/// All Requests Provider (for admin)
final allRequestsProvider = StreamProvider<List<Request>>((ref) {
  final service = ref.watch(requestServiceProvider);
  return service.getAllRequests();
});

/// Requests by Status Provider
final requestsByStatusProvider = StreamProvider.family<List<Request>, RequestStatus>(
  (ref, status) {
    final service = ref.watch(requestServiceProvider);
    return service.getRequestsByStatus(status);
  },
);

// ==================== REQUEST VALIDATION PROVIDERS ====================

/// Can Create Request Provider (check 3 active limit)
final canCreateRequestProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentRequestUserIdProvider);
  
  if (userId == null) {
    return false;
  }

  final service = ref.watch(requestServiceProvider);
  return await service.canCreateRequest(userId);
});

/// Active Request Count Provider
final activeRequestCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentRequestUserIdProvider);
  
  if (userId == null) {
    return 0;
  }

  final service = ref.watch(requestServiceProvider);
  return await service.getActiveRequestCount(userId);
});

// ==================== REQUEST SUMMARY PROVIDERS ====================

/// Request Summary for Employee
class RequestSummary {
  final int total;
  final int pending;
  final int assigned;
  final int inProgress;
  final int completed;
  final int active;

  const RequestSummary({
    required this.total,
    required this.pending,
    required this.assigned,
    required this.inProgress,
    required this.completed,
    required this.active,
  });
}

final myRequestsSummaryProvider = Provider<RequestSummary>((ref) {
  final requestsAsync = ref.watch(myRequestsProvider);

  return requestsAsync.when(
    data: (requests) {
      return RequestSummary(
        total: requests.length,
        pending: requests.where((r) => r.status == RequestStatus.pending).length,
        assigned: requests.where((r) => r.status == RequestStatus.assigned).length,
        inProgress: requests.where((r) => r.status == RequestStatus.inProgress).length,
        completed: requests.where((r) => r.status == RequestStatus.completed).length,
        active: requests.where((r) => r.isActive).length,
      );
    },
    loading: () => const RequestSummary(
      total: 0,
      pending: 0,
      assigned: 0,
      inProgress: 0,
      completed: 0,
      active: 0,
    ),
    error: (error, stackTrace) => const RequestSummary(
      total: 0,
      pending: 0,
      assigned: 0,
      inProgress: 0,
      completed: 0,
      active: 0,
    ),
  );
});

// ==================== CLEANER LIST PROVIDER ====================

/// User Profile Model (lightweight for cleaner list)
class CleanerProfile {
  final String id;
  final String name;
  final String? email;
  final String? photoUrl;
  final int activeTaskCount;

  CleanerProfile({
    required this.id,
    required this.name,
    this.email,
    this.photoUrl,
    this.activeTaskCount = 0,
  });

  factory CleanerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CleanerProfile(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      activeTaskCount: data['activeTaskCount'] as int? ?? 0,
    );
  }
}

/// Available Cleaners Provider (for employee to select cleaner)
final availableCleanersProvider = StreamProvider<List<CleanerProfile>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'cleaner')
        .snapshots()
        .asyncMap((snapshot) async {
      final cleaners = <CleanerProfile>[];
      
      for (var doc in snapshot.docs) {
        final cleaner = CleanerProfile.fromFirestore(doc);
        
        // Get active task count for this cleaner
        final requestService = ref.read(requestServiceProvider);
        final stats = await requestService.getRequestStatsByCleaner(cleaner.id);
        final activeCount = stats['active'] ?? 0;
        
        cleaners.add(CleanerProfile(
          id: cleaner.id,
          name: cleaner.name,
          email: cleaner.email,
          photoUrl: cleaner.photoUrl,
          activeTaskCount: activeCount,
        ));
      }
      
      // Sort by active task count (least busy first)
      cleaners.sort((a, b) => a.activeTaskCount.compareTo(b.activeTaskCount));
      
      return cleaners;
    });
  } catch (e) {
    _logger.error('Error getting cleaners', e);
    return Stream.value([]);
  }
});

// ==================== REQUEST ACTIONS ====================

/// Request Actions Provider
final requestActionsProvider = Provider<RequestActions>((ref) {
  return RequestActions(ref);
});

class RequestActions {
  final Ref ref;

  RequestActions(this.ref);

  /// Create new request
  Future<String> createRequest({
    required String location,
    required String description,
    String? assignedTo,          // Optional cleaner selection
    String? assignedToName,
    bool isUrgent = false,
    DateTime? preferredDateTime,
    Uint8List? imageBytes,       // Optional image
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      // Upload image if provided
      String? imageUrl;
      if (imageBytes != null) {
        _logger.info('Uploading request image...');
        final storageService = ref.read(storageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes,
          folder: 'requests',
          userId: user.uid,
        );

        if (result.isSuccess && result.data != null) {
          imageUrl = result.data;
          _logger.info('Image uploaded: $imageUrl');
        } else {
          _logger.warning('Image upload failed: ${result.error}');
        }
      }

      // Create request
      final service = ref.read(requestServiceProvider);
      final requestId = await service.createRequest(
        userId: user.uid,
        userName: user.displayName ?? 'Unknown',
        userRole: 'employee',
        location: location,
        description: description,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        isUrgent: isUrgent,
        preferredDateTime: preferredDateTime,
        imageUrl: imageUrl,
      );

      _logger.info('Request created successfully: $requestId');
      return requestId;
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error creating request', e);
      throw FirestoreException('Gagal membuat permintaan. Silakan coba lagi.');
    }
  }

  /// Self-assign request (cleaner picks from pending)
  Future<void> selfAssignRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      final service = ref.read(requestServiceProvider);
      await service.selfAssignRequest(
        requestId,
        user.uid,
        user.displayName ?? 'Unknown',
      );

      _logger.info('Request self-assigned successfully');
    } on ValidationException {
      rethrow;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _logger.error('Error self-assigning request', e);
      throw FirestoreException('Gagal mengambil permintaan. Silakan coba lagi.');
    }
  }

  /// Start request (cleaner starts working)
  Future<void> startRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      final service = ref.read(requestServiceProvider);
      await service.startRequest(requestId, user.uid);

      _logger.info('Request started successfully');
    } on ValidationException {
      rethrow;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _logger.error('Error starting request', e);
      throw FirestoreException('Gagal memulai permintaan. Silakan coba lagi.');
    }
  }

  /// Complete request (cleaner finishes work)
  Future<void> completeRequest({
    required String requestId,
    Uint8List? completionImageBytes,
    String? completionNotes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      // Upload completion image if provided
      String? completionImageUrl;
      if (completionImageBytes != null) {
        _logger.info('Uploading completion image...');
        final storageService = ref.read(storageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: completionImageBytes,
          folder: 'request_completions',
          userId: user.uid,
        );

        if (result.isSuccess && result.data != null) {
          completionImageUrl = result.data;
          _logger.info('Completion image uploaded: $completionImageUrl');
        } else {
          _logger.warning('Completion image upload failed: ${result.error}');
        }
      }

      // Complete request
      final service = ref.read(requestServiceProvider);
      await service.completeRequest(
        requestId: requestId,
        cleanerId: user.uid,
        completionImageUrl: completionImageUrl,
        completionNotes: completionNotes,
      );

      _logger.info('Request completed successfully');
    } on ValidationException {
      rethrow;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _logger.error('Error completing request', e);
      throw FirestoreException('Gagal menyelesaikan permintaan. Silakan coba lagi.');
    }
  }

  /// Cancel request (by requester)
  Future<void> cancelRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      final service = ref.read(requestServiceProvider);
      await service.cancelRequest(requestId, user.uid);

      _logger.info('Request cancelled successfully');
    } on ValidationException {
      rethrow;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _logger.error('Error cancelling request', e);
      throw FirestoreException('Gagal membatalkan permintaan. Silakan coba lagi.');
    }
  }

  /// Delete request (soft delete)
  Future<void> deleteRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw ValidationException('User not logged in');
      }

      final service = ref.read(requestServiceProvider);
      await service.softDeleteRequest(requestId, user.uid);

      _logger.info('Request deleted successfully');
    } on ValidationException {
      rethrow;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _logger.error('Error deleting request', e);
      throw FirestoreException('Gagal menghapus permintaan. Silakan coba lagi.');
    }
  }

  /// Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      final service = ref.read(requestServiceProvider);
      return await service.getRequestById(requestId);
    } catch (e) {
      _logger.error('Error getting request', e);
      return null;
    }
  }
}
