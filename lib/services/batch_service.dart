import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';

/// Service responsible for handling batch operations on reports.
/// Uses Supabase for database operations.
class BatchService {
  final SupabaseClient _supabase;
  final _logger = AppLogger('BatchService');

  BatchService(this._supabase);

  /// Verifies multiple reports at once.
  Future<void> bulkVerifyReports(List<String> reportIds, String adminId) async {
    _logger.info('Batch verifying ${reportIds.length} reports');
    
    try {
      // Supabase supports batch updates via .in_() filter
      await _supabase
          .from('reports')
          .update({
            'status': 'verified',
            'verified_at': DateTime.now().toIso8601String(),
            'verified_by': adminId,
          })
          .inFilter('id', reportIds);
      
      _logger.info('Batch verification successful');
    } catch (e) {
      _logger.error('Batch verification failed', e);
      rethrow;
    }
  }

  /// Deletes multiple reports at once (soft delete).
  Future<void> bulkDeleteReports(List<String> reportIds, String deletedBy) async {
    _logger.info('Batch deleting ${reportIds.length} reports');
    
    try {
      // Soft delete by setting deleted_at
      await _supabase
          .from('reports')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': deletedBy,
          })
          .inFilter('id', reportIds);
      
      _logger.info('Batch deletion successful');
    } catch (e) {
      _logger.error('Batch deletion failed', e);
      rethrow;
    }
  }
  
  /// Assigns multiple reports to a cleaner.
  Future<void> bulkAssignReports(
    List<String> reportIds, 
    String cleanerId, 
    String cleanerName,
  ) async {
    _logger.info('Batch assigning ${reportIds.length} reports to $cleanerName');
    
    try {
      await _supabase
          .from('reports')
          .update({
            'cleaner_id': cleanerId,
            'cleaner_name': cleanerName,
            'status': 'assigned',
            'assigned_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', reportIds);
      
      _logger.info('Batch assignment successful');
    } catch (e) {
      _logger.error('Batch assignment failed', e);
      rethrow;
    }
  }

  /// Bulk approve requests
  Future<void> bulkApproveRequests(List<String> requestIds, String approvedBy) async {
    _logger.info('Batch approving ${requestIds.length} requests');
    
    try {
      await _supabase
          .from('requests')
          .update({
            'status': 'approved',
            'approved_at': DateTime.now().toIso8601String(),
            'approved_by': approvedBy,
          })
          .inFilter('id', requestIds);
      
      _logger.info('Batch approval successful');
    } catch (e) {
      _logger.error('Batch approval failed', e);
      rethrow;
    }
  }
}

/// Provider for BatchService using Supabase.
final batchServiceProvider = Provider<BatchService>((ref) {
  final supabase = Supabase.instance.client;
  return BatchService(supabase);
});

