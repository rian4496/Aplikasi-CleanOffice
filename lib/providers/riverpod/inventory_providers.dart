// lib/providers/riverpod/inventory_providers.dart
// Inventory providers with Riverpod code generation

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import './auth_providers.dart';

part 'inventory_providers.g.dart';

final _inventoryService = InventoryService();

// ==================== INVENTORY ITEMS ====================

/// Stream all inventory items
@riverpod
Stream<List<InventoryItem>> allInventoryItems(Ref ref) {
  return _inventoryService.streamAllItems();
}

/// Stream low stock items
@riverpod
Stream<List<InventoryItem>> lowStockItems(Ref ref) {
  return _inventoryService.streamLowStockItems();
}

/// Get low stock count
@riverpod
Stream<int> lowStockCount(Ref ref) {
  return ref.watch(lowStockItemsProvider).when(
    data: (items) => Stream.value(items.length),
    loading: () => Stream.value(0),
    error: (_, _) => Stream.value(0),
  );
}

// ==================== STOCK REQUESTS ====================

/// Stream pending stock requests
@riverpod
Stream<List<StockRequest>> pendingStockRequests(Ref ref) {
  return _inventoryService.streamPendingRequests();
}

/// Stream user's stock requests
@riverpod
Stream<List<StockRequest>> myStockRequests(Ref ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return _inventoryService.streamUserRequests(user.uid);
    },
    loading: () => Stream.value([]),
    error: (error, stack) => Stream.value([]),
  );
}

/// Get pending requests count
@riverpod
Stream<int> pendingRequestsCount(Ref ref) {
  return ref.watch(pendingStockRequestsProvider).when(
    data: (requests) => Stream.value(requests.length),
    loading: () => Stream.value(0),
    error: (_, _) => Stream.value(0),
  );
}
