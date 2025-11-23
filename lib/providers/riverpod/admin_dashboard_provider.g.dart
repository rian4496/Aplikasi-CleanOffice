// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminDashboardData)
const adminDashboardDataProvider = AdminDashboardDataProvider._();

final class AdminDashboardDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const AdminDashboardDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardDataHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return adminDashboardData(ref);
  }
}

String _$adminDashboardDataHash() =>
    r'6b665b37efcfb339667e54c5ef1e714ac688c419';

@ProviderFor(recentActivities)
const recentActivitiesProvider = RecentActivitiesProvider._();

final class RecentActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  const RecentActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentActivitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentActivitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return recentActivities(ref);
  }
}

String _$recentActivitiesHash() => r'1d61bafd1b432299756ca61a686a08fb4f791027';
