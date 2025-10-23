/// Service layer untuk interaksi dengan Firestore
/// Memisahkan business logic dari UI layer
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import '../models/report.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('FirestoreService');

  // Collection references
  CollectionReference get _reportsCollection =>
      _firestore.collection('reports');

  // ==================== REPORT QUERIES ====================

  /// Stream semua laporan (untuk admin)
  /// Diurutkan berdasarkan tanggal terbaru
  Stream<List<Report>> getAllReports({String? departmentId}) {
    try {
      Query query = _reportsCollection.orderBy('date', descending: true);

      // Filter by department jika ada
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return Report.fromFirestore(doc);
              } catch (e) {
                _logger.warning('Error parsing report ${doc.id}: $e');
                return null;
              }
            })
            .whereType<Report>()
            .toList();
      });
    } catch (e) {
      _logger.severe('Error getting all reports: $e');
      return Stream.value([]);
    }
  }

  /// Stream laporan berdasarkan user ID
  Stream<List<Report>> getReportsByUser(String userId) {
    try {
      return _reportsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Report.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting reports by user: $e');
      return Stream.value([]);
    }
  }

  /// Stream laporan berdasarkan cleaner ID
  Stream<List<Report>> getReportsByCleaner(String cleanerId) {
    try {
      return _reportsCollection
          .where('cleanerId', isEqualTo: cleanerId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Report.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting reports by cleaner: $e');
      return Stream.value([]);
    }
  }

  /// Stream laporan berdasarkan status
  Stream<List<Report>> getReportsByStatus(
    ReportStatus status, {
    String? departmentId,
  }) {
    try {
      Query query = _reportsCollection
          .where('status', isEqualTo: status.toFirestore())
          .orderBy('date', descending: true);

      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      });
    } catch (e) {
      _logger.severe('Error getting reports by status: $e');
      return Stream.value([]);
    }
  }

  /// Get single report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _reportsCollection.doc(reportId).get();
      if (doc.exists) {
        return Report.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting report by ID: $e');
      return null;
    }
  }

  // ==================== SUMMARY & ANALYTICS ====================

  /// Stream untuk summary berdasarkan status
  /// Returns Map dengan key ReportStatus dan value count
  Stream<Map<ReportStatus, int>> getReportSummary({String? departmentId}) {
    try {
      Query query = _reportsCollection;

      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }

      return query.snapshots().map((snapshot) {
        final Map<ReportStatus, int> summary = {
          ReportStatus.pending: 0,
          ReportStatus.assigned: 0,
          ReportStatus.inProgress: 0,
          ReportStatus.completed: 0,
          ReportStatus.verified: 0,
          ReportStatus.rejected: 0,
        };

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final status = ReportStatus.fromString(
              data['status'] as String? ?? 'pending',
            );
            summary[status] = (summary[status] ?? 0) + 1;
          } catch (e) {
            _logger.warning('Error parsing document ${doc.id} for summary: $e');
          }
        }

        return summary;
      });
    } catch (e) {
      _logger.severe('Error getting report summary: $e');
      return Stream.value({});
    }
  }

  /// Get reports yang selesai hari ini
  Stream<List<Report>> getTodayCompletedReports({String? departmentId}) {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      Query query = _reportsCollection
          .where('status', whereIn: ['completed', 'verified'])
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'completedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .orderBy('completedAt', descending: true);

      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      });
    } catch (e) {
      _logger.severe('Error getting today completed reports: $e');
      return getReportsByStatus(
        ReportStatus.completed,
        departmentId: departmentId,
      );
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create new report
  Future<String?> createReport(Report report) async {
    try {
      final docRef = await _reportsCollection.add(report.toFirestore());
      _logger.info('Report created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.severe('Error creating report: $e');
      rethrow;
    }
  }

  /// Update existing report
  Future<void> updateReport(
    String reportId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _reportsCollection.doc(reportId).update(updates);
      _logger.info('Report $reportId updated');
    } catch (e) {
      _logger.severe('Error updating report: $e');
      rethrow;
    }
  }

  /// Update report status
  Future<void> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    try {
      final updates = <String, dynamic>{'status': newStatus.toFirestore()};

      // Add timestamp based on status
      switch (newStatus) {
        case ReportStatus.assigned:
          updates['assignedAt'] = FieldValue.serverTimestamp();
          break;
        case ReportStatus.inProgress:
          updates['startedAt'] = FieldValue.serverTimestamp();
          break;
        case ReportStatus.completed:
          updates['completedAt'] = FieldValue.serverTimestamp();
          break;
        case ReportStatus.verified:
          updates['verifiedAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await updateReport(reportId, updates);
    } catch (e) {
      _logger.severe('Error updating report status: $e');
      rethrow;
    }
  }

  /// Verify report (untuk admin)
  Future<void> verifyReport(
    String reportId,
    String adminId,
    String adminName, {
    String? notes,
    bool approved = true,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': approved
            ? ReportStatus.verified.toFirestore()
            : ReportStatus.rejected.toFirestore(),
        'verifiedBy': adminId,
        'verifiedByName': adminName,
        'verifiedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null && notes.isNotEmpty) {
        updates['verificationNotes'] = notes;
      }

      await updateReport(reportId, updates);
      _logger.info(
        'Report $reportId ${approved ? "verified" : "rejected"} by $adminName',
      );
    } catch (e) {
      _logger.severe('Error verifying report: $e');
      rethrow;
    }
  }

  /// Assign report to cleaner
  Future<void> assignReportToCleaner(
    String reportId,
    String cleanerId,
    String cleanerName,
  ) async {
    try {
      await updateReport(reportId, {
        'cleanerId': cleanerId,
        'cleanerName': cleanerName,
        'status': ReportStatus.assigned.toFirestore(),
        'assignedAt': FieldValue.serverTimestamp(),
      });
      _logger.info('Report $reportId assigned to $cleanerName');
    } catch (e) {
      _logger.severe('Error assigning report to cleaner: $e');
      rethrow;
    }
  }

  // 🆕 NEW METHOD: Complete report with proof photo
  /// Complete report with proof photo (untuk cleaner)
  /// Digunakan saat cleaner menandai laporan selesai dengan upload foto bukti
  Future<void> completeReportWithProof(
    String reportId,
    String completionImageUrl,
  ) async {
    try {
      await updateReport(reportId, {
        'status': ReportStatus.completed.toFirestore(),
        'completedAt': FieldValue.serverTimestamp(),
        'completionImageUrl': completionImageUrl,
      });
      _logger.info('Report $reportId completed with proof image');
    } catch (e) {
      _logger.severe('Error completing report with proof: $e');
      rethrow;
    }
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _reportsCollection.doc(reportId).delete();
      _logger.info('Report $reportId deleted');
    } catch (e) {
      _logger.severe('Error deleting report: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS & METRICS ====================

  /// Get average completion time for verified reports
  Future<Duration?> getAverageCompletionTime({String? departmentId}) async {
    try {
      Query query = _reportsCollection
          .where('status', isEqualTo: ReportStatus.verified.toFirestore())
          .where('startedAt', isNull: false)
          .where('completedAt', isNull: false);

      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return null;

      int totalMinutes = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final startedAt = (data['startedAt'] as Timestamp?)?.toDate();
        final completedAt = (data['completedAt'] as Timestamp?)?.toDate();

        if (startedAt != null && completedAt != null) {
          final duration = completedAt.difference(startedAt);
          totalMinutes += duration.inMinutes;
          count++;
        }
      }

      if (count == 0) return null;
      return Duration(minutes: totalMinutes ~/ count);
    } catch (e) {
      _logger.severe('Error calculating average completion time: $e');
      return null;
    }
  }

  /// Get cleaner performance stats
  Future<Map<String, dynamic>> getCleanerStats(String cleanerId) async {
    try {
      final snapshot = await _reportsCollection
          .where('cleanerId', isEqualTo: cleanerId)
          .get();

      int totalReports = snapshot.docs.length;
      int completedReports = 0;
      int verifiedReports = 0;
      int rejectedReports = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'completed') completedReports++;
        if (status == 'verified') verifiedReports++;
        if (status == 'rejected') rejectedReports++;
      }

      return {
        'totalReports': totalReports,
        'completedReports': completedReports,
        'verifiedReports': verifiedReports,
        'rejectedReports': rejectedReports,
        'successRate': totalReports > 0
            ? (verifiedReports / totalReports * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      _logger.severe('Error getting cleaner stats: $e');
      return {};
    }
  }
}