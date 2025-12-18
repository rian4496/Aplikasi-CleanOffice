// lib/models/user_profile.dart
// User Profile Model for Supabase

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
  final String? employeeId;
  final String status; // 'active', 'inactive', 'deleted'
  final String verificationStatus; // 'pending', 'approved', 'rejected'
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
    this.employeeId,
    this.status = 'inactive',  // New users start inactive
    this.verificationStatus = 'pending',  // Wait for admin approval
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
      'employeeId': employeeId,
      'status': status,
      'verificationStatus': verificationStatus,
      'location': location,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Handle joinDate from various formats (String ISO8601)
    DateTime parseJoinDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfile(
      uid: map['uid'] ?? map['id'] ?? '',
      displayName: map['displayName'] ?? map['display_name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? UserRole.employee,
      joinDate: parseJoinDate(map['joinDate']),
      departmentId: map['departmentId'],
      employeeId: map['employeeId'],
      status: map['status'] ?? 'inactive',
      verificationStatus: map['verificationStatus'] ?? 'pending',
      location: map['location'],
    );
  }

  /// Factory constructor for Supabase document
  factory UserProfile.fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      // Supabase uses 'id' directly (Auth ID = Database ID)
      uid: data['id'] as String? ?? '',
      displayName: data['display_name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoURL: data['photo_url'] as String?,
      phoneNumber: data['phone_number'] as String?,
      role: data['role'] as String? ?? UserRole.employee,
      joinDate: DateTime.tryParse(data['created_at'] as String? ?? '') ??
          DateTime.tryParse(data['join_date'] as String? ?? '') ??
          DateTime.now(),
      departmentId: data['department_id'] as String?,
      employeeId: data['employee_id'] as String?,
      status: data['status'] as String? ?? 'inactive',
      verificationStatus: data['verification_status'] as String? ?? 'pending',
      location: data['location'] as String?,
    );
  }

  /// Convert to Supabase document format
  Map<String, dynamic> toSupabase() {
    return {
      'display_name': displayName,
      'email': email,
      'photo_url': photoURL,
      'phone_number': phoneNumber,
      'role': role,
      'department_id': departmentId,
      'employee_id': employeeId,
      'status': status,
      'verification_status': verificationStatus,
      'location': location,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? departmentId,
    String? employeeId,
    String? status,
    String? verificationStatus,
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
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      location: location ?? this.location,
    );
  }

  bool get isActive => status == 'active';
  bool get isAdmin => role == UserRole.admin;
  bool get isKasubbag => role == UserRole.kasubbag;
  bool get isTeknisi => role == UserRole.teknisi;
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

