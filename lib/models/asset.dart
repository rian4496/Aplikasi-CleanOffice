// lib/models/asset.dart
// SIM-ASET: Asset Model

import 'package:flutter/material.dart';

// ==================== ASSET STATUS ENUM ====================
enum AssetStatus {
  active,
  inactive,
  disposed;

  static AssetStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AssetStatus.active;
      case 'inactive':
        return AssetStatus.inactive;
      case 'disposed':
        return AssetStatus.disposed;
      default:
        return AssetStatus.active;
    }
  }

  String toDatabase() {
    switch (this) {
      case AssetStatus.active:
        return 'active';
      case AssetStatus.inactive:
        return 'inactive';
      case AssetStatus.disposed:
        return 'disposed';
    }
  }

  String get displayName {
    switch (this) {
      case AssetStatus.active:
        return 'Aktif';
      case AssetStatus.inactive:
        return 'Non-Aktif';
      case AssetStatus.disposed:
        return 'Dibuang';
    }
  }

  Color get color {
    switch (this) {
      case AssetStatus.active:
        return Colors.green;
      case AssetStatus.inactive:
        return Colors.orange;
      case AssetStatus.disposed:
        return Colors.grey;
    }
  }
}

// ==================== ASSET CONDITION ENUM ====================
enum AssetCondition {
  good,
  fair,
  poor,
  broken;

  static AssetCondition fromString(String condition) {
    switch (condition.toLowerCase()) {
      case 'good':
        return AssetCondition.good;
      case 'fair':
        return AssetCondition.fair;
      case 'poor':
        return AssetCondition.poor;
      case 'broken':
        return AssetCondition.broken;
      default:
        return AssetCondition.good;
    }
  }

  String toDatabase() {
    switch (this) {
      case AssetCondition.good:
        return 'good';
      case AssetCondition.fair:
        return 'fair';
      case AssetCondition.poor:
        return 'poor';
      case AssetCondition.broken:
        return 'broken';
    }
  }

  String get displayName {
    switch (this) {
      case AssetCondition.good:
        return 'Baik';
      case AssetCondition.fair:
        return 'Cukup';
      case AssetCondition.poor:
        return 'Buruk';
      case AssetCondition.broken:
        return 'Rusak';
    }
  }

  Color get color {
    switch (this) {
      case AssetCondition.good:
        return Colors.green;
      case AssetCondition.fair:
        return Colors.blue;
      case AssetCondition.poor:
        return Colors.orange;
      case AssetCondition.broken:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case AssetCondition.good:
        return Icons.check_circle;
      case AssetCondition.fair:
        return Icons.info;
      case AssetCondition.poor:
        return Icons.warning;
      case AssetCondition.broken:
        return Icons.error;
    }
  }
}

// ==================== ASSET MODEL ====================
class Asset {
  final String id;
  final String name;
  final String? description;
  final String qrCode;
  final String category;
  final String? locationId;
  final String? locationName; // Joined from locations table
  final AssetStatus status;
  final AssetCondition condition;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? warrantyUntil;
  final String? imageUrl;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asset({
    required this.id,
    required this.name,
    this.description,
    required this.qrCode,
    required this.category,
    this.locationId,
    this.locationName,
    required this.status,
    required this.condition,
    this.purchaseDate,
    this.purchasePrice,
    this.warrantyUntil,
    this.imageUrl,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Supabase
  factory Asset.fromSupabase(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      qrCode: map['qr_code'] as String,
      category: map['category'] as String,
      locationId: map['location_id'] as String?,
      locationName: map['locations']?['name'] as String?, // Joined
      status: AssetStatus.fromString(map['status'] ?? 'active'),
      condition: AssetCondition.fromString(map['condition'] ?? 'good'),
      purchaseDate: map['purchase_date'] != null 
          ? DateTime.parse(map['purchase_date']) 
          : null,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble(),
      warrantyUntil: map['warranty_until'] != null 
          ? DateTime.parse(map['warranty_until']) 
          : null,
      imageUrl: map['image_url'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Convert to Map for Supabase insert/update
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'qr_code': qrCode,
      'category': category,
      'location_id': locationId,
      'status': status.toDatabase(),
      'condition': condition.toDatabase(),
      'purchase_date': purchaseDate?.toIso8601String().split('T').first,
      'purchase_price': purchasePrice,
      'warranty_until': warrantyUntil?.toIso8601String().split('T').first,
      'image_url': imageUrl,
      'notes': notes,
      'created_by': createdBy,
    };
  }

  // CopyWith
  Asset copyWith({
    String? id,
    String? name,
    String? description,
    String? qrCode,
    String? category,
    String? locationId,
    String? locationName,
    AssetStatus? status,
    AssetCondition? condition,
    DateTime? purchaseDate,
    double? purchasePrice,
    DateTime? warrantyUntil,
    String? imageUrl,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      qrCode: qrCode ?? this.qrCode,
      category: category ?? this.category,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      warrantyUntil: warrantyUntil ?? this.warrantyUntil,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if warranty is still valid
  bool get isWarrantyValid {
    if (warrantyUntil == null) return false;
    return warrantyUntil!.isAfter(DateTime.now());
  }

  // Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return 'Elektronik';
      case 'furniture':
        return 'Furniture';
      case 'kendaraan':
        return 'Kendaraan';
      case 'it_equipment':
        return 'IT Equipment';
      default:
        return 'Lainnya';
    }
  }

  // Get category icon
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Icons.electrical_services;
      case 'furniture':
        return Icons.chair;
      case 'kendaraan':
        return Icons.directions_car;
      case 'it_equipment':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }
}
