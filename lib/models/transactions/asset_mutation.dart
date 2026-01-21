// lib/models/transactions/asset_mutation.dart
// Model for Asset Mutation (Mutasi Aset Tetap)
// Maps to 'asset_mutations' table (formerly 'inventory_mutations')

import 'package:flutter/material.dart';

enum MutationStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get toDatabase => name;

  String get displayName {
    switch (this) {
      case MutationStatus.pending:
        return 'Menunggu Persetujuan';
      case MutationStatus.approved:
        return 'Disetujui';
      case MutationStatus.rejected:
        return 'Ditolak';
      case MutationStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case MutationStatus.pending:
        return Colors.orange;
      case MutationStatus.approved:
        return Colors.green;
      case MutationStatus.rejected:
        return Colors.red;
      case MutationStatus.cancelled:
        return Colors.grey;
    }
  }

  static MutationStatus fromString(String value) {
    return MutationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MutationStatus.pending,
    );
  }
}

class AssetMutation {
  final String id;
  final String mutationCode;
  final String assetId;
  final String? assetName; // Joined
  final String? assetCode; // Joined
  final String? originLocationId;
  final String? originLocationName; // Joined
  final String? destinationLocationId;
  final String? destinationLocationName; // Joined
  final String? requesterId;
  final String? requesterName; // Joined
  final String? approverId;
  final String? approverName; // Joined
  final MutationStatus status;
  final String? reason;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AssetMutation({
    required this.id,
    required this.mutationCode,
    required this.assetId,
    this.assetName,
    this.assetCode,
    this.originLocationId,
    this.originLocationName,
    this.destinationLocationId,
    this.destinationLocationName,
    this.requesterId,
    this.requesterName,
    this.approverId,
    this.approverName,
    required this.status,
    this.reason,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory AssetMutation.fromJson(Map<String, dynamic> json) {
    return AssetMutation(
      id: json['id']?.toString() ?? '',
      mutationCode: json['mutation_code'] ?? '-',
      assetId: json['asset_id']?.toString() ?? '',
      assetName: json['assets']?['name'],
      assetCode: json['assets']?['asset_code'],
      originLocationId: json['origin_location_id']?.toString(),
      originLocationName: json['origin_location']?['name'],
      destinationLocationId: json['destination_location_id']?.toString(),
      destinationLocationName: json['destination_location']?['name'],
      requesterId: json['requester_id']?.toString(),
      requesterName: json['requester']?['display_name'] ?? json['requester']?['full_name'], 
      approverId: json['approver_id']?.toString(),
      approverName: json['approver']?['display_name'] ?? json['approver']?['full_name'],
      status: MutationStatus.fromString(json['status'] ?? 'pending'),
      reason: json['reason'],
      rejectionReason: json['rejection_reason'], // or 'notes' if we reuse column
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'mutation_code': mutationCode,
      'asset_id': assetId,
      'origin_location_id': originLocationId,
      'destination_location_id': destinationLocationId,
      'requester_id': requesterId,
      'status': status.toDatabase,
      'reason': reason,
      // 'created_at': handled by default
    };
  }

  AssetMutation copyWith({
    String? id,
    String? mutationCode,
    String? assetId,
    String? originLocationId,
    String? destinationLocationId,
    String? requesterId,
    String? approverId,
    MutationStatus? status,
    String? reason,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetMutation(
      id: id ?? this.id,
      mutationCode: mutationCode ?? this.mutationCode,
      assetId: assetId ?? this.assetId,
      assetName: this.assetName,
      assetCode: this.assetCode,
      originLocationId: originLocationId ?? this.originLocationId,
      originLocationName: this.originLocationName,
      destinationLocationId: destinationLocationId ?? this.destinationLocationId,
      destinationLocationName: this.destinationLocationName,
      requesterId: requesterId ?? this.requesterId,
      requesterName: this.requesterName,
      approverId: approverId ?? this.approverId,
      approverName: this.approverName,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
