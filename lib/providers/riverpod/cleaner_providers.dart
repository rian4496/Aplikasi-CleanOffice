import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import './auth_providers.dart';
import './report_providers.dart';

final _logger = AppLogger('CleanerProviders');

// ==================== CLEANER REPORTS PROVIDERS (NEW!) ====================

/// Provider untuk pending reports (belum diambil siapa-siapa)
final pendingReportsProvider = StreamProvider<List<Report>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('reports')
      .where('status', isEqualTo: 'pending')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Report.fromFirestore(doc);
    }).toList();
  });
});

/// Provider untuk cleaner's active reports (assigned & in_progress)
final cleanerActiveReportsProvider = StreamProvider<List<Report>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('reports')
      .where('cleanerId', isEqualTo: userId)
      .where('status', whereIn: ['assigned', 'in_progress'])
      .orderBy('assignedAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Report.fromFirestore(doc);
    }).toList();
  });
});

/// Provider untuk single report by ID
final reportDetailProvider =
    StreamProvider.family<Report?, String>((ref, reportId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('reports').doc(reportId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return Report.fromFirestore(doc);
  });
});

// ==================== CLEANER REQUESTS PROVIDERS ====================

/// Provider untuk available requests (pending & not assigned)
final availableRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('requests')
      .where('status', whereIn: ['pending'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  });
});

/// Provider untuk cleaner's assigned requests
final cleanerAssignedRequestsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
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
      return {'id': doc.id, ...doc.data()};
    }).toList();
  });
});

/// Provider untuk single request by ID
final requestByIdProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, requestId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('requests').doc(requestId).snapshots().map((
    doc,
  ) {
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  });
});

// ==================== CLEANER STATISTICS (UPDATED - dari REPORTS!) ====================

/// Provider untuk cleaner statistics - UPDATED untuk menghitung dari REPORTS
final cleanerStatsProvider = Provider<Map<String, int>>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    };
  }

  // Watch active reports (assigned & in_progress)
  final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);

  // Watch completed reports
  final completedReportsAsync = ref.watch(cleanerReportsProvider(userId));

  return activeReportsAsync.when(
    data: (activeReports) {
      // Count assigned
      final assigned =
          activeReports.where((r) => r.status == ReportStatus.assigned).length;

      // Count in progress
      final inProgress = activeReports
          .where((r) => r.status == ReportStatus.inProgress)
          .length;

      // Get completed count
      return completedReportsAsync.when(
        data: (allReports) {
          final completed = allReports
              .where(
                (r) =>
                    r.status == ReportStatus.completed ||
                    r.status == ReportStatus.verified,
              )
              .length;

          return {
            'assigned': assigned,
            'inProgress': inProgress,
            'completed': completed,
            'total': assigned + inProgress + completed,
          };
        },
        loading: () => {
          'assigned': assigned,
          'inProgress': inProgress,
          'completed': 0,
          'total': assigned + inProgress,
        },
        error: (error, stackTrace) => {
          'assigned': assigned,
          'inProgress': inProgress,
          'completed': 0,
          'total': assigned + inProgress,
        },
      );
    },
    loading: () => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    },
    error: (error, stack) => {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
    },
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

  // ==================== REPORT ACTIONS (NEW!) ====================

  /// Accept a report (pending → assigned)
  Future<void> acceptReport(String reportId) async {
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

      _logger.info('Accepting report: $reportId by user: $userId');

      await _firestore.collection('reports').doc(reportId).update({
        'status': 'assigned',
        'cleanerId': userId,
        'cleanerName': user.displayName ?? 'Petugas',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Report accepted successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Accept report error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected accept report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Start working on a report (assigned → in_progress)
  Future<void> startReport(String reportId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Starting report: $reportId');

      await _firestore.collection('reports').doc(reportId).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Report started successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Start report error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected start report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a report (in_progress → completed) - TANPA FOTO
  Future<void> completeReport(String reportId) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing report: $reportId');

      await _firestore.collection('reports').doc(reportId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Report completed successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Complete report error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected complete report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Complete a report WITH PROOF PHOTO (in_progress → completed)
  /// 🆕 BATCH 2: Method baru untuk complete dengan foto bukti
  Future<void> completeReportWithProof(
    String reportId,
    String completionImageUrl,
  ) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing report with proof: $reportId');

      await _firestore.collection('reports').doc(reportId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completionImageUrl': completionImageUrl, // ← Foto bukti
      });

      _logger.info('Report completed with proof successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Complete report with proof error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected complete report error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // ==================== REQUEST ACTIONS ====================

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

  /// Complete a request - TANPA FOTO
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

  /// Complete a request WITH PROOF PHOTO (in_progress → completed)
  /// 🆕 BATCH 2: Method baru untuk complete dengan foto bukti
  Future<void> completeRequestWithProof(
    String requestId,
    String completionImageUrl,
  ) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Completing request with proof: $requestId');

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completionImageUrl': completionImageUrl, // ← Foto bukti
      });

      _logger.info('Request completed with proof successfully');
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Complete request with proof error', e, stackTrace);
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

final cleanerActionsProvider =
    NotifierProvider<CleanerActionsNotifier, AsyncValue<void>>(
  () => CleanerActionsNotifier(),
);