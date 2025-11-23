// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk AppwriteDatabaseService singleton
/// Digunakan di seluruh inventory providers

@ProviderFor(appwriteDatabaseService)
const appwriteDatabaseServiceProvider = AppwriteDatabaseServiceProvider._();

/// Provider untuk AppwriteDatabaseService singleton
/// Digunakan di seluruh inventory providers

final class AppwriteDatabaseServiceProvider
    extends
        $FunctionalProvider<
          AppwriteDatabaseService,
          AppwriteDatabaseService,
          AppwriteDatabaseService
        >
    with $Provider<AppwriteDatabaseService> {
  /// Provider untuk AppwriteDatabaseService singleton
  /// Digunakan di seluruh inventory providers
  const AppwriteDatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appwriteDatabaseServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appwriteDatabaseServiceHash();

  @$internal
  @override
  $ProviderElement<AppwriteDatabaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppwriteDatabaseService create(Ref ref) {
    return appwriteDatabaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppwriteDatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppwriteDatabaseService>(value),
    );
  }
}

String _$appwriteDatabaseServiceHash() =>
    r'1494f51b806808b4d193c4564fa18494e9388490';

/// Stream all inventory items

@ProviderFor(allInventoryItems)
const allInventoryItemsProvider = AllInventoryItemsProvider._();

/// Stream all inventory items

final class AllInventoryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryItem>>,
          List<InventoryItem>,
          Stream<List<InventoryItem>>
        >
    with
        $FutureModifier<List<InventoryItem>>,
        $StreamProvider<List<InventoryItem>> {
  /// Stream all inventory items
  const AllInventoryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allInventoryItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allInventoryItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InventoryItem>> create(Ref ref) {
    return allInventoryItems(ref);
  }
}

String _$allInventoryItemsHash() => r'1a1158c7e5814ae854384e851be54ee100184083';

/// Stream low stock items

@ProviderFor(lowStockItems)
const lowStockItemsProvider = LowStockItemsProvider._();

/// Stream low stock items

final class LowStockItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryItem>>,
          List<InventoryItem>,
          Stream<List<InventoryItem>>
        >
    with
        $FutureModifier<List<InventoryItem>>,
        $StreamProvider<List<InventoryItem>> {
  /// Stream low stock items
  const LowStockItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<InventoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InventoryItem>> create(Ref ref) {
    return lowStockItems(ref);
  }
}

String _$lowStockItemsHash() => r'74179369ace6c2e85a6d5a722e5f811a4b738bd6';

/// Get low stock count

@ProviderFor(lowStockCount)
const lowStockCountProvider = LowStockCountProvider._();

/// Get low stock count

final class LowStockCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Get low stock count
  const LowStockCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lowStockCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lowStockCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return lowStockCount(ref);
  }
}

String _$lowStockCountHash() => r'a6b0f54793e7eb57988d91a6a91014911aef2796';

/// Stream pending stock requests

@ProviderFor(pendingStockRequests)
const pendingStockRequestsProvider = PendingStockRequestsProvider._();

/// Stream pending stock requests

final class PendingStockRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockRequest>>,
          List<StockRequest>,
          Stream<List<StockRequest>>
        >
    with
        $FutureModifier<List<StockRequest>>,
        $StreamProvider<List<StockRequest>> {
  /// Stream pending stock requests
  const PendingStockRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingStockRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingStockRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<StockRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StockRequest>> create(Ref ref) {
    return pendingStockRequests(ref);
  }
}

String _$pendingStockRequestsHash() =>
    r'883fe4e169b15adbba685be388f2dc598667f9e3';

/// Stream user's stock requests

@ProviderFor(myStockRequests)
const myStockRequestsProvider = MyStockRequestsProvider._();

/// Stream user's stock requests

final class MyStockRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockRequest>>,
          List<StockRequest>,
          Stream<List<StockRequest>>
        >
    with
        $FutureModifier<List<StockRequest>>,
        $StreamProvider<List<StockRequest>> {
  /// Stream user's stock requests
  const MyStockRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myStockRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myStockRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<StockRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StockRequest>> create(Ref ref) {
    return myStockRequests(ref);
  }
}

String _$myStockRequestsHash() => r'949f6b52e8e62d69b8718cdb5bd6ddde1e646d7c';

/// Get pending requests count

@ProviderFor(pendingRequestsCount)
const pendingRequestsCountProvider = PendingRequestsCountProvider._();

/// Get pending requests count

final class PendingRequestsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Get pending requests count
  const PendingRequestsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRequestsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRequestsCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return pendingRequestsCount(ref);
  }
}

String _$pendingRequestsCountHash() =>
    r'2c7a9636c9e29f9a60d49f1f3aa4e49efbbc003a';
