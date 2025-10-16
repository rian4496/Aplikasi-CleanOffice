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
}