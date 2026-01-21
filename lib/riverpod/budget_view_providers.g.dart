// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetFilterYear)
const budgetFilterYearProvider = BudgetFilterYearProvider._();

final class BudgetFilterYearProvider
    extends $NotifierProvider<BudgetFilterYear, int> {
  const BudgetFilterYearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetFilterYearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetFilterYearHash();

  @$internal
  @override
  BudgetFilterYear create() => BudgetFilterYear();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$budgetFilterYearHash() => r'085d77efb84ee99873441331e1df73d24727637e';

abstract class _$BudgetFilterYear extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredBudgets)
const filteredBudgetsProvider = FilteredBudgetsProvider._();

final class FilteredBudgetsProvider
    extends $FunctionalProvider<List<Budget>, List<Budget>, List<Budget>>
    with $Provider<List<Budget>> {
  const FilteredBudgetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredBudgetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredBudgetsHash();

  @$internal
  @override
  $ProviderElement<List<Budget>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Budget> create(Ref ref) {
    return filteredBudgets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Budget> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Budget>>(value),
    );
  }
}

String _$filteredBudgetsHash() => r'9b88de4a0dd620a8abd3411bba83547b4d2143f4';

@ProviderFor(budgetGlobalStats)
const budgetGlobalStatsProvider = BudgetGlobalStatsProvider._();

final class BudgetGlobalStatsProvider
    extends $FunctionalProvider<BudgetStats, BudgetStats, BudgetStats>
    with $Provider<BudgetStats> {
  const BudgetGlobalStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetGlobalStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetGlobalStatsHash();

  @$internal
  @override
  $ProviderElement<BudgetStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetStats create(Ref ref) {
    return budgetGlobalStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetStats>(value),
    );
  }
}

String _$budgetGlobalStatsHash() => r'839735457c4837c41b5e7c9ac20c1691eab6d2ee';
