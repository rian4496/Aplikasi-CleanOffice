// lib/providers/riverpod/request_providers.dart
// ✅ REQUEST PROVIDERS - Migrated to Appwrite
//
// FEATURES:
// - Stream providers for real-time request updates
// - Request validation (3 active limit)
// - Request actions (create, self-assign, start, complete, cancel)
// - Role-based data access

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../services/appwrite_storage_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './inventory_providers.dart' show appwriteDatabaseServiceProvider;

final _logger = AppLogger('RequestProviders');

// ==================== REQUEST STREAM PROVIDERS ====================

/// My Requests Provider (for employee to see own requests)
final myRequestsProvider = StreamProvider<List<Request>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getServiceRequestsByUser(userId);
});

/// Pending Requests Provider (for cleaner to self-assign)
final pendingRequestsProvider = StreamProvider<List<Request>>((ref) {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getPendingServiceRequests();
});

/// My Assigned Requests Provider (for cleaner to see assigned requests)
final myAssignedRequestsProvider = StreamProvider<List<Request>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getServiceRequestsByCleaner(userId);
});

/// All Requests Provider (for admin)
final allRequestsProvider = StreamProvider<List<Request>>((ref) {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getAllServiceRequests();
});

/// Requests by Status Provider
final requestsByStatusProvider =
    StreamProvider.family<List<Request>, RequestStatus>(
  (ref, status) {
    final service = ref.watch(appwriteDatabaseServiceProvider);
    return service.getServiceRequestsByStatus(status);
  },
);

/// Request by ID Provider (for detail screen)
final requestByIdProvider = StreamProvider.family<Request?, String>(
  (ref, requestId) {
    final service = ref.watch(appwriteDatabaseServiceProvider);
    return service.watchServiceRequestById(requestId);
  },
);

// ==================== REQUEST VALIDATION PROVIDERS ====================

/// Can Create Request Provider (check 3 active limit)
final canCreateRequestProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return false;
  }

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return await service.canCreateServiceRequest(userId);
});

/// Active Request Count Provider
final activeRequestCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return 0;
  }

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return await service.getActiveServiceRequestCount(userId);
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
        pending:
            requests.where((r) => r.status == RequestStatus.pending).length,
        assigned:
            requests.where((r) => r.status == RequestStatus.assigned).length,
        inProgress:
            requests.where((r) => r.status == RequestStatus.inProgress).length,
        completed:
            requests.where((r) => r.status == RequestStatus.completed).length,
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
}

/// Available Cleaners Provider (for employee to select cleaner)
/// TODO: Implement with Appwrite users query when needed
final availableCleanersProvider = StreamProvider<List<CleanerProfile>>((ref) {
  // For now, return empty list - cleaner selection feature can be added later
  // This would require querying users collection with role='cleaner'
  return Stream.value([]);
});

// ==================== REQUEST ACTIONS ====================

/// Request Actions Provider
final requestActionsProvider = Provider<RequestActions>((ref) {
  return RequestActions(ref);
});

/// Storage Service Provider for image uploads
final appwriteStorageServiceProvider = Provider<AppwriteStorageService>((ref) {
  return AppwriteStorageService();
});

class RequestActions {
  final Ref ref;

  RequestActions(this.ref);

  /// Create new request
  Future<String> createRequest({
    required String location,
    required String description,
    String? assignedTo,
    String? assignedToName,
    bool isUrgent = false,
    DateTime? preferredDateTime,
    Uint8List? imageBytes,
  }) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      // Check if user can create request (max 3 active)
      final service = ref.read(appwriteDatabaseServiceProvider);
      final canCreate = await service.canCreateServiceRequest(userProfile.uid);
      if (!canCreate) {
        throw const ValidationException(
          message: 'Anda sudah memiliki 3 permintaan aktif. Tunggu sampai selesai.',
        );
      }

      // Upload image if provided
      String? imageUrl;
      if (imageBytes != null) {
        _logger.info('Uploading request image...');
        final storageService = ref.read(appwriteStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes,
          folder: 'requests',
          userId: userProfile.uid,
        );
        if (result.isSuccess && result.data != null) {
          imageUrl = result.data;
          _logger.info('Image uploaded: $imageUrl');
        } else {
          _logger.warning('Image upload failed: ${result.error}');
        }
      }

