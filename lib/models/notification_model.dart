// lib/models/notification_model.dart
// Models for notifications system

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

class AppNotification extends Equatable {
  final String id;
  final String userId; // Who receives this notification
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data; // Extra data (reportId, etc.)
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.read = false,
    required this.createdAt,
  });

  // From Firestore
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      title: map['title'] as String,
      message: map['message'] as String,
      data: map['data'] as Map<String, dynamic>?,
      read: map['read'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        data,
        read,
        createdAt,
      ];
}

// ==================== NOTIFICATION SETTINGS ====================

class NotificationSettings extends Equatable {
  final String userId;
  final bool enabled;
  final bool urgentReport;
  final bool reportAssigned;
  final bool reportCompleted;
  final bool reportOverdue;
  final bool reportRejected;
  final bool newComment;
  final bool sound;
  final bool vibration;

  const NotificationSettings({
    required this.userId,
    this.enabled = true,
    this.urgentReport = true,
    this.reportAssigned = true,
    this.reportCompleted = true,
    this.reportOverdue = true,
    this.reportRejected = true,
    this.newComment = true,
    this.sound = true,
    this.vibration = true,
  });

  factory NotificationSettings.fromMap(String userId, Map<String, dynamic> map) {
    return NotificationSettings(
      userId: userId,
      enabled: map['enabled'] as bool? ?? true,
      urgentReport: map['urgentReport'] as bool? ?? true,
      reportAssigned: map['reportAssigned'] as bool? ?? true,
      reportCompleted: map['reportCompleted'] as bool? ?? true,
      reportOverdue: map['reportOverdue'] as bool? ?? true,
      reportRejected: map['reportRejected'] as bool? ?? true,
      newComment: map['newComment'] as bool? ?? true,
      sound: map['sound'] as bool? ?? true,
      vibration: map['vibration'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'urgentReport': urgentReport,
      'reportAssigned': reportAssigned,
      'reportCompleted': reportCompleted,
      'reportOverdue': reportOverdue,
      'reportRejected': reportRejected,
      'newComment': newComment,
      'sound': sound,
      'vibration': vibration,
    };
  }

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

  NotificationSettings copyWith({
    String? userId,
    bool? enabled,
    bool? urgentReport,
    bool? reportAssigned,
    bool? reportCompleted,
    bool? reportOverdue,
    bool? reportRejected,
    bool? newComment,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      urgentReport: urgentReport ?? this.urgentReport,
      reportAssigned: reportAssigned ?? this.reportAssigned,
      reportCompleted: reportCompleted ?? this.reportCompleted,
      reportOverdue: reportOverdue ?? this.reportOverdue,
      reportRejected: reportRejected ?? this.reportRejected,
      newComment: newComment ?? this.newComment,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        enabled,
        urgentReport,
        reportAssigned,
        reportCompleted,
        reportOverdue,
        reportRejected,
        newComment,
        sound,
        vibration,
      ];
}
