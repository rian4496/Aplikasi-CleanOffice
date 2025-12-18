// lib/services/inventory_service.dart
// Inventory management service - Using Supabase

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';
import '../models/stock_history.dart';
import '../models/stock_request.dart';
import '../models/stock_opname.dart';
import '../core/logging/app_logger.dart';

class InventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logger = AppLogger('InventoryService');

  // ==================== INVENTORY ITEMS ====================

  /// Get all inventory items as Future
  Future<List<InventoryItem>> getAllItems() async {
    try {
      // Fetch all items, then filter client-side to ensure deleted items are excluded
      final response = await _supabase
          .from('inventory_items')
          .select()
          .order('name');
      
      // Client-side filter to DEFINITELY exclude deleted items
      final items = (response as List)
          .map((data) => InventoryItem.fromSupabase(data))
          .where((item) {
            // Check raw data for deleted_at
            final rawData = response.firstWhere((d) => d['id'] == item.id, orElse: () => {});
            final deletedAt = rawData['deleted_at'];
            final isActive = rawData['is_active'] ?? true;
            
            // Exclude if deleted_at is set OR is_active is false
            return deletedAt == null && isActive != false;
          })
          .toList();
      
      _logger.info('Loaded ${items.length} active inventory items (filtered from ${response.length} total)');
      return items;
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
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      _logger.info('Added inventory item: ${item.name}');
    } catch (e) {
      _logger.error('Failed to add item', e);
      rethrow;
    }
  }
  /// Update item with history logging for stock changes
  Future<void> updateItem(
    String itemId, 
    Map<String, dynamic> updates, {
    String? performedBy,
    String? performedByName,
  }) async {
    try {
      // 1. Try to log stock movement (non-blocking for stock update)
      // Support BOTH camelCase (from InventoryAddEditScreen) and snake_case (from InventoryFormDialog)
      final hasStockUpdate = updates.containsKey('currentStock') || updates.containsKey('current_stock');
      
      if (hasStockUpdate) {
        final newStock = (updates['currentStock'] ?? updates['current_stock']) as int;
        
        try {
          // Fetch current item to compare
          final currentItem = await getItemById(itemId);
          final diff = newStock - currentItem.currentStock;

          if (diff != 0) {
            // Try to record movement (won't block if it fails)
            await _recordMovementSafe(
              itemId: itemId,
              type: diff > 0 ? TransactionType.IN : TransactionType.OUT,
              quantity: diff.abs(),
              performedBy: performedBy ?? 'SYSTEM',
              performedByName: performedByName ?? 'System',
              notes: 'Manual edit adjustment',
            );
          }
        } catch (e) {
          // Log error but don't block the stock update
          _logger.error('Failed to record stock movement (non-fatal)', e);
        }
      }

      // 2. Convert ALL updates (including currentStock) to snake_case
      final snakeCaseUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        snakeCaseUpdates[_toSnakeCase(key)] = value;
      });
      snakeCaseUpdates['updated_at'] = DateTime.now().toIso8601String();
      
      // 3. Update the item in database (this is the source of truth for stock)
      await _supabase.from('inventory_items').update(snakeCaseUpdates).eq('id', itemId);
      _logger.info('Updated inventory item: $itemId');
    } catch (e) {
      _logger.error('Failed to update item', e);
      rethrow;
    }
  }
  
  /// Record movement without throwing (for optional logging)
  Future<void> _recordMovementSafe({
    required String itemId,
    required TransactionType type,
    required int quantity,
    required String performedBy,
    required String performedByName,
    String? referenceId,
    String? notes,
  }) async {
    try {
      // Only insert movement record, don't update stock (main update handles it)
      await _supabase.from('stock_movements').insert({
        'item_id': itemId,
        'type': type.name,
        'quantity': quantity,
        'reference_id': referenceId,
        'notes': notes,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'created_at': DateTime.now().toIso8601String(),
      });
      _logger.info('Recorded stock movement: ${type.name} $quantity for item $itemId');
    } catch (e) {
      _logger.error('Failed to record stock movement to history table', e);
      // Don't rethrow - this is a non-critical operation
    }
  }

  /// Delete item (soft delete) with history logging
  Future<void> deleteItem(
    String itemId, {
    String? performedBy,
    String? performedByName,
  }) async {
    try {
      print('🗑️ DELETE ATTEMPT - Item ID: $itemId');
      print('👤 Performed by: $performedByName ($performedBy)');
      
      // Get item first to log its stock
      final item = await getItemById(itemId);
      print('✅ Item found: ${item.name}, Stock: ${item.currentStock}');
      
      // 1. Record deletion movement ONLY if there's stock
      if (item.currentStock > 0) {
        try {
          await _supabase.from('stock_movements').insert({
            'item_id': itemId,
            'type': TransactionType.OUT.name,
            'quantity': item.currentStock,
            'reference_id': null,
            'notes': 'Item deleted (Soft Delete)',
            'performed_by': performedBy ?? 'SYSTEM',
            'performed_by_name': performedByName ?? 'System',
            'created_at': DateTime.now().toIso8601String(),
          });
          print('📝 Movement logged successfully');
        } catch (e) {
          print('⚠️ Movement logging failed (non-fatal): $e');
          _logger.error('Failed to log deletion movement (non-fatal)', e);
          // Continue with delete even if logging fails
        }
      }

      // 2. Soft delete the item
      print('🔄 Attempting database update...');
      final response = await _supabase.from('inventory_items').update({
        'deleted_at': DateTime.now().toIso8601String(),
        'current_stock': 0,
        'is_active': false,
      }).eq('id', itemId).select();
      
      print('📊 Response: $response');
      print('📊 Response length: ${(response as List).length}');
      
      // Verify the update actually happened
      if (response.isEmpty) {
        throw Exception('Failed to delete item: No rows were updated. Item ID: $itemId may not exist or RLS policy blocked the update.');
      }
      
      print('✅ DELETE SUCCESS - Item: $itemId');
      _logger.info('Soft deleted inventory item: $itemId');
    } catch (e) {
      print('❌ DELETE FAILED: $e');
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
          .order('created_at', ascending: false);
      
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
          .order('created_at', ascending: false);
      
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
      await _supabase.from('stock_requests').insert(request.toSupabase());
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

  // ==================== STOCK OPERATIONS (With History) ====================

  /// Record stock movement (The single source of truth for stock changes)
  Future<void> _recordMovement({
    required String itemId,
    required TransactionType type,
    required int quantity, // Absolute positive value usually
    required String performedBy,
    required String performedByName,
    String? referenceId,
    String? notes,
  }) async {
    try {
      // 1. Create movement record
      await _supabase.from('stock_movements').insert({
        'item_id': itemId,
        'type': type.name,
        'quantity': quantity,
        'reference_id': referenceId,
        'notes': notes,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Update actual stock manually (DB trigger disabled)
      // NOTE: There appears to be a DB trigger conflict. Using manual update only.
      // TODO: Disable or remove the database trigger to prevent double-updates
      
      final item = await getItemById(itemId);
      int newStock = item.currentStock;

      if (type == TransactionType.IN) {
        newStock += quantity;
      } else if (type == TransactionType.OUT) {
        newStock -= quantity;
      } else if (type == TransactionType.ADJUST) {
         // For ADJUST, quantity is the signed delta
         newStock += quantity; 
      }

      await _supabase.from('inventory_items').update({
        'current_stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);

      _logger.info('Recorded movement: ${type.name} $quantity for item $itemId. New Stock: $newStock');
    } catch (e) {
      _logger.error('Failed to record stock movement', e);
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
    await _recordMovement(
      itemId: itemId,
      type: TransactionType.IN,
      quantity: quantity,
      performedBy: performedBy,
      performedByName: performedByName,
      referenceId: referenceId,
      notes: notes,
    );
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
    
    await _recordMovement(
      itemId: itemId,
      type: TransactionType.OUT,
      quantity: quantity,
      performedBy: performedBy,
      performedByName: performedByName,
      referenceId: referenceId,
      notes: notes,
    );
  }

  // ==================== STOCK HISTORY ====================
  
  /// Stream item history from stock_movements table
  Stream<List<StockHistory>> streamItemHistory(String itemId) {
    return Stream.fromFuture(_getItemHistory(itemId));
  }
  
  /// Get item history as Future
  Future<List<StockHistory>> _getItemHistory(String itemId) async {
    try {
      // Fetch movements for this item
      final response = await _supabase
          .from('stock_movements')
          .select()
          .eq('item_id', itemId)
          .order('created_at', ascending: false);
      
      final movements = (response as List)
          .map((data) => StockMovement.fromSupabase(data))
          .toList();
      
      if (movements.isEmpty) {
        return [];
      }
      
      // Get current item to calculate backwards
      final item = await getItemById(itemId);
      int runningStock = item.currentStock;
      
      // Convert movements to history (reverse order to calculate from newest to oldest)
      final historyList = <StockHistory>[];
      
      for (int i = 0; i < movements.length; i++) {
        final movement = movements[i];
        final newStock = runningStock;
        int previousStock;
        
        // Calculate previous stock based on movement type
        if (movement.type == TransactionType.IN) {
          previousStock = runningStock - movement.quantity;
        } else if (movement.type == TransactionType.OUT) {
          previousStock = runningStock + movement.quantity;
        } else { // ADJUST
          previousStock = runningStock - movement.quantity;
        }
        
        // Map TransactionType to StockAction
        StockAction action;
        if (movement.type == TransactionType.IN) {
          action = StockAction.add;
        } else if (movement.type == TransactionType.OUT) {
          action = movement.referenceId != null ? StockAction.fulfillRequest : StockAction.reduce;
        } else {
          action = StockAction.adjustment;
        }
        
        historyList.add(StockHistory(
          id: movement.id,
          itemId: movement.itemId,
          action: action,
          quantity: movement.quantity,
          previousStock: previousStock,
          newStock: newStock,
          notes: movement.notes,
          performedByName: movement.performedByName ?? 'System',
          timestamp: movement.createdAt,
        ));
        
        // Update running stock for next iteration (going backwards in time)
        runningStock = previousStock;
      }
      
      return historyList;
    } catch (e) {
      _logger.error('Failed to get item history', e);
      return [];
    }
  }
  
  /// Stream all history with limit
  Stream<List<StockHistory>> streamAllHistory({int limit = 50}) {
    return Stream.fromFuture(_getAllHistory(limit: limit));
  }
  
  /// Get all history as Future
  Future<List<StockHistory>> _getAllHistory({int limit = 50}) async {
    try {
      // This is complex because we need to calculate previous/new stock for each item
      // For now, return empty or implement a simplified version
      final response = await _supabase
          .from('stock_movements')
          .select('*, inventory_items(name, current_stock)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      final movements = (response as List)
          .map((data) => StockMovement.fromSupabase(data))
          .toList();
      
      // Simple conversion without calculating exact previous/new stock
      return movements.map((m) {
        StockAction action;
        if (m.type == TransactionType.IN) {
          action = StockAction.add;
        } else if (m.type == TransactionType.OUT) {
          action = m.referenceId != null ? StockAction.fulfillRequest : StockAction.reduce;
        } else {
          action = StockAction.adjustment;
        }
        
        return StockHistory(
          id: m.id,
          itemId: m.itemId,
          action: action,
          quantity: m.quantity,
          previousStock: 0, // Placeholder - would need complex calculation
          newStock: 0, // Placeholder
          notes: m.notes,
          performedByName: m.performedByName ?? 'System',
          timestamp: m.createdAt,
        );
      }).toList();
    } catch (e) {
      _logger.error('Failed to get all history', e);
      return [];
    }
  }
  
  /// Get history by date range
  Future<List<StockHistory>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? itemId,
  }) async {
    try {
      // Build query with all filters applied upfront
      dynamic response;
      
      if (itemId != null) {
        response = await _supabase
            .from('stock_movements')
            .select()
            .eq('item_id', itemId)
            .gte('created_at', startDate.toIso8601String())
            .lte('created_at', endDate.toIso8601String())
            .order('created_at', ascending: false);
      } else {
        response = await _supabase
            .from('stock_movements')
            .select()
            .gte('created_at', startDate.toIso8601String())
            .lte('created_at', endDate.toIso8601String())
            .order('created_at', ascending: false);
      }
      
      final movements = (response as List)
          .map((data) => StockMovement.fromSupabase(data))
          .toList();
      
      // Simple conversion
      return movements.map((m) {
        StockAction action;
        if (m.type == TransactionType.IN) {
          action = StockAction.add;
        } else if (m.type == TransactionType.OUT) {
          action = m.referenceId != null ? StockAction.fulfillRequest : StockAction.reduce;
        } else {
          action = StockAction.adjustment;
        }
        
        return StockHistory(
          id: m.id,
          itemId: m.itemId,
          action: action,
          quantity: m.quantity,
          previousStock: 0,
          newStock: 0,
          notes: m.notes,
          performedByName: m.performedByName ?? 'System',
          timestamp: m.createdAt,
        );
      }).toList();
    } catch (e) {
      _logger.error('Failed to get history by date range', e);
      return [];
    }
  }

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

  // ==================== STOCK OPNAME (Audit) ====================

  /// Get list of opnames
  Future<List<StockOpname>> getOpnames() async {
    try {
      final response = await _supabase
          .from('stock_opnames')
          .select()
          .order('started_at', ascending: false);
      
      return (response as List)
          .map((data) => StockOpname.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get opnames', e);
      return [];
    }
  }

  /// Create a new Opname session
  Future<String> createOpname({
    required String notes,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      final now = DateTime.now();
      // Generate simple opname number: OPN-YYYYMMDD-HHMM
      final opnameNumber = 'OPN-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('stock_opnames')
          .insert({
            'opname_number': opnameNumber,
            'status': 'OPEN',
            'notes': notes,
            'performed_by': performedBy,
            'performed_by_name': performedByName,
            'started_at': now.toIso8601String(),
          })
          .select()
          .single();
      
      final opnameId = response['id'] as String;

      // Auto-populate items snapshot
      // In a real app with 10k+ items, we might not want to do this synchronously or for ALL items.
      // But for < 500 items, it's fine to snapshot all current stock.
      final allItems = await getAllItems();
      
      for (final item in allItems) {
        await _supabase.from('stock_opname_items').insert({
          'opname_id': opnameId,
          'item_id': item.id,
          'system_stock': item.currentStock,
          'actual_stock': null, // To be filled
        });
      }

      _logger.info('Created Opname session: $opnameNumber');
      return opnameId;
    } catch (e) {
      _logger.error('Failed to create opname', e);
      rethrow;
    }
  }

  /// Get items for an opname session
  Future<List<StockOpnameItem>> getOpnameItems(String opnameId) async {
    try {
      final response = await _supabase
          .from('stock_opname_items')
          .select('*, inventory_items(name)') // Join to get name
          .eq('opname_id', opnameId)
          .order('created_at');
      
      return (response as List)
          .map((data) => StockOpnameItem.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get opname items', e);
      return [];
    }
  }

  /// Update actual stock count for an item in opname
  Future<void> updateOpnameItem({
    required String opnameItemId,
    required int actualStock,
    String? notes,
  }) async {
    try {
      await _supabase.from('stock_opname_items').update({
        'actual_stock': actualStock,
        'notes': notes,
      }).eq('id', opnameItemId);
    } catch (e) {
      _logger.error('Failed to update opname item', e);
      rethrow;
    }
  }

  /// Complete Opname (Apply adjustments)
  Future<void> completeOpname(String opnameId) async {
    try {
      // 1. Get all items in this opname
      final opnameItems = await getOpnameItems(opnameId);
      
      // 2. Iterate and check for discrepancies
      for (final item in opnameItems) {
        // Only process if actual stock was input and different from system
        if (item.actualStock != null && item.actualStock != item.systemStock) {
          final diff = item.actualStock! - item.systemStock;
          
          // Create movement record for adjustment
          await _recordMovement(
            itemId: item.itemId,
            type: TransactionType.ADJUST,
            quantity: diff, // + or -
            performedBy: 'SYSTEM', // Or get trigger user if possible, but fine for now
            performedByName: 'Opname System',
            referenceId: opnameId,
            notes: 'Stock Opname Adjustment from ${item.systemStock} to ${item.actualStock}',
          );
        }
      }

      // 3. Close the opname session
      await _supabase.from('stock_opnames').update({
        'status': 'COMPLETED',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', opnameId);

      _logger.info('Completed Opname: $opnameId');
    } catch (e) {
      _logger.error('Failed to complete opname', e);
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

