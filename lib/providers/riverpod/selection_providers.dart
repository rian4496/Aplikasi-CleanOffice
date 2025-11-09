// lib/providers/riverpod/selection_providers.dart
// SIMPLIFIED - Providers for batch selection (read-only)

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== SELECTION STATE (Read-only) ====================
// Note: For now, these are read-only providers
// Widgets will manage selection state locally using StatefulWidget

/// Selected report IDs (read-only - returns empty by default)
final selectedReportIdsProvider = Provider<Set<String>>((ref) {
  return {};
});

/// Selection mode (read-only - returns false by default)
final selectionModeProvider = Provider<bool>((ref) {
  return false;
});

/// Count of selected items
final selectedCountProvider = Provider<int>((ref) {
  return ref.watch(selectedReportIdsProvider).length;
});
