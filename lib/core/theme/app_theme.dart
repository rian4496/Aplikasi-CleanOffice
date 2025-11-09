// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ==================== PALET WARNA UTAMA ====================

  // Primary Colors (Biru/Indigo)
  static const Color primary = Color(0xFF3F51B5); // Indigo 500
  static const Color primaryDark = Color(0xFF303F9F); // Indigo 700
  static const Color primaryLight = Color(0xFFE8EAF6); // Indigo 50

  // Secondary/Accent Color
  static const Color secondary = Color(0xFF448AFF); // Blue A200
  static const Color accent = Color(0xFF00BCD4); // Cyan

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Neutral Colors
  static const Color background = Color(0xFFF4F6F8); // Abu-abu sangat muda
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Hampir hitam
  static const Color textSecondary = Color(0xFF757575); // Abu-abu tua
  static const Color textHint = Color(0xFFBDBDBD); // Abu-abu muda
  static const Color divider = Color(0xFFE0E0E0);

  // ==================== MODERN DASHBOARD COLORS ====================

  // Header Gradient
  static const Color headerGradientStart = Color(0xFF5B6FE5);
  static const Color headerGradientEnd = Color(0xFF4F5FD8);

  // Stat Card Accent Colors
  static const Color blueAccent = Color(0xFF5B6FE5);
  static const Color orangeAccent = Color(0xFFFF9800);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  // Chart Colors (Multi-color bars)
  static const Color chartPink = Color(0xFFE91E63);
  static const Color chartPurple = Color(0xFF673AB7);
  static const Color chartNavy = Color(0xFF283593);
  static const Color chartMint = Color(0xFF4CAF50);
  static const Color chartYellow = Color(0xFFFFC107);
  static const Color chartOrange = Color(0xFFFF9800);

  // Modern Backgrounds
  static const Color modernBg = Color(0xFFF9FAFB); // Lighter gray
  static const Color cardBg = Colors.white;

  // Shadow helper
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: card,
        onSurface: textPrimary,
        // DIHAPUS: Properti 'background' di dalam ColorScheme sudah deprecated.
        // background: background, 
      ),

      // Scaffold
      // Pengaturan ini sudah benar untuk mengatur warna latar belakang utama aplikasi.
      scaffoldBackgroundColor: background,

      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: false,
        backgroundColor: card,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins', // Contoh penggunaan custom font
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: card,
        margin: EdgeInsets.zero,
      ),
      
      // TextTheme
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      
      // ListTileTheme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        iconColor: primary,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primary.withAlpha(26),
        labelStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
        side: BorderSide.none,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
