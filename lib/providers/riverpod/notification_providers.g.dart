// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of user notifications

@ProviderFor(userNotifications)
const userNotificationsProvider = UserNotificationsProvider._();

/// Stream of user notifications

final class UserNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          Stream<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $StreamProvider<List<AppNotification>> {
  /// Stream of user notifications
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
  $StreamProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotification>> create(Ref ref) {
    return userNotifications(ref);
  }
}

String _$userNotificationsHash() => r'97e14f9a4cf89dc0da53cd822c1cde73b84c6315';

/// Stream of unread notification count

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Stream of unread notification count

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Stream of unread notification count
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
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'40a46308fc9b6df77bd75201dce98889761eaa18';

/// Notification settings - stored locally for now
/// Note: Appwrite simplified schema doesn't include notification_settings collection
/// This could be added later or stored in user preferences

@ProviderFor(notificationSettings)
const notificationSettingsProvider = NotificationSettingsProvider._();

/// Notification settings - stored locally for now
/// Note: Appwrite simplified schema doesn't include notification_settings collection
/// This could be added later or stored in user preferences

final class NotificationSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationSettings>,
          NotificationSettings,
          Stream<NotificationSettings>
        >
    with
        $FutureModifier<NotificationSettings>,
        $StreamProvider<NotificationSettings> {
  /// Notification settings - stored locally for now
  /// Note: Appwrite simplified schema doesn't include notification_settings collection
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
  $StreamProviderElement<NotificationSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationSettings> create(Ref ref) {
    return notificationSettings(ref);
  }
}

String _$notificationSettingsHash() =>
    r'e140fb5e7a19e6ca5c0efd8b9c2c6b3121413c67';

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
    r'c726fa542d1fe4866c837c797103304b76a75c9b';

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
    r'a77e7beb36dd36cbd089db46c652d1d68b6f1370';

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
    r'84273d5b849bad6a527c44943f0872013fe869cd';

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
/// Can be enhanced to store in Appwrite later

@ProviderFor(saveNotificationSettings)
const saveNotificationSettingsProvider = SaveNotificationSettingsFamily._();

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Appwrite later

final class SaveNotificationSettingsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Save notification settings
  /// Note: For now, settings are handled locally
  /// Can be enhanced to store in Appwrite later
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
/// Can be enhanced to store in Appwrite later

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
  /// Can be enhanced to store in Appwrite later

  SaveNotificationSettingsProvider call(NotificationSettings settings) =>
      SaveNotificationSettingsProvider._(argument: settings, from: this);

  @override
  String toString() => r'saveNotificationSettingsProvider';
}
