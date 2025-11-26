import 'package:flutter/material.dart';
import 'shared_design_constants.dart';

/// Cleaner Module Color Palette
/// Primary: Green theme (#10B981)
/// Fresh, energetic, task-oriented colors
class CleanerColors {
  CleanerColors._();

  // ==================== PRIMARY COLORS ====================
  /// Primary green - main brand color for Cleaner module
  static const Color primary = Color(0xFF10B981); // Green 500
  static const Color primaryLight = Color(0xFF34D399); // Green 400
  static const Color primaryDark = Color(0xFF059669); // Green 600
  static const Color primaryPastel = Color(0xFFF0FDF4); // Green 50

  // ==================== GRADIENT ====================
  /// AppBar gradient (Green to Teal)
  static const Color gradientStart = Color(0xFF10B981); // Green 500
  static const Color gradientEnd = Color(0xFF14B8A6); // Teal 500

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== STATUS COLORS (Shared from Admin) ====================
  /// Success color - task completed, verified
  static const Color success = Color(0xFF10B981); // Green 500
  static const Color successLight = Color(0xFF34D399); // Green 400
  static const Color successDark = Color(0xFF059669); // Green 600
  static const Color successBackground = Color(0xFFF0FDF4); // Green 50

  /// Warning color - in progress, pending
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400
  static const Color warningDark = Color(0xFFD97706); // Amber 600
  static const Color warningBackground = Color(0xFFFEFCE8); // Amber 50

  /// Error color - failed, overdue, high priority
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color errorDark = Color(0xFFDC2626); // Red 600
  static const Color errorBackground = Color(0xFFFFF1F2); // Red 50

  /// Info color - informational states
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA); // Blue 400
  static const Color infoDark = Color(0xFF2563EB); // Blue 600
  static const Color infoBackground = Color(0xFFEFF6FF); // Blue 50

  // ==================== NEUTRAL COLORS ====================
  /// Background colors
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color backgroundDark = Color(0xFFF3F4F6); // Gray 100
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDim = Color(0xFFF9FAFB); // Gray 50

  /// Text colors
  static const Color textPrimary = Color(0xFF1F2937); // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray 300
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  /// Border colors
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color borderDark = Color(0xFFD1D5DB); // Gray 300
  static const Color borderLight = Color(0xFFF3F4F6); // Gray 100

  /// Divider color
  static const Color divider = Color(0xFFE5E7EB); // Gray 200

  // ==================== PASTEL STAT CARD COLORS ====================
  /// Pastel colors for mobile stat cards (rotating palette)
  /// Emphasis on green/teal theme
  static const List<StatCardColorPair> statCardPalette = [
    StatCardColorPair(
      background: Color(0xFFF0FDF4), // Green 50
      foreground: Color(0xFF15803D), // Green 700
    ),
    StatCardColorPair(
      background: Color(0xFFEFF6FF), // Blue 50
      foreground: Color(0xFF1E40AF), // Blue 800
    ),
    StatCardColorPair(
      background: Color(0xFFF0FDFA), // Teal 50
      foreground: Color(0xFF115E59), // Teal 800
    ),
    StatCardColorPair(
      background: Color(0xFFFEFCE8), // Yellow 50
      foreground: Color(0xFFA16207), // Yellow 700
    ),
    StatCardColorPair(
      background: Color(0xFFFFF7ED), // Orange 50
      foreground: Color(0xFFC2410C), // Orange 700
    ),
    StatCardColorPair(
      background: Color(0xFFF5F3FF), // Purple 50
      foreground: Color(0xFF7C3AED), // Purple 600
    ),
  ];

  /// Get stat card colors by index (rotating)
  static StatCardColorPair getStatCardColors(int index) {
    return statCardPalette[index % statCardPalette.length];
  }

  // ==================== PERFORMANCE RATING COLORS ====================
  /// Performance/rating levels
  static const Color performanceExcellent = Color(0xFF10B981); // Green 500
  static const Color performanceGood = Color(0xFF3B82F6); // Blue 500
  static const Color performanceAverage = Color(0xFFF59E0B); // Amber 500
  static const Color performancePoor = Color(0xFFEF4444); // Red 500

  /// Get performance color by rating (0-5)
  static Color getPerformanceColor(double rating) {
    if (rating >= 4.5) return performanceExcellent;
    if (rating >= 3.5) return performanceGood;
    if (rating >= 2.5) return performanceAverage;
    return performancePoor;
  }

  /// Performance badge colors (for "Maluk", "Baik", etc)
  static const Color badgeExcellent = Color(0xFF10B981); // Green
  static const Color badgeGood = Color(0xFF3B82F6); // Blue
  static const Color badgeNeedsImprovement = Color(0xFFF59E0B); // Amber

  // ==================== PRIORITY COLORS ====================
  /// Task priority colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red 500
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber 500
  static const Color priorityLow = Color(0xFF3B82F6); // Blue 500
  static const Color priorityNormal = Color(0xFF6B7280); // Gray 500

  /// Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityNormal;
    }
  }

  // ==================== TASK STATUS COLORS ====================
  /// Task-specific status colors
  static const Color statusActive = Color(0xFF10B981); // Green - active tasks
  static const Color statusAvailable = Color(0xFF3B82F6); // Blue - available
  static const Color statusInProgress = Color(0xFFF59E0B); // Amber - in progress
  static const Color statusCompleted = Color(0xFF059669); // Dark green - done
  static const Color statusOverdue = Color(0xFFEF4444); // Red - overdue

  // ==================== BONUS/REWARD COLORS ====================
  /// Bonus points, achievements
  static const Color bonusGold = Color(0xFFF59E0B); // Amber 500
  static const Color bonusBackground = Color(0xFFFFFBEB); // Amber 25

  // ==================== CHART COLORS ====================
  /// Chart color palette for analytics (green-focused)
  static const List<Color> chartColors = [
    Color(0xFF10B981), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
  ];

  /// Get chart color by index
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}
