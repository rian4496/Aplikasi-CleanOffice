// lib/models/notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String type; // 'report_created', 'report_assigned', 'report_completed', etc.
  final String title;
  final String message;
  final String? reportId;
  final String? imageUrl;
  final bool isUrgent;
  final String? status;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.reportId,
    this.imageUrl,
    this.isUrgent = false,
    this.status,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      type: data['type'] ?? 'general',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      reportId: data['reportId'],
      imageUrl: data['imageUrl'],
      isUrgent: data['isUrgent'] ?? false,
      status: data['status'],
      data: data['data'] as Map<String, dynamic>?,
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'message': message,
      'reportId': reportId,
      'imageUrl': imageUrl,
      'isUrgent': isUrgent,
      'status': status,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get icon based on type
  IconData get icon {
    switch (type) {
      case 'report_created':
        return Icons.add_circle_outline;
      case 'report_assigned':
        return Icons.assignment_ind;
      case 'report_in_progress':
        return Icons.pending_actions;
      case 'report_completed':
        return Icons.check_circle;
      case 'report_verified':
        return Icons.verified;
      case 'report_rejected':
        return Icons.cancel;
      case 'report_urgent':
        return Icons.priority_high;
      default:
        return Icons.notifications;
    }
  }

  /// Get icon color based on type
  Color get iconColor {
    switch (type) {
      case 'report_created':
        return const Color(0xFF2196F3); // Blue
      case 'report_assigned':
        return const Color(0xFF9C27B0); // Purple
      case 'report_in_progress':
        return const Color(0xFFFF9800); // Orange
      case 'report_completed':
        return const Color(0xFF4CAF50); // Green
      case 'report_verified':
        return const Color(0xFF00BCD4); // Cyan
      case 'report_rejected':
        return const Color(0xFFF44336); // Red
      case 'report_urgent':
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF607D8B); // Grey
    }
  }

  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    }
  }

  /// Copy with method
  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? type,
    String? title,
    String? message,
    String? reportId,
    String? imageUrl,
    bool? isUrgent,
    String? status,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      reportId: reportId ?? this.reportId,
      imageUrl: imageUrl ?? this.imageUrl,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}