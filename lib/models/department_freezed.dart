// lib/models/department_freezed.dart
// Department model - Freezed Version
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'department_freezed.freezed.dart';
part 'department_freezed.g.dart';

@freezed
class Department with _$Department {
  const Department._(); // Private constructor for custom methods

  const factory Department({
    required String id,
    required String name,
    required String description,
    required String supervisorId,
    required List<String> locations,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Department;

  /// Convert dari JSON ke Department object
  factory Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);

  /// Convert dari Map ke Department object (backward compatibility)
  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department.fromJson({
      'id': id,
      'name': map['name'] ?? '',
      'description': map['description'] ?? '',
      'supervisorId': map['supervisorId'] ?? '',
      'locations': map['locations'] ?? [],
      'createdAt': map['createdAt'], // TimestampConverter handles this
      'updatedAt': map['updatedAt'],
    });
  }

  /// Convert Department object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    return json;
  }
}
