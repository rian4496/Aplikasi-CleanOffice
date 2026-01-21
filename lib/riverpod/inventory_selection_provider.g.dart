// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selection state for batch operations

@ProviderFor(InventorySelection)
const inventorySelectionProvider = InventorySelectionProvider._();

/// Selection state for batch operations
final class InventorySelectionProvider
    extends $NotifierProvider<InventorySelection, Set<String>> {
  /// Selection state for batch operations
  const InventorySelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventorySelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventorySelectionHash();

  @$internal
  @override
  InventorySelection create() => InventorySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$inventorySelectionHash() =>
    r'06dd767f4f0957d352cb53e1c80b7996c22ff87d';

/// Selection state for batch operations

abstract class _$InventorySelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to track if selection mode is active

@ProviderFor(SelectionMode)
const selectionModeProvider = SelectionModeProvider._();

/// Provider to track if selection mode is active
final class SelectionModeProvider
    extends $NotifierProvider<SelectionMode, bool> {
  /// Provider to track if selection mode is active
  const SelectionModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionModeHash();

  @$internal
  @override
  SelectionMode create() => SelectionMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$selectionModeHash() => r'e1f331f7de570dc615905960b8adacbd4d2bc20a';

/// Provider to track if selection mode is active

abstract class _$SelectionMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
