// lib/services/web_notification_service_stub.dart
// 🔔 Stub for non-web platforms (Android, iOS, Desktop)
// This file provides a no-op implementation for platforms that don't support dart:js_interop

/// Stub service for handling browser push notifications (non-web platforms)
/// All methods return appropriate defaults since browser notifications are not available.
class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._();
  factory WebNotificationService() => _instance;
  WebNotificationService._();

  /// Check if browser notifications are supported (always false on non-web)
  bool get isSupported => false;

  /// Get current permission status (always 'unsupported' on non-web)
  String get permissionStatus => 'unsupported';

  /// Check if notifications are enabled (always false on non-web)
  bool get isEnabled => false;

  /// Request notification permission (no-op on non-web)
  Future<String> requestPermission() async => 'unsupported';

  /// Show a browser notification (no-op on non-web)
  bool showNotification({
    required String title,
    required String body,
    String? icon,
  }) => false;

  /// Play notification sound (no-op on non-web)
  bool playSound() => false;
}
