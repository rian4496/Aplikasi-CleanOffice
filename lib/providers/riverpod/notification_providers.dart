// lib/providers/riverpod/notification_providers.dart
// Notification providers - Migrated to Appwrite

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/notification_model.dart';
import './auth_providers.dart';
import './inventory_providers.dart' show appwriteDatabaseServiceProvider;

part 'notification_providers.g.dart';

// ==================== USER NOTIFICATIONS ====================

/// Stream of user notifications
@riverpod
Stream<List<AppNotification>> userNotifications(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getUserNotifications(user.$id);
}

// ==================== UNREAD COUNT ====================

/// Stream of unread notification count
@riverpod
Stream<int> unreadNotificationCount(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);

  final service = ref.watch(appwriteDatabaseServiceProvider);
  return service.getUnreadNotificationCount(user.$id);
}

// ==================== NOTIFICATION SETTINGS ====================

/// Notification settings - stored locally for now
/// Note: Appwrite simplified schema doesn't include notification_settings collection
/// This could be added later or stored in user preferences
@riverpod
Stream<NotificationSettings> notificationSettings(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(NotificationSettings(userId: ''));
  }

  // Return default settings - can be enhanced later
  return Stream.value(NotificationSettings(userId: user.$id));
}

// ==================== ACTIONS ====================

/// Mark notification as read
@riverpod
Future<void> markNotificationAsRead(
  Ref ref,
  String notificationId,
) async {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  await service.markNotificationAsRead(notificationId);
}

/// Mark all notifications as read
@riverpod
Future<void> markAllNotificationsAsRead(Ref ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return;

  final service = ref.watch(appwriteDatabaseServiceProvider);
  await service.markAllNotificationsAsRead(user.$id);
}

/// Delete notification
@riverpod
Future<void> deleteNotification(
  Ref ref,
  String notificationId,
) async {
  final service = ref.watch(appwriteDatabaseServiceProvider);
  await service.deleteNotification(notificationId);
}

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Appwrite later
@riverpod
Future<void> saveNotificationSettings(
  Ref ref,
  NotificationSettings settings,
) async {
  // TODO: Implement when notification_settings collection is added
  // For now, settings could be stored in SharedPreferences
}
