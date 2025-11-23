// lib/core/design/admin_colors.dart
// 🎨 Admin Role - Color Palette
// Mobile-first color system with pastel cards and status colors

import 'package:flutter/material.dart';

/// Admin-specific color palette
/// Includes pastel colors for mobile stat cards and status colors
class AdminColors {
  AdminColors._(); // Private constructor to prevent instantiation

  // ==================== PRIMARY COLORS ====================
  
  /// Main brand color (Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // ==================== STATUS COLORS ====================
  
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // ==================== NEUTRAL COLORS ====================
  
  static const Color background = Color(0xFFF9FAFB); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color divider = Color(0xFFD1D5DB); // Gray 300
  
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textDisabled = Color(0xFF9CA3AF); // Gray 400

  // ==================== PASTEL STAT CARDS (Mobile) ====================
  
  /// Pastel backgrounds for mobile stat cards
  static const Color cardPinkBg = Color(0xFFFFF1F2); // Rose 50
  static const Color cardBlueBg = Color(0xFFEFF6FF); // Blue 50
  static const Color cardGreenBg = Color(0xFFF0FDF4); // Green 50
  static const Color cardYellowBg = Color(0xFFFEFCE8); // Yellow 50
  static const Color cardPurpleBg = Color(0xFFFAF5FF); // Purple 50
  
  /// Darker foreground colors for stat cards (for contrast)
  static const Color cardPinkDark = Color(0xFFBE123C); // Rose 700
  static const Color cardBlueDark = Color(0xFF1E40AF); // Blue 700
  static const Color cardGreenDark = Color(0xFF15803D); // Green 700
  static const Color cardYellowDark = Color(0xFFA16207); // Yellow 700
  static const Color cardPurpleDark = Color(0xFF6B21A8); // Purple 700

  // ==================== CHART COLORS ====================
  
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartYellow = Color(0xFFF59E0B);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color chartPink = Color(0xFFEC4899);
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartTeal = Color(0xFF14B8A6);
  
  /// Chart colors for weekly report (4 status bars)
  static const Color chartNavy = Color(0xFF1E3A8A); // Navy for In Progress
  static const Color chartMint = Color(0xFF6EE7B7); // Mint for Completed

  // ==================== STATUS BADGE COLORS ====================
  
  /// Status badge colors (lighter, for mobile)
  static const Color badgePending = Color(0xFFFCD34D); // Yellow 300
  static const Color badgeInProgress = Color(0xFF60A5FA); // Blue 400
  static const Color badgeNeedsVerify = Color(0xFFC084FC); // Purple 400
  static const Color badgeCompleted = Color(0xFF34D399); // Green 400
  static const Color badgeUrgent = Color(0xFFF87171); // Red 400

  // ==================== GRADIENT COLORS ====================
  
  /// Gradient for AppBar (mobile)
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradient for header (desktop)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ==================== HELPER METHODS ====================
  
  /// Get pastel color pair for stat card by index
  static StatCardColors getStatCardColors(int index) {
    final colors = [
      StatCardColors(cardPinkBg, cardPinkDark),
      StatCardColors(cardBlueBg, cardBlueDark),
      StatCardColors(cardGreenBg, cardGreenDark),
      StatCardColors(cardYellowBg, cardYellowDark),
      StatCardColors(cardPurpleBg, cardPurpleDark),
    ];
    return colors[index % colors.length];
  }

  /// Get chart color by index
  static Color getChartColor(int index) {
    final colors = [
      chartBlue,
      chartGreen,
      chartYellow,
      chartRed,
      chartPurple,
      chartPink,
      chartOrange,
      chartTeal,
    ];
    return colors[index % colors.length];
  }

  /// Get status badge color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return badgePending;
      case 'inprogress':
      case 'in_progress':
        return badgeInProgress;
      case 'needsverification':
      case 'needs_verification':
        return badgeNeedsVerify;
      case 'completed':
      case 'verified':
        return badgeCompleted;
      case 'urgent':
        return badgeUrgent;
      default:
        return textSecondary;
    }
  }
}

/// Helper class for stat card color pairs
class StatCardColors {
  final Color background;
  final Color foreground;

  const StatCardColors(this.background, this.foreground);
}
