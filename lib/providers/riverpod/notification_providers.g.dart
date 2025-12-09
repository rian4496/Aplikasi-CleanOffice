// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Future-based user notifications (Supabase doesn't support real-time streams the same way)

@ProviderFor(userNotifications)
const userNotificationsProvider = UserNotificationsProvider._();

/// Future-based user notifications (Supabase doesn't support real-time streams the same way)

final class UserNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          FutureOr<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $FutureProvider<List<AppNotification>> {
  /// Future-based user notifications (Supabase doesn't support real-time streams the same way)
  const UserNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppNotification>> create(Ref ref) {
    return userNotifications(ref);
  }
}

String _$userNotificationsHash() => r'e41ca26a960a5bc8ed9039c27ba74735fe325cc1';

/// Unread notification count

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Unread notification count

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Unread notification count
  const UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'48badcebb243ee9ecdef5d6280ba68862f5a436b';

/// Notification settings - stored locally for now
/// Note: Supabase schema doesn't include notification_settings table
/// This could be added later or stored in user preferences

@ProviderFor(notificationSettings)
const notificationSettingsProvider = NotificationSettingsProvider._();

/// Notification settings - stored locally for now
/// Note: Supabase schema doesn't include notification_settings table
/// This could be added later or stored in user preferences

final class NotificationSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationSettings>,
          NotificationSettings,
          FutureOr<NotificationSettings>
        >
    with
        $FutureModifier<NotificationSettings>,
        $FutureProvider<NotificationSettings> {
  /// Notification settings - stored locally for now
  /// Note: Supabase schema doesn't include notification_settings table
  /// This could be added later or stored in user preferences
  const NotificationSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsHash();

  @$internal
  @override
  $FutureProviderElement<NotificationSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationSettings> create(Ref ref) {
    return notificationSettings(ref);
  }
}

String _$notificationSettingsHash() =>
    r'b814010b2ebf3e0c0235fb393a50f876f68ab3f6';

/// Mark notification as read

@ProviderFor(markNotificationAsRead)
const markNotificationAsReadProvider = MarkNotificationAsReadFamily._();

/// Mark notification as read

final class MarkNotificationAsReadProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Mark notification as read
  const MarkNotificationAsReadProvider._({
    required MarkNotificationAsReadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'markNotificationAsReadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$markNotificationAsReadHash();

  @override
  String toString() {
    return r'markNotificationAsReadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return markNotificationAsRead(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkNotificationAsReadProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$markNotificationAsReadHash() =>
    r'd129cf7ac9f1cbbce4a1def02dc08e3f64fab902';

/// Mark notification as read

final class MarkNotificationAsReadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const MarkNotificationAsReadFamily._()
    : super(
        retry: null,
        name: r'markNotificationAsReadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Mark notification as read

  MarkNotificationAsReadProvider call(String notificationId) =>
      MarkNotificationAsReadProvider._(argument: notificationId, from: this);

  @override
  String toString() => r'markNotificationAsReadProvider';
}

/// Mark all notifications as read

@ProviderFor(markAllNotificationsAsRead)
const markAllNotificationsAsReadProvider =
    MarkAllNotificationsAsReadProvider._();

/// Mark all notifications as read

final class MarkAllNotificationsAsReadProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Mark all notifications as read
  const MarkAllNotificationsAsReadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markAllNotificationsAsReadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markAllNotificationsAsReadHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return markAllNotificationsAsRead(ref);
  }
}

String _$markAllNotificationsAsReadHash() =>
    r'5571e22d6f726ad799fff5ec449e27a9804ce1bf';

/// Delete notification

@ProviderFor(deleteNotification)
const deleteNotificationProvider = DeleteNotificationFamily._();

/// Delete notification

final class DeleteNotificationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Delete notification
  const DeleteNotificationProvider._({
    required DeleteNotificationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteNotificationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteNotificationHash();

  @override
  String toString() {
    return r'deleteNotificationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteNotification(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteNotificationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteNotificationHash() =>
    r'f0a90cd97650088a8aa8e08189751b42504db18e';

/// Delete notification

final class DeleteNotificationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const DeleteNotificationFamily._()
    : super(
        retry: null,
        name: r'deleteNotificationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Delete notification

  DeleteNotificationProvider call(String notificationId) =>
      DeleteNotificationProvider._(argument: notificationId, from: this);

  @override
  String toString() => r'deleteNotificationProvider';
}

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Supabase later

@ProviderFor(saveNotificationSettings)
const saveNotificationSettingsProvider = SaveNotificationSettingsFamily._();

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Supabase later

final class SaveNotificationSettingsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Save notification settings
  /// Note: For now, settings are handled locally
  /// Can be enhanced to store in Supabase later
  const SaveNotificationSettingsProvider._({
    required SaveNotificationSettingsFamily super.from,
    required NotificationSettings super.argument,
  }) : super(
         retry: null,
         name: r'saveNotificationSettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saveNotificationSettingsHash();

  @override
  String toString() {
    return r'saveNotificationSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as NotificationSettings;
    return saveNotificationSettings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveNotificationSettingsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saveNotificationSettingsHash() =>
    r'8d07456ceda5cde67422f73ec14d3de9c4cfeea7';

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Supabase later

final class SaveNotificationSettingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, NotificationSettings> {
  const SaveNotificationSettingsFamily._()
    : super(
        retry: null,
        name: r'saveNotificationSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Save notification settings
  /// Note: For now, settings are handled locally
  /// Can be enhanced to store in Supabase later

  SaveNotificationSettingsProvider call(NotificationSettings settings) =>
      SaveNotificationSettingsProvider._(argument: settings, from: this);

  @override
  String toString() => r'saveNotificationSettingsProvider';
}
