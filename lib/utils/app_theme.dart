import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF1A4D8C); // Deep Navy Kalsel
  static const Color secondary = Color(0xFFFFC107); // Golden Accent
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FB); // Ghost White
  static const Color error = Color(0xFFD32F2F);
  static const Color modernBg = Color(0xFFF3F4F6); // Light gray modern background
  
  // Semantic Colors
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color info = Color(0xFF29B6F6); // Light Blue
  static const Color success = Color(0xFF66BB6A); // Green
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gunmetal
  static const Color textSecondary = Color(0xFF6B7280); // Slate Gray

  // Spacing
  static const double spacingEmpty = 0.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Components Radius
  static final BorderRadius radiusMd = BorderRadius.circular(12.0);
  static final BorderRadius radiusLg = BorderRadius.circular(16.0);

  // Shadows
  static final List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
      ),
    );
  }
}

