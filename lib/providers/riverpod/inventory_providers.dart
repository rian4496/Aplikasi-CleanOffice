// lib/providers/riverpod/inventory_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../models/inventory_item.dart';
import '../../services/supabase_database_service.dart';
import './supabase_service_providers.dart';
import './auth_providers.dart';

part 'inventory_providers.g.dart';

// ==================== INVENTORY ITEMS ====================

/// Stream all inventory items
@riverpod
Stream<List<InventoryItem>> allInventoryItems(Ref ref) {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getAllInventoryItems();
}

/// Stream low stock items
@riverpod
Stream<List<InventoryItem>> lowStockItems(Ref ref) {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getLowStockItems();
}

/// Get low stock count
@riverpod
Stream<int> lowStockCount(Ref ref) {
  return ref.watch(lowStockItemsProvider).when(
    data: (items) => Stream.value(items.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
}

// ==================== STOCK REQUESTS ====================

/// Stream pending stock requests
@riverpod
Stream<List<StockRequest>> pendingStockRequests(Ref ref) {
  final service = ref.watch(supabaseDatabaseServiceProvider);
  return service.getPendingStockRequests();
}

/// Stream user's stock requests
@riverpod
Stream<List<StockRequest>> myStockRequests(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(supabaseDatabaseServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return service.getStockRequestsByUser(user.id);
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
    error: (_, __) => Stream.value(0),
  );
}

// ==================== LEGACY COMPATIBILITY ====================
// TODO: Remove after all screens are migrated

/// Legacy provider - redirects to supabaseDatabaseServiceProvider
@Deprecated('Use supabaseDatabaseServiceProvider instead')
@riverpod
SupabaseDatabaseService appwriteDatabaseService(Ref ref) {
  return ref.watch(supabaseDatabaseServiceProvider);
}
