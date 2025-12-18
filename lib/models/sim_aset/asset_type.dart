// lib/models/sim_aset/asset_type.dart
// SIM-ASET: Asset Type Model (Bergerak/Tidak Bergerak)

class AssetType {
  final String id;
  final String code;
  final String name;
  final String? description;
  final DateTime createdAt;

  AssetType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory AssetType.fromSupabase(Map<String, dynamic> json) {
    return AssetType(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'code': code,
      'name': name,
      'description': description,
    };
  }

  bool get isMovable => code == 'movable';
  bool get isImmovable => code == 'immovable';
}

