import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'supervisorId': supervisorId,
      'locations': locations,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      supervisorId: map['supervisorId'] ?? '',
      locations: List<String>.from(map['locations'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
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
