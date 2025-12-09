import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'inventory_item_freezed.freezed.dart';
part 'inventory_item_freezed.g.dart';

// Custom converters for DateTime (replacing Firestore ones)
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();
  
  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
  
  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();
  
  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    return null;
  }
  
  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}


enum StockStatus {
  inStock,
  mediumStock,
  lowStock,
  outOfStock;

  Color get color {
    switch (this) {
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

  String get label {
    switch (this) {
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

// ==================== STOCK REQUEST STATUS ENUM ====================

enum StockRequestStatus {
  pending,
  approved,
  rejected,
  fulfilled;

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

// ==================== ITEM CATEGORY ENUM ====================

enum ItemCategory {
  alat,
  consumable,
  ppe;

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

// ==================== INVENTORY ITEM MODEL ====================

@freezed
class InventoryItem with _$InventoryItem {
  const InventoryItem._();

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
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _InventoryItem;

  // Custom fromJson
  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);

  // Supabase factory (snake_case)
  factory InventoryItem.fromSupabase(Map<String, dynamic> data) {
    return InventoryItem(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'consumable',
      currentStock: data['current_stock'] as int? ?? 0,
      maxStock: data['max_stock'] as int? ?? 0,
      minStock: data['min_stock'] as int? ?? 0,
      unit: data['unit'] as String? ?? 'pcs',
      description: data['description'] as String?,
      imageUrl: data['image_url'] as String?,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String) : DateTime.now(),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : DateTime.now(),
    );
  }


  // Appwrite factory
  factory InventoryItem.fromAppwrite(Map<String, dynamic> data) {
    final id = data['\$id'] as String? ?? data['id'] as String? ?? '';
    final normalizedData = Map<String, dynamic>.from(data);
    normalizedData['id'] = id;
    
    // Handle Appwrite system fields
    if (data.containsKey('\$createdAt')) normalizedData['createdAt'] = data['\$createdAt'];
    if (data.containsKey('\$updatedAt')) normalizedData['updatedAt'] = data['\$updatedAt'];

    return InventoryItem.fromJson(normalizedData);
  }

  // Legacy fromMap
  factory InventoryItem.fromMap(String id, Map<String, dynamic> data) {
    return InventoryItem.fromJson({'id': id, ...data});
  }

  // To Firestore/Map
  Map<String, dynamic> toFirestore() {
    return toJson()..remove('id');
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toAppwrite() {
    return toJson()..remove('id');
  }

  // Computed properties
  double get stockPercentage => maxStock > 0 ? (currentStock / maxStock) * 100 : 0;

  StockStatus get status {
    if (currentStock == 0) return StockStatus.outOfStock;
    if (currentStock <= minStock) return StockStatus.lowStock;
    if (stockPercentage >= 50) return StockStatus.inStock;
    return StockStatus.mediumStock;
  }

  Color get statusColor => status.color;
  String get statusLabel => status.label;
}

// ==================== STOCK REQUEST MODEL ====================

@freezed
class StockRequest with _$StockRequest {
  const StockRequest._();

  const factory StockRequest({
    required String id,
    required String itemId,
    required String itemName,
    required String requesterId,
    required String requesterName,
    required int requestedQuantity,
    String? notes,
    required StockRequestStatus status,
    @TimestampConverter() required DateTime requestedAt,
    @NullableTimestampConverter() DateTime? approvedAt,
    String? approvedBy,
    String? approvedByName,
    String? rejectionReason,
  }) = _StockRequest;

  factory StockRequest.fromJson(Map<String, dynamic> json) => _$StockRequestFromJson(json);

  // Supabase factory (snake_case)
  factory StockRequest.fromSupabase(Map<String, dynamic> data) {
    return StockRequest(
      id: data['id'] as String? ?? '',
      itemId: data['item_id'] as String? ?? '',
      itemName: data['item_name'] as String? ?? '',
      requesterId: data['requester_id'] as String? ?? '',
      requesterName: data['requester_name'] as String? ?? '',
      requestedQuantity: data['requested_quantity'] as int? ?? 0,
      notes: data['notes'] as String?,
      status: StockRequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'pending'),
        orElse: () => StockRequestStatus.pending,
      ),
      requestedAt: data['requested_at'] != null 
          ? DateTime.parse(data['requested_at'] as String) 
          : DateTime.now(),
      approvedAt: data['approved_at'] != null 
          ? DateTime.parse(data['approved_at'] as String) 
          : null,
      approvedBy: data['approved_by'] as String?,
      approvedByName: data['approved_by_name'] as String?,
      rejectionReason: data['rejection_reason'] as String?,
    );
  }


  factory StockRequest.fromAppwrite(Map<String, dynamic> data) {
    final id = data['\$id'] as String? ?? data['id'] as String? ?? '';
    final normalizedData = Map<String, dynamic>.from(data);
    normalizedData['id'] = id;
    
    // Handle Appwrite system fields
    if (data.containsKey('\$createdAt')) normalizedData['requestedAt'] = data['\$createdAt'];
    
    // Map status string to enum if needed (though json_serializable handles string matching usually)
    // But since we renamed the enum, we might need to be careful if the DB has old values?
    // Assuming DB values match the enum names (pending, approved, etc.) which they do.

    return StockRequest.fromJson(normalizedData);
  }

  factory StockRequest.fromMap(String id, Map<String, dynamic> data) {
    return StockRequest.fromJson({'id': id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    return toJson()..remove('id');
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toAppwrite() {
    return toJson()..remove('id');
  }

  Color get statusColor => status.color;
  String get statusLabel => status.label;
}
