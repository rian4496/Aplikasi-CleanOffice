// lib/core/design/admin_typography.dart
// ✍️ Admin Role - Typography System
// Consistent text styles for mobile and desktop

import 'package:flutter/material.dart';

/// Admin-specific typography
/// Optimized for readability on mobile and desktop
class AdminTypography {
  AdminTypography._(); // Private constructor

  // ==================== FONT FAMILY ====================
  
  static const String fontFamily = 'Inter'; // or 'Roboto', 'SF Pro'

  // ==================== HEADINGS ====================
  
  /// H1 - Page titles (mobile: 28px, desktop: 32px)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h1Mobile = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
  );

  /// H2 - Section titles (mobile: 20px, desktop: 24px)
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h2Mobile = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
    fontFamily: fontFamily,
  );

  /// H3 - Card titles
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// H4 - Subheadings
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// H5 - Small headings
  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
  );

  // ==================== BODY TEXT ====================
  
  /// Body 1 - Primary body text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );

  /// Body 2 - Secondary body text
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );

  /// Caption - Small explanatory text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// Overline - Labels, tags
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    fontFamily: fontFamily,
  );

  // ==================== SPECIAL STYLES ====================
  
  /// Stat number - Large numbers in stat cards (mobile: 32px, desktop: 36px)
  static const TextStyle statNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFamily: fontFamily,
  );
  
  static const TextStyle statNumberMobile = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFamily: fontFamily,
  );

  /// Stat label - Labels in stat cards
  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontFamily: fontFamily,
  );

  /// Card title - Titles in cards
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// Button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.25,
    fontFamily: fontFamily,
  );

  /// Button text (large)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.25,
    fontFamily: fontFamily,
  );

  /// Badge text - Status badges
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Timestamp - "2 menit lalu"
  static const TextStyle timestamp = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    fontFamily: fontFamily,
  );

  // ==================== HELPER METHODS ====================
  
  /// Get heading style based on screen size
  static TextStyle getH1(bool isMobile) => isMobile ? h1Mobile : h1;
  static TextStyle getH2(bool isMobile) => isMobile ? h2Mobile : h2;
  static TextStyle getStatNumber(bool isMobile) =>
      isMobile ? statNumberMobile : statNumber;

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply opacity to text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withValues(alpha: opacity),
    );
  }
}

