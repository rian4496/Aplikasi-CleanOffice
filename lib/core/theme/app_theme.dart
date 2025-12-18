import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Kept for backward compatibility)
  static const Color primary = Color(0xFF1A4D8C); // Deep Navy Kalsel
  static const Color primaryLight = Color(0xFF3D6FAC); // Lighter Navy
  static const Color primaryDark = Color(0xFF0F3159); // Darker Navy
  static const Color secondary = Color(0xFFFFC107); // Golden Accent
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FB); // Ghost White
  static const Color error = Color(0xFFD32F2F);
  static const Color modernBg = Color(0xFFF3F4F6); // Light gray modern background
  
  // Gradient Colors
  static const Color headerGradientStart = Color(0xFF1A4D8C); // Same as primary
  static const Color headerGradientEnd = Color(0xFF2E6CB5); // Lighter blue
  
  // Semantic Colors
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color info = Color(0xFF29B6F6); // Light Blue
  static const Color success = Color(0xFF66BB6A); // Green
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gunmetal
  static const Color textSecondary = Color(0xFF6B7280); // Slate Gray
  static const Color textHint = Color(0xFF9CA3AF); // Gray-400 for hint text

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
  static final BorderRadius cardRadius = BorderRadius.circular(12.0); // Alias for cards
  
  // Shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

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
  
  // Accent Colors (for dashboard stats)
  static const Color orangeAccent = Color(0xFFFF9800);
  static const Color greenAccent = Color(0xFF4CAF50);
  static const Color purpleAccent = Color(0xFF9C27B0);
  static const Color blueAccent = Color(0xFF2196F3);
  
  // Chart Colors
  static const Color chartPrimary = Color(0xFF1A4D8C);
  static const Color chartSecondary = Color(0xFF4CAF50);
  static const Color chartYellow = Color(0xFFFFC107); // Amber/Yellow
  static const Color chartMint = Color(0xFF26A69A); // Teal/Mint  
  static const Color chartPink = Color(0xFFE91E63); // Pink
  static const Color chartShadow = Color(0xFF455A64); // Blue Grey 700
  
  // Card & Layout Colors
  static const Color card = Color(0xFFFFFFFF); // White card background
  static const Color divider = Color(0xFFE5E7EB); // Gray-200 divider
  static const Color chartNavy = Color(0xFF1A4D8C); // Same as primary for charts
  
  // Card Shadow
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  // Status Colors (Badges)
  static const Color badgePending = Color(0xFFFCD34D); // Yellow 300
  static const Color badgeInProgress = Color(0xFF60A5FA); // Blue 400
  static const Color badgeCompleted = Color(0xFF34D399); // Green 400
  static const Color badgeUrgent = Color(0xFFF87171); // Red 400

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return badgePending;
      case 'inprogress':
      case 'in_progress':
        return badgeInProgress;
      case 'completed':
      case 'verified':
        return badgeCompleted;
      case 'urgent':
        return badgeUrgent;
      default:
        return textSecondary;
    }
  }

  // ✅ FLEX COLOR SCHEME IMPLEMENTATION
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primary,
        primaryContainer: Color(0xFFD0E4FF),
        secondary: secondary,
        secondaryContainer: Color(0xFFFFD740),
        tertiary: Color(0xFF006875),
        tertiaryContainer: Color(0xFF95F0FF),
        appBarColor: Color(0xFFFFD740), // Same as secondaryContainer
        error: error,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 12.0,
        elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
        elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        fabUseShape: true,
        fabRadius: 16.0,
        chipRadius: 8.0,
        cardRadius: 12.0,
        popupMenuRadius: 8.0,
      ),
      visualDensity: VisualDensity.comfortable,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }
  
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF9ECAFF),
        primaryContainer: Color(0xFF003258),
        secondary: Color(0xFFFFB300),
        secondaryContainer: Color(0xFFC76800),
        tertiary: Color(0xFF4DD0E1),
        tertiaryContainer: Color(0xFF004D40),
        appBarColor: Color(0xFFC76800), // Same as secondaryContainer
        error: Color(0xFFCF6679),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 12.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        fabUseShape: true,
        fabRadius: 16.0,
        chipRadius: 8.0,
        cardRadius: 12.0,
        popupMenuRadius: 8.0,
      ),
      visualDensity: VisualDensity.comfortable,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }
}

