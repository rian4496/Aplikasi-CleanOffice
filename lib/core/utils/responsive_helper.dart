// lib/core/utils/responsive_helper.dart
// Responsive utility for adaptive layouts across mobile, tablet, and desktop

import 'package:flutter/material.dart';

class ResponsiveHelper {
  // ==================== BREAKPOINTS ====================
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1024;
  
  // ==================== PLATFORM DETECTION ====================
  
  /// Returns true if screen width is less than 600px (mobile)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }
  
  /// Returns true if screen width is between 600px and 1024px (tablet)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }
  
  /// Returns true if screen width is 1024px or greater (desktop)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }
  
  // ==================== RESPONSIVE VALUES ====================
  
  /// Returns different values based on screen size
  /// If tablet value is not provided, uses mobile value
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  // ==================== SPACING ====================
  
  /// Returns adaptive padding based on screen size
  /// Mobile: 16px, Tablet: 24px, Desktop: 32px
  static double padding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }
  
  /// Returns adaptive margin based on screen size
  static double margin(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }
  
  /// Returns adaptive spacing between elements
  static double spacing(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }
  
  // ==================== GRID LAYOUT ====================
  
  /// Returns number of columns for grid based on screen size
  /// Mobile: 2, Tablet: 3, Desktop: 4
  static int gridColumns(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }
  
  /// Returns grid aspect ratio based on screen size
  static double gridAspectRatio(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1.2,
      tablet: 1.3,
      desktop: 1.4,
    );
  }
  
  // ==================== TYPOGRAPHY ====================
  
  /// Returns adaptive font size for headings
  static double headingFontSize(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
  }
  
  /// Returns adaptive font size for body text
  static double bodyFontSize(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 14.0,
      tablet: 15.0,
      desktop: 16.0,
    );
  }
  
  // ==================== SIDEBAR ====================
  
  /// Returns sidebar width for desktop/tablet
  static double sidebarWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0,
      tablet: 72,   // Rail navigation (icon only)
      desktop: 240, // Full sidebar with text
    );
  }
  
  /// Returns true if sidebar should be shown persistently
  static bool showPersistentSidebar(BuildContext context) {
    return isDesktop(context) || isTablet(context);
  }
  
  // ==================== CARDS ====================
  
  /// Returns card elevation based on screen size
  static double cardElevation(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 2.0,
      tablet: 3.0,
      desktop: 4.0,
    );
  }
  
  /// Returns card border radius based on screen size
  static double cardBorderRadius(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
  }
  
  // ==================== CONTENT WIDTH ====================
  
  /// Returns maximum content width for large screens
  /// Prevents content from stretching too wide on large monitors
  static double maxContentWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: double.infinity,
      tablet: double.infinity,
      desktop: 1600,
    );
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Returns appropriate cross axis count for grid/wrap
  static int getCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    return responsiveValue(
      context,
      mobile: mobile ?? 2,
      tablet: tablet ?? 3,
      desktop: desktop ?? 4,
    );
  }
  
  /// Returns device orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
