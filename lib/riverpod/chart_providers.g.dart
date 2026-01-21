// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected time range for charts

@ProviderFor(ChartTimeRangeNotifier)
const chartTimeRangeProvider = ChartTimeRangeNotifierProvider._();

/// Selected time range for charts
final class ChartTimeRangeNotifierProvider
    extends $NotifierProvider<ChartTimeRangeNotifier, ChartTimeRange> {
  /// Selected time range for charts
  const ChartTimeRangeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chartTimeRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chartTimeRangeNotifierHash();

  @$internal
  @override
  ChartTimeRangeNotifier create() => ChartTimeRangeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChartTimeRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChartTimeRange>(value),
    );
  }
}

String _$chartTimeRangeNotifierHash() =>
    r'89a84e0f6eccc685a103f12d848443dc61159b28';

/// Selected time range for charts

abstract class _$ChartTimeRangeNotifier extends $Notifier<ChartTimeRange> {
  ChartTimeRange build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ChartTimeRange, ChartTimeRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChartTimeRange, ChartTimeRange>,
              ChartTimeRange,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Reports trend data over time

@ProviderFor(reportsTrendData)
const reportsTrendDataProvider = ReportsTrendDataProvider._();

/// Reports trend data over time

final class ReportsTrendDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendData>,
          TrendData,
          FutureOr<TrendData>
        >
    with $FutureModifier<TrendData>, $FutureProvider<TrendData> {
  /// Reports trend data over time
  const ReportsTrendDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsTrendDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsTrendDataHash();

  @$internal
  @override
  $FutureProviderElement<TrendData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TrendData> create(Ref ref) {
    return reportsTrendData(ref);
  }
}

String _$reportsTrendDataHash() => r'7866a5ee678a751e4e987b733bdb1abaa61140d3';

/// Reports aggregated by location

@ProviderFor(reportsByLocation)
const reportsByLocationProvider = ReportsByLocationProvider._();

/// Reports aggregated by location

final class ReportsByLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LocationStats>>,
          List<LocationStats>,
          FutureOr<List<LocationStats>>
        >
    with
        $FutureModifier<List<LocationStats>>,
        $FutureProvider<List<LocationStats>> {
  /// Reports aggregated by location
  const ReportsByLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsByLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsByLocationHash();

  @$internal
  @override
  $FutureProviderElement<List<LocationStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LocationStats>> create(Ref ref) {
    return reportsByLocation(ref);
  }
}

String _$reportsByLocationHash() => r'0d0c7157de452b29f3959ead37398eeb18b5ad97';

/// Reports aggregated by status

@ProviderFor(reportsByStatus)
const reportsByStatusProvider = ReportsByStatusProvider._();

/// Reports aggregated by status

final class ReportsByStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StatusStats>>,
          List<StatusStats>,
          FutureOr<List<StatusStats>>
        >
    with
        $FutureModifier<List<StatusStats>>,
        $FutureProvider<List<StatusStats>> {
  /// Reports aggregated by status
  const ReportsByStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsByStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsByStatusHash();

  @$internal
  @override
  $FutureProviderElement<List<StatusStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StatusStats>> create(Ref ref) {
    return reportsByStatus(ref);
  }
}

String _$reportsByStatusHash() => r'bd96dc69eda17a074baca5dd8aac7fe08602b7dc';

/// Top cleaners by performance

@ProviderFor(topCleaners)
const topCleanersProvider = TopCleanersFamily._();

/// Top cleaners by performance

final class TopCleanersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CleanerPerformance>>,
          List<CleanerPerformance>,
          FutureOr<List<CleanerPerformance>>
        >
    with
        $FutureModifier<List<CleanerPerformance>>,
        $FutureProvider<List<CleanerPerformance>> {
  /// Top cleaners by performance
  const TopCleanersProvider._({
    required TopCleanersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'topCleanersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topCleanersHash();

  @override
  String toString() {
    return r'topCleanersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CleanerPerformance>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CleanerPerformance>> create(Ref ref) {
    final argument = this.argument as int;
    return topCleaners(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopCleanersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topCleanersHash() => r'b27ebbdfa505b795f42edb90a0006fee3ca7ab4e';

/// Top cleaners by performance

final class TopCleanersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CleanerPerformance>>, int> {
  const TopCleanersFamily._()
    : super(
        retry: null,
        name: r'topCleanersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Top cleaners by performance

  TopCleanersProvider call({int limit = 10}) =>
      TopCleanersProvider._(argument: limit, from: this);

  @override
  String toString() => r'topCleanersProvider';
}

/// Summary statistics

@ProviderFor(summaryStats)
const summaryStatsProvider = SummaryStatsProvider._();

/// Summary statistics

final class SummaryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Summary statistics
  const SummaryStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'summaryStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$summaryStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return summaryStats(ref);
  }
}

String _$summaryStatsHash() => r'439d839ededc843bbbf09f1434de7a4e417a257f';
