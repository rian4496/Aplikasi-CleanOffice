// lib/services/notification_service.dart
// ✅ COMPLETE Notification Service for In-App Notifications

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
      debugPrint('Error getting admin IDs: $e');
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

  /// Send notification to multiple recipients
  Future<void> _sendToMultipleRecipients({
    required List<String> recipientIds,
    required String type,
    required String title,
    required String message,
    String? reportId,
    String? imageUrl,
    bool isUrgent = false,
    String? status,
    Map<String, dynamic>? data,
  }) async {
    for (final recipientId in recipientIds) {
      await _createNotification(
        recipientId: recipientId,
        type: type,
        title: title,
        message: message,
        reportId: reportId,
        imageUrl: imageUrl,
        isUrgent: isUrgent,
        status: status,
        data: data,
      );
    }
  }

  // ==================== NOTIFICATION TRIGGERS ====================

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

  // ==================== UTILITY METHODS ====================

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
}