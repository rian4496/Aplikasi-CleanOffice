/// Class untuk mengelola role dan permission user dalam aplikasi
class UserRole {
  // Role constants
  static const String cleaner = 'cleaner';
  static const String employee = 'employee';
  static const String supervisor = 'supervisor';

  /// Mendapatkan semua role yang tersedia
  static List<String> get allRoles => [cleaner, employee, supervisor];

  /// Mendapatkan nama tampilan role dalam Bahasa Indonesia
  static String getRoleDisplayName(String role) {
    switch (role) {
      case cleaner:
        return 'Petugas Kebersihan';
      case employee:
        return 'Karyawan';
      case supervisor:
        return 'Supervisor';
      default:
        return role;
    }
  }

  /// Mendapatkan deskripsi role
  static String getRoleDescription(String role) {
    switch (role) {
      case cleaner:
        return 'Melakukan tugas kebersihan dan membuat laporan';
      case employee:
        return 'Membuat permintaan dan evaluasi kebersihan';
      case supervisor:
        return 'Memantau dan memverifikasi laporan kebersihan';
      default:
        return 'Akses terbatas ke sistem';
    }
  }

  // ==================== PERMISSION CHECKS ====================

  /// Employee dapat membuat permintaan kebersihan
  static bool canRequestCleaning(String role) {
    return role == employee;
  }

  /// Cleaner dapat membuat dan mengerjakan laporan
  static bool canSubmitReport(String role) {
    return role == cleaner;
  }

  /// Supervisor dapat memverifikasi laporan
  static bool canVerifyReports(String role) {
    return role == supervisor;
  }

  /// Supervisor dapat melihat semua laporan
  static bool canViewAllReports(String role) {
    return role == supervisor;
  }

  /// Supervisor dapat melihat dashboard analytics
  static bool canViewDashboard(String role) {
    return role == supervisor;
  }

  /// Supervisor dapat mengelola assignment tugas
  static bool canAssignTasks(String role) {
    return role == supervisor;
  }

  /// Employee dapat memberikan rating
  static bool canRateCleaning(String role) {
    return role == employee;
  }

  /// Semua role dapat edit profile sendiri
  static bool canEditProfile(String role) {
    return allRoles.contains(role);
  }

  /// Supervisor dapat melihat performance metrics petugas
  static bool canViewPerformanceMetrics(String role) {
    return role == supervisor;
  }

  /// Supervisor dapat export data/laporan
  static bool canExportData(String role) {
    return role == supervisor;
  }

  // ==================== ROUTE HELPERS ====================

  /// Mendapatkan home route berdasarkan role
  static String getHomeRoute(String role) {
    switch (role) {
      case employee:
        return '/home_employee';
      case cleaner:
        return '/home_cleaner';
      case supervisor:
        return '/home_supervisor';
      default:
        return '/login';
    }
  }

  /// Check apakah role valid
  static bool isValidRole(String role) {
    return allRoles.contains(role);
  }

  /// Mendapatkan icon code point untuk role (untuk UI)
  static int getRoleIconCodePoint(String role) {
    switch (role) {
      case cleaner:
        return 0xe14a; // Icons.cleaning_services
      case employee:
        return 0xe7fd; // Icons.person
      case supervisor:
        return 0xe8f2; // Icons.admin_panel_settings
      default:
        return 0xe7fd; // Icons.person
    }
  }

  /// Mendapatkan warna untuk role (untuk UI)
  static int getRoleColorValue(String role) {
    switch (role) {
      case cleaner:
        return 0xFF42A5F5; // Blue
      case employee:
        return 0xFF66BB6A; // Green
      case supervisor:
        return 0xFF5E35B1; // Purple
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // ==================== HIERARCHY CHECKS ====================

  /// Mendapatkan level hierarki role (semakin tinggi semakin besar authority)
  static int getRoleLevel(String role) {
    switch (role) {
      case supervisor:
        return 3;
      case cleaner:
        return 2;
      case employee:
        return 1;
      default:
        return 0;
    }
  }

  /// Check apakah role1 memiliki authority lebih tinggi dari role2
  static bool hasHigherAuthority(String role1, String role2) {
    return getRoleLevel(role1) > getRoleLevel(role2);
  }

  /// Check apakah role adalah management level
  static bool isManagementLevel(String role) {
    return role == supervisor;
  }

  /// Check apakah role adalah operational level
  static bool isOperationalLevel(String role) {
    return role == cleaner || role == employee;
  }
}