// lib/services/inventory_service.dart
// Inventory management service - Using Appwrite

import '../models/inventory_item.dart';
import '../models/stock_history.dart';
import '../services/appwrite_database_service.dart';

class InventoryService {
  final AppwriteDatabaseService _dbService = AppwriteDatabaseService();

  // ==================== INVENTORY ITEMS ====================

  /// Stream all inventory items
  Stream<List<InventoryItem>> streamAllItems() {
    return _dbService.getAllInventoryItems();
  }

  /// Stream low stock items
  Stream<List<InventoryItem>> streamLowStockItems() {
    return _dbService.getLowStockItems();
  }

  /// Add new item
  Future<void> addItem(InventoryItem item) async {
    await _dbService.createInventoryItem(item);
  }

  /// Update item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = DateTime.now().toIso8601String();
    await _dbService.updateInventoryItem(itemId, updates);
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    await _dbService.softDeleteInventoryItem(itemId);
  }

  /// Update stock
  Future<void> updateStock(String itemId, int newStock) async {
    await _dbService.updateInventoryStock(itemId, newStock);
  }

  // ==================== STOCK REQUESTS ====================

  /// Stream all pending requests
  Stream<List<StockRequest>> streamPendingRequests() {
    return _dbService.getPendingStockRequests();
  }

  /// Stream user's requests
  Stream<List<StockRequest>> streamUserRequests(String userId) {
    return _dbService.getStockRequestsByUser(userId);
  }

  /// Create request
  Future<void> createRequest(StockRequest request) async {
    await _dbService.createStockRequest(request);
  }

  /// Approve request
  Future<void> approveRequest(String requestId, String approvedBy, String approvedByName) async {
    await _dbService.approveStockRequest(requestId, approvedBy, approvedByName);
  }

  /// Reject request
  Future<void> rejectRequest(String requestId, String reason) async {
    await _dbService.rejectStockRequest(requestId, 'system', 'System', reason);
  }

  // ==================== ENHANCED STOCK OPERATIONS WITH HISTORY ====================

  /// Get single item by ID
  Future<InventoryItem> getItemById(String itemId) async {
    final item = await _dbService.getInventoryItemById(itemId);
    if (item == null) {
      throw Exception('Item not found');
    }
    return item;
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

    // Log to history (TODO: implement stock history in Appwrite)
    // For now, just update the stock
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

    // Log to history (TODO: implement stock history in Appwrite)
    // For now, just update the stock
  }

  /// Fulfill approved request and reduce stock
  Future<void> fulfillRequest({
    required String requestId,
    required String fulfilledBy,
    required String fulfilledByName,
  }) async {
    // Get all stock requests and find the one we need
    final requests = await _dbService.getAllStockRequests().first;
    final request = requests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => throw Exception('Request not found'),
    );

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
    await _dbService.fulfillStockRequest(requestId);
  }

  // ==================== STOCK HISTORY ====================
  // Note: Stock history functionality requires additional Appwrite collection setup
  // These methods return empty streams for now

  /// Stream stock history for an item
  Stream<List<StockHistory>> streamItemHistory(String itemId) {
    // TODO: Implement stock history collection in Appwrite
    return Stream.value([]);
  }

  /// Stream all stock history (for admin audit)
  Stream<List<StockHistory>> streamAllHistory({int limit = 50}) {
    // TODO: Implement stock history collection in Appwrite
    return Stream.value([]);
  }

  /// Get history by date range
  Future<List<StockHistory>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? itemId,
  }) async {
    // TODO: Implement stock history collection in Appwrite
    return [];
  }

  // ==================== BATCH OPERATIONS ====================

  /// Bulk delete multiple items
  Future<void> bulkDelete(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    // Delete items one by one (Appwrite doesn't have batch operations like Firestore)
    for (final itemId in itemIds) {
      await _dbService.softDeleteInventoryItem(itemId);
    }
  }

  /// Bulk update category for multiple items
  Future<void> bulkUpdateCategory(List<String> itemIds, String category) async {
    if (itemIds.isEmpty) return;

    final now = DateTime.now().toIso8601String();

    // Update category for each item
    for (final itemId in itemIds) {
      await _dbService.updateInventoryItem(itemId, {
        'category': category,
        'updatedAt': now,
      });
    }
  }

  /// Bulk update stock for multiple items
  Future<void> bulkUpdateStock(
    Map<String, int> itemStockMap,
    String performedBy,
    String performedByName,
  ) async {
    if (itemStockMap.isEmpty) return;

    for (final entry in itemStockMap.entries) {
      final itemId = entry.key;
      final newStock = entry.value;

      // Update item stock
      await _dbService.updateInventoryStock(itemId, newStock);

      // Log history (TODO: implement stock history in Appwrite)
    }
  }
}
