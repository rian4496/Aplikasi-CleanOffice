// lib/services/notification_helper.dart - FIXED

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class NotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create notification when employee creates a new report
  static Future<void> notifyReportCreated({
    required Report report,
    required List<String> adminIds,
  }) async {
    final batch = _firestore.batch();

    for (final adminId in adminIds) {
      final notificationRef = _firestore.collection('notifications').doc();
      
      batch.set(notificationRef, {
        'recipientId': adminId,
        'type': 'report_created',
        'title': 'Laporan Baru Masuk',
        'message': 'Laporan baru dari ${report.userName} untuk "${report.location}"',
        'reportId': report.id,
        'imageUrl': report.imageUrl,
        'isUrgent': report.isUrgent,
        'status': report.status.toFirestore(),
        'data': {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Notify employee when their report is assigned to a cleaner
  static Future<void> notifyReportAssigned({
    required Report report,
    required String cleanerName,
  }) async {
    await _firestore.collection('notifications').add({
      'recipientId': report.userId,
      'type': 'report_assigned',
      'title': 'Laporan Ditugaskan',
      'message': 'Laporan Anda untuk "${report.location}" telah ditugaskan ke $cleanerName',
      'reportId': report.id,
      'imageUrl': report.imageUrl,
      'isUrgent': report.isUrgent,
      'status': report.status.toFirestore(),
      'data': {
        'cleanerId': report.cleanerId,
        'cleanerName': cleanerName,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also notify cleaner
    if (report.cleanerId != null) {
      await _firestore.collection('notifications').add({
        'recipientId': report.cleanerId!,
        'type': 'report_assigned',
        'title': report.isUrgent ? '⚠️ Tugas Baru (URGEN)' : 'Tugas Baru',
        'message': 'Anda ditugaskan untuk membersihkan "${report.location}"',
        'reportId': report.id,
        'imageUrl': report.imageUrl,
        'isUrgent': report.isUrgent,
        'status': report.status.toFirestore(),
        'data': {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Notify when cleaner starts working on a report
  static Future<void> notifyReportInProgress({
    required Report report,
  }) async {
    await _firestore.collection('notifications').add({
      'recipientId': report.userId,
      'type': 'report_in_progress',
      'title': 'Laporan Sedang Dikerjakan',
      'message': '${report.cleanerName ?? "Petugas"} sedang mengerjakan laporan Anda untuk "${report.location}"',
      'reportId': report.id,
      'imageUrl': report.imageUrl,
      'isUrgent': report.isUrgent,
      'status': report.status.toFirestore(),
      'data': {
        'cleanerId': report.cleanerId,
        'cleanerName': report.cleanerName,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Notify when report is completed
  static Future<void> notifyReportCompleted({
    required Report report,
    required List<String> adminIds,
  }) async {
    final batch = _firestore.batch();

    // Notify employee
    final employeeNotificationRef = _firestore.collection('notifications').doc();
    batch.set(employeeNotificationRef, {
      'recipientId': report.userId,
      'type': 'report_completed',
      'title': 'Laporan Selesai',
      'message': 'Laporan untuk "${report.location}" telah diselesaikan oleh ${report.cleanerName ?? "petugas"}',
      'reportId': report.id,
      'imageUrl': report.imageUrl,
      'isUrgent': report.isUrgent,
      'status': report.status.toFirestore(),
      'data': {
        'cleanerId': report.cleanerId,
        'cleanerName': report.cleanerName,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify admins
    for (final adminId in adminIds) {
      final adminNotificationRef = _firestore.collection('notifications').doc();
      batch.set(adminNotificationRef, {
        'recipientId': adminId,
        'type': 'report_completed',
        'title': 'Laporan Selesai - Perlu Verifikasi',
        'message': 'Laporan untuk "${report.location}" telah diselesaikan dan menunggu verifikasi',
        'reportId': report.id,
        'imageUrl': report.imageUrl,
        'isUrgent': report.isUrgent,
        'status': report.status.toFirestore(),
        'data': {
          'userId': report.userId,
          'userName': report.userName,
          'cleanerId': report.cleanerId,
          'cleanerName': report.cleanerName,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Notify when admin verifies a report
  static Future<void> notifyReportVerified({
    required Report report,
  }) async {
    final batch = _firestore.batch();

    // Notify employee
    final employeeNotificationRef = _firestore.collection('notifications').doc();
    batch.set(employeeNotificationRef, {
      'recipientId': report.userId,
      'type': 'report_verified',
      'title': 'Laporan Terverifikasi',
      'message': 'Laporan Anda untuk "${report.location}" telah diverifikasi',
      'reportId': report.id,
      'imageUrl': report.imageUrl,
      'isUrgent': report.isUrgent,
      'status': report.status.toFirestore(),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify cleaner
    if (report.cleanerId != null) {
      final cleanerNotificationRef = _firestore.collection('notifications').doc();
      batch.set(cleanerNotificationRef, {
        'recipientId': report.cleanerId!,
        'type': 'report_verified',
        'title': 'Pekerjaan Terverifikasi',
        'message': 'Pekerjaan Anda untuk "${report.location}" telah diverifikasi',
        'reportId': report.id,
        'imageUrl': report.imageUrl,
        'isUrgent': report.isUrgent,
        'status': report.status.toFirestore(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Notify when report is rejected
  static Future<void> notifyReportRejected({
    required Report report,
    required String reason,
  }) async {
    await _firestore.collection('notifications').add({
      'recipientId': report.userId,
      'type': 'report_rejected',
      'title': 'Laporan Ditolak',
      'message': 'Laporan Anda untuk "${report.location}" ditolak. Alasan: $reason',
      'reportId': report.id,
      'imageUrl': report.imageUrl,
      'isUrgent': report.isUrgent,
      'status': report.status.toFirestore(),
      'data': {
        'reason': reason,
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Notify urgent report to all admins
  static Future<void> notifyUrgentReport({
    required Report report,
    required List<String> adminIds,
  }) async {
    final batch = _firestore.batch();

    for (final adminId in adminIds) {
      final notificationRef = _firestore.collection('notifications').doc();
      
      batch.set(notificationRef, {
        'recipientId': adminId,
        'type': 'report_urgent',
        'title': '⚠️ LAPORAN URGEN',
        'message': 'Laporan urgen dari ${report.userName} untuk "${report.location}" membutuhkan perhatian segera!',
        'reportId': report.id,
        'imageUrl': report.imageUrl,
        'isUrgent': true,
        'status': report.status.toFirestore(),
        'data': {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Helper to get all admin user IDs
  static Future<List<String>> getAdminIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      // Return empty list if error
      return [];
    }
  }
}