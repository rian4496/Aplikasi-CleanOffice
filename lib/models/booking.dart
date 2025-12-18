// lib/models/booking.dart
// SIM-ASET: Booking Model

import 'package:flutter/material.dart';

// ==================== BOOKING STATUS ENUM ====================
enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed;

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'approved':
        return BookingStatus.approved;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  String toDatabase() => name;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Menunggu';
      case BookingStatus.approved:
        return 'Disetujui';
      case BookingStatus.rejected:
        return 'Ditolak';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.completed:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.approved:
        return Icons.check_circle;
      case BookingStatus.rejected:
        return Icons.cancel;
      case BookingStatus.cancelled:
        return Icons.block;
      case BookingStatus.completed:
        return Icons.done_all;
    }
  }
}

// ==================== BOOKING MODEL ====================
class Booking {
  final String id;
  final String assetId;
  final String? assetName; // Joined
  final String userId;
  final String? userName; // Joined
  final String title;
  final String? purpose;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final String? approvedBy;
  final String? approvedByName; // Joined
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.assetId,
    this.assetName,
    required this.userId,
    this.userName,
    required this.title,
    this.purpose,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromSupabase(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      assetId: map['asset_id'] as String,
      assetName: map['assets']?['name'] as String?,
      userId: map['user_id'] as String,
      userName: map['user']?['display_name'] as String?,
      title: map['title'] as String,
      purpose: map['purpose'] as String?,
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      status: BookingStatus.fromString(map['status'] ?? 'pending'),
      approvedBy: map['approved_by'] as String?,
      approvedByName: map['approver']?['display_name'] as String?,
      approvedAt: map['approved_at'] != null 
          ? DateTime.parse(map['approved_at']) 
          : null,
      rejectionReason: map['rejection_reason'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'asset_id': assetId,
      'user_id': userId,
      'title': title,
      'purpose': purpose,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toDatabase(),
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'notes': notes,
    };
  }

  // Get duration
  Duration get duration => endTime.difference(startTime);

  // Get duration in hours
  double get durationHours => duration.inMinutes / 60;

  // Is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == BookingStatus.approved && 
           now.isAfter(startTime) && 
           now.isBefore(endTime);
  }

  // Is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return status == BookingStatus.approved && now.isBefore(startTime);
  }

  // Formatted time range
  String get timeRange {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }
}

