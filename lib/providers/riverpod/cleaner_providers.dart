import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './report_providers.dart';

final _logger = AppLogger('CleanerProviders');

// ==================== CLEANER REQUESTS PROVIDERS ====================

/// Provider untuk available requests (pending & not assigned)
final availableRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('requests')
      .where('status', whereIn: ['pending'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

/// Provider untuk cleaner's assigned requests
final cleanerAssignedRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('requests')
      .where('cleanerId', isEqualTo: userId)
      .where('status', whereIn: ['accepted', 'in_progress'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

/// Provider untuk single request by ID
final requestByIdProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, requestId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('requests')
      .doc(requestId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return {
      'id': doc.id,
      ...doc.data()!,
    };
  });
});

// ==================== CLEANER STATISTICS ====================

/// Provider untuk cleaner statistics
final cleanerStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value({
      'completed': 0,
      'inProgress': 0,
      'total': 0,
    });
  }
  
  final reportsAsync = ref.watch(cleanerReportsProvider(userId));
  
  return reportsAsync.when(
    data: (reports) {
      final completed = reports.where((r) => r.status.toFirestore() == 'completed' || r.status.toFirestore() == 'verified').length;
      final inProgress = reports.where((r) => r.status.toFirestore() == 'in_progress').length;
      
      return Stream.value({
        'completed': completed,
        'inProgress': inProgress,
        'total': reports.length,
      });
    },
    loading: () => Stream.value({
      'completed': 0,
      'inProgress': 0,
      'total': 0,
    }),
    error: (_, __) => Stream.value({
      'completed': 0,
      'inProgress': 0,
      'total': 0,
    }),
  );
});

// ==================== CLEANER ACTIONS ====================

/// Notifier untuk cleaner actions
class CleanerActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  /// Accept a cleaning request
  Future<void> acceptRequest(String requestId) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw const AuthException(message: 'User not logged in');
      }

      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not authenticated');
      }

      _logger.info('Accepting request: $requestId by user: $userId');

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'cleanerId': userId,
        'cleanerName': user.displayName ?? 'Petugas',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Request accepted successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Accept request error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected accept request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Start working on a request
  Future<void> startRequest(String requestId) async {
    state = const AsyncValue.loading();
    
    try {
      _logger.info('Starting request: $requestId');

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Request started successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Start request error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected start request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a request
  Future<void> completeRequest(String requestId) async {
    state = const AsyncValue.loading();
    
    try {
      _logger.info('Completing request: $requestId');

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Request completed successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Complete request error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected complete request error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Create a new cleaning report
  Future<void> createCleaningReport({
    required String location,
    required String description,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw const AuthException(message: 'User not logged in');
      }

      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not authenticated');
      }

      _logger.info('Creating cleaning report');

      await _firestore.collection('reports').add({
        'userId': userId,
        'userName': user.displayName ?? 'Petugas',
        'userEmail': user.email,
        'cleanerId': userId,
        'cleanerName': user.displayName ?? 'Petugas',
        'location': location,
        'description': description,
        'imageUrl': imageUrl,
        'status': 'completed', // Cleaner creates already completed reports
        'isUrgent': false,
        'date': FieldValue.serverTimestamp(),
        'assignedAt': FieldValue.serverTimestamp(),
        'startedAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Cleaning report created successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Create cleaning report error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected create report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final cleanerActionsProvider = NotifierProvider<CleanerActionsNotifier, AsyncValue<void>>(
  () => CleanerActionsNotifier(),
);