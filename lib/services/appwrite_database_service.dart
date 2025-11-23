// lib/services/appwrite_database_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:logging/logging.dart';
import '../core/services/appwrite_client.dart';
import '../core/config/appwrite_config.dart';
import '../models/report.dart';
import '../models/inventory_item.dart'; // Includes StockRequest, RequestStatus (for inventory)
import '../models/notification_model.dart';
import '../models/request.dart' as service_request; // ServiceRequest model
import '../models/user_profile.dart';

/// Appwrite Database Service
///
/// Replaces FirestoreService with Appwrite Database API
/// Handles all database operations for reports, inventory, requests, etc.
class AppwriteDatabaseService {
  static final AppwriteDatabaseService _instance =
      AppwriteDatabaseService._internal();
  factory AppwriteDatabaseService() => _instance;
  AppwriteDatabaseService._internal();

  final Logger _logger = Logger('AppwriteDatabaseService');

  // Get Appwrite services
  Databases get _databases => AppwriteClient().databases;
  Realtime get _realtime => AppwriteClient().realtime;

  // ==================== REPORT QUERIES ====================

  /// Get all reports (for admin)
  /// Returns Stream of Reports list
  Stream<List<Report>> getAllReports({String? departmentId}) {
    try {
      final queries = <String>[
        Query.equal('deletedAt', [null]),
        Query.orderDesc('date'),
      ];

      if (departmentId != null && departmentId.isNotEmpty) {
        queries.add(Query.equal('departmentId', departmentId));
      }

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) {
                  try {
                    return Report.fromAppwrite(doc.data);
                  } catch (e) {
                    _logger.warning('Error parsing report ${doc.$id}: $e');
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

  /// Get reports by user ID
  Stream<List<Report>> getReportsByUser(String userId) {
    try {
      final queries = [
        Query.equal('userId', userId),
        Query.equal('deletedAt', [null]),
        Query.orderDesc('date'),
      ];

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => Report.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting reports by user: $e');
      return Stream.value([]);
    }
  }

  /// Get reports by cleaner ID
  Stream<List<Report>> getReportsByCleaner(String cleanerId) {
    try {
      final queries = [
        Query.equal('cleanerId', cleanerId),
        Query.equal('deletedAt', [null]),
        Query.orderDesc('date'),
      ];

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => Report.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting reports by cleaner: $e');
      return Stream.value([]);
    }
  }

  /// Get reports by status
  Stream<List<Report>> getReportsByStatus(
    ReportStatus status, {
    String? departmentId,
  }) {
    try {
      final queries = [
        Query.equal('status', status.toFirestore()),
        Query.equal('deletedAt', [null]),
        Query.orderDesc('date'),
      ];

      if (departmentId != null && departmentId.isNotEmpty) {
        queries.add(Query.equal('departmentId', departmentId));
      }

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => Report.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting reports by status: $e');
      return Stream.value([]);
    }
  }

  /// Get single report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        documentId: reportId,
      );

      return Report.fromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting report by ID: $e');
      return null;
    }
  }

  // ==================== SUMMARY & ANALYTICS ====================

  /// Get report summary by status
  /// Returns Map with ReportStatus as key and count as value
  Stream<Map<ReportStatus, int>> getReportSummary({String? departmentId}) {
    try {
      final queries = [Query.equal('deletedAt', [null])];

      if (departmentId != null && departmentId.isNotEmpty) {
        queries.add(Query.equal('departmentId', departmentId));
      }

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            final Map<ReportStatus, int> summary = {
              ReportStatus.pending: 0,
              ReportStatus.assigned: 0,
              ReportStatus.inProgress: 0,
              ReportStatus.completed: 0,
              ReportStatus.verified: 0,
              ReportStatus.rejected: 0,
            };

            for (var doc in response.documents) {
              try {
                final status = ReportStatus.fromString(
                  doc.data['status'] as String? ?? 'pending',
                );
                summary[status] = (summary[status] ?? 0) + 1;
              } catch (e) {
                _logger.warning('Error parsing document ${doc.$id}: $e');
              }
            }

            return summary;
          });
    } catch (e) {
      _logger.severe('Error getting report summary: $e');
      return Stream.value({});
    }
  }

  /// Get today's completed reports
  Stream<List<Report>> getTodayCompletedReports({String? departmentId}) {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final queries = [
        Query.equal('deletedAt', [null]),
        Query.equal('status', ['completed', 'verified']),
        Query.greaterThanEqual(
          'completedAt',
          startOfDay.toIso8601String(),
        ),
        Query.lessThanEqual(
          'completedAt',
          endOfDay.toIso8601String(),
        ),
        Query.orderDesc('completedAt'),
      ];

      if (departmentId != null && departmentId.isNotEmpty) {
        queries.add(Query.equal('departmentId', departmentId));
      }

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => Report.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting today completed reports: $e');
      return Stream.value([]);
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create new report
  Future<String?> createReport(Report report) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        documentId: ID.unique(),
        data: report.toAppwrite(),
      );

      _logger.info('Report created with ID: ${doc.$id}');
      return doc.$id;
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
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        documentId: reportId,
        data: updates,
      );

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
      final updates = <String, dynamic>{
        'status': newStatus.toFirestore(),
      };

      // Add timestamp based on status
      final now = DateTime.now().toIso8601String();
      switch (newStatus) {
        case ReportStatus.assigned:
          updates['assignedAt'] = now;
          break;
        case ReportStatus.inProgress:
          updates['startedAt'] = now;
          break;
        case ReportStatus.completed:
          updates['completedAt'] = now;
          break;
        case ReportStatus.verified:
          updates['verifiedAt'] = now;
          break;
        default:
          break;
      }

      await updateReport(reportId, updates);

      // TODO: Send notifications based on status
      // final report = await getReportById(reportId);
      // if (report != null) {
      //   await NotificationService().notifyReportStatusChanged(report);
      // }
    } catch (e) {
      _logger.severe('Error updating report status: $e');
      rethrow;
    }
  }

  /// Verify report (for admin)
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
        'verifiedAt': DateTime.now().toIso8601String(),
      };

      if (notes != null && notes.isNotEmpty) {
        updates['verificationNotes'] = notes;
      }

      await updateReport(reportId, updates);
      _logger.info(
        'Report $reportId ${approved ? "verified" : "rejected"} by $adminName',
      );

      // TODO: Send notification
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
        'assignedAt': DateTime.now().toIso8601String(),
      });

      _logger.info('Report $reportId assigned to $cleanerName');

      // TODO: Send notification to cleaner
    } catch (e) {
      _logger.severe('Error assigning report to cleaner: $e');
      rethrow;
    }
  }

  /// Complete report with proof photo (for cleaner)
  Future<void> completeReportWithProof(
    String reportId,
    String completionImageUrl,
  ) async {
    try {
      await updateReport(reportId, {
        'status': ReportStatus.completed.toFirestore(),
        'completedAt': DateTime.now().toIso8601String(),
        'completionImageUrl': completionImageUrl,
      });

      _logger.info('Report $reportId completed with proof image');

      // TODO: Send notification to employee and admins
    } catch (e) {
      _logger.severe('Error completing report with proof: $e');
      rethrow;
    }
  }

  // ==================== SOFT DELETE OPERATIONS ====================

  /// Soft delete report (mark as deleted)
  Future<void> softDeleteReport(String reportId, String deletedByUserId) async {
    try {
      await updateReport(reportId, {
        'deletedAt': DateTime.now().toIso8601String(),
        'deletedBy': deletedByUserId,
      });

      _logger.info('Report $reportId soft deleted by $deletedByUserId');
    } catch (e) {
      _logger.severe('Error soft deleting report: $e');
      rethrow;
    }
  }

  /// Restore soft deleted report
  Future<void> restoreReport(String reportId) async {
    try {
      await updateReport(reportId, {
        'deletedAt': null,
        'deletedBy': null,
      });

      _logger.info('Report $reportId restored');
    } catch (e) {
      _logger.severe('Error restoring report: $e');
      rethrow;
    }
  }

  /// Permanent delete (hard delete) - use with caution
  Future<void> permanentDeleteReport(String reportId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        documentId: reportId,
      );

      _logger.info('Report $reportId permanently deleted');
    } catch (e) {
      _logger.severe('Error permanently deleting report: $e');
      rethrow;
    }
  }

  /// Get soft deleted reports (for admin review/cleanup)
  Stream<List<Report>> getDeletedReports({String? userId}) {
    try {
      final queries = [
        Query.notEqual('deletedAt', [null]),
        Query.orderDesc('deletedAt'),
      ];

      if (userId != null && userId.isNotEmpty) {
        queries.add(Query.equal('userId', userId));
      }

      return _realtime
          .subscribe([AppwriteConfig.reportsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.reportsCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => Report.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting deleted reports: $e');
      return Stream.value([]);
    }
  }

  /// Legacy delete method (now calls soft delete for backward compatibility)
  Future<void> deleteReport(String reportId) async {
    await softDeleteReport(reportId, 'system');
  }

  // ==================== STATISTICS & METRICS ====================

  /// Get average completion time for verified reports
  Future<Duration?> getAverageCompletionTime({String? departmentId}) async {
    try {
      final queries = [
        Query.equal('deletedAt', [null]),
        Query.equal('status', ReportStatus.verified.toFirestore()),
        Query.notEqual('startedAt', [null]),
        Query.notEqual('completedAt', [null]),
      ];

      if (departmentId != null && departmentId.isNotEmpty) {
        queries.add(Query.equal('departmentId', departmentId));
      }

      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        queries: queries,
      );

      if (response.documents.isEmpty) return null;

      int totalMinutes = 0;
      int count = 0;

      for (var doc in response.documents) {
        final startedAt = DateTime.tryParse(doc.data['startedAt'] ?? '');
        final completedAt = DateTime.tryParse(doc.data['completedAt'] ?? '');

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
      final queries = [
        Query.equal('cleanerId', cleanerId),
        Query.equal('deletedAt', [null]),
      ];

      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.reportsCollectionId,
        queries: queries,
      );

      int totalReports = response.documents.length;
      int completedReports = 0;
      int verifiedReports = 0;
      int rejectedReports = 0;

      for (var doc in response.documents) {
        final status = doc.data['status'] as String?;

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

  // ==================== USER PROFILE QUERIES ====================

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      _logger.info('Updating user profile: ${profile.uid}');

      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: profile.uid,
        data: profile.toAppwrite(),
      );

      _logger.info('User profile updated successfully');
    } catch (e) {
      _logger.severe('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
      );

      return UserProfile.fromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting user profile: $e');
      return null;
    }
  }

  // ==================== INVENTORY QUERIES ====================

  /// Get all inventory items
  Stream<List<InventoryItem>> getAllInventoryItems() {
    try {
      final queries = [
        Query.equal('deletedAt', [null]),
        Query.orderAsc('name'),
      ];

      return _realtime
          .subscribe([AppwriteConfig.inventoryChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.inventoryCollectionId,
              queries: queries,
            );

            return response.documents
                .map((doc) => _inventoryItemFromAppwrite(doc.data))
                .whereType<InventoryItem>()
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting inventory items: $e');
      return Stream.value([]);
    }
  }

  /// Get low stock items (quantity <= minStock)
  Stream<List<InventoryItem>> getLowStockItems() {
    try {
      return _realtime
          .subscribe([AppwriteConfig.inventoryChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.inventoryCollectionId,
              queries: [
                Query.equal('deletedAt', [null]),
              ],
            );

            return response.documents
                .map((doc) => _inventoryItemFromAppwrite(doc.data))
                .whereType<InventoryItem>()
                .where((item) => (item.currentStock) <= (item.minStock))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting low stock items: $e');
      return Stream.value([]);
    }
  }

  /// Get inventory item by ID
  Future<InventoryItem?> getInventoryItemById(String itemId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
      );

      return _inventoryItemFromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting inventory item: $e');
      return null;
    }
  }

  /// Helper: Convert Appwrite document to InventoryItem
  InventoryItem? _inventoryItemFromAppwrite(Map<String, dynamic> data) {
    try {
      return InventoryItem(
        id: data['\$id'] ?? '',
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        currentStock: data['quantity'] ?? 0, // Map quantity to currentStock
        maxStock: (data['quantity'] ?? 0) * 2, // Estimate maxStock (quantity * 2)
        minStock: data['minStock'] ?? 0,
        unit: data['unit'] ?? '',
        description: data['description'],
        imageUrl: data['imageUrl'],
        createdAt: DateTime.parse(data['\$createdAt']),
        updatedAt: DateTime.parse(data['\$updatedAt']),
      );
    } catch (e) {
      _logger.warning('Error parsing inventory item: $e');
      return null;
    }
  }

  /// Create inventory item
  Future<String?> createInventoryItem(InventoryItem item) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: ID.unique(),
        data: {
          'name': item.name,
          'category': item.category,
          'quantity': item.currentStock,
          'unit': item.unit,
          'minStock': item.minStock,
          'location': null,
          'imageUrl': item.imageUrl,
          'description': item.description,
          'lastRestocked': null,
          'deletedAt': null,
        },
      );

      return doc.$id;
    } catch (e) {
      _logger.severe('Error creating inventory item: $e');
      return null;
    }
  }

  /// Update inventory item
  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: updates,
      );
    } catch (e) {
      _logger.severe('Error updating inventory item: $e');
      rethrow;
    }
  }

  /// Update inventory stock
  Future<void> updateInventoryStock(String itemId, int newQuantity) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: {
          'quantity': newQuantity,
          'lastRestocked': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.severe('Error updating inventory stock: $e');
      rethrow;
    }
  }

  /// Soft delete inventory item
  Future<void> softDeleteInventoryItem(String itemId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.inventoryCollectionId,
        documentId: itemId,
        data: {
          'deletedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.severe('Error soft deleting inventory item: $e');
      rethrow;
    }
  }

  // ==================== STOCK REQUEST QUERIES ====================

  /// Get all pending stock requests
  Stream<List<StockRequest>> getPendingStockRequests() {
    try {
      return _realtime
          .subscribe([AppwriteConfig.stockRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockRequestsCollectionId,
              queries: [
                Query.equal('status', 'pending'),
                Query.orderDesc('requestedAt'),
              ],
            );

            return response.documents
                .map((doc) => _stockRequestFromAppwrite(doc.data))
                .whereType<StockRequest>()
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting pending stock requests: $e');
      return Stream.value([]);
    }
  }

  /// Get stock requests by user ID
  Stream<List<StockRequest>> getStockRequestsByUser(String userId) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.stockRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockRequestsCollectionId,
              queries: [
                Query.equal('requesterId', userId),
                Query.orderDesc('requestedAt'),
              ],
            );

            return response.documents
                .map((doc) => _stockRequestFromAppwrite(doc.data))
                .whereType<StockRequest>()
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting user stock requests: $e');
      return Stream.value([]);
    }
  }

  /// Get all stock requests
  Stream<List<StockRequest>> getAllStockRequests() {
    try {
      return _realtime
          .subscribe([AppwriteConfig.stockRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockRequestsCollectionId,
              queries: [
                Query.orderDesc('requestedAt'),
              ],
            );

            return response.documents
                .map((doc) => _stockRequestFromAppwrite(doc.data))
                .whereType<StockRequest>()
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting all stock requests: $e');
      return Stream.value([]);
    }
  }

  /// Helper: Convert Appwrite document to StockRequest
  StockRequest? _stockRequestFromAppwrite(Map<String, dynamic> data) {
    try {
      return StockRequest(
        id: data['\$id'] ?? '',
        itemId: data['itemId'] ?? '',
        itemName: data['itemName'] ?? '',
        requesterId: data['requesterId'] ?? '',
        requesterName: data['requesterName'] ?? '',
        requestedQuantity: data['quantity'] ?? 0,
        notes: data['notes'],
        status: RequestStatus.values.firstWhere(
          (e) => e.name == (data['status'] ?? 'pending'),
          orElse: () => RequestStatus.pending,
        ),
        requestedAt: DateTime.tryParse(data['requestedAt'] ?? '') ?? DateTime.now(),
        approvedAt: data['processedAt'] != null
            ? DateTime.tryParse(data['processedAt'])
            : null,
        approvedBy: data['processedBy'],
        approvedByName: data['processedByName'],
        rejectionReason: data['rejectionReason'],
      );
    } catch (e) {
      _logger.warning('Error parsing stock request: $e');
      return null;
    }
  }

  /// Create stock request
  Future<String?> createStockRequest(StockRequest request) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockRequestsCollectionId,
        documentId: ID.unique(),
        data: {
          'itemId': request.itemId,
          'itemName': request.itemName,
          'requesterId': request.requesterId,
          'requesterName': request.requesterName,
          'quantity': request.requestedQuantity,
          'notes': request.notes,
          'status': request.status.name,
          'requestedAt': request.requestedAt.toIso8601String(),
          'processedAt': null,
          'processedBy': null,
          'processedByName': null,
          'rejectionReason': null,
        },
      );

      return doc.$id;
    } catch (e) {
      _logger.severe('Error creating stock request: $e');
      return null;
    }
  }

  /// Approve stock request
  Future<void> approveStockRequest(
    String requestId,
    String approvedBy,
    String approvedByName,
  ) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'approved',
          'processedAt': DateTime.now().toIso8601String(),
          'processedBy': approvedBy,
          'processedByName': approvedByName,
        },
      );
    } catch (e) {
      _logger.severe('Error approving stock request: $e');
      rethrow;
    }
  }

  /// Reject stock request
  Future<void> rejectStockRequest(
    String requestId,
    String rejectedBy,
    String rejectedByName,
    String reason,
  ) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'rejected',
          'processedAt': DateTime.now().toIso8601String(),
          'processedBy': rejectedBy,
          'processedByName': rejectedByName,
          'rejectionReason': reason,
        },
      );
    } catch (e) {
      _logger.severe('Error rejecting stock request: $e');
      rethrow;
    }
  }

  /// Fulfill stock request (mark as completed)
  Future<void> fulfillStockRequest(String requestId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'fulfilled',
        },
      );
    } catch (e) {
      _logger.severe('Error fulfilling stock request: $e');
      rethrow;
    }
  }

  // ==================== NOTIFICATION QUERIES ====================

  /// Get notifications for a user
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.notificationsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.notificationsCollectionId,
              queries: [
                Query.equal('userId', userId),
                Query.orderDesc('\$createdAt'),
                Query.limit(50),
              ],
            );

            return response.documents
                .map((doc) => _notificationFromAppwrite(doc.data))
                .whereType<AppNotification>()
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting user notifications: $e');
      return Stream.value([]);
    }
  }

  /// Get unread notification count
  Stream<int> getUnreadNotificationCount(String userId) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.notificationsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.notificationsCollectionId,
              queries: [
                Query.equal('userId', userId),
                Query.equal('isRead', false),
              ],
            );

            return response.documents.length;
          });
    } catch (e) {
      _logger.severe('Error getting unread count: $e');
      return Stream.value(0);
    }
  }

  /// Helper: Convert Appwrite document to AppNotification
  AppNotification? _notificationFromAppwrite(Map<String, dynamic> data) {
    try {
      return AppNotification(
        id: data['\$id'] ?? '',
        userId: data['userId'] ?? '',
        type: NotificationType.values.firstWhere(
          (e) => e.name == (data['type'] ?? 'general'),
          orElse: () => NotificationType.general,
        ),
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        data: null, // Appwrite simplified schema doesn't have data field
        read: data['isRead'] ?? false,
        createdAt: DateTime.tryParse(data['\$createdAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      _logger.warning('Error parsing notification: $e');
      return null;
    }
  }

  /// Create notification
  Future<String?> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'type': type.name,
          'title': title,
          'message': message,
          'isRead': false,
        },
      );

      return doc.$id;
    } catch (e) {
      _logger.severe('Error creating notification: $e');
      return null;
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: notificationId,
        data: {
          'isRead': true,
        },
      );
    } catch (e) {
      _logger.severe('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isRead', false),
        ],
      );

      for (final doc in response.documents) {
        await _databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.notificationsCollectionId,
          documentId: doc.$id,
          data: {'isRead': true},
        );
      }
    } catch (e) {
      _logger.severe('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: notificationId,
      );
    } catch (e) {
      _logger.severe('Error deleting notification: $e');
      rethrow;
    }
  }

  // ==================== SERVICE REQUEST QUERIES ====================

  /// Get all service requests (admin)
  Stream<List<service_request.Request>> getAllServiceRequests() {
    try {
      return _realtime
          .subscribe([AppwriteConfig.serviceRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.serviceRequestsCollectionId,
              queries: [
                Query.isNull('deletedAt'),
                Query.orderDesc('\$createdAt'),
              ],
            );

            return response.documents
                .map((doc) => service_request.Request.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting all service requests: $e');
      return Stream.value([]);
    }
  }

  /// Get service requests by user (requester)
  Stream<List<service_request.Request>> getServiceRequestsByUser(String userId) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.serviceRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.serviceRequestsCollectionId,
              queries: [
                Query.equal('requesterId', userId),
                Query.isNull('deletedAt'),
                Query.orderDesc('\$createdAt'),
              ],
            );

            return response.documents
                .map((doc) => service_request.Request.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting user service requests: $e');
      return Stream.value([]);
    }
  }

  /// Get pending service requests (for cleaner self-assign)
  Stream<List<service_request.Request>> getPendingServiceRequests() {
    try {
      return _realtime
          .subscribe([AppwriteConfig.serviceRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.serviceRequestsCollectionId,
              queries: [
                Query.equal('status', 'pending'),
                Query.isNull('deletedAt'),
                Query.orderDesc('\$createdAt'),
              ],
            );

            return response.documents
                .map((doc) => service_request.Request.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting pending service requests: $e');
      return Stream.value([]);
    }
  }

  /// Get service requests assigned to cleaner
  Stream<List<service_request.Request>> getServiceRequestsByCleaner(String cleanerId) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.serviceRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.serviceRequestsCollectionId,
              queries: [
                Query.equal('cleanerId', cleanerId),
                Query.isNull('deletedAt'),
                Query.orderDesc('\$createdAt'),
              ],
            );

            return response.documents
                .map((doc) => service_request.Request.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting cleaner service requests: $e');
      return Stream.value([]);
    }
  }

  /// Get service requests by status
  Stream<List<service_request.Request>> getServiceRequestsByStatus(
    service_request.RequestStatus status,
  ) {
    try {
      return _realtime
          .subscribe([AppwriteConfig.serviceRequestsChannel])
          .stream
          .asyncMap((_) async {
            final response = await _databases.listDocuments(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.serviceRequestsCollectionId,
              queries: [
                Query.equal('status', status.toFirestore()),
                Query.isNull('deletedAt'),
                Query.orderDesc('\$createdAt'),
              ],
            );

            return response.documents
                .map((doc) => service_request.Request.fromAppwrite(doc.data))
                .toList();
          });
    } catch (e) {
      _logger.severe('Error getting service requests by status: $e');
      return Stream.value([]);
    }
  }

  /// Watch single service request by ID
  Stream<service_request.Request?> watchServiceRequestById(String requestId) {
    try {
      final channel = AppwriteConfig.getDocumentChannel(
        AppwriteConfig.serviceRequestsCollectionId,
        requestId,
      );

      return _realtime.subscribe([channel]).stream.asyncMap((_) async {
        try {
          final doc = await _databases.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.serviceRequestsCollectionId,
            documentId: requestId,
          );
          return service_request.Request.fromAppwrite(doc.data);
        } catch (e) {
          return null;
        }
      });
    } catch (e) {
      _logger.severe('Error watching service request: $e');
      return Stream.value(null);
    }
  }

  /// Get service request by ID
  Future<service_request.Request?> getServiceRequestById(String requestId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.serviceRequestsCollectionId,
        documentId: requestId,
      );
      return service_request.Request.fromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting service request: $e');
      return null;
    }
  }

  /// Create service request
  Future<String?> createServiceRequest(service_request.Request request) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.serviceRequestsCollectionId,
        documentId: ID.unique(),
        data: request.toAppwrite(),
      );

      _logger.info('Service request created: ${doc.$id}');
      return doc.$id;
    } catch (e) {
      _logger.severe('Error creating service request: $e');
      return null;
    }
  }

  /// Update service request
  Future<void> updateServiceRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.serviceRequestsCollectionId,
        documentId: requestId,
        data: updates,
      );
    } catch (e) {
      _logger.severe('Error updating service request: $e');
      rethrow;
    }
  }

  /// Self-assign service request (cleaner picks from pending)
  Future<void> selfAssignServiceRequest(
    String requestId,
    String cleanerId,
    String cleanerName,
  ) async {
    try {
      await updateServiceRequest(requestId, {
        'cleanerId': cleanerId,
        'cleanerName': cleanerName,
        'status': 'assigned',
        'assignedAt': DateTime.now().toIso8601String(),
      });
      _logger.info('Service request $requestId self-assigned to $cleanerName');
    } catch (e) {
      _logger.severe('Error self-assigning service request: $e');
      rethrow;
    }
  }

  /// Start service request
  Future<void> startServiceRequest(String requestId) async {
    try {
      await updateServiceRequest(requestId, {
        'status': 'in_progress',
        'startedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.severe('Error starting service request: $e');
      rethrow;
    }
  }

  /// Complete service request
  Future<void> completeServiceRequest(
    String requestId, {
    String? completionImageUrl,
    String? completionNotes,
  }) async {
    try {
      await updateServiceRequest(requestId, {
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
        'completionImageUrl': completionImageUrl,
        'completionNotes': completionNotes,
      });
    } catch (e) {
      _logger.severe('Error completing service request: $e');
      rethrow;
    }
  }

  /// Cancel service request
  Future<void> cancelServiceRequest(String requestId) async {
    try {
      await updateServiceRequest(requestId, {
        'status': 'cancelled',
      });
    } catch (e) {
      _logger.severe('Error cancelling service request: $e');
      rethrow;
    }
  }

  /// Soft delete service request
  Future<void> softDeleteServiceRequest(
    String requestId,
    String deletedByUserId,
  ) async {
    try {
      await updateServiceRequest(requestId, {
        'deletedAt': DateTime.now().toIso8601String(),
        'deletedBy': deletedByUserId,
      });
    } catch (e) {
      _logger.severe('Error soft deleting service request: $e');
      rethrow;
    }
  }

  /// Get active service request count for user (for 3 active limit)
  Future<int> getActiveServiceRequestCount(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.serviceRequestsCollectionId,
        queries: [
          Query.equal('requesterId', userId),
          Query.isNull('deletedAt'),
          Query.notEqual('status', 'completed'),
          Query.notEqual('status', 'cancelled'),
        ],
      );

      return response.documents.length;
    } catch (e) {
      _logger.severe('Error getting active request count: $e');
      return 0;
    }
  }

  /// Check if user can create new service request (max 3 active)
  Future<bool> canCreateServiceRequest(String userId) async {
    final count = await getActiveServiceRequestCount(userId);
    return count < 3;
  }
}
