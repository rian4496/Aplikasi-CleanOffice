// lib/models/maintenance_log.dart
// SIM-ASET: Maintenance Log Model

import 'package:flutter/material.dart';

// ==================== MAINTENANCE TYPE ENUM ====================
enum MaintenanceType {
  preventive,
  corrective,
  scheduled,
  repair,
  inspection,
  upgrade;

  static MaintenanceType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'preventive':
        return MaintenanceType.preventive;
      case 'corrective':
        return MaintenanceType.corrective;
      case 'scheduled':
        return MaintenanceType.scheduled;
      case 'repair':
        return MaintenanceType.repair;
      case 'inspection':
        return MaintenanceType.inspection;
      case 'upgrade':
        return MaintenanceType.upgrade;
      default:
        return MaintenanceType.corrective;
    }
  }

  String toDatabase() => name;

  String get displayName {
    switch (this) {
      case MaintenanceType.preventive:
        return 'Preventif';
      case MaintenanceType.corrective:
        return 'Perbaikan';
      case MaintenanceType.scheduled:
        return 'Terjadwal';
      case MaintenanceType.repair:
        return 'Repair';
      case MaintenanceType.inspection:
        return 'Inspeksi';
      case MaintenanceType.upgrade:
        return 'Upgrade';
    }
  }

  IconData get icon {
    switch (this) {
      case MaintenanceType.preventive:
        return Icons.schedule;
      case MaintenanceType.corrective:
        return Icons.build;
      case MaintenanceType.scheduled:
        return Icons.calendar_today;
      case MaintenanceType.repair:
        return Icons.handyman;
      case MaintenanceType.inspection:
        return Icons.search;
      case MaintenanceType.upgrade:
        return Icons.upgrade;
    }
  }

  Color get color {
    switch (this) {
      case MaintenanceType.preventive:
        return Colors.blue;
      case MaintenanceType.corrective:
        return Colors.orange;
      case MaintenanceType.scheduled:
        return Colors.teal;
      case MaintenanceType.repair:
        return Colors.deepOrange;
      case MaintenanceType.inspection:
        return Colors.cyan;
      case MaintenanceType.upgrade:
        return Colors.purple;
    }
  }
}

// ==================== MAINTENANCE STATUS ENUM ====================
enum MaintenanceStatus {
  pending,
  approved,
  inProgress,
  completed,
  rejected,
  cancelled;

  static MaintenanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MaintenanceStatus.pending;
      case 'approved':
        return MaintenanceStatus.approved;
      case 'in_progress':
      case 'inprogress':
        return MaintenanceStatus.inProgress;
      case 'completed':
        return MaintenanceStatus.completed;
      case 'rejected':
        return MaintenanceStatus.rejected;
      case 'cancelled':
        return MaintenanceStatus.cancelled;
      default:
        return MaintenanceStatus.pending;
    }
  }

  String toDatabase() {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'pending';
      case MaintenanceStatus.approved:
        return 'approved';
      case MaintenanceStatus.inProgress:
        return 'in_progress';
      case MaintenanceStatus.completed:
        return 'completed';
      case MaintenanceStatus.rejected:
        return 'rejected';
      case MaintenanceStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Menunggu';
      case MaintenanceStatus.approved:
        return 'Disetujui';
      case MaintenanceStatus.inProgress:
        return 'Dikerjakan';
      case MaintenanceStatus.completed:
        return 'Selesai';
      case MaintenanceStatus.rejected:
        return 'Ditolak';
      case MaintenanceStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case MaintenanceStatus.pending:
        return Colors.orange;
      case MaintenanceStatus.approved:
        return Colors.blue;
      case MaintenanceStatus.inProgress:
        return Colors.indigo;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.rejected:
        return Colors.red;
      case MaintenanceStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case MaintenanceStatus.pending:
        return Icons.hourglass_empty;
      case MaintenanceStatus.approved:
        return Icons.check_circle_outline;
      case MaintenanceStatus.inProgress:
        return Icons.autorenew;
      case MaintenanceStatus.completed:
        return Icons.check_circle;
      case MaintenanceStatus.rejected:
        return Icons.cancel;
      case MaintenanceStatus.cancelled:
        return Icons.block;
    }
  }
}

