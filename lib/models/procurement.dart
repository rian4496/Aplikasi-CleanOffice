import 'package:flutter/material.dart';

enum ProcurementStatus {
  draft,
  submitted,
  approvedAdmin, // Disetujui Admin, lanjut ke Kasubbag
  approvedKasubbag, // Disetujui Kasubbag (Final)
  rejected,
  completed; // Barang sudah dibeli/diterima

  String get displayName {
    switch (this) {
      case ProcurementStatus.draft:
        return 'Draft';
      case ProcurementStatus.submitted:
        return 'Diajukan';
      case ProcurementStatus.approvedAdmin:
        return 'Verifikasi Admin';
      case ProcurementStatus.approvedKasubbag:
        return 'Disetujui';
      case ProcurementStatus.rejected:
        return 'Ditolak';
      case ProcurementStatus.completed:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case ProcurementStatus.draft:
        return Colors.grey;
      case ProcurementStatus.submitted:
        return Colors.blue;
      case ProcurementStatus.approvedAdmin:
        return Colors.orange;
      case ProcurementStatus.approvedKasubbag:
        return Colors.green;
      case ProcurementStatus.rejected:
        return Colors.red;
      case ProcurementStatus.completed:
        return Colors.teal;
    }
  }
}

class ProcurementItem {
  final String id;
  final String requestId;
  final String itemName;
  final String description;
  final int quantity;
  final double estimatedUnitPrice;
  final String unit; // e.g., 'Unit', 'Pcs'
  
  // Computed
  double get estimatedTotalPrice => quantity * estimatedUnitPrice;

  const ProcurementItem({
    required this.id,
    required this.requestId,
    required this.itemName,
    required this.description,
    required this.quantity,
    required this.estimatedUnitPrice,
    required this.unit,
  });

  factory ProcurementItem.fromSupabase(Map<String, dynamic> map) {
    return ProcurementItem(
      id: map['id'],
      requestId: map['request_id'],
      itemName: map['item_name'],
      description: map['description'] ?? '',
      quantity: map['quantity'],
      estimatedUnitPrice: (map['estimated_unit_price'] as num).toDouble(),
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'request_id': requestId, // ID might be set later
      'item_name': itemName,
      'description': description,
      'quantity': quantity,
      'estimated_unit_price': estimatedUnitPrice,
      'unit': unit,
    };
  }
}

class ProcurementRequest {
  final String id;
  final String title; // e.g., "Pengadaan Laptop Diskominfo 2024"
  final String description;
  final String departmentId; // Bidang
  final String departmentName; // Joined
  final int fiscalYear; // Tahun Anggaran
  final ProcurementStatus status;
  final double totalEstimatedCost;
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProcurementItem>? items;

  const ProcurementRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    this.departmentName = '',
    required this.fiscalYear,
    required this.status,
    required this.totalEstimatedCost,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory ProcurementRequest.fromSupabase(Map<String, dynamic> map) {
    return ProcurementRequest(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      departmentId: map['department_id'],
      departmentName: map['departments']?['name'] ?? '',
      fiscalYear: map['fiscal_year'],
      status: ProcurementStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProcurementStatus.draft,
      ),
      totalEstimatedCost: (map['total_estimated_cost'] as num).toDouble(),
      createdBy: map['created_by'],
      createdByName: map['profiles']?['full_name'], // Assuming join on profiles
      createdAt: DateTime.tryParse(map['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']) ?? DateTime.now(),
      // Items handled separately usually
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'description': description,
      'department_id': departmentId,
      'fiscal_year': fiscalYear,
      'status': status.name,
      'total_estimated_cost': totalEstimatedCost,
      'created_by': createdBy,
    };
  }
}

