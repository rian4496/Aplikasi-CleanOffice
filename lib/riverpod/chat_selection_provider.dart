// lib/riverpod/chat_selection_provider.dart
// Provider untuk mengelola selection mode di Chat List

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_selection_provider.g.dart';

/// State untuk selection mode
class ChatSelectionState {
  final Set<String> selectedIds;
  final bool isSelectionMode;

  const ChatSelectionState({
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  ChatSelectionState copyWith({
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return ChatSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  int get selectedCount => selectedIds.length;
  
  bool isSelected(String id) => selectedIds.contains(id);
}

/// Provider untuk mengelola selection state di Chat List
@riverpod
class ChatSelection extends _$ChatSelection {
  @override
  ChatSelectionState build() {
    return const ChatSelectionState();
  }

  /// Toggle selection untuk satu item
  void toggleSelection(String conversationId) {
    final newSelected = Set<String>.from(state.selectedIds);
    
    if (newSelected.contains(conversationId)) {
      newSelected.remove(conversationId);
    } else {
      newSelected.add(conversationId);
    }
    
    // Jika tidak ada yang dipilih, keluar dari selection mode
    if (newSelected.isEmpty) {
      state = const ChatSelectionState();
    } else {
      state = state.copyWith(
        selectedIds: newSelected,
        isSelectionMode: true,
      );
    }
  }

  /// Start selection mode dengan item pertama
  void startSelection(String conversationId) {
    state = ChatSelectionState(
      selectedIds: {conversationId},
      isSelectionMode: true,
    );
  }

  /// Select all items
  void selectAll(List<String> allIds) {
    state = state.copyWith(
      selectedIds: allIds.toSet(),
      isSelectionMode: true,
    );
  }

  /// Clear selection dan keluar dari selection mode
  void clearSelection() {
    state = const ChatSelectionState();
  }

  /// Check if item is selected
  bool isSelected(String id) {
    return state.selectedIds.contains(id);
  }
}

