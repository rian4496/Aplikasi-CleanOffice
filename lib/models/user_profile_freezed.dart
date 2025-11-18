// lib/models/user_profile_freezed.dart
// User Profile model - Freezed Version

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';
import 'user_role.dart';

part 'user_profile_freezed.freezed.dart';
part 'user_profile_freezed.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const UserProfile._(); // Private constructor for custom methods

  const factory UserProfile({
    required String uid,
    required String displayName,
    required String email,
    String? photoURL,
    String? phoneNumber,
    required String role,
    @TimestampConverter() required DateTime joinDate,
    String? departmentId,
    String? employeeId,
    @Default('active') String status, // 'active', 'inactive'
    String? location, // Lokasi kerja/ruangan
  }) = _UserProfile;

  /// Convert dari JSON ke UserProfile object
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  /// Convert dari Map ke UserProfile object (backward compatibility)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile.fromJson({
      'uid': map['uid'] ?? '',
      'displayName': map['displayName'] ?? '',
      'email': map['email'] ?? '',
      'photoURL': map['photoURL'],
      'phoneNumber': map['phoneNumber'],
      'role': map['role'] ?? UserRole.employee,
      'joinDate': map['joinDate'], // TimestampConverter handles this
      'departmentId': map['departmentId'],
      'employeeId': map['employeeId'],
      'status': map['status'] ?? 'active',
      'location': map['location'],
    });
  }

  /// Convert UserProfile object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    return {
      'uid': json['uid'],
      'displayName': json['displayName'],
      'email': json['email'],
      'photoURL': json['photoURL'],
      'phoneNumber': json['phoneNumber'],
      'role': json['role'],
      'joinDate': json['joinDate'], // Already Timestamp from converter
      'departmentId': json['departmentId'],
      'employeeId': json['employeeId'],
      'status': json['status'],
      'location': json['location'],
    };
  }

  /// Static helper methods
  static List<String> get allStatuses => ['active', 'inactive'];

  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      default:
        return status;
    }
  }
}

// ==================== USER PROFILE EXTENSION ====================

extension UserProfileExtension on UserProfile {
  bool get isActive => status == 'active';
  bool get isCleaner => role == UserRole.cleaner;
  bool get isEmployee => role == UserRole.employee;
}
