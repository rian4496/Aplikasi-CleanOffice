// lib/models/notification_model_freezed.dart
// Notification models - Freezed Version

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'notification_model_freezed.freezed.dart';
part 'notification_model_freezed.g.dart';

// ==================== NOTIFICATION TYPE ====================

enum NotificationType {
  urgentReport('Laporan Urgent', Icons.warning, Colors.red),
  reportAssigned('Tugas Baru', Icons.assignment, Colors.blue),
  reportCompleted('Laporan Selesai', Icons.check_circle, Colors.green),
  reportOverdue('Laporan Terlambat', Icons.schedule, Colors.orange),
  reportRejected('Laporan Ditolak', Icons.cancel, Colors.red),
  newComment('Komentar Baru', Icons.comment, Colors.purple),
  statusUpdated('Status Diupdate', Icons.update, Colors.blue),
  lowStockAlert('Stok Rendah', Icons.inventory, Colors.orange),
  general('Notifikasi', Icons.notifications, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const NotificationType(this.label, this.icon, this.color);
}

// ==================== APP NOTIFICATION ====================

@freezed
class AppNotification with _$AppNotification {
  const AppNotification._(); // Private constructor for custom methods

  const factory AppNotification({
    required String id,
    required String userId, // Who receives this notification
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data, // Extra data (reportId, etc.)
    @Default(false) bool read,
    @ISODateTimeConverter() required DateTime createdAt,
  }) = _AppNotification;

  /// Convert dari JSON ke AppNotification object
  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  /// Convert dari Map ke AppNotification object (backward compatibility)
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification.fromJson({
      'id': id,
      'userId': map['userId'],
      'type': map['type'], // json_serializable handles enum
      'title': map['title'],
      'message': map['message'],
      'data': map['data'],
      'read': map['read'] ?? false,
      'createdAt': map['createdAt'],
    });
  }

  /// Convert AppNotification object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    // Convert enum to string
    json['type'] = type.name;
    return json;
  }
}

// ==================== APP NOTIFICATION EXTENSION ====================

extension AppNotificationExtension on AppNotification {
  // Helper getters for backward compatibility
  bool get isRead => read;
  String? get reportId => data?['reportId'] as String?;
  String? get imageUrl => data?['imageUrl'] as String?;
  bool get isUrgent => type == NotificationType.urgentReport || type == NotificationType.reportOverdue;
  IconData get icon => type.icon;
  Color get iconColor => type.color;

  // Time ago helper
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    }
  }
}

// ==================== NOTIFICATION SETTINGS ====================

@freezed
class NotificationSettings with _$NotificationSettings {
  const NotificationSettings._(); // Private constructor for custom methods

  const factory NotificationSettings({
    required String userId,
    @Default(true) bool enabled,
    @Default(true) bool urgentReport,
    @Default(true) bool reportAssigned,
    @Default(true) bool reportCompleted,
    @Default(true) bool reportOverdue,
    @Default(true) bool reportRejected,
    @Default(true) bool newComment,
    @Default(true) bool sound,
    @Default(true) bool vibration,
  }) = _NotificationSettings;

  /// Convert dari JSON ke NotificationSettings object
  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

  /// Convert dari Map ke NotificationSettings object (backward compatibility)
  factory NotificationSettings.fromMap(String userId, Map<String, dynamic> map) {
    return NotificationSettings.fromJson({
      'userId': userId,
      'enabled': map['enabled'] ?? true,
      'urgentReport': map['urgentReport'] ?? true,
      'reportAssigned': map['reportAssigned'] ?? true,
      'reportCompleted': map['reportCompleted'] ?? true,
      'reportOverdue': map['reportOverdue'] ?? true,
      'reportRejected': map['reportRejected'] ?? true,
      'newComment': map['newComment'] ?? true,
      'sound': map['sound'] ?? true,
      'vibration': map['vibration'] ?? true,
    });
  }

  /// Convert NotificationSettings object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove userId from map for Firestore (it's the document ID)
    json.remove('userId');
    return json;
  }
}

// ==================== NOTIFICATION SETTINGS EXTENSION ====================

extension NotificationSettingsExtension on NotificationSettings {
  bool isTypeEnabled(NotificationType type) {
    if (!enabled) return false;

    switch (type) {
      case NotificationType.urgentReport:
        return urgentReport;
      case NotificationType.reportAssigned:
        return reportAssigned;
      case NotificationType.reportCompleted:
        return reportCompleted;
      case NotificationType.reportOverdue:
        return reportOverdue;
      case NotificationType.reportRejected:
        return reportRejected;
      case NotificationType.newComment:
        return newComment;
      default:
        return true;
    }
  }
}
