// lib/services/notification_service.dart
// ✅ IMPROVED Notification Service - Added Cleaning Request Support + Enhancements

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/report.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== HELPER METHODS ====================

  /// Get all admin user IDs
  Future<List<String>> _getAdminIds() async {
    try {
      debugPrint('🔍 Getting admin IDs...');
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final adminIds = snapshot.docs.map((doc) => doc.id).toList();
      debugPrint('✅ Found ${adminIds.length} admins: $adminIds');
      
      return adminIds;
    } catch (e) {
      debugPrint('❌ Error getting admin IDs: $e');
      return [];
    }
  }

  /// ✨ NEW: Get all cleaner user IDs
  Future<List<String>> _getCleanerIds() async {
    try {
      debugPrint('🔍 Getting cleaner IDs...');
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'cleaner')
          .get();

      final cleanerIds = snapshot.docs.map((doc) => doc.id).toList();
      debugPrint('✅ Found ${cleanerIds.length} cleaners: $cleanerIds');
      
      return cleanerIds;
    } catch (e) {
      debugPrint('❌ Error getting cleaner IDs: $e');
      return [];
    }
  }

  /// ✨ NEW: Get all staff IDs (admins + cleaners)
  Future<List<String>> _getStaffIds() async {
    try {
      final adminIds = await _getAdminIds();
      final cleanerIds = await _getCleanerIds();
      final staffIds = [...adminIds, ...cleanerIds];
      
      debugPrint('✅ Found ${staffIds.length} staff members (${adminIds.length} admins + ${cleanerIds.length} cleaners)');
      return staffIds;
    } catch (e) {
      debugPrint('❌ Error getting staff IDs: $e');
      return [];
    }
  }

  /// Create notification in Firestore
  Future<void> _createNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    String? reportId,
    String? requestId, // ✨ NEW: for cleaning requests
    String? imageUrl,
    bool isUrgent = false,
    String? status,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipientId': recipientId,
        'type': type,
        'title': title,
        'message': message,
        'reportId': reportId,
        'requestId': requestId, // ✨ NEW
        'imageUrl': imageUrl,
        'isUrgent': isUrgent,
        'status': status,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Notification created for user: $recipientId');
    } catch (e) {
      debugPrint('❌ Error creating notification: $e');
    }
  }

  /// ✨ IMPROVED: Send notification to multiple recipients with batch write
  Future<void> _sendToMultipleRecipients({
    required List<String> recipientIds,
    required String type,
    required String title,
    required String message,
    String? reportId,
    String? requestId, // ✨ NEW
    String? imageUrl,
    bool isUrgent = false,
    String? status,
    Map<String, dynamic>? data,
  }) async {
    if (recipientIds.isEmpty) {
      debugPrint('⚠️ No recipients to send notification');
      return;
    }

    try {
      // ✨ IMPROVED: Use batch write for better performance
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      for (final recipientId in recipientIds) {
        final notificationRef = _firestore.collection('notifications').doc();
        
        batch.set(notificationRef, {
          'recipientId': recipientId,
          'type': type,
          'title': title,
          'message': message,
          'reportId': reportId,
          'requestId': requestId, // ✨ NEW
          'imageUrl': imageUrl,
          'isUrgent': isUrgent,
          'status': status,
          'data': data,
          'isRead': false,
          'createdAt': timestamp,
        });
      }

      await batch.commit();
      debugPrint('✅ Batch notification sent to ${recipientIds.length} recipients');
    } catch (e) {
      debugPrint('❌ Error sending batch notifications: $e');
      
      // ✨ IMPROVED: Fallback to individual sends if batch fails
      debugPrint('🔄 Attempting individual sends as fallback...');
      for (final recipientId in recipientIds) {
        await _createNotification(
          recipientId: recipientId,
          type: type,
          title: title,
          message: message,
          reportId: reportId,
          requestId: requestId,
          imageUrl: imageUrl,
          isUrgent: isUrgent,
          status: status,
          data: data,
        );
      }
    }
  }

  // ==================== REPORT NOTIFICATIONS ====================

  /// 1. Notify when report is created (to admins)
  Future<void> notifyReportCreated(Report report) async {
    try {
      debugPrint('📨 Creating notification for report: ${report.id}');
      final adminIds = await _getAdminIds();
      debugPrint('📤 Sending to ${adminIds.length} admins');
      
      await _sendToMultipleRecipients(
        recipientIds: adminIds,
        type: 'report_created',
        title: 'Laporan Baru',
        message: '${report.userName} membuat laporan di ${report.location}',
        reportId: report.id,
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
        status: report.status.toFirestore(),
        data: {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
        },
      );
      
      debugPrint('✅ Report created notification sent to ${adminIds.length} admins');
    } catch (e) {
      debugPrint('❌ Error sending report created notification: $e');
    }
  }

  /// 2. Notify when report is urgent (to admins with priority)
  Future<void> notifyUrgentReport(Report report) async {
    try {
      final adminIds = await _getAdminIds();
      
      await _sendToMultipleRecipients(
        recipientIds: adminIds,
        type: 'report_urgent',
        title: '⚠️ LAPORAN URGENT',
        message: 'Laporan URGENT di ${report.location} perlu segera ditangani!',
        reportId: report.id,
        imageUrl: report.imageUrl,
        isUrgent: true,
        status: report.status.toFirestore(),
        data: {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
          'description': report.description,
        },
      );
      
      debugPrint('✅ Urgent notification sent to ${adminIds.length} admins');
    } catch (e) {
      debugPrint('❌ Error sending urgent notification: $e');
    }
  }

  /// 3. Notify when report is assigned to cleaner (to both employee & cleaner)
  Future<void> notifyReportAssigned({
    required Report report,
    required String cleanerId,
    required String cleanerName,
  }) async {
    try {
      // Notify employee that their report is assigned
      await _createNotification(
        recipientId: report.userId,
        type: 'report_assigned',
        title: 'Laporan Ditugaskan',
        message: 'Laporan Anda di ${report.location} telah ditugaskan ke $cleanerName',
        reportId: report.id,
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
        status: ReportStatus.assigned.toFirestore(),
        data: {
          'cleanerId': cleanerId,
          'cleanerName': cleanerName,
          'location': report.location,
        },
      );
      
      // Notify cleaner about new assignment
      await _createNotification(
        recipientId: cleanerId,
        type: 'report_assigned',
        title: report.isUrgent ? '⚠️ Tugas Baru (URGENT)' : 'Tugas Baru',
        message: 'Anda ditugaskan untuk menangani laporan di ${report.location}',
        reportId: report.id,
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
        status: ReportStatus.assigned.toFirestore(),
        data: {
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
          'description': report.description,
        },
      );
      
      debugPrint('✅ Assignment notification sent to employee and cleaner');
    } catch (e) {
      debugPrint('❌ Error sending assignment notification: $e');
    }
  }

  /// 4. Notify when cleaner starts working (to employee)
  Future<void> notifyReportInProgress({
    required Report report,
  }) async {
    try {
      final cleanerName = report.cleanerName ?? 'Petugas';
      
      await _createNotification(
        recipientId: report.userId,
        type: 'report_in_progress',
        title: 'Laporan Sedang Dikerjakan',
        message: '$cleanerName sedang mengerjakan laporan Anda di ${report.location}',
        reportId: report.id,
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
        status: ReportStatus.inProgress.toFirestore(),
        data: {
          'cleanerId': report.cleanerId,
          'cleanerName': cleanerName,
          'location': report.location,
        },
      );
      
      debugPrint('✅ In-progress notification sent to user: ${report.userName}');
    } catch (e) {
      debugPrint('❌ Error sending in-progress notification: $e');
    }
  }

  /// 5. Notify when report is completed (to employee & admins)
  Future<void> notifyReportCompleted({
    required Report report,
    String? completionImageUrl,
  }) async {
    try {
      final cleanerName = report.cleanerName ?? 'Petugas';
      
      // Notify employee
      await _createNotification(
        recipientId: report.userId,
        type: 'report_completed',
        title: 'Laporan Selesai ✓',
        message: '$cleanerName telah menyelesaikan laporan di ${report.location}',
        reportId: report.id,
        imageUrl: completionImageUrl ?? report.imageUrl,
        status: ReportStatus.completed.toFirestore(),
        data: {
          'cleanerId': report.cleanerId,
          'cleanerName': cleanerName,
          'location': report.location,
          'completionImageUrl': completionImageUrl,
        },
      );
      
      // Notify admins for verification
      final adminIds = await _getAdminIds();
      await _sendToMultipleRecipients(
        recipientIds: adminIds,
        type: 'report_completed',
        title: 'Laporan Perlu Verifikasi',
        message: 'Laporan di ${report.location} selesai dikerjakan oleh $cleanerName',
        reportId: report.id,
        imageUrl: completionImageUrl ?? report.imageUrl,
        status: ReportStatus.completed.toFirestore(),
        data: {
          'cleanerId': report.cleanerId,
          'cleanerName': cleanerName,
          'userId': report.userId,
          'userName': report.userName,
          'location': report.location,
        },
      );
      
      debugPrint('✅ Completion notification sent to user and ${adminIds.length} admins');
    } catch (e) {
      debugPrint('❌ Error sending completion notification: $e');
    }
  }

  /// 6. Notify when report is verified (to employee & cleaner)
  Future<void> notifyReportVerified({
    required Report report,
    required String verifiedBy,
    String? notes,
  }) async {
    try {
      // Notify employee
      await _createNotification(
        recipientId: report.userId,
        type: 'report_verified',
        title: 'Laporan Terverifikasi ✓',
        message: 'Laporan Anda di ${report.location} telah diverifikasi',
        reportId: report.id,
        imageUrl: report.imageUrl,
        status: ReportStatus.verified.toFirestore(),
        data: {
          'verifiedBy': verifiedBy,
          'verificationNotes': notes,
          'location': report.location,
        },
      );
      
      // Notify cleaner if assigned
      if (report.cleanerId != null) {
        await _createNotification(
          recipientId: report.cleanerId!,
          type: 'report_verified',
          title: 'Pekerjaan Terverifikasi ✓',
          message: 'Pekerjaan Anda di ${report.location} telah diverifikasi',
          reportId: report.id,
          imageUrl: report.imageUrl,
          status: ReportStatus.verified.toFirestore(),
          data: {
            'verifiedBy': verifiedBy,
            'verificationNotes': notes,
            'location': report.location,
          },
        );
      }
      
      debugPrint('✅ Verification notification sent');
    } catch (e) {
      debugPrint('❌ Error sending verification notification: $e');
    }
  }

  /// 7. Notify when report is rejected (to employee & cleaner)
  Future<void> notifyReportRejected({
    required Report report,
    required String rejectedBy,
    String? reason,
  }) async {
    try {
      // Notify employee
      await _createNotification(
        recipientId: report.userId,
        type: 'report_rejected',
        title: 'Laporan Ditolak',
        message: 'Laporan Anda di ${report.location} ditolak${reason != null ? ": $reason" : ""}',
        reportId: report.id,
        imageUrl: report.imageUrl,
        status: ReportStatus.rejected.toFirestore(),
        data: {
          'rejectedBy': rejectedBy,
          'reason': reason,
          'location': report.location,
        },
      );
      
      // Notify cleaner if assigned
      if (report.cleanerId != null) {
        await _createNotification(
          recipientId: report.cleanerId!,
          type: 'report_rejected',
          title: 'Pekerjaan Ditolak',
          message: 'Laporan di ${report.location} ditolak${reason != null ? ": $reason" : ""}',
          reportId: report.id,
          imageUrl: report.imageUrl,
          status: ReportStatus.rejected.toFirestore(),
          data: {
            'rejectedBy': rejectedBy,
            'reason': reason,
            'location': report.location,
          },
        );
      }
      
      debugPrint('✅ Rejection notification sent');
    } catch (e) {
      debugPrint('❌ Error sending rejection notification: $e');
    }
  }

  // ==================== ✨ NEW: CLEANING REQUEST NOTIFICATIONS ====================

  /// 8. ✨ NEW: Notify when cleaning request is created (to cleaners & admins)
  Future<void> notifyNewRequest({
    required String requestId,
    required String location,
    required bool isUrgent,
    String? description,
    String? imageUrl,
    DateTime? preferredDateTime,
  }) async {
    try {
      debugPrint('📨 Creating notification for cleaning request: $requestId');
      
      // Get all staff (cleaners + admins)
      final staffIds = await _getStaffIds();
      debugPrint('📤 Sending to ${staffIds.length} staff members');
      
      // Format preferred time if exists
      String timeInfo = '';
      if (preferredDateTime != null) {
        timeInfo = '\nWaktu diinginkan: ${preferredDateTime.day}/${preferredDateTime.month} ${preferredDateTime.hour}:${preferredDateTime.minute.toString().padLeft(2, '0')}';
      }
      
      await _sendToMultipleRecipients(
        recipientIds: staffIds,
        type: 'request_created',
        title: isUrgent ? '🚨 URGEN: Permintaan Layanan Baru' : '📋 Permintaan Layanan Baru',
        message: 'Permintaan layanan kebersihan di $location$timeInfo',
        requestId: requestId,
        imageUrl: imageUrl,
        isUrgent: isUrgent,
        status: 'pending',
        data: {
          'location': location,
          'description': description,
          'preferredDateTime': preferredDateTime?.toIso8601String(),
          'isUrgent': isUrgent,
        },
      );
      
      debugPrint('✅ Cleaning request notification sent to ${staffIds.length} staff members');
    } catch (e) {
      debugPrint('❌ Error sending cleaning request notification: $e');
      rethrow; // Re-throw to handle in create_request_screen
    }
  }

  /// 9. ✨ NEW: Notify when request is assigned (to requester & cleaner)
  Future<void> notifyRequestAssigned({
    required String requestId,
    required String requesterId,
    required String cleanerId,
    required String cleanerName,
    required String location,
  }) async {
    try {
      // Notify requester
      await _createNotification(
        recipientId: requesterId,
        type: 'request_assigned',
        title: 'Permintaan Ditugaskan',
        message: 'Permintaan Anda di $location telah ditugaskan ke $cleanerName',
        requestId: requestId,
        status: 'assigned',
        data: {
          'cleanerId': cleanerId,
          'cleanerName': cleanerName,
          'location': location,
        },
      );
      
      // Notify cleaner
      await _createNotification(
        recipientId: cleanerId,
        type: 'request_assigned',
        title: 'Tugas Baru',
        message: 'Anda ditugaskan untuk permintaan layanan di $location',
        requestId: requestId,
        status: 'assigned',
        data: {
          'requesterId': requesterId,
          'location': location,
        },
      );
      
      debugPrint('✅ Request assignment notification sent');
    } catch (e) {
      debugPrint('❌ Error sending request assignment notification: $e');
    }
  }

  /// 10. ✨ NEW: Notify when request is completed (to requester)
  Future<void> notifyRequestCompleted({
    required String requestId,
    required String requesterId,
    required String location,
    required String cleanerName,
    String? completionImageUrl,
  }) async {
    try {
      await _createNotification(
        recipientId: requesterId,
        type: 'request_completed',
        title: 'Permintaan Selesai ✓',
        message: '$cleanerName telah menyelesaikan permintaan Anda di $location',
        requestId: requestId,
        imageUrl: completionImageUrl,
        status: 'completed',
        data: {
          'cleanerName': cleanerName,
          'location': location,
          'completionImageUrl': completionImageUrl,
        },
      );
      
      debugPrint('✅ Request completion notification sent');
    } catch (e) {
      debugPrint('❌ Error sending request completion notification: $e');
    }
  }

  // ==================== ✨ NEW: ENHANCED UTILITY METHODS ====================

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      debugPrint('✅ Notification marked as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
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
      
      debugPrint('✅ All notifications marked as read for user: $userId');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete single notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      debugPrint('✅ Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      debugPrint('✅ All notifications deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting notifications: $e');
    }
  }

  /// Get unread notification count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// ✨ NEW: Get unread count stream (real-time updates)
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// ✨ NEW: Get notifications stream for a user (real-time updates)
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to recent 50 notifications
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  }
}