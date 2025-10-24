// lib/core/utils/date_formatter.dart

import 'package:intl/intl.dart';

/// Class utility terpusat untuk memformat tanggal secara konsisten.
///
/// Pastikan Anda sudah menjalankan `await initializeDateFormatting('id_ID', null);`
/// di file main.dart sebelum menggunakan class ini.
class DateFormatter {
  /// Format tanggal lengkap.
  /// Contoh: Senin, 16 Oktober 2025
  static String fullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal pendek.
  /// Contoh: 16 Okt 2025
  static String shortDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal dan waktu.
  /// Contoh: 16 Okt 10:30
  static String shortDateWithTime(DateTime date) {
    return DateFormat('dd MMM HH:mm', 'id_ID').format(date);
  }

  /// Format waktu saja.
  /// Contoh: 10:30
  static String timeOnly(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  // ==================== TAMBAHAN UNTUK CLEANER REPORTS ====================

  /// Format tanggal dengan waktu lengkap.
  /// Contoh: 20 Okt 2025, 14:30
  static String fullDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Format waktu relatif (relative time).
  /// Contoh: "2 menit lalu", "3 jam lalu", "Kemarin"
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }

  // ==================== TAMBAHAN UNTUK EMPLOYEE SCREENS ====================
  
  /// Format tanggal standar (alias untuk shortDate).
  /// Contoh: 24 Okt 2025
  /// Digunakan oleh report_history_screen.dart
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format waktu saja (alias untuk timeOnly).
  /// Contoh: 14:30
  /// Digunakan oleh report_detail_employee_screen.dart
  static String time(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }
}