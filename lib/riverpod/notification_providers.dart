// lib/providers/riverpod/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './auth_providers.dart';
import '../../models/notification_model.dart';

// ==================== NOTIFICATION PROVIDERS ====================

/// Provider untuk user notifications (filtered by recipientId)
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('notifications')
      .where('recipientId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(50) // Limit to 50 most recent
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return NotificationModel.fromFirestore(doc);
        }).toList();
      });
});

/// Provider untuk unread count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  
  return notificationsAsync.when(
    data: (notifications) {
      return notifications.where((n) => !n.isRead).length;
    },
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

// ==================== NOTIFICATION ACTIONS ====================

/// Provider untuk notification actions
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});

class NotificationActions {
  final Ref ref;

  NotificationActions(this.ref);

  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Create notification
  Future<void> createNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    String? reportId,
    String? imageUrl,
    bool? isUrgent,
    String? status,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('notifications').add({
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'message': message,
      'reportId': reportId,
      'imageUrl': imageUrl,
      'isUrgent': isUrgent ?? false,
      'status': status,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
