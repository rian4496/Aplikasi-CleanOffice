// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selection state notifier

@ProviderFor(SelectionNotifier)
const selectionProvider = SelectionNotifierProvider._();

/// Selection state notifier
final class SelectionNotifierProvider
    extends $NotifierProvider<SelectionNotifier, SelectionState> {
  /// Selection state notifier
  const SelectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionNotifierHash();

  @$internal
  @override
  SelectionNotifier create() => SelectionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectionState>(value),
    );
  }
}

String _$selectionNotifierHash() => r'b7502b0631c7f3d634fd8f3bd66595bc2543ddb8';

/// Selection state notifier

abstract class _$SelectionNotifier extends $Notifier<SelectionState> {
  SelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SelectionState, SelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SelectionState, SelectionState>,
              SelectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Check if a specific ID is selected

@ProviderFor(isSelected)
const isSelectedProvider = IsSelectedFamily._();

/// Check if a specific ID is selected

final class IsSelectedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Check if a specific ID is selected
  const IsSelectedProvider._({
    required IsSelectedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isSelectedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isSelectedHash();

  @override
  String toString() {
    return r'isSelectedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isSelected(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsSelectedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isSelectedHash() => r'273dc1e2819bf75a94e396416a4c290779e59a53';

/// Check if a specific ID is selected

final class IsSelectedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsSelectedFamily._()
    : super(
        retry: null,
        name: r'isSelectedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Check if a specific ID is selected

  IsSelectedProvider call(String id) =>
      IsSelectedProvider._(argument: id, from: this);

  @override
  String toString() => r'isSelectedProvider';
}

/// Get selected count

@ProviderFor(selectedCount)
const selectedCountProvider = SelectedCountProvider._();

/// Get selected count

final class SelectedCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Get selected count
  const SelectedCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return selectedCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedCountHash() => r'ddd07c4de8a969b4c8a44c9651083d0489ea38c9';

/// Check if in selection mode

@ProviderFor(isSelectionMode)
const isSelectionModeProvider = IsSelectionModeProvider._();

/// Check if in selection mode

final class IsSelectionModeProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Check if in selection mode
  const IsSelectionModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSelectionModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSelectionModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isSelectionMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSelectionModeHash() => r'd171a3ab2d948aeb628b1e1d475365f8337d67f4';
