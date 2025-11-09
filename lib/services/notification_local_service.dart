// lib/services/notification_local_service.dart
// Local notification service using flutter_local_notifications

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

class NotificationLocalService {
  static final NotificationLocalService _instance = NotificationLocalService._internal();
  factory NotificationLocalService() => _instance;
  NotificationLocalService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Show notification
  Future<void> showNotification(AppNotification notification) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      'cleanoffice_channel',
      'CleanOffice Notifications',
      channelDescription: 'Notifications for CleanOffice app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: notification.type.color,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notification.id.hashCode,
      notification.title,
      notification.message,
      details,
      payload: notification.id,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Update badge count (iOS)
  Future<void> updateBadgeCount(int count) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS badge update would go here
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Navigate to relevant screen based on payload
    // This will be handled by the app's navigation system
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request permissions (iOS)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true; // Android doesn't need runtime permission for notifications
  }
}
