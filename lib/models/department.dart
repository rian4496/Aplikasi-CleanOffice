// lib/models/department.dart
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'supervisorId': supervisorId,
      'locations': locations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Appwrite document format
  Map<String, dynamic> toAppwrite() => toMap();

  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      supervisorId: map['supervisorId'] ?? '',
      locations: List<String>.from(map['locations'] ?? []),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  /// Factory from Appwrite document
  factory Department.fromAppwrite(Map<String, dynamic> data) {
    return Department(
      id: data['\$id'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      supervisorId: data['supervisorId'] ?? '',
      locations: List<String>.from(data['locations'] ?? []),
      createdAt: _parseDate(data['\$createdAt']) ?? _parseDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(data['\$updatedAt']) ?? _parseDate(data['updatedAt']),
    );
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
