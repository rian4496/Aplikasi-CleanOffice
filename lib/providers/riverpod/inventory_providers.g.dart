// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$allInventoryItemsHash() => r'063abfcb317752401d6c603c61379ad984d64591';

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

String _$lowStockItemsHash() => r'2061f8d6cde3850ac7781f7acc5b454d484df93a';

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

String _$lowStockCountHash() => r'5159499a162e76c25cfe32dd52c85a80ce50f399';

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
    r'd526cb674e258e0365191d1c346425a3d1d0ad9e';

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

String _$myStockRequestsHash() => r'a994d81d148d77bb13298db0d7dd71a528d85d34';

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
    r'a5630ad8577b663bdb955c28c1ee28da067a1a62';