      // Create request
      final request = Request(
        id: '', // Will be generated by Appwrite
        location: location,
        description: description,
        requestedBy: userProfile.uid,
        requestedByName: userProfile.displayName,
        requestedByRole: userProfile.role,
        status: assignedTo != null ? RequestStatus.assigned : RequestStatus.pending,
        createdAt: DateTime.now(),
        isUrgent: isUrgent,
        preferredDateTime: preferredDateTime,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        assignedAt: assignedTo != null ? DateTime.now() : null,
        assignedBy: assignedTo != null ? 'employee' : null,
        imageUrl: imageUrl,
      );

      final requestId = await service.createServiceRequest(request);
      if (requestId == null) {
        throw const DatabaseException(message: 'Gagal membuat permintaan.');
      }

      _logger.info('Request created successfully: $requestId');
      return requestId;
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error creating request', e);
      throw const DatabaseException(
        message: 'Gagal membuat permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Self-assign request (cleaner picks from pending)
  Future<void> selfAssignRequest(String requestId) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      final service = ref.read(appwriteDatabaseServiceProvider);
      await service.selfAssignServiceRequest(
        requestId,
        userProfile.uid,
        userProfile.displayName,
      );

      _logger.info('Request self-assigned successfully');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error self-assigning request', e);
      throw const DatabaseException(
        message: 'Gagal mengambil permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Start request (cleaner starts working)
  Future<void> startRequest(String requestId) async {
    try {
      final service = ref.read(appwriteDatabaseServiceProvider);
      await service.startServiceRequest(requestId);

      _logger.info('Request started successfully');
    } catch (e) {
      _logger.error('Error starting request', e);
      throw const DatabaseException(
        message: 'Gagal memulai permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Complete request (cleaner finishes work)
  Future<void> completeRequest({
    required String requestId,
    Uint8List? completionImageBytes,
    String? completionNotes,
  }) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      // Upload completion image if provided
      String? completionImageUrl;
      if (completionImageBytes != null) {
        _logger.info('Uploading completion image...');
        final storageService = ref.read(appwriteStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: completionImageBytes,
          folder: 'request_completions',
          userId: userProfile.uid,
        );
        if (result.isSuccess && result.data != null) {
          completionImageUrl = result.data;
          _logger.info('Completion image uploaded: $completionImageUrl');
        } else {
          _logger.warning('Completion image upload failed: ${result.error}');
        }
      }

      // Complete request
      final service = ref.read(appwriteDatabaseServiceProvider);
      await service.completeServiceRequest(
        requestId,
        completionImageUrl: completionImageUrl,
        completionNotes: completionNotes,
      );

      _logger.info('Request completed successfully');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error completing request', e);
      throw const DatabaseException(
        message: 'Gagal menyelesaikan permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Cancel request (by requester)
  Future<void> cancelRequest(String requestId) async {
    try {
      final service = ref.read(appwriteDatabaseServiceProvider);
      await service.cancelServiceRequest(requestId);

      _logger.info('Request cancelled successfully');
    } catch (e) {
      _logger.error('Error cancelling request', e);
      throw const DatabaseException(
        message: 'Gagal membatalkan permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Delete request (soft delete)
  Future<void> deleteRequest(String requestId) async {
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }

      final service = ref.read(appwriteDatabaseServiceProvider);
      await service.softDeleteServiceRequest(requestId, userProfile.uid);

      _logger.info('Request deleted successfully');
    } on ValidationException {
      rethrow;
    } catch (e) {
      _logger.error('Error deleting request', e);
      throw const DatabaseException(
        message: 'Gagal menghapus permintaan. Silakan coba lagi.',
      );
    }
  }

  /// Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      final service = ref.read(appwriteDatabaseServiceProvider);
      return await service.getServiceRequestById(requestId);
    } catch (e) {
      _logger.error('Error getting request', e);
      return null;
    }
  }
}
