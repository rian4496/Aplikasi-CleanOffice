// lib/services/batch_service.dart
// Service for batch operations on Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';

class BatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Maximum items per batch (Firestore limit is 500)
  static const int maxBatchSize = 500;
  
  /// Bulk verify reports
  Future<void> bulkVerify(List<String> reportIds, {String? verifiedBy}) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      batch.update(docRef, {
        'status': ReportStatus.verified.toString(),
        'verifiedAt': FieldValue.serverTimestamp(),
        if (verifiedBy != null) 'verifiedBy': verifiedBy,
      });
    });
  }
  
  /// Bulk assign to cleaner
  Future<void> bulkAssign(
    List<String> reportIds,
    String cleanerId,
    String cleanerName,
  ) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      batch.update(docRef, {
        'assignedToId': cleanerId,
        'cleanerName': cleanerName,
        'status': ReportStatus.assigned.toString(),
        'assignedAt': FieldValue.serverTimestamp(),
      });
    });
  }
  
  /// Bulk change status
  Future<void> bulkChangeStatus(
    List<String> reportIds,
    ReportStatus status,
  ) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      final updateData = <String, dynamic>{
        'status': status.toString(),
      };
      
      // Add timestamp based on status
      switch (status) {
        case ReportStatus.completed:
          updateData['completedAt'] = FieldValue.serverTimestamp();
          break;
        case ReportStatus.verified:
          updateData['verifiedAt'] = FieldValue.serverTimestamp();
          break;
        case ReportStatus.inProgress:
          updateData['startedAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }
      
      batch.update(docRef, updateData);
    });
  }
  
  /// Bulk delete reports
  Future<void> bulkDelete(List<String> reportIds) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      batch.delete(docRef);
    });
  }
  
  /// Bulk archive reports (soft delete)
  Future<void> bulkArchive(List<String> reportIds) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      batch.update(docRef, {
        'archived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });
    });
  }
  
  /// Bulk mark as urgent
  Future<void> bulkMarkUrgent(List<String> reportIds, bool isUrgent) async {
    await _executeBatch(reportIds, (batch, id) {
      final docRef = _firestore.collection('reports').doc(id);
      batch.update(docRef, {
        'isUrgent': isUrgent,
      });
    });
  }
  
  /// Execute batch operations with automatic chunking
  Future<void> _executeBatch(
    List<String> ids,
    void Function(WriteBatch batch, String id) operation,
  ) async {
    // Split into chunks if exceeds max batch size
    final chunks = _chunkList(ids, maxBatchSize);
    
    for (final chunk in chunks) {
      final batch = _firestore.batch();
      
      for (final id in chunk) {
        operation(batch, id);
      }
      
      await batch.commit();
    }
  }
  
  /// Split list into chunks
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
  
  /// Get estimated time for batch operation
  Duration estimateBatchTime(int itemCount) {
    // Rough estimate: ~100ms per item
    return Duration(milliseconds: itemCount * 100);
  }
}

// Provider
final batchServiceProvider = Provider<BatchService>((ref) {
  return BatchService();
});
