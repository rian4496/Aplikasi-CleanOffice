class UserRole {
  static const String cleaner = 'cleaner';
  static const String employee = 'employee';

  static List<String> get allRoles => [cleaner, employee];

  static String getRoleDisplayName(String role) {
    switch (role) {
      case cleaner:
        return 'Petugas Kebersihan';
      case employee:
        return 'Karyawan';
      default:
        return role;
    }
  }

  static String getRoleDescription(String role) {
    switch (role) {
      case cleaner:
        return 'Melakukan tugas kebersihan dan membuat laporan';
      case employee:
        return 'Membuat permintaan dan evaluasi kebersihan';
      default:
        return 'Akses terbatas ke sistem';
    }
  }

  static bool canRequestCleaning(String role) {
    return role == employee;
  }

  static bool canSubmitReport(String role) {
    return role == cleaner;
  }

  // Permission check for basic profile editing
  static bool canEditProfile(String role) {
    return allRoles.contains(role); // All roles can edit their own profile
  }

  // Check if user can rate cleaning service
  static bool canRateCleaning(String role) {
    return role == employee;
  }
}