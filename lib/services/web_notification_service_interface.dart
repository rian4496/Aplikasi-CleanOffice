// lib/services/web_notification_service_interface.dart
// 🔔 Conditional export for WebNotificationService
// Uses conditional imports to load web-specific or stub implementation

export 'web_notification_service_stub.dart'
    if (dart.library.js_interop) 'web_notification_service.dart';
