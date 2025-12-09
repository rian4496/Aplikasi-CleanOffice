// lib/providers/riverpod/notification_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../models/notification_model.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';

part 'notification_providers.g.dart';

// ==================== USER NOTIFICATIONS ====================

/// Future-based user notifications (Supabase doesn't support real-time streams the same way)
@riverpod
Future<List<AppNotification>> userNotifications(Ref ref) async {
  final user = supabase.Supabase.instance.client.auth.currentSession?.user;
  if (user == null) return [];

  // TODO: Implement notification methods in SupabaseDatabaseService
  // For now, return empty list
  return [];
}

// ==================== UNREAD COUNT ====================

/// Unread notification count
@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final user = supabase.Supabase.instance.client.auth.currentSession?.user;
  if (user == null) return 0;

  // TODO: Implement notification methods in SupabaseDatabaseService
  return 0;
}

// ==================== NOTIFICATION SETTINGS ====================

/// Notification settings - stored locally for now
/// Note: Supabase schema doesn't include notification_settings table
/// This could be added later or stored in user preferences
@riverpod
Future<NotificationSettings> notificationSettings(Ref ref) async {
  final user = supabase.Supabase.instance.client.auth.currentSession?.user;
  if (user == null) {
    return NotificationSettings(userId: '');
  }

  // Return default settings - can be enhanced later
  return NotificationSettings(userId: user.id);
}

// ==================== ACTIONS ====================

/// Mark notification as read
@riverpod
Future<void> markNotificationAsRead(
  Ref ref,
  String notificationId,
) async {
  // TODO: Implement in SupabaseDatabaseService
  // final service = ref.watch(supabaseDatabaseServiceProvider);
  // await service.markNotificationAsRead(notificationId);
}

/// Mark all notifications as read
@riverpod
Future<void> markAllNotificationsAsRead(Ref ref) async {
  final user = supabase.Supabase.instance.client.auth.currentSession?.user;
  if (user == null) return;

  // TODO: Implement in SupabaseDatabaseService
  // final service = ref.watch(supabaseDatabaseServiceProvider);
  // await service.markAllNotificationsAsRead(user.id);
}

/// Delete notification
@riverpod
Future<void> deleteNotification(
  Ref ref,
  String notificationId,
) async {
  // TODO: Implement in SupabaseDatabaseService
  // final service = ref.watch(supabaseDatabaseServiceProvider);
  // await service.deleteNotification(notificationId);
}

/// Save notification settings
/// Note: For now, settings are handled locally
/// Can be enhanced to store in Supabase later
@riverpod
Future<void> saveNotificationSettings(
  Ref ref,
  NotificationSettings settings,
) async {
  // TODO: Implement when notifications feature is fully implemented
  // For now, settings could be stored in SharedPreferences
}
