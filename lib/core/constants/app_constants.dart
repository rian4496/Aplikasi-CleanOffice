import 'package:flutter/material.dart';

/// Centralized constants untuk aplikasi Clean Office
/// Menghindari hardcoded values yang tersebar di codebase

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ==================== APP INFO ====================
  static const String appName = 'Clean Office';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem Manajemen Kebersihan';

  // ==================== FIRESTORE COLLECTIONS ====================
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String requestsCollection = 'requests';
  static const String departmentsCollection = 'departments';
  static const String schedulesCollection = 'schedules';
  static const String notificationsCollection = 'notifications';

  // ==================== STORAGE PATHS ====================
  static const String profilePicturesPath = 'profile_pictures';
  static const String reportImagesPath = 'report_images';
  static const String requestImagesPath = 'request_images';

  // ==================== ROUTES ====================
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeEmployeeRoute = '/home_employee';
  static const String homeCleanerRoute = '/home_cleaner';
  static const String homeAdminRoute = '/home_admin';
  static const String profileRoute = '/profile';
  static const String createReportRoute = '/create_report';
  static const String createRequestRoute = '/create_request';
  static const String reportDetailRoute = '/report_detail';
  static const String requestDetailRoute = '/request_detail';
  static const String verificationRoute = '/verification';
  static const String requestHistoryRoute = '/request_history';
  static const String editProfileRoute = '/edit_profile';
  static const String changePasswordRoute = '/change_password';

  // ==================== LOCATIONS ====================
  static const List<String> predefinedLocations = [
    'Toilet Lantai 1',
    'Toilet Lantai 2',
    'Toilet Lantai 3',
    'Area Lobby',
    'Dapur Karyawan',
    'Ruang Rapat A-101',
    'Ruang Rapat A-102',
    'Ruang Rapat B-201',
    'Ruang Rapat B-202',
    'Halaman Depan',
    'Halaman Belakang',
    'Ruang Server',
    'Pantry Lantai 1',
    'Pantry Lantai 2',
    'Area Parkir Indoor',
    'Area Parkir Outdoor',
    'Musholla',
    'Cafeteria',
    'Gudang',
    'Ruang HRD',
  ];

  // ==================== PAGINATION ====================
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 50;
  static const int recentItemsLimit = 5;

  // ==================== VALIDATION ====================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;

  // ==================== FILE UPLOAD ====================
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int imageQuality = 85;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // ==================== TIMEOUTS ====================
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration cacheTimeout = Duration(hours: 1);

  // ==================== UI ====================
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  // ==================== ANIMATION ====================
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ==================== COLORS (Material 3 compatible) ====================
  static const Color primaryColor = Color(0xFF5E35B1); // Deep Purple
  static const Color secondaryColor = Color(0xFF42A5F5); // Blue
  static const Color errorColor = Color(0xFFEF5350); // Red
  static const Color successColor = Color(0xFF66BB6A); // Green
  static const Color warningColor = Color(0xFFFFA726); // Orange
  static const Color infoColor = Color(0xFF29B6F6); // Light Blue

  // Status colors
  static const Color pendingColor = Color(0xFFFFA726); // Orange
  static const Color assignedColor = Color(0xFF42A5F5); // Blue
  static const Color inProgressColor = Color(0xFF29B6F6); // Light Blue
  static const Color completedColor = Color(0xFF66BB6A); // Green
  static const Color verifiedColor = Color(0xFF4CAF50); // Dark Green
  static const Color rejectedColor = Color(0xFFEF5350); // Red

  // ==================== DATE FORMATS ====================
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String fullDateTimeFormat = 'dd MMMM yyyy HH:mm:ss';

  // ==================== ERROR MESSAGES ====================
  static const String genericErrorMessage = 'Terjadi kesalahan. Silakan coba lagi';
  static const String networkErrorMessage = 'Koneksi internet bermasalah';
  static const String noDataMessage = 'Tidak ada data';
  static const String unauthorizedMessage = 'Anda tidak memiliki akses';
  static const String sessionExpiredMessage = 'Sesi Anda telah berakhir. Silakan login kembali';

  // ==================== SUCCESS MESSAGES ====================
  static const String loginSuccessMessage = 'Login berhasil';
  static const String logoutSuccessMessage = 'Logout berhasil';
  static const String registerSuccessMessage = 'Registrasi berhasil';
  static const String updateSuccessMessage = 'Data berhasil diperbarui';
  static const String deleteSuccessMessage = 'Data berhasil dihapus';
  static const String submitSuccessMessage = 'Data berhasil dikirim';

  // ==================== CONFIRMATION MESSAGES ====================
  static const String deleteConfirmMessage = 'Apakah Anda yakin ingin menghapus?';
  static const String logoutConfirmMessage = 'Apakah Anda yakin ingin keluar?';
  static const String cancelConfirmMessage = 'Apakah Anda yakin ingin membatalkan?';

  // ==================== VALIDATION MESSAGES ====================
  static const String requiredFieldMessage = 'Field ini wajib diisi';
  static const String invalidEmailMessage = 'Format email tidak valid';
  static const String passwordTooShortMessage = 'Password minimal $minPasswordLength karakter';
  static const String passwordMismatchMessage = 'Password tidak cocok';
  static const String invalidPhoneMessage = 'Nomor telepon tidak valid';

  // ==================== REGEX PATTERNS ====================
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^(\+62|62|0)[0-9]{9,13}$',
  );
  static final RegExp nameRegex = RegExp(
    r'^[a-zA-Z\s]+$',
  );

  // ==================== HELPER METHODS ====================

  /// Validate email format
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  /// Validate phone format (Indonesia)
  static bool isValidPhone(String phone) {
    return phoneRegex.hasMatch(phone);
  }

  /// Validate name (only letters and spaces)
  static bool isValidName(String name) {
    return nameRegex.hasMatch(name) && 
           name.length >= minNameLength && 
           name.length <= maxNameLength;
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength && 
           password.length <= maxPasswordLength;
  }

  /// Check if file size is valid
  static bool isValidFileSize(int bytes) {
    return bytes <= maxImageSizeBytes;
  }

  /// Format file size to human readable
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Extension untuk easy access ke constants
extension BuildContextExtension on BuildContext {
  // Easy access ke theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Easy access ke screen size
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  
  // Easy access ke padding
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}