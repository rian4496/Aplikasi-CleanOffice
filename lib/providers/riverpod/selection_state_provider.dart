// lib/providers/riverpod/selection_state_provider.dart
// Selection state management for batch operations

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_state_provider.g.dart';

// ==================== SELECTION STATE ====================

/// Selection state class
class SelectionState {
  final Set<String> selectedIds;
  final bool isSelectionMode;
  
  const SelectionState({
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });
  
  SelectionState copyWith({
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
  
  int get selectedCount => selectedIds.length;
  
  bool get hasSelection => selectedIds.isNotEmpty;
  
  bool isSelected(String id) => selectedIds.contains(id);
}

// ==================== SELECTION NOTIFIER ====================

/// Selection state notifier
@riverpod
class SelectionNotifier extends _$SelectionNotifier {
  @override
  SelectionState build() => const SelectionState();
  
  /// Toggle selection for a single item
  void toggleSelection(String id) {
    final currentIds = Set<String>.from(state.selectedIds);
    
    if (currentIds.contains(id)) {
      currentIds.remove(id);
    } else {
      currentIds.add(id);
    }
    
    state = state.copyWith(
      selectedIds: currentIds,
      isSelectionMode: currentIds.isNotEmpty,
    );
  }
  
  /// Enter selection mode with first item selected
  void enterSelectionMode(String firstId) {
    state = SelectionState(
      selectedIds: {firstId},
      isSelectionMode: true,
    );
  }
  
  /// Select all items
  void selectAll(List<String> ids) {
    state = state.copyWith(
      selectedIds: Set<String>.from(ids),
      isSelectionMode: true,
    );
  }
  
  /// Deselect all items but stay in selection mode
  void deselectAll() {
    state = state.copyWith(
      selectedIds: const {},
      isSelectionMode: true,
    );
  }
  
  /// Clear selection and exit selection mode
  void clearSelection() {
    state = const SelectionState();
  }
  
  /// Exit selection mode
  void exitSelectionMode() {
    state = const SelectionState();
  }
}

// ==================== COMPUTED PROVIDERS ====================

/// Check if a specific ID is selected
@riverpod
bool isSelected(Ref ref, String id) {
  final selectionState = ref.watch(selectionProvider);
  return selectionState.isSelected(id);
}

/// Get selected count
@riverpod
int selectedCount(Ref ref) {
  final selectionState = ref.watch(selectionProvider);
  return selectionState.selectedCount;
}

/// Check if in selection mode
@riverpod
bool isSelectionMode(Ref ref) {
  final selectionState = ref.watch(selectionProvider);
  return selectionState.isSelectionMode;
}
