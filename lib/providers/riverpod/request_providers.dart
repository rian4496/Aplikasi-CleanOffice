// lib/providers/riverpod/request_providers.dart
// ✅ REQUEST PROVIDERS - Migrated to Supabase
//
// FEATURES:
// - Future providers for request data (Supabase uses Futures, not Streams)
// - Request validation (3 active limit)
// - Request actions (create, self-assign, start, complete, cancel)
// - Role-based data access

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../models/user_role.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';

final _logger = AppLogger('RequestProviders');

// ==================== REQUEST PROVIDERS ====================

/// My Requests Provider (for employee to see own requests)
final myRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return [];
  }

  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByUserId(userId);
});

/// Pending Requests Provider (for cleaner to self-assign)
final pendingRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByStatus('pending');
});

/// My Assigned Requests Provider (for cleaner to see assigned requests)
final myAssignedRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return [];
  }

  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getRequestsByCleanerId(userId);
});

/// All Requests Provider (for admin)
final allRequestsProvider = FutureProvider<List<Request>>((ref) async {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getAllRequests();
});

/// Requests by Status Provider
final requestsByStatusProvider =
    FutureProvider.family<List<Request>, RequestStatus>(
  (ref, status) async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return service.getRequestsByStatus(status.toDatabase());
  },
);

/// Request by ID Provider (for detail screen)
final requestByIdProvider = FutureProvider.family<Request?, String>(
  (ref, requestId) async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return service.getRequestById(requestId);
  },
);

// ==================== REQUEST VALIDATION PROVIDERS ====================

/// Can Create Request Provider (check 3 active limit)
final canCreateRequestProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return false;
  }

  final service = ref.watch(supabaseDatabaseServiceProvider);
  final requests = await service.getRequestsByUserId(userId);
  
  // Count active requests (not completed or cancelled)
  final activeCount = requests.where((r) => r.isActive).length;
  return activeCount < 3;
});

/// Active Request Count Provider
final activeRequestCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return 0;
  }

  final service = ref.watch(supabaseDatabaseServiceProvider);
  final requests = await service.getRequestsByUserId(userId);
  
  // Count active requests (not completed or cancelled)
  return requests.where((r) => r.isActive).length;
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

/// Available Cleaners Provider - Fetches all active cleaners from Supabase
/// This provider is used by Cleaner Management screen to display all cleaners
final availableCleanersProvider = FutureProvider<List<CleanerProfile>>((ref) async {
  final service = ref.read(supabaseDatabaseServiceProvider);

  try {
    _logger.info('🔍 Fetching cleaners from Supabase...');

    // Fetch all users
    final allUsers = await service.getAllUserProfiles();

    // Filter for cleaners with active status
    final cleaners = allUsers.where((user) =>
      user.role == UserRole.cleaner &&
      user.status == 'active'
    ).toList();

    _logger.info('✅ Found ${cleaners.length} active cleaners');

    // Map UserProfile to CleanerProfile
    return cleaners.map((user) => CleanerProfile(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      activeTaskCount: 0, // TODO: Calculate from requests in future enhancement
    )).toList();
  } catch (e, stackTrace) {
    _logger.error('❌ Error fetching cleaners', e, stackTrace);
    rethrow;
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
      final service = ref.read(supabaseDatabaseServiceProvider);
      final requests = await service.getRequestsByUserId(userProfile.uid);
      final activeCount = requests.where((r) => r.isActive).length;
      
      if (activeCount >= 3) {
        throw const ValidationException(
          message: 'Anda sudah memiliki 3 permintaan aktif. Tunggu sampai selesai.',
        );
      }

      // Upload image if provided
      String? imageUrl;
      if (imageBytes != null) {
        _logger.info('Uploading request image...');
        final storageService = ref.read(supabaseStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes,
          bucket: 'report-images', // Using report-images bucket for requests too
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
        id: '', // Will be generated by Supabase
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

      final createdRequest = await service.createRequest(request);
      _logger.info('Request created successfully: ${createdRequest.id}');
      return createdRequest.id;
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

      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.assignRequestToCleaner(
        requestId: requestId,
        cleanerId: userProfile.uid,
        cleanerName: userProfile.displayName,
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
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.updateRequestStatus(requestId, 'in_progress');

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
        final storageService = ref.read(supabaseStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: completionImageBytes,
          bucket: 'report-images',
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
      final service = ref.read(supabaseDatabaseServiceProvider);
      final updates = <String, dynamic>{
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      };
      
      if (completionImageUrl != null) {
        updates['completion_image_url'] = completionImageUrl;
      }
      if (completionNotes != null) {
        updates['notes'] = completionNotes;
      }
      
      await service.updateRequest(requestId, updates);

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
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const ValidationException(message: 'User not logged in');
      }
      
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.cancelRequest(requestId, userProfile.uid);

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

      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.deleteRequest(requestId, userProfile.uid);

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
      final service = ref.read(supabaseDatabaseServiceProvider);
      return await service.getRequestById(requestId);
    } catch (e) {
      _logger.error('Error getting request', e);
      return null;
    }
  }
}
