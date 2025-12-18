// lib/models/sim_aset/department.dart
// SIM-ASET: Department Model (BRIDA Bidang)

class Department {
  final String id;
  final String code;
  final String name;
  final String? parentId;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  factory Department.fromSupabase(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'code': code,
      'name': name,
      'parent_id': parentId,
      'description': description,
      'is_active': isActive,
    };
  }
}

