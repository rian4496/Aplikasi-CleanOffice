// lib/models/location.dart
// SIM-ASET: Location Model

class Location {
  final String id;
  final String name;
  final String? building;
  final String? floor;
  final String? room;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location({
    required this.id,
    required this.name,
    this.building,
    this.floor,
    this.room,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromSupabase(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      name: map['name'] as String,
      building: map['building'] as String?,
      floor: map['floor'] as String?,
      room: map['room'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'room': room,
      'description': description,
    };
  }

  // Get full location string
  String get fullLocation {
    final parts = <String>[];
    if (building != null) parts.add(building!);
    if (floor != null) parts.add('Lt. $floor');
    if (room != null) parts.add(room!);
    return parts.isNotEmpty ? parts.join(' - ') : name;
  }

  // Get short location
  String get shortLocation {
    if (room != null) return room!;
    if (floor != null) return 'Lt. $floor';
    return name;
  }
}

