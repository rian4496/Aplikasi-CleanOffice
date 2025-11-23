import 'package:hooks_riverpod/hooks_riverpod.dart';

// 1. Selection Mode Notifier
class SelectionModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final selectionModeProvider = NotifierProvider<SelectionModeNotifier, bool>(() {
  return SelectionModeNotifier();
});

// 2. Selected Report IDs Notifier
class SelectedReportIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final newState = Set<String>.from(state);
    if (newState.contains(id)) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    state = newState;
  }

  void selectAll(List<String> ids) {
    state = Set.from(ids);
  }

  void clear() {
    state = {};
  }
}

final selectedReportIdsProvider = NotifierProvider<SelectedReportIdsNotifier, Set<String>>(() {
  return SelectedReportIdsNotifier();
});

// 3. Computed Selection Count
final selectedCountProvider = Provider<int>((ref) {
  return ref.watch(selectedReportIdsProvider).length;
});

// Helper methods (updated to use Notifier)
void toggleReportSelection(WidgetRef ref, String reportId) {
  ref.read(selectedReportIdsProvider.notifier).toggle(reportId);
  
  // Auto-exit if empty
  final currentSelection = ref.read(selectedReportIdsProvider);
  if (currentSelection.isEmpty) {
    ref.read(selectionModeProvider.notifier).set(false);
  }
}

void selectAllReports(WidgetRef ref, List<String> allIds) {
  ref.read(selectedReportIdsProvider.notifier).selectAll(allIds);
  ref.read(selectionModeProvider.notifier).set(true);
}

void clearSelection(WidgetRef ref) {
  ref.read(selectedReportIdsProvider.notifier).clear();
  ref.read(selectionModeProvider.notifier).set(false);
}
