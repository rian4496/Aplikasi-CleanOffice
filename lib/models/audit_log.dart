// lib/models/audit_log.dart
// Audit Log Model for SIM-ASET ERP

import 'package:freezed_annotation/freezed_annotation.dart';

/// Enum for audit actions
class AuditAction {
  static const String login = 'LOGIN';
  static const String logout = 'LOGOUT';
  static const String create = 'CREATE';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
  static const String approve = 'APPROVE';
  static const String reject = 'REJECT';
  static const String export = 'EXPORT';
  static const String view = 'VIEW';
  
  static String getDisplayName(String action) {
    switch (action) {
      case login: return 'Login';
      case logout: return 'Logout';
      case create: return 'Buat Baru';
      case update: return 'Update';
      case delete: return 'Hapus';
      case approve: return 'Setujui';
      case reject: return 'Tolak';
      case export: return 'Export';
      case view: return 'Lihat';
      default: return action;
    }
  }
}

/// Enum for entity types
class AuditEntityType {
  static const String user = 'user';
  static const String asset = 'asset';
  static const String procurement = 'procurement';
  static const String loan = 'loan';
  static const String disposal = 'disposal';
  static const String ticket = 'ticket';
  static const String report = 'report';
  static const String session = 'session';
  
  static String getDisplayName(String? type) {
    switch (type) {
      case user: return 'User';
      case asset: return 'Aset';
      case procurement: return 'Pengadaan';
      case loan: return 'Peminjaman';
      case disposal: return 'Penghapusan';
      case ticket: return 'Tiket';
      case report: return 'Laporan';
      case session: return 'Sesi';
      default: return type ?? '-';
    }
  }
}

class AuditLog {
  final String id;
  final DateTime createdAt;
  final String? userId;
  final String? userEmail;
  final String action;
  final String? entityType;
  final String? entityId;
  final String? description;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final Map<String, dynamic>? metadata;

  AuditLog({
    required this.id,
    required this.createdAt,
    this.userId,
    this.userEmail,
    required this.action,
    this.entityType,
    this.entityId,
    this.description,
    this.oldData,
    this.newData,
    this.metadata,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
      action: json['action'] as String,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      description: json['description'] as String?,
      oldData: json['old_data'] as Map<String, dynamic>?,
      newData: json['new_data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'user_email': userEmail,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'old_data': oldData,
      'new_data': newData,
      'metadata': metadata,
    };
  }

  /// Helper getters
  String get actionDisplayName => AuditAction.getDisplayName(action);
  String get entityTypeDisplayName => AuditEntityType.getDisplayName(entityType);
  
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
