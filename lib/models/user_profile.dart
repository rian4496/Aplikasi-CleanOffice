// lib/models/user_profile.dart
// MIGRATED TO APPWRITE - No Firebase dependencies

import 'user_role.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final String? phoneNumber;
  final String role;
  final DateTime joinDate;
  final String? departmentId;
  final String? staffId;
  final String status; // 'active', 'inactive', 'deleted'
  final String? location; // Lokasi kerja/ruangan

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.phoneNumber,
    required this.role,
    required this.joinDate,
    this.departmentId,
    this.staffId,
    this.status = 'active',
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'role': role,
      'joinDate': joinDate.toIso8601String(),
      'departmentId': departmentId,
      'staffId': staffId,
      'status': status,
      'location': location,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Handle joinDate from Appwrite (String ISO8601)
    DateTime parseJoinDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfile(
      uid: map['uid'] ?? map['\$id'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? UserRole.employee,
      joinDate: parseJoinDate(map['joinDate']),
      departmentId: map['departmentId'],
      staffId: map['staffId'],
      status: map['status'] ?? 'active',
      location: map['location'],
    );
  }

  /// Factory constructor for Appwrite document
  factory UserProfile.fromAppwrite(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['\$id'] as String? ?? data['uid'] as String? ?? '',
      displayName: data['displayName'] as String? ?? data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoURL: data['photoURL'] as String? ?? data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String? ?? data['phone'] as String?,
      role: data['role'] as String? ?? UserRole.employee,
      joinDate: DateTime.tryParse(data['\$createdAt'] as String? ?? '') ??
          DateTime.tryParse(data['joinDate'] as String? ?? '') ??
          DateTime.now(),
      departmentId: data['departmentId'] as String?,
      staffId: data['staffId'] as String?,
      status: data['status'] as String? ?? 'active',
      location: data['location'] as String?,
    );
  }

  /// Convert to Appwrite document format
  Map<String, dynamic> toAppwrite() {
    return {
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'role': role,
      'departmentId': departmentId,
      'staffId': staffId,
      'status': status,
      'location': location,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? departmentId,
    String? staffId,
    String? status,
    String? location,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      joinDate: joinDate,
      departmentId: departmentId ?? this.departmentId,
      staffId: staffId ?? this.staffId,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }

  bool get isActive => status == 'active';
  bool get isCleaner => role == UserRole.cleaner;
  bool get isEmployee => role == UserRole.employee;

  static List<String> get allStatuses => ['active', 'inactive', 'deleted'];

  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'deleted':
        return 'Dihapus';
      default:
        return status;
    }
  }
}
