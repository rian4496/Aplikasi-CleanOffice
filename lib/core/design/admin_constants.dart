// lib/core/design/admin_constants.dart
// 📏 Admin Role - Design Constants
// Spacing, sizing, radius, shadows, and animations

import 'package:flutter/material.dart';

/// Admin design constants
/// Consistent spacing, sizing, and other design tokens
class AdminConstants {
  AdminConstants._(); // Private constructor

  // ==================== SPACING ====================
  
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // Screen padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 12.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  // Card padding
  static const double cardPadding = 16.0;
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);

  // Section padding
 static const double sectionPadding = 20.0;

  // Margins
  static const double cardMargin = 8.0;
  static const double sectionMargin = 16.0;

  // Gaps
  static const double gridGap = 12.0;
  static const double listGap = 8.0;

  // ==================== SIZING ====================
  
  // Touch targets
  static const double touchTargetMin = 48.0;
  static const double touchTargetComfortable = 56.0;
  static const double touchTargetLarge = 72.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;

  // FAB size
  static const double fabSize = 56.0;
  static const double fabIconSize = 24.0;

  // Bottom nav height
  static const double bottomNavHeight = 56.0;
  static const double bottomNavIconSize = 24.0;

  // AppBar height
  static const double appBarHeight = 56.0;

  // Stat card dimensions (mobile)
  static const double statCardHeight = 120.0;
  static const double statCardMinWidth = 150.0;

  // ==================== BORDER RADIUS ====================
  
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 9999.0;

  // Specific uses
  static const double buttonRadius = radiusSm;
  static const double cardRadius = radiusMd;
  static const double sheetRadius = radiusLg;
  static const double chipRadius = radiusRound;

  // BorderRadius objects
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(cardRadius));

  // ====== ============= SHADOWS ====================
  
  /// Card shadow (elevation 1)
  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Elevated shadow (elevation 2)
  static final List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Modal shadow (elevation 3)
  static final List<BoxShadow> shadowModal = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Hover shadow
  static final List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // ==================== ANIMATIONS ====================
  
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  // Easing curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutBack = Curves.easeOutBack;

  // ==================== BREAKPOINTS ====================
  
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  
  // Alias for compatibility with new screens
  static const double tabletBreakpoint = breakpointTablet;

  // Helper methods
  static bool isMobile(double width) => width < breakpointMobile;
  static bool isTablet(double width) =>
      width >= breakpointMobile && width < breakpointTablet;
  static bool isDesktop(double width) => width >= breakpointTablet;

  // ==================== GRID ====================
  
  /// Get cross axis count based on screen width
  static int getStatCardCrossAxisCount(double width) {
    if (width < breakpointMobile) return 2; // Mobile: 2x2
    if (width < breakpointTablet) return 3; // Tablet: 3 columns
    return 4; // Desktop: 4 columns
  }

  /// Get child aspect ratio for stat cards
  static double getStatCardAspectRatio(double width) {
    if (width < breakpointMobile) return 1.2; // Mobile: slightly wider
    return 1.4; // Desktop: more square
  }

  // ==================== Z-INDEX ====================
  
  static const int zIndexContent = 0;
  static const int zIndexAppBar = 10;
  static const int zIndexBottomNav = 20;
  static const int zIndexFAB = 30;
  static const int zIndexModal = 40;
  static const int zIndexToast = 50;
}
