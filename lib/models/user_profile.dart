import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String status; // 'active', 'inactive'
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
      'joinDate': joinDate,
      'departmentId': departmentId,
      'employeeId': employeeId,
      'status': status,
      'location': location,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? UserRole.employee,
      joinDate: (map['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      departmentId: map['departmentId'],
      employeeId: map['employeeId'],
      status: map['status'] ?? 'active',
      location: map['location'],
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? departmentId,
    String? employeeId,
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
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }

  bool get isActive => status == 'active';
  bool get isCleaner => role == UserRole.cleaner;
  bool get isEmployee => role == UserRole.employee;

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