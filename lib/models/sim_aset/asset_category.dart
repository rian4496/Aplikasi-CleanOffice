// lib/models/sim_aset/asset_category.dart
// SIM-ASET: Asset Category Model

class AssetCategory {
  final String id;
  final String? typeId;
  final String code;
  final String name;
  final String? icon;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  AssetCategory({
    required this.id,
    this.typeId,
    required this.code,
    required this.name,
    this.icon,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory AssetCategory.fromSupabase(Map<String, dynamic> json) {
    return AssetCategory(
      id: json['id'] as String,
      typeId: json['type_id'] as String?,
      code: json['code'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'type_id': typeId,
      'code': code,
      'name': name,
      'icon': icon,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
