// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ==================== PALET WARNA UTAMA (MODERN) ====================

  // Primary Brand Colors (Purple/Blue Gradient)
  static const Color primary = Color(0xFF7B5AFF); // Vibrant Purple
  static const Color primaryDark = Color(0xFF5D5FEF); // Deep Purple/Blue
  static const Color primaryLight = Color(0xFFE9E3FF); // Light Purple

  // Secondary/Accent Colors
  static const Color secondary = Color(0xFF6AD2FF); // Light Blue
  static const Color accent = Color(0xFF4318FF); // Electric Blue

  // Status Colors
  static const Color success = Color(0xFF05CD99); // Mint Green
  static const Color warning = Color(0xFFFFB547); // Orange/Yellow
  static const Color error = Color(0xFFEE5D50); // Soft Red
  static const Color info = Color(0xFF11CDEF); // Cyan

  // Neutral Colors
  static const Color background = Color(0xFFF4F7FE); // Light Grayish Blue (Dashboard Bg)
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2B3674); // Deep Navy (Main Text)
  static const Color textSecondary = Color(0xFFA3AED0); // Cool Gray (Subtitles)
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E5F2);

  // ==================== DASHBOARD SPECIFIC COLORS ====================

  // Header Gradient (Light Blue - Softer)
  static const Color headerGradientStart = Color(0xFF64B5F6); // Light Blue
  static const Color headerGradientEnd = Color(0xFF42A5F5);   // Medium Blue (lighter, less dominant)

  // Stat Card Gradients
  static const List<Color> blueGradient = [Color(0xFF4481EB), Color(0xFF04BEFE)];
  static const List<Color> purpleGradient = [Color(0xFF89216B), Color(0xFFDA4453)];

  // Chart Colors
  static const Color chartPrimary = Color(0xFF4318FF);
  static const Color chartSecondary = Color(0xFF6AD2FF);
  static const Color chartTertiary = Color(0xFFEFF4FB);
  
  // Missing Colors from Error Log
  static const Color blueAccent = Color(0xFF4481EB);
  static const Color orangeAccent = Color(0xFFFFB547);
  static const Color greenAccent = Color(0xFF05CD99);
  static const Color purpleAccent = Color(0xFF89216B);
  
  static const Color chartPink = Color(0xFFFF7675);
  static const Color chartNavy = Color(0xFF2B3674);
  static const Color chartMint = Color(0xFF00B894);
  static const Color chartYellow = Color(0xFFFDCB6E);
  
  static const Color modernBg = Color(0xFFF4F7FE);

  // ==================== STYLES & SHADOWS ====================

  // Shadows
  static BoxShadow get cardShadow => BoxShadow(
    color: const Color(0xFF7090B0).withOpacity(0.08),
    blurRadius: 40,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFF7090B0).withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  // Border Radius
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 16.0;

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'DM Sans', // Modern font choice (needs to be added to pubspec)

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
      ),

      // Scaffold
      scaffoldBackgroundColor: background,

      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background, // Transparent look
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'DM Sans',
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0, // We use custom shadows
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        color: card,
        margin: EdgeInsets.zero,
      ),
      
      // TextTheme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),
      
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none, // Clean look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: Colors.black, width: 1), // Black, normal weight
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      
      // Text Selection (Cursor & Selection Color)
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black, // Black cursor
        selectionColor: Color(0x40000000), // Light black selection
        selectionHandleColor: Colors.black,
      ),
    );
  }
}
