// lib/services/inventory_notification_service.dart
// Service for creating low stock notifications

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/notification_model.dart';

class InventoryNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check inventory and create low stock notifications for admins
  Future<void> checkAndNotifyLowStock() async {
    try {
      // Get all low stock items
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .get();

      final lowStockItems = inventorySnapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.id, doc.data()))
          .where((item) =>
              item.status == StockStatus.lowStock ||
              item.status == StockStatus.outOfStock)
          .toList();

      if (lowStockItems.isEmpty) return;

      // Get all admin users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final adminIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      // Create notifications for each admin
      final now = DateTime.now();
      final batch = _firestore.batch();

      for (final adminId in adminIds) {
        // Check if notification already exists for today
        final existingNotif = await _firestore
            .collection('notifications')
            .where('recipientId', isEqualTo: adminId)
            .where('type', isEqualTo: 'low_stock_alert')
            .where('createdAt',
                isGreaterThan: DateTime(now.year, now.month, now.day).toIso8601String())
            .limit(1)
            .get();

        if (existingNotif.docs.isEmpty) {
          // Create new notification
          final notification = AppNotification(
            id: 'notif_${now.millisecondsSinceEpoch}_$adminId',
            userId: adminId,
            type: NotificationType.lowStockAlert,
            title: 'Peringatan Stok Rendah',
            message:
                '${lowStockItems.length} item memiliki stok rendah atau habis. Segera lakukan restok!',
            read: false,
            createdAt: now,
            data: {
              'lowStockCount': lowStockItems.length,
              'items': lowStockItems
                  .take(5)
                  .map((item) => {
                        'id': item.id,
                        'name': item.name,
                        'currentStock': item.currentStock,
                        'minStock': item.minStock,
                      })
                  .toList(),
            },
          );

          final docRef = _firestore
              .collection('notifications')
              .doc(notification.id);
          batch.set(docRef, notification.toMap());
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating low stock notifications: $e');
    }
  }

  /// Create notification for specific low stock item
  Future<void> notifyLowStockItem(InventoryItem item) async {
    if (item.status != StockStatus.lowStock &&
        item.status != StockStatus.outOfStock) {
      return;
    }

    try {
      // Get all admin users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final now = DateTime.now();
      final batch = _firestore.batch();

      for (final userDoc in usersSnapshot.docs) {
        final notification = AppNotification(
          id: 'notif_${now.millisecondsSinceEpoch}_${userDoc.id}',
          userId: userDoc.id,
          type: NotificationType.lowStockAlert,
          title: 'Stok ${item.name} Rendah',
          message:
              'Stok ${item.name} tersisa ${item.currentStock} ${item.unit}. Minimum: ${item.minStock} ${item.unit}',
          read: false,
          createdAt: now,
          data: {
            'itemId': item.id,
            'itemName': item.name,
            'currentStock': item.currentStock,
            'minStock': item.minStock,
            'unit': item.unit,
          },
        );

        final docRef = _firestore
            .collection('notifications')
            .doc(notification.id);
        batch.set(docRef, notification.toMap());
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating low stock notification for ${item.name}: $e');
    }
  }

  /// Create notification when item is out of stock
  Future<void> notifyOutOfStock(InventoryItem item) async {
    try {
      // Get all admin users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final now = DateTime.now();
      final batch = _firestore.batch();

      for (final userDoc in usersSnapshot.docs) {
        final notification = AppNotification(
          id: 'notif_${now.millisecondsSinceEpoch}_${userDoc.id}',
          userId: userDoc.id,
          type: NotificationType.lowStockAlert,
          title: '⚠️ ${item.name} Habis!',
          message:
              '${item.name} telah habis! Segera lakukan restok.',
          read: false,
          createdAt: now,
          data: {
            'itemId': item.id,
            'itemName': item.name,
            'currentStock': 0,
            'minStock': item.minStock,
            'unit': item.unit,
            'urgent': true,
          },
        );

        final docRef = _firestore
            .collection('notifications')
            .doc(notification.id);
        batch.set(docRef, notification.toMap());
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating out of stock notification for ${item.name}: $e');
    }
  }
}
