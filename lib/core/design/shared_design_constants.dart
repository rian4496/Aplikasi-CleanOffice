import 'package:flutter/material.dart';

/// Shared Design Constants
/// Used across all modules (Admin, Employee, Cleaner)
/// Ensures consistency in spacing, sizing, borders, shadows, and animations
class SharedDesignConstants {
  SharedDesignConstants._();

  // ==================== SPACING SCALE ====================
  /// Spacing scale (based on 4px grid system)
  static const double space2xs = 2.0; // Tight spacing
  static const double spaceXs = 4.0; // Icon padding
  static const double spaceSm = 8.0; // Small gaps
  static const double spaceMd = 16.0; // Default padding
  static const double spaceLg = 24.0; // Section spacing
  static const double spaceXl = 32.0; // Large spacing
  static const double space2xl = 48.0; // Extra large spacing
  static const double space3xl = 64.0; // Massive spacing

  /// Common padding values
  static const EdgeInsets paddingSm = EdgeInsets.all(spaceSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spaceMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spaceLg);

  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: spaceMd);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: spaceMd);

  // ==================== SIZING ====================
  /// Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  /// Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 80.0;

  /// Touch target (Material Design min 48dp)
  static const double minTouchTarget = 48.0;

  /// Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  /// App bar height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 120.0;

  /// Bottom nav height
  static const double bottomNavHeight = 64.0;

  // ==================== BORDER RADIUS ====================
  /// Border radius values
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0; // Pill shape

  /// Common border radius
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  /// Top-only border radius (for bottom sheets, modals)
  static const BorderRadius borderRadiusTopMd = BorderRadius.vertical(
    top: Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusTopLg = BorderRadius.vertical(
    top: Radius.circular(radiusLg),
  );
  static const BorderRadius borderRadiusTopXl = BorderRadius.vertical(
    top: Radius.circular(radiusXl),
  );

  // ==================== SHADOWS (Elevation Levels) ====================
  /// Shadow level 0 - Flat (no shadow)
  static const List<BoxShadow> shadowNone = [];

  /// Shadow level 1 - Card (subtle depth)
  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Shadow level 2 - Elevated (medium depth)
  static final List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Shadow level 3 - Modal (strong depth)
  static final List<BoxShadow> shadowModal = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Hover shadow (for interactive elements)
  static final List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  /// Bottom nav shadow (top shadow)
  static final List<BoxShadow> shadowBottomNav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, -2),
    ),
  ];

  // ==================== ANIMATION DURATIONS ====================
  /// Animation duration constants
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 800);

  // ==================== ANIMATION CURVES ====================
  /// Animation curves
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveQuick = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.easeOutBack;

  // ==================== RESPONSIVE BREAKPOINTS ====================
  /// Breakpoints for responsive layout
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointXl = 1536.0;

  /// Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointTablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointDesktop;

  // ==================== STAT CARD COLORS (Shared Pastel Palette) ====================
  /// Shared stat card color palette (used by all modules)
  static const List<StatCardColorPair> statCardColors = [
    StatCardColorPair(
      background: Color(0xFFFFF1F2), // Pink 50
      foreground: Color(0xFFBE123C), // Rose 700
    ),
    StatCardColorPair(
      background: Color(0xFFEFF6FF), // Blue 50
      foreground: Color(0xFF1E40AF), // Blue 800
    ),
    StatCardColorPair(
      background: Color(0xFFF0FDF4), // Green 50
      foreground: Color(0xFF15803D), // Green 700
    ),
    StatCardColorPair(
      background: Color(0xFFFEFCE8), // Yellow 50
      foreground: Color(0xFFA16207), // Yellow 700
    ),
    StatCardColorPair(
      background: Color(0xFFF5F3FF), // Purple 50
      foreground: Color(0xFF7C3AED), // Purple 600
    ),
    StatCardColorPair(
      background: Color(0xFFFFF7ED), // Orange 50
      foreground: Color(0xFFC2410C), // Orange 700
    ),
  ];

  /// Get stat card colors by index (rotating)
  static StatCardColorPair getStatCardColors(int index) {
    return statCardColors[index % statCardColors.length];
  }
}

/// Stat card color pair
class StatCardColorPair {
  final Color background;
  final Color foreground;

  const StatCardColorPair({
    required this.background,
    required this.foreground,
  });
}
