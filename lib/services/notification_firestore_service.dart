// lib/services/notification_firestore_service.dart
// Firestore CRUD operations for notifications

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import 'notification_local_service.dart';

class NotificationFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationLocalService _localNotifications = NotificationLocalService();

  /// Create notification in Firestore
  Future<void> createNotification(AppNotification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Stream notifications for a user
  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Get unread count
  Stream<int> streamUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  /// Mark all as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }

  /// Send notification to user
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: _firestore.collection('notifications').doc().id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await createNotification(notification);

    // Show local notification
    await _localNotifications.showNotification(notification);
  }

  /// Get notification settings
  Future<NotificationSettings> getSettings(String userId) async {
    try {
      final doc = await _firestore
          .collection('notificationSettings')
          .doc(userId)
          .get();

      if (doc.exists) {
        return NotificationSettings.fromMap(userId, doc.data()!);
      }
      return NotificationSettings(userId: userId);
    } catch (e) {
      return NotificationSettings(userId: userId);
    }
  }

  /// Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      await _firestore
          .collection('notificationSettings')
          .doc(settings.userId)
          .set(settings.toMap());
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Stream notification settings
  Stream<NotificationSettings> streamSettings(String userId) {
    return _firestore
        .collection('notificationSettings')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return NotificationSettings.fromMap(userId, doc.data()!);
      }
      return NotificationSettings(userId: userId);
    });
  }
}
