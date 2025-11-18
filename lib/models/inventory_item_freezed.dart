// lib/models/inventory_item_freezed.dart
// Inventory item model - Freezed Version

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'inventory_item_freezed.freezed.dart';
part 'inventory_item_freezed.g.dart';

// ==================== STOCK STATUS ====================

enum StockStatus {
  inStock,
  mediumStock,
  lowStock,
  outOfStock,
}

// ==================== STOCK REQUEST STATUS ====================

enum StockRequestStatus {
  pending,
  approved,
  rejected,
  fulfilled,
}

extension StockRequestStatusExtension on StockRequestStatus {
  Color get color {
    switch (this) {
      case StockRequestStatus.pending:
        return Colors.orange;
      case StockRequestStatus.approved:
        return Colors.green;
      case StockRequestStatus.rejected:
        return Colors.red;
      case StockRequestStatus.fulfilled:
        return Colors.blue;
    }
  }

  String get label {
    switch (this) {
      case StockRequestStatus.pending:
        return 'Pending';
      case StockRequestStatus.approved:
        return 'Disetujui';
      case StockRequestStatus.rejected:
        return 'Ditolak';
      case StockRequestStatus.fulfilled:
        return 'Selesai';
    }
  }
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

// ==================== INVENTORY ITEM ====================

@freezed
class InventoryItem with _$InventoryItem {
  const InventoryItem._(); // Private constructor for custom methods

  const factory InventoryItem({
    required String id,
    required String name,
    required String category, // 'alat', 'consumable', 'ppe'
    required int currentStock,
    required int maxStock,
    required int minStock,
    required String unit,
    String? description,
    String? imageUrl,
    @ISODateTimeConverter() required DateTime createdAt,
    @ISODateTimeConverter() required DateTime updatedAt,
  }) = _InventoryItem;

  /// Convert dari JSON ke InventoryItem object
  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);

  /// Convert dari Map ke InventoryItem object (backward compatibility)
  factory InventoryItem.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItem.fromJson({
      'id': id,
      ...map,
    });
  }

  /// Convert InventoryItem object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    return json;
  }
}

// ==================== INVENTORY ITEM EXTENSION ====================

extension InventoryItemExtension on InventoryItem {
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
}

// ==================== STOCK REQUEST ====================

@freezed
class StockRequest with _$StockRequest {
  const StockRequest._(); // Private constructor for custom methods

  const factory StockRequest({
    required String id,
    required String itemId,
    required String itemName,
    required String requesterId,
    required String requesterName,
    required int requestedQuantity,
    String? notes,
    required StockRequestStatus status,
    @ISODateTimeConverter() required DateTime requestedAt,
    @NullableISODateTimeConverter() DateTime? approvedAt,
    String? approvedBy,
    String? approvedByName,
    String? rejectionReason,
  }) = _StockRequest;

  /// Convert dari JSON ke StockRequest object
  factory StockRequest.fromJson(Map<String, dynamic> json) => _$StockRequestFromJson(json);

  /// Convert dari Map ke StockRequest object (backward compatibility)
  factory StockRequest.fromMap(String id, Map<String, dynamic> map) {
    return StockRequest.fromJson({
      'id': id,
      'itemId': map['itemId'],
      'itemName': map['itemName'],
      'requesterId': map['requesterId'],
      'requesterName': map['requesterName'],
      'requestedQuantity': map['requestedQuantity'],
      'notes': map['notes'],
      'status': map['status'], // Will be handled by json_serializable
      'requestedAt': map['requestedAt'],
      'approvedAt': map['approvedAt'],
      'approvedBy': map['approvedBy'],
      'approvedByName': map['approvedByName'],
      'rejectionReason': map['rejectionReason'],
    });
  }

  /// Convert StockRequest object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    // Convert enum to string for backward compatibility
    json['status'] = status.name;
    return json;
  }
}

// ==================== STOCK REQUEST EXTENSION ====================

extension StockRequestExtension on StockRequest {
  Color get statusColor => status.color;
  String get statusLabel => status.label;
}
