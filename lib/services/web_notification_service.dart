// lib/services/web_notification_service.dart
// 🔔 Web Browser Notification Service
// Uses JavaScript interop to show browser push notifications

import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for handling browser push notifications (Web only)
class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._();
  factory WebNotificationService() => _instance;
  WebNotificationService._();

  /// Check if browser notifications are supported
  bool get isSupported {
    if (!kIsWeb) return false;
    return _isNotificationSupported();
  }

  /// Get current permission status: 'granted', 'denied', 'default', or 'unsupported'
  String get permissionStatus {
    if (!kIsWeb) return 'unsupported';
    return _getNotificationPermission();
  }

  /// Check if notifications are enabled (permission granted)
  bool get isEnabled => permissionStatus == 'granted';

  /// Request notification permission from user
  /// Returns: 'granted', 'denied', 'default', 'unsupported', or 'error'
  Future<String> requestPermission() async {
    if (!kIsWeb) return 'unsupported';
    final result = await _requestNotificationPermission().toDart;
    return result.toString();
  }

  /// Show a browser notification
  /// Returns true if notification was shown successfully
  bool showNotification({
    required String title,
    required String body,
    String? icon,
  }) {
    if (!kIsWeb) return false;
    if (!isEnabled) return false;
    return _showBrowserNotification(
      title.toJS,
      body.toJS,
      (icon ?? '/icons/Icon-192.png').toJS,
    );
  }

  /// Play notification sound (chime)
  bool playSound() {
    if (!kIsWeb) return false;
    return _playNotificationSound();
  }
}

// JavaScript interop declarations
@JS('isNotificationSupported')
external bool _isNotificationSupported();

@JS('getNotificationPermission')
external String _getNotificationPermission();

@JS('requestNotificationPermission')
external JSPromise<JSString> _requestNotificationPermission();

@JS('showBrowserNotification')
external bool _showBrowserNotification(JSString title, JSString body, JSString icon);

@JS('playNotificationSound')
external bool _playNotificationSound();
