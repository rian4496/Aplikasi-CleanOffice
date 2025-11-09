// lib/providers/riverpod/notification_providers.dart
// Notification providers using Riverpod code generation

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/notification_model.dart';
import '../../services/notification_firestore_service.dart';
import './auth_providers.dart';

part 'notification_providers.g.dart';

final _notificationService = NotificationFirestoreService();

// ==================== USER NOTIFICATIONS ====================

/// Stream of user notifications
@riverpod
Stream<List<AppNotification>> userNotifications(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  return _notificationService.streamUserNotifications(user.uid);
}

// ==================== UNREAD COUNT ====================

/// Stream of unread notification count
@riverpod
Stream<int> unreadNotificationCount(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  
  return _notificationService.streamUnreadCount(user.uid);
}

// ==================== NOTIFICATION SETTINGS ====================

/// Stream of notification settings
@riverpod
Stream<NotificationSettings> notificationSettings(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(NotificationSettings(userId: ''));
  }
  
  return _notificationService.streamSettings(user.uid);
}

// ==================== ACTIONS ====================

/// Mark notification as read
@riverpod
Future<void> markNotificationAsRead(
  Ref ref,
  String notificationId,
) async {
  await _notificationService.markAsRead(notificationId);
}

/// Mark all notifications as read
@riverpod
Future<void> markAllNotificationsAsRead(Ref ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return;
  
  await _notificationService.markAllAsRead(user.uid);
}

/// Delete notification
@riverpod
Future<void> deleteNotification(
  Ref ref,
  String notificationId,
) async {
  await _notificationService.deleteNotification(notificationId);
}

/// Save notification settings
@riverpod
Future<void> saveNotificationSettings(
  Ref ref,
  NotificationSettings settings,
) async {
  await _notificationService.saveSettings(settings);
}
