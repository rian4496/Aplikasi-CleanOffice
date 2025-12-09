// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk SupabaseAuthService singleton

@ProviderFor(supabaseAuthService)
const supabaseAuthServiceProvider = SupabaseAuthServiceProvider._();

/// Provider untuk SupabaseAuthService singleton

final class SupabaseAuthServiceProvider
    extends
        $FunctionalProvider<
          SupabaseAuthService,
          SupabaseAuthService,
          SupabaseAuthService
        >
    with $Provider<SupabaseAuthService> {
  /// Provider untuk SupabaseAuthService singleton
  const SupabaseAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseAuthServiceHash();

  @$internal
  @override
  $ProviderElement<SupabaseAuthService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseAuthService create(Ref ref) {
    return supabaseAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseAuthService>(value),
    );
  }
}

String _$supabaseAuthServiceHash() =>
    r'863d181123922eeffed7d270036239046586fe1c';

/// Provider untuk SupabaseDatabaseService singleton

@ProviderFor(supabaseDatabaseService)
const supabaseDatabaseServiceProvider = SupabaseDatabaseServiceProvider._();

/// Provider untuk SupabaseDatabaseService singleton

final class SupabaseDatabaseServiceProvider
    extends
        $FunctionalProvider<
          SupabaseDatabaseService,
          SupabaseDatabaseService,
          SupabaseDatabaseService
        >
    with $Provider<SupabaseDatabaseService> {
  /// Provider untuk SupabaseDatabaseService singleton
  const SupabaseDatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseDatabaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseDatabaseServiceHash();

  @$internal
  @override
  $ProviderElement<SupabaseDatabaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseDatabaseService create(Ref ref) {
    return supabaseDatabaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseDatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseDatabaseService>(value),
    );
  }
}

String _$supabaseDatabaseServiceHash() =>
    r'53c08e7d5a71ebb6a8cff259fe47252e86641e60';

/// Provider untuk SupabaseStorageService singleton

@ProviderFor(supabaseStorageService)
const supabaseStorageServiceProvider = SupabaseStorageServiceProvider._();

/// Provider untuk SupabaseStorageService singleton

final class SupabaseStorageServiceProvider
    extends
        $FunctionalProvider<
          SupabaseStorageService,
          SupabaseStorageService,
          SupabaseStorageService
        >
    with $Provider<SupabaseStorageService> {
  /// Provider untuk SupabaseStorageService singleton
  const SupabaseStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseStorageServiceHash();

  @$internal
  @override
  $ProviderElement<SupabaseStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseStorageService create(Ref ref) {
    return supabaseStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseStorageService>(value),
    );
  }
}

String _$supabaseStorageServiceHash() =>
    r'16af8b65592b89d8a4149782c2957b91358f9123';