// ==================== PRIORITY ENUM ====================
enum MaintenancePriority {
  low,
  normal,
  high,
  urgent;

  static MaintenancePriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return MaintenancePriority.low;
      case 'normal':
        return MaintenancePriority.normal;
      case 'high':
        return MaintenancePriority.high;
      case 'urgent':
        return MaintenancePriority.urgent;
      default:
        return MaintenancePriority.normal;
    }
  }

  String toDatabase() => name;

  String get displayName {
    switch (this) {
      case MaintenancePriority.low:
        return 'Rendah';
      case MaintenancePriority.normal:
        return 'Normal';
      case MaintenancePriority.high:
        return 'Tinggi';
      case MaintenancePriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case MaintenancePriority.low:
        return Colors.grey;
      case MaintenancePriority.normal:
        return Colors.blue;
      case MaintenancePriority.high:
        return Colors.orange;
      case MaintenancePriority.urgent:
        return Colors.red;
    }
  }
}

// ==================== MAINTENANCE LOG MODEL ====================
class MaintenanceLog {
  final String id;
  final String assetId;
  final String? assetName; // Joined
  final String? technicianId;
  final String? technicianName; // Joined
  final MaintenanceType type;
  final String title;
  final String? description;
  final MaintenanceStatus status;
  final MaintenancePriority priority;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final double? cost;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceLog({
    required this.id,
    required this.assetId,
    this.assetName,
    this.technicianId,
    this.technicianName,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.cost,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceLog.fromSupabase(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'] as String,
      assetId: map['asset_id'] as String,
      assetName: map['assets']?['name'] as String?,
      technicianId: map['technician_id'] as String?,
      technicianName: map['technician']?['display_name'] as String?,
      type: MaintenanceType.fromString(map['type'] ?? 'repair'),
      title: map['title'] as String,
      description: map['description'] as String?,
      status: MaintenanceStatus.fromString(map['status'] ?? 'pending'),
      priority: MaintenancePriority.fromString(map['priority'] ?? 'normal'),
      scheduledAt: map['scheduled_at'] != null 
          ? DateTime.parse(map['scheduled_at']) 
          : null,
      startedAt: map['started_at'] != null 
          ? DateTime.parse(map['started_at']) 
          : null,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      notes: map['notes'] as String?,
      cost: (map['cost'] as num?)?.toDouble(),
      beforeImageUrl: map['before_image_url'] as String?,
      afterImageUrl: map['after_image_url'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'asset_id': assetId,
      'technician_id': technicianId,
      'type': type.toDatabase(),
      'title': title,
      'description': description,
      'status': status.toDatabase(),
      'priority': priority.toDatabase(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'cost': cost,
      'before_image_url': beforeImageUrl,
      'after_image_url': afterImageUrl,
      'created_by': createdBy,
    };
  }

  // Get duration in minutes
  int? get durationMinutes {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inMinutes;
  }

  // Check if request is urgent
  bool get isUrgent => priority == MaintenancePriority.urgent || priority == MaintenancePriority.high;

  // Alias getters for screen compatibility
  DateTime? get scheduledDate => scheduledAt;
  DateTime? get completedDate => completedAt;
  String? get assignedToName => technicianName;

  // copyWith method
  MaintenanceLog copyWith({
    String? id,
    String? assetId,
    String? assetName,
    String? technicianId,
    String? technicianName,
    MaintenanceType? type,
    String? title,
    String? descriptionValue,
    MaintenanceStatus? status,
    MaintenancePriority? priority,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    double? cost,
    String? beforeImageUrl,
    String? afterImageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceLog(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: descriptionValue ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

