/// Class untuk mengelola role dan permission user dalam aplikasi
class UserRole {
  // Role constants
  static const String admin = 'admin'; // SYS_ADMIN
  static const String kasubbag = 'kasubbag'; // KASUBBAG UMPEG
  static const String teknisi = 'teknisi'; // TEKNISI (Executor)
  static const String cleaner = 'cleaner'; // CLEANER (Field Staff)
  static const String employee = 'employee'; // EMPLOYEE (General Staff)

  /// Mendapatkan semua role yang tersedia
  static List<String> get allRoles => [admin, kasubbag, teknisi, cleaner, employee];

  /// Mendapatkan nama tampilan role dalam Bahasa Indonesia
  static String getRoleDisplayName(String role) {
    switch (role) {
      case admin:
        return 'Admin Sistem';
      case kasubbag:
        return 'Kasubag Umpeg';
      case teknisi:
        return 'Teknisi Aset';
      case cleaner:
        return 'Petugas Kebersihan';
      case employee:
        return 'Pegawai Umum';
      default:
        return role;
    }
  }

  /// Mendapatkan deskripsi role
  static String getRoleDescription(String role) {
    switch (role) {
      case admin:
        return 'Full Access Management';
      case kasubbag:
        return 'Approval & Monitoring';
      case teknisi:
        return 'Eksekusi Tiket Maintenance';
      case cleaner:
        return 'Lapor & Tiket Sederhana';
      case employee:
        return 'Peminjaman & Penggunaan Aset';
      default:
        return 'Akses Terbatas';
    }
  }

  // ==================== PERMISSION CHECKS (Helper) ====================
  // Keeping simple helpers useful for general UI logic
  
  static bool isManagement(String role) => role == admin || role == kasubbag;
  static bool isExecutor(String role) => role == teknisi || role == cleaner;
}

/// Database-backed user role record
class UserRoleRecord {
  final String id;
  final String userId;
  final String? employeeId;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserRoleRecord({
    required this.id,
    required this.userId,
    this.employeeId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRoleRecord.fromJson(Map<String, dynamic> json) {
    return UserRoleRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      employeeId: json['employee_id'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For creating new user role (without id, timestamps)
  static Map<String, dynamic> toInsertJson({
    required String userId,
    String? employeeId,
    required String role,
  }) {
    return {
      'user_id': userId,
      'employee_id': employeeId,
      'role': role,
    };
  }

  String get displayName => UserRole.getRoleDisplayName(role);
  String get description => UserRole.getRoleDescription(role);
  bool get isManagement => UserRole.isManagement(role);
  bool get isExecutor => UserRole.isExecutor(role);
}
