// lib/models/inventory_item.dart
// Inventory item model

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ==================== INVENTORY ITEM ====================

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String category; // 'alat', 'consumable', 'ppe'
  final int currentStock;
  final int maxStock;
  final int minStock;
  final String unit;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.maxStock,
    required this.minStock,
    required this.unit,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  double get stockPercentage => maxStock > 0 ? (currentStock / maxStock) * 100 : 0;

  StockStatus get status {
    if (currentStock == 0) return StockStatus.outOfStock;
    if (currentStock <= minStock) return StockStatus.lowStock;
    if (stockPercentage >= 50) return StockStatus.inStock;
    return StockStatus.mediumStock;
  }

  Color get statusColor {
    switch (status) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.mediumStock:
        return Colors.amber;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  String get statusLabel {
    switch (status) {
      case StockStatus.inStock:
        return 'Stok Cukup';
      case StockStatus.mediumStock:
        return 'Stok Sedang';
      case StockStatus.lowStock:
        return 'Stok Menipis';
      case StockStatus.outOfStock:
        return 'Habis';
    }
  }

  // From Firestore (legacy)
  factory InventoryItem.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItem(
      id: id,
      name: map['name'] as String,
      category: map['category'] as String,
      currentStock: map['currentStock'] as int,
      maxStock: map['maxStock'] as int,
      minStock: map['minStock'] as int,
      unit: map['unit'] as String,
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// From Supabase (snake_case)
  factory InventoryItem.fromSupabase(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      currentStock: map['quantity'] as int? ?? 0,
      maxStock: map['max_stock'] as int? ?? 100,
      minStock: map['min_stock'] as int? ?? 0,
      unit: map['unit'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : DateTime.now(),
    );
  }

  // To Firestore (legacy)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'currentStock': currentStock,
      'maxStock': maxStock,
      'minStock': minStock,
      'unit': unit,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// To Supabase (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'category': category,
      'quantity': currentStock,
      'min_stock': minStock,
      'unit': unit,
      'description': description,
      'image_url': imageUrl,
      'location': null, // Add if needed
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? currentStock,
    int? maxStock,
    int? minStock,
    String? unit,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      maxStock: maxStock ?? this.maxStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        currentStock,
        maxStock,
        minStock,
        unit,
        description,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}


// ==================== STOCK STATUS ====================

enum StockStatus {
  inStock,
  mediumStock,
  lowStock,
  outOfStock,
}

// ==================== STOCK REQUEST ====================

class StockRequest extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final String requesterId;
  final String requesterName;
  final int requestedQuantity;
  final String? notes;
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? approvedByName;
  final String? rejectionReason;

  const StockRequest({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.requesterId,
    required this.requesterName,
    required this.requestedQuantity,
    this.notes,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.approvedBy,
    this.approvedByName,
    this.rejectionReason,
  });

  Color get statusColor {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.fulfilled:
        return Colors.blue;
    }
  }

  String get statusLabel {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Disetujui';
      case RequestStatus.rejected:
        return 'Ditolak';
      case RequestStatus.fulfilled:
        return 'Selesai';
    }
  }

  factory StockRequest.fromMap(String id, Map<String, dynamic> map) {
    return StockRequest(
      id: id,
      itemId: map['itemId'] as String,
      itemName: map['itemName'] as String,
      requesterId: map['requesterId'] as String,
      requesterName: map['requesterName'] as String,
      requestedQuantity: map['requestedQuantity'] as int,
      notes: map['notes'] as String?,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: DateTime.parse(map['requestedAt'] as String),
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt'] as String) : null,
      approvedBy: map['approvedBy'] as String?,
      approvedByName: map['approvedByName'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  /// From Supabase (snake_case)
  factory StockRequest.fromSupabase(Map<String, dynamic> map) {
    return StockRequest(
      id: map['id'] as String,
      itemId: map['item_id'] as String,
      itemName: map['item_name'] as String,
      requesterId: map['requester_id'] as String,
      requesterName: map['requester_name'] as String,
      requestedQuantity: map['requested_quantity'] as int,
      notes: map['notes'] as String?,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'pending'),
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: map['requested_at'] != null
          ? DateTime.parse(map['requested_at'] as String)
          : DateTime.now(),
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String)
          : null,
      approvedBy: map['approved_by'] as String?,
      approvedByName: map['approved_by_name'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requestedQuantity': requestedQuantity,
      'notes': notes,
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
      'rejectionReason': rejectionReason,
    };
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        requesterId,
        requesterName,
        requestedQuantity,
        notes,
        status,
        requestedAt,
        approvedAt,
        approvedBy,
        approvedByName,
        rejectionReason,
      ];
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  fulfilled,
}

// ==================== ITEM CATEGORY ====================

enum ItemCategory {
  alat,
  consumable,
  ppe,
}

extension ItemCategoryExtension on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.alat:
        return 'Alat Kebersihan';
      case ItemCategory.consumable:
        return 'Bahan Habis Pakai';
      case ItemCategory.ppe:
        return 'Alat Pelindung Diri';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.alat:
        return Icons.cleaning_services;
      case ItemCategory.consumable:
        return Icons.water_drop;
      case ItemCategory.ppe:
        return Icons.security;
    }
  }

  Color get color {
    switch (this) {
      case ItemCategory.alat:
        return Colors.blue;
      case ItemCategory.consumable:
        return Colors.green;
      case ItemCategory.ppe:
        return Colors.orange;
    }
  }
}
