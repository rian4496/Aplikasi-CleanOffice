// lib/providers/riverpod/inventory_selection_provider.dart
// State management for inventory item selection (batch operations)

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_selection_provider.g.dart';

/// Selection state for batch operations
@riverpod
class InventorySelection extends _$InventorySelection {
  @override
  Set<String> build() {
    return {};
  }

  /// Toggle selection of a single item
  void toggleItem(String itemId) {
    if (state.contains(itemId)) {
      state = Set.from(state)..remove(itemId);
    } else {
      state = Set.from(state)..add(itemId);
    }
  }

  /// Select a single item
  void selectItem(String itemId) {
    if (!state.contains(itemId)) {
      state = Set.from(state)..add(itemId);
    }
  }

  /// Deselect a single item
  void deselectItem(String itemId) {
    if (state.contains(itemId)) {
      state = Set.from(state)..remove(itemId);
    }
  }

  /// Select all items from a list
  void selectAll(List<String> itemIds) {
    state = Set.from(itemIds);
  }

  /// Clear all selections
  void clearSelection() {
    state = {};
  }

  /// Check if an item is selected
  bool isSelected(String itemId) {
    return state.contains(itemId);
  }

  /// Get count of selected items
  int get selectedCount => state.length;

  /// Check if any items are selected
  bool get hasSelection => state.isNotEmpty;
}

/// Provider to track if selection mode is active
@riverpod
class SelectionMode extends _$SelectionMode {
  @override
  bool build() {
    return false;
  }

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
    // Clear selection when disabling selection mode
    ref.read(inventorySelectionProvider.notifier).clearSelection();
  }

  void toggle() {
    state = !state;
    if (!state) {
      // Clear selection when disabling
      ref.read(inventorySelectionProvider.notifier).clearSelection();
    }
  }
}
