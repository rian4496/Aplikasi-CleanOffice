// lib/services/inventory_service.dart
// Inventory management service - Using Supabase

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';
import '../models/stock_history.dart';
import '../core/logging/app_logger.dart';

class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logger = AppLogger('InventoryService');

  // ==================== INVENTORY ITEMS ====================

  /// Get all inventory items as Future
  Future<List<InventoryItem>> getAllItems() async {
    try {
      final response = await _supabase
          .from('inventory_items')
          .select()
          .isFilter('deleted_at', null)
          .order('name');
      
      return (response as List)
          .map((data) => InventoryItem.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get all items', e);
      rethrow;
    }
  }

  /// Stream all inventory items (for compatibility)
  Stream<List<InventoryItem>> streamAllItems() {
    return Stream.fromFuture(getAllItems());
  }

  /// Get low stock items
  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final response = await _supabase
          .from('inventory_items')
          .select()
          .isFilter('deleted_at', null);
      
      final items = (response as List)
          .map((data) => InventoryItem.fromSupabase(data))
          .where((item) => item.currentStock <= item.minStock)
          .toList();
      
      return items;
    } catch (e) {
      _logger.error('Failed to get low stock items', e);
      rethrow;
    }
  }

  /// Stream low stock items (for compatibility)
  Stream<List<InventoryItem>> streamLowStockItems() {
    return Stream.fromFuture(getLowStockItems());
  }

  /// Add new item
  Future<void> addItem(InventoryItem item) async {
    try {
      await _supabase.from('inventory_items').insert({
        'name': item.name,
        'category': item.category,
        'current_stock': item.currentStock,
        'max_stock': item.maxStock,
        'min_stock': item.minStock,
        'unit': item.unit,
        'description': item.description,
        'image_url': item.imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      _logger.info('Added inventory item: ${item.name}');
    } catch (e) {
      _logger.error('Failed to add item', e);
      rethrow;
    }
  }

  /// Update item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      // Convert camelCase to snake_case
      final snakeCaseUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        snakeCaseUpdates[_toSnakeCase(key)] = value;
      });
      snakeCaseUpdates['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase.from('inventory_items').update(snakeCaseUpdates).eq('id', itemId);
      _logger.info('Updated inventory item: $itemId');
    } catch (e) {
      _logger.error('Failed to update item', e);
      rethrow;
    }
  }

  /// Delete item (soft delete)
  Future<void> deleteItem(String itemId) async {
    try {
      await _supabase.from('inventory_items').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);
      _logger.info('Soft deleted inventory item: $itemId');
    } catch (e) {
      _logger.error('Failed to delete item', e);
      rethrow;
    }
  }

  /// Update stock
  Future<void> updateStock(String itemId, int newStock) async {
    try {
      await _supabase.from('inventory_items').update({
        'current_stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);
      _logger.info('Updated stock for item $itemId to $newStock');
    } catch (e) {
      _logger.error('Failed to update stock', e);
      rethrow;
    }
  }

  // ==================== STOCK REQUESTS ====================

  /// Get pending requests
  Future<List<StockRequest>> getPendingRequests() async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select()
          .eq('status', 'pending')
          .order('requested_at', ascending: false);
      
      return (response as List)
          .map((data) => StockRequest.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get pending requests', e);
      return [];
    }
  }

  Stream<List<StockRequest>> streamPendingRequests() {
    return Stream.fromFuture(getPendingRequests());
  }

  /// Get user's requests
  Future<List<StockRequest>> getUserRequests(String userId) async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select()
          .eq('requester_id', userId)
          .order('requested_at', ascending: false);
      
      return (response as List)
          .map((data) => StockRequest.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get user requests', e);
      return [];
    }
  }

  Stream<List<StockRequest>> streamUserRequests(String userId) {
    return Stream.fromFuture(getUserRequests(userId));
  }

  /// Create request
  Future<void> createRequest(StockRequest request) async {
    try {
      await _supabase.from('stock_requests').insert({
        'item_id': request.itemId,
        'item_name': request.itemName,
        'requester_id': request.requesterId,
        'requester_name': request.requesterName,
        'requested_quantity': request.requestedQuantity,
        'notes': request.notes,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
      });
      _logger.info('Created stock request for ${request.itemName}');
    } catch (e) {
      _logger.error('Failed to create request', e);
      rethrow;
    }
  }

  /// Approve request
  Future<void> approveRequest(String requestId, String approvedBy, String approvedByName) async {
    try {
      await _supabase.from('stock_requests').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': approvedBy,
        'approved_by_name': approvedByName,
      }).eq('id', requestId);
      _logger.info('Approved request: $requestId');
    } catch (e) {
      _logger.error('Failed to approve request', e);
      rethrow;
    }
  }

  /// Reject request
  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      await _supabase.from('stock_requests').update({
        'status': 'rejected',
        'rejection_reason': reason,
      }).eq('id', requestId);
      _logger.info('Rejected request: $requestId');
    } catch (e) {
      _logger.error('Failed to reject request', e);
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  Future<InventoryItem> getItemById(String itemId) async {
    try {
      final response = await _supabase
          .from('inventory_items')
          .select()
          .eq('id', itemId)
          .single();
      
      return InventoryItem.fromSupabase(response);
    } catch (e) {
      _logger.error('Failed to get item by ID', e);
      rethrow;
    }
  }

  Future<void> addStock({
    required String itemId,
    required int quantity,
    required String performedBy,
    required String performedByName,
    String? notes,
    String? referenceId,
  }) async {
    final item = await getItemById(itemId);
    final newStock = item.currentStock + quantity;
    await updateStock(itemId, newStock);
    _logger.info('Added $quantity stock to item $itemId');
  }

  Future<void> reduceStock({
    required String itemId,
    required int quantity,
    required String performedBy,
    required String performedByName,
    String? notes,
    String? referenceId,
  }) async {
    final item = await getItemById(itemId);
    if (quantity > item.currentStock) {
      throw Exception('Stok tidak cukup. Diminta: $quantity, Tersedia: ${item.currentStock}');
    }
    final newStock = item.currentStock - quantity;
    await updateStock(itemId, newStock);
    _logger.info('Reduced $quantity stock from item $itemId');
  }

  // Stock history (placeholder)
  Stream<List<StockHistory>> streamItemHistory(String itemId) => Stream.value([]);
  Stream<List<StockHistory>> streamAllHistory({int limit = 50}) => Stream.value([]);
  Future<List<StockHistory>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? itemId,
  }) async => [];

  // Bulk operations
  Future<void> bulkDelete(List<String> itemIds) async {
    for (final itemId in itemIds) {
      await deleteItem(itemId);
    }
  }

  Future<void> bulkUpdateCategory(List<String> itemIds, String category) async {
    for (final itemId in itemIds) {
      await updateItem(itemId, {'category': category});
    }
  }

  Future<void> bulkUpdateStock(
    Map<String, int> itemStockMap,
    String performedBy,
    String performedByName,
  ) async {
    for (final entry in itemStockMap.entries) {
      await updateStock(entry.key, entry.value);
    }
  }

  /// Fulfill a stock request - update status to fulfilled and reduce stock
  Future<void> fulfillRequest({
    required String requestId,
    required String fulfilledBy,
    required String fulfilledByName,
  }) async {
    try {
      // Get the request first
      final response = await _supabase
          .from('stock_requests')
          .select()
          .eq('id', requestId)
          .single();
      
      final request = StockRequest.fromSupabase(response);
      
      // Reduce stock from inventory
      await reduceStock(
        itemId: request.itemId,
        quantity: request.requestedQuantity,
        performedBy: fulfilledBy,
        performedByName: fulfilledByName,
        referenceId: requestId,
        notes: 'Fulfilled request #$requestId',
      );
      
      // Update request status
      await _supabase
          .from('stock_requests')
          .update({
            'status': 'fulfilled',
            'fulfilled_at': DateTime.now().toIso8601String(),
            'fulfilled_by': fulfilledBy,
            'fulfilled_by_name': fulfilledByName,
          })
          .eq('id', requestId);
      
      _logger.info('Fulfilled request: $requestId');
    } catch (e) {
      _logger.error('Failed to fulfill request: $requestId', e);
      rethrow;
    }
  }

  String _toSnakeCase(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
