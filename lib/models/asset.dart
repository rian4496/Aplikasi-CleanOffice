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
      // English codes
      case 'good':
      case 'baik':
        return AssetCondition.good;
      case 'fair':
      case 'cukup':
        return AssetCondition.fair;
      case 'poor':
      case 'kurang':
        return AssetCondition.poor;
      case 'broken':
      case 'rusak':
      case 'rusak_ringan':
      case 'rusak_berat':
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
        return 'Cukup Baik';
      case AssetCondition.poor:
        return 'Kurang Baik';
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
  final String qrCode; // Mapped from asset_code in DB
  final String category;
  final String brand;
  final String model;
  final String? typeId;       // FK to asset_types
  final String? categoryId;   // FK to asset_categories
  final String? departmentId; // FK to departments
  final String? conditionId;  // FK to asset_conditions
  final String? organizationId; // FK to organizations
  final String? organizationName; // Joined from organizations table
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
  // Custodian (Pemegang Aset) - only for movable assets
  final String? custodianId;
  final String? custodianName;
  final String? custodianNip;

  Asset({
    required this.id,
    required this.name,
    this.description,
    required this.qrCode,
    required this.category,
    this.brand = '-',
    this.model = '-',
    this.typeId,
    this.categoryId,
    this.departmentId,
    this.conditionId,
    this.organizationId,
    this.organizationName,
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
    this.custodianId,
    this.custodianName,
    this.custodianNip,
  });

  // Factory constructor from Supabase
  factory Asset.fromSupabase(Map<String, dynamic> map) {
    return Asset(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Asset',
      description: map['description'] as String?,
      qrCode: (map['asset_code'] ?? map['qr_code'])?.toString() ?? '-',
      category: (map['category'] is Map 
          ? map['category']['name'] 
          : (map['asset_categories'] is Map ? map['asset_categories']['name'] : map['category']?.toString())) ?? 'Lainnya',
      brand: map['brand']?.toString() ?? '-',
      model: map['model']?.toString() ?? '-',
      typeId: map['type_id'] as String?,
      categoryId: map['category_id'] as String?,
      departmentId: map['department_id'] as String?,
      conditionId: map['condition_id'] as String?,
      organizationId: map['organization_id'] as String?,
      organizationName: map['organizations']?['name'] as String? ?? map['organization_name'] as String?,
      locationId: map['location_id'] as String?,
      locationName: map['locations']?['name'] as String? ?? map['location_name'] as String?, // Joined or direct
      status: AssetStatus.fromString(map['status'] ?? 'active'),
      condition: AssetCondition.fromString(map['condition'] ?? 'good'),
      purchaseDate: map['purchase_date'] != null 
          ? DateTime.parse(map['purchase_date']) 
          : null,
      purchasePrice: (map['purchase_price'] ?? map['price'] as num?)?.toDouble(), // Try both column names
      warrantyUntil: map['warranty_until'] != null 
          ? DateTime.parse(map['warranty_until']) 
          : null,
      imageUrl: map['image_url'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      custodianId: map['custodian_id'] as String?,
      custodianName: map['custodian']?['full_name'] as String? ?? map['custodian_name'] as String?,
      custodianNip: map['custodian']?['nip'] as String? ?? map['custodian_nip'] as String?,
    );
  }

  // Convert to Map for Supabase insert/update
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'asset_code': qrCode,
      'category': category,
      'brand': brand,
      'model': model,
      'organization_id': organizationId,
      'location_id': locationId,
      'status': status.toDatabase(),
      'condition': condition.toDatabase(),
      'purchase_date': purchaseDate?.toIso8601String().split('T').first,
      'purchase_price': purchasePrice,
      'warranty_until': warrantyUntil?.toIso8601String().split('T').first,
      'image_url': imageUrl,
      'notes': notes,
      'created_by': createdBy,
      'custodian_id': custodianId,
    };
  }

  // CopyWith
  Asset copyWith({
    String? id,
    String? name,
    String? description,
    String? qrCode,
    String? category,
    String? brand,
    String? model,
    String? organizationId,
    String? organizationName,
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
    String? custodianId,
    String? custodianName,
    String? custodianNip,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      qrCode: qrCode ?? this.qrCode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
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
      custodianId: custodianId ?? this.custodianId,
      custodianName: custodianName ?? this.custodianName,
      custodianNip: custodianNip ?? this.custodianNip,
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

  // Formatted helpers
  String? get purchaseDateFormatted {
    if (purchaseDate == null) return null;
    return '${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}';
  }

  String? get warrantyUntilFormatted {
    if (warrantyUntil == null) return null;
    return '${warrantyUntil!.day}/${warrantyUntil!.month}/${warrantyUntil!.year}';
  }

  String? get purchasePriceFormatted {
    if (purchasePrice == null) return null;
    return 'Rp ${purchasePrice!.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

