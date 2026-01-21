// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk mengelola selection state di Chat List

@ProviderFor(ChatSelection)
const chatSelectionProvider = ChatSelectionProvider._();

/// Provider untuk mengelola selection state di Chat List
final class ChatSelectionProvider
    extends $NotifierProvider<ChatSelection, ChatSelectionState> {
  /// Provider untuk mengelola selection state di Chat List
  const ChatSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatSelectionHash();

  @$internal
  @override
  ChatSelection create() => ChatSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatSelectionState>(value),
    );
  }
}

String _$chatSelectionHash() => r'4793068b2961038dc5e185939b0652ebfbe8bd5f';

/// Provider untuk mengelola selection state di Chat List

abstract class _$ChatSelection extends $Notifier<ChatSelectionState> {
  ChatSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ChatSelectionState, ChatSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatSelectionState, ChatSelectionState>,
              ChatSelectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
