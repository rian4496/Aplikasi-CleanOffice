// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filter state notifier

@ProviderFor(FilterNotifier)
const filterProvider = FilterNotifierProvider._();

/// Filter state notifier
final class FilterNotifierProvider
    extends $NotifierProvider<FilterNotifier, FilterState> {
  /// Filter state notifier
  const FilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterNotifierHash();

  @$internal
  @override
  FilterNotifier create() => FilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterState>(value),
    );
  }
}

String _$filterNotifierHash() => r'2338d5923cbce3a5e19dccc858b1dfcf3781b2cb';

/// Filter state notifier

abstract class _$FilterNotifier extends $Notifier<FilterState> {
  FilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FilterState, FilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilterState, FilterState>,
              FilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Filtered reports based on current filter state

@ProviderFor(filteredReports)
const filteredReportsProvider = FilteredReportsProvider._();

/// Filtered reports based on current filter state

final class FilteredReportsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Report>>,
          List<Report>,
          FutureOr<List<Report>>
        >
    with $FutureModifier<List<Report>>, $FutureProvider<List<Report>> {
  /// Filtered reports based on current filter state
  const FilteredReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredReportsHash();

  @$internal
  @override
  $FutureProviderElement<List<Report>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Report>> create(Ref ref) {
    return filteredReports(ref);
  }
}

String _$filteredReportsHash() => r'2815c43563d461db881d3805b251c8d1e61579ef';

/// Count of filtered reports

@ProviderFor(filteredCount)
const filteredCountProvider = FilteredCountProvider._();

/// Count of filtered reports

final class FilteredCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Count of filtered reports
  const FilteredCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return filteredCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$filteredCountHash() => r'1f21985afd9bbacfcc904976c56ad425f1977775';
