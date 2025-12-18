// lib/models/department.dart
// Department Model for Supabase

class Department {
  final String id;
  final String name;
  final String description;
  final String supervisorId;
  final List<String> locations;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.supervisorId,
    required this.locations,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper to parse dates from various formats
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      supervisorId: map['supervisorId'] ?? map['supervisor_id'] ?? '',
      locations: List<String>.from(map['locations'] ?? []),
      createdAt: _parseDate(map['createdAt']) ?? _parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']) ?? _parseDate(map['updated_at']),
    );
  }

  /// Create from Supabase (snake_case)
  factory Department.fromSupabase(Map<String, dynamic> data) {
    return Department(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      supervisorId: data['supervisor_id'] ?? '',
      locations: List<String>.from(data['locations'] ?? []),
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  /// Convert to Supabase document format (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'supervisor_id': supervisorId,
      'locations': locations,
    };
  }

  Department copyWith({
    String? name,
    String? description,
    String? supervisorId,
    List<String>? locations,
  }) {
    return Department(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      supervisorId: supervisorId ?? this.supervisorId,
      locations: locations ?? this.locations,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

