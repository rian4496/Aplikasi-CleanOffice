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

String _$userNotificationsHash() => r'b575bf5000e49ad83c4ff7ac8a3969092b29bfd8';

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
    r'e5b53b42f4fdb2cf7a898b02130f41d8df9d2c73';

/// Stream of notification settings

@ProviderFor(notificationSettings)
const notificationSettingsProvider = NotificationSettingsProvider._();

/// Stream of notification settings

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
  /// Stream of notification settings
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
    r'eaf9bbead42a050638c66d0ba2da63b69b1dbf58';

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
    r'5bc0aba3c4599f520be0b8a38531f02e88f9ad82';

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
    r'6a799dc0803feec207571ec35639289d6cf07333';

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
    r'e41bf20ee4b85c8df79b085eade6c169248fd1e7';

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

@ProviderFor(saveNotificationSettings)
const saveNotificationSettingsProvider = SaveNotificationSettingsFamily._();

/// Save notification settings

final class SaveNotificationSettingsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Save notification settings
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
    r'48431b10404d49977639a7ac083b817eb2b706c6';

/// Save notification settings

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

  SaveNotificationSettingsProvider call(NotificationSettings settings) =>
      SaveNotificationSettingsProvider._(argument: settings, from: this);

  @override
  String toString() => r'saveNotificationSettingsProvider';
}
