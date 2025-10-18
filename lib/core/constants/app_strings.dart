// lib/core/constants/app_strings.dart

/// Centralized strings untuk aplikasi
/// Memudahkan maintenance dan internationalization di masa depan
class AppStrings {
  AppStrings._(); // Private constructor

  // ==================== EMPLOYEE HOME SCREEN ====================
  static const String employeeHomeTitle = 'Beranda Karyawan';
  static const String reportProblemTitle = 'Laporkan Masalah Kebersihan';
  static const String reportProblemSubtitle = 'Foto masalah kebersihan yang Anda temui';
  static const String createReportButton = 'Buat Laporan Baru';
  static const String createFirstReportButton = 'Buat Laporan Pertama';
  static const String reportHistoryTitle = 'Riwayat Laporan Anda';
  static const String searchReports = 'Cari laporan...';
  
  // Progress Cards
  static const String progressSent = 'Terkirim';
  static const String progressInProgress = 'Dikerjakan';
  static const String progressCompleted = 'Selesai';
  
  // Quick Actions
  static const String quickActionUrgent = 'Urgen';
  static const String quickActionHistory = 'Riwayat';
  static const String quickActionStats = 'Statistik';
  
  // Empty State
  static const String emptyStateTitle = 'Belum ada laporan';
  static const String emptyStateSubtitle = 'Laporkan masalah kebersihan yang Anda temui\nagar segera ditangani';
  static const String emptySearchTitle = 'Tidak ada hasil';
  static const String emptySearchSubtitle = 'Coba kata kunci lain';
  
  // Actions
  static const String deleteReport = 'Hapus Laporan';
  static const String deleteReportConfirm = 'Apakah Anda yakin ingin menghapus laporan ini?';
  static const String reportDeleted = 'Laporan dihapus';
  static const String undo = 'UNDO';
  static const String cancel = 'BATAL';
  static const String delete = 'HAPUS';
  
  // Logout
  static const String logoutTitle = 'Konfirmasi Logout';
  static const String logoutConfirm = 'Apakah Anda yakin ingin keluar?';
  static const String logout = 'KELUAR';
  
  // Error Messages
  static const String errorGeneric = 'Terjadi kesalahan';
  static const String errorDeleteFailed = 'Gagal menghapus';
  static const String tryAgain = 'Coba Lagi';
  
  // Sort & Filter
  static const String sortByNewest = 'Terbaru';
  static const String sortByOldest = 'Terlama';
  static const String sortByUrgent = 'Urgen';
  static const String sortByLocation = 'Lokasi';
  static const String filterAll = 'Semua';
  static const String filterPending = 'Menunggu';
  static const String filterInProgress = 'Dikerjakan';
  static const String filterCompleted = 'Selesai';
}