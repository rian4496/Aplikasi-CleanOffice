import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/appwrite_config.dart';
import '../core/services/appwrite_client.dart';
import '../core/logging/app_logger.dart';

/// Service responsible for handling batch operations on reports.
/// Follows SRP by focusing solely on bulk actions.
class BatchService {
  final Databases _databases;
  final _logger = AppLogger('BatchService');

  BatchService(this._databases);

  /// Verifies multiple reports at once.
  /// Note: Appwrite does not support atomic batch writes natively in Client SDK yet.
  /// We execute these in parallel.
  Future<void> bulkVerifyReports(List<String> reportIds, String adminId) async {
    _logger.info('Batch verifying ${reportIds.length} reports');
    
    final futures = reportIds.map((id) => _databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reportsCollectionId,
      documentId: id,
      data: {
        'status': 'verified',
        'verifiedAt': DateTime.now().toIso8601String(),
        'verifiedBy': adminId,
      },
    ));

    try {
      await Future.wait(futures);
      _logger.info('Batch verification successful');
    } catch (e) {
      _logger.error('Batch verification failed', e);
      rethrow;
    }
  }

  /// Deletes multiple reports at once.
  Future<void> bulkDeleteReports(List<String> reportIds) async {
    _logger.info('Batch deleting ${reportIds.length} reports');
    
    final futures = reportIds.map((id) => _databases.deleteDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reportsCollectionId,
      documentId: id,
    ));

    try {
      await Future.wait(futures);
      _logger.info('Batch deletion successful');
    } catch (e) {
      _logger.error('Batch deletion failed', e);
      rethrow;
    }
  }
  
  /// Assigns multiple reports to a cleaner.
  Future<void> bulkAssignReports(List<String> reportIds, String cleanerId, String cleanerName) async {
    _logger.info('Batch assigning ${reportIds.length} reports to $cleanerName');
    
    final futures = reportIds.map((id) => _databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reportsCollectionId,
      documentId: id,
      data: {
        'cleanerId': cleanerId,
        'cleanerName': cleanerName,
        'status': 'pending', 
        'assignedAt': DateTime.now().toIso8601String(),
      },
    ));

    try {
      await Future.wait(futures);
      _logger.info('Batch assignment successful');
    } catch (e) {
      _logger.error('Batch assignment failed', e);
      rethrow;
    }
  }
}

/// Provider for BatchService.
/// Follows DIP by injecting dependencies.
final batchServiceProvider = Provider<BatchService>((ref) {
  final client = AppwriteClient().client;
  final databases = Databases(client);
  return BatchService(databases);
});
