// lib/services/inventory_service.dart
// Inventory management service

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';
import '../models/stock_history.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INVENTORY ITEMS ====================

  /// Stream all inventory items
  Stream<List<InventoryItem>> streamAllItems() {
    return _firestore
        .collection('inventory')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream low stock items
  Stream<List<InventoryItem>> streamLowStockItems() {
    return streamAllItems().map((items) =>
        items.where((item) => item.status == StockStatus.lowStock || 
                             item.status == StockStatus.outOfStock).toList());
  }

  /// Add new item
  Future<void> addItem(InventoryItem item) async {
    await _firestore.collection('inventory').doc(item.id).set(item.toMap());
  }

  /// Update item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore.collection('inventory').doc(itemId).update(updates);
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('inventory').doc(itemId).delete();
  }

  /// Update stock
  Future<void> updateStock(String itemId, int newStock) async {
    await updateItem(itemId, {'currentStock': newStock});
  }

  // ==================== STOCK REQUESTS ====================

  /// Stream all pending requests
  Stream<List<StockRequest>> streamPendingRequests() {
    return _firestore
        .collection('stockRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream user's requests
  Stream<List<StockRequest>> streamUserRequests(String userId) {
    return _firestore
        .collection('stockRequests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockRequest.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Create request
  Future<void> createRequest(StockRequest request) async {
    await _firestore.collection('stockRequests').doc(request.id).set(request.toMap());
  }

  /// Approve request
  Future<void> approveRequest(String requestId, String approvedBy, String approvedByName) async {
    await _firestore.collection('stockRequests').doc(requestId).update({
      'status': 'approved',
      'approvedAt': DateTime.now().toIso8601String(),
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
    });
  }

  /// Reject request
  Future<void> rejectRequest(String requestId, String reason) async {
    await _firestore.collection('stockRequests').doc(requestId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
  }

  // ==================== ENHANCED STOCK OPERATIONS WITH HISTORY ====================

  /// Get single item by ID
  Future<InventoryItem> getItemById(String itemId) async {
    final doc = await _firestore.collection('inventory').doc(itemId).get();
    if (!doc.exists) {
      throw Exception('Item not found');
    }
    return InventoryItem.fromMap(doc.id, doc.data()!);
  }

  /// Add stock with history logging
  Future<void> addStock({
    required String itemId,
    required int quantity,
    required String performedBy,
    required String performedByName,
    String? notes,
    String? referenceId,
  }) async {
    // Get current item
    final item = await getItemById(itemId);
    final newStock = item.currentStock + quantity;

    // Update stock
    await updateStock(itemId, newStock);

    // Log to history
    await _logStockHistory(
      itemId: itemId,
      itemName: item.name,
      action: StockAction.add,
      quantity: quantity,
      previousStock: item.currentStock,
      newStock: newStock,
      performedBy: performedBy,
      performedByName: performedByName,
      notes: notes,
      referenceId: referenceId,
    );
  }

  /// Reduce stock with history logging
  Future<void> reduceStock({
    required String itemId,
    required int quantity,
    required String performedBy,
    required String performedByName,
    String? notes,
    String? referenceId,
  }) async {
    // Get current item
    final item = await getItemById(itemId);

    // Validate sufficient stock
    if (quantity > item.currentStock) {
      throw Exception(
        'Stok tidak cukup. Diminta: $quantity, Tersedia: ${item.currentStock}',
      );
    }

    final newStock = item.currentStock - quantity;

    // Update stock
    await updateStock(itemId, newStock);

    // Log to history
    await _logStockHistory(
      itemId: itemId,
      itemName: item.name,
      action: StockAction.reduce,
      quantity: quantity,
      previousStock: item.currentStock,
      newStock: newStock,
      performedBy: performedBy,
      performedByName: performedByName,
      notes: notes,
      referenceId: referenceId,
    );
  }

  /// Fulfill approved request and reduce stock
  Future<void> fulfillRequest({
    required String requestId,
    required String fulfilledBy,
    required String fulfilledByName,
  }) async {
    // Get request
    final requestDoc = await _firestore
        .collection('stockRequests')
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('Request not found');
    }

    final request = StockRequest.fromMap(requestDoc.id, requestDoc.data()!);

    // Validate request is approved
    if (request.status != RequestStatus.approved) {
      throw Exception('Request belum disetujui');
    }

    // Reduce stock with history logging
    await reduceStock(
      itemId: request.itemId,
      quantity: request.requestedQuantity,
      performedBy: fulfilledBy,
      performedByName: fulfilledByName,
      notes: 'Fulfilled request from ${request.requesterName}',
      referenceId: requestId,
    );

    // Update request status to fulfilled
    await _firestore.collection('stockRequests').doc(requestId).update({
      'status': 'fulfilled',
      'fulfilledAt': DateTime.now().toIso8601String(),
      'fulfilledBy': fulfilledBy,
      'fulfilledByName': fulfilledByName,
    });
  }

  // ==================== STOCK HISTORY ====================

  /// Log stock history entry
  Future<void> _logStockHistory({
    required String itemId,
    required String itemName,
    required StockAction action,
    required int quantity,
    required int previousStock,
    required int newStock,
    required String performedBy,
    required String performedByName,
    String? notes,
    String? referenceId,
  }) async {
    final now = DateTime.now();
    final historyEntry = StockHistory(
      id: 'hist_${now.millisecondsSinceEpoch}',
      itemId: itemId,
      itemName: itemName,
      action: action,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      performedBy: performedBy,
      performedByName: performedByName,
      notes: notes,
      timestamp: now,
      referenceId: referenceId,
    );

    await _firestore
        .collection('stockHistory')
        .doc(historyEntry.id)
        .set(historyEntry.toMap());
  }

  /// Stream stock history for an item
  Stream<List<StockHistory>> streamItemHistory(String itemId) {
    return _firestore
        .collection('stockHistory')
        .where('itemId', isEqualTo: itemId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockHistory.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Stream all stock history (for admin audit)
  Stream<List<StockHistory>> streamAllHistory({int limit = 50}) {
    return _firestore
        .collection('stockHistory')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockHistory.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get history by date range
  Future<List<StockHistory>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? itemId,
  }) async {
    var query = _firestore
        .collection('stockHistory')
        .where('timestamp',
            isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());

    if (itemId != null) {
      query = query.where('itemId', isEqualTo: itemId);
    }

    final snapshot = await query.orderBy('timestamp', descending: true).get();

    return snapshot.docs
        .map((doc) => StockHistory.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Bulk delete multiple items
  Future<void> bulkDelete(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    final batch = _firestore.batch();

    // Delete items
    for (final itemId in itemIds) {
      final itemRef = _firestore.collection('inventory').doc(itemId);
      batch.delete(itemRef);
    }

    // Commit batch
    await batch.commit();
  }

  /// Bulk update category for multiple items
  Future<void> bulkUpdateCategory(List<String> itemIds, String category) async {
    if (itemIds.isEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now().toIso8601String();

    // Update category for each item
    for (final itemId in itemIds) {
      final itemRef = _firestore.collection('inventory').doc(itemId);
      batch.update(itemRef, {
        'category': category,
        'updatedAt': now,
      });
    }

    // Commit batch
    await batch.commit();
  }

  /// Bulk update stock for multiple items
  Future<void> bulkUpdateStock(
    Map<String, int> itemStockMap,
    String performedBy,
    String performedByName,
  ) async {
    if (itemStockMap.isEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final entry in itemStockMap.entries) {
      final itemId = entry.key;
      final newStock = entry.value;

      // Update item stock
      final itemRef = _firestore.collection('inventory').doc(itemId);
      batch.update(itemRef, {
        'currentStock': newStock,
        'updatedAt': now.toIso8601String(),
      });

      // Log history (individual writes, not batched)
      final item = await getItemById(itemId);
      await _logStockHistory(
        itemId: itemId,
        itemName: item.name,
        action: StockAction.adjustment,
        quantity: (newStock - item.currentStock).abs(),
        previousStock: item.currentStock,
        newStock: newStock,
        performedBy: performedBy,
        performedByName: performedByName,
        notes: 'Bulk stock adjustment',
      );
    }

    // Commit batch
    await batch.commit();
  }
}
