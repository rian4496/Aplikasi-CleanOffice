// lib/core/design/inventory_design_tokens.dart
// Design tokens untuk Inventory Module
// Mengikuti AdminColors design system dengan pastel palette

import 'package:flutter/material.dart';
import 'admin_colors.dart';
import 'admin_constants.dart';
import 'admin_typography.dart';

/// Design tokens khusus untuk inventory module
/// Menggunakan pastel color palette dari AdminColors
class InventoryDesignTokens {
  InventoryDesignTokens._();

  // ==================== CATEGORY COLORS ====================

  /// Warna untuk kategori Alat (Tools)
  static const CategoryColors alat = CategoryColors(
    primary: Color(0xFF3B82F6), // Blue 500
    background: Color(0xFFEFF6FF), // Blue 50
    icon: Icons.cleaning_services,
    label: 'Alat Kebersihan',
  );

  /// Warna untuk kategori Consumable
  static const CategoryColors consumable = CategoryColors(
    primary: Color(0xFF10B981), // Green 500
    background: Color(0xFFF0FDF4), // Green 50
    icon: Icons.water_drop,
    label: 'Bahan Habis Pakai',
  );

  /// Warna untuk kategori PPE (Personal Protective Equipment)
  static const CategoryColors ppe = CategoryColors(
    primary: Color(0xFFF59E0B), // Amber 500
    background: Color(0xFFFFFBEB), // Amber 50
    icon: Icons.security,
    label: 'Alat Pelindung Diri',
  );

  /// Get category colors by category name
  static CategoryColors getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'alat':
        return alat;
      case 'consumable':
        return consumable;
      case 'ppe':
        return ppe;
      default:
        return alat; // Default fallback
    }
  }

  // ==================== STOCK STATUS COLORS ====================

  /// Warna untuk status Stok Cukup (In Stock ≥50%)
  static const StatusColors inStock = StatusColors(
    color: Color(0xFF10B981), // Green 500
    background: Color(0xFFD1FAE5), // Green 100
    label: 'Stok Cukup',
    icon: Icons.check_circle,
  );

  /// Warna untuk status Stok Sedang (Medium 30-49%)
  static const StatusColors mediumStock = StatusColors(
    color: Color(0xFFF59E0B), // Amber 500
    background: Color(0xFFFDE68A), // Amber 200
    label: 'Stok Sedang',
    icon: Icons.info,
  );

  /// Warna untuk status Stok Rendah (Low 1-29% or ≤ minStock)
  static const StatusColors lowStock = StatusColors(
    color: Color(0xFFF97316), // Orange 500
    background: Color(0xFFFFEDD5), // Orange 100
    label: 'Stok Rendah',
    icon: Icons.warning,
  );

  /// Warna untuk status Habis (Out of Stock 0%)
  static const StatusColors outOfStock = StatusColors(
    color: Color(0xFFEF4444), // Red 500
    background: Color(0xFFFEE2E2), // Red 100
    label: 'Habis',
    icon: Icons.cancel,
  );

  /// Get status colors by stock percentage and min stock
  static StatusColors getStatusColors(int currentStock, int maxStock, int minStock) {
    if (currentStock == 0) return outOfStock;

    final percentage = (currentStock / maxStock) * 100;

    if (currentStock <= minStock || percentage < 30) return lowStock;
    if (percentage < 50) return mediumStock;
    return inStock;
  }

  // ==================== CARD DESIGN ====================

  /// Card background colors - rotating pastel palette
  /// Menggunakan AdminColors.getStatCardColors untuk konsistensi
  static Color getCardBackground(int index) {
    final colorPair = AdminColors.getStatCardColors(index % 5);
    return colorPair.background;
  }

  /// Card foreground colors
  static Color getCardForeground(int index) {
    final colorPair = AdminColors.getStatCardColors(index % 5);
    return colorPair.foreground;
  }

  /// Card specifications
  static const double cardBorderRadius = AdminConstants.cardRadius; // 12px
  static const double cardPadding = AdminConstants.cardPadding; // 16px
  static const double cardMarginHorizontal = AdminConstants.screenPaddingHorizontal; // 16px
  static const double cardMarginVertical = AdminConstants.listGap; // 12px

  /// Card elevation
  static const double cardElevationNormal = 1.0;
  static const double cardElevationSelected = 4.0;
  static const double cardElevationHover = 2.0;

  /// Card shadow
  static BoxShadow get cardShadow => const BoxShadow(
    color: Color(0x0D000000), // Black with 0.05 opacity
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static BoxShadow get cardShadowElevated => const BoxShadow(
    color: Color(0x14000000), // Black with 0.08 opacity
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  // ==================== ICON CONTAINER ====================

  /// Icon container size
  static const double iconContainerSize = 56.0;
  static const double iconContainerRadius = 12.0;
  static const double iconSize = 32.0;

  /// Icon container background (white with opacity)
  static const Color iconContainerBackground = Color(0x4DFFFFFF); // White with 0.3 opacity

  // ==================== STATUS BADGE ====================

  /// Status badge styling
  static const double badgeBorderRadius = 999.0; // Full pill shape
  static const double badgePaddingHorizontal = 8.0;
  static const double badgePaddingVertical = 4.0;
  static const double badgeIconSize = 14.0;

  /// Badge text style
  static TextStyle get badgeTextStyle => AdminTypography.badge.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  /// Badge background with opacity (15%)
  static Color getBadgeBackground(Color statusColor) {
    // Convert to ARGB with 15% opacity (0.15 * 255 = ~38 = 0x26)
    final alpha = ((statusColor.a * 255.0).round() * 0.15).round();
    return statusColor.withAlpha(alpha);
  }

  // ==================== PROGRESS BAR ====================

  /// Progress bar styling
  static const double progressBarHeight = 6.0;
  static const double progressBarRadius = 3.0;
  static const Color progressBarBackground = AdminColors.border;

  /// Progress bar gradient (optional)
  static LinearGradient getProgressGradient(Color color) {
    final alpha80 = ((color.a * 255.0).round() * 0.8).round();
    final lightColor = color.withAlpha(alpha80);
    return LinearGradient(
      colors: [lightColor, color],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  // ==================== FILTER CHIPS ====================

  /// Chip styling
  static const double chipHeight = 40.0;
  static const double chipBorderRadius = 20.0;
  static const double chipPaddingHorizontal = 16.0;
  static const double chipIconSize = 20.0;
  static const double chipSpacing = 8.0;

  /// Chip active state
  static const Color chipActiveBackground = AdminColors.primary;
  static const Color chipActiveText = Colors.white;
  static List<BoxShadow> get chipActiveShadow => AdminConstants.shadowElevated;

  /// Chip inactive state
  static const Color chipInactiveBackground = Colors.white;
  static const Color chipInactiveText = AdminColors.textSecondary;
  static const Color chipInactiveBorder = AdminColors.border;

  // ==================== ALERT BANNER ====================

  /// Low stock alert banner colors
  static const Color alertBackground = Color(0xFFFFFBEB); // Amber 50
  static const Color alertBorder = Color(0xFFFDE68A); // Amber 200
  static const Color alertIcon = Color(0xFFD97706); // Amber 600
  static const Color alertText = Color(0xFF78350F); // Amber 900

  /// Alert banner styling
  static const double alertBorderRadius = AdminConstants.cardRadius;
  static const double alertPadding = 12.0;
  static const double alertIconSize = 24.0;

  // ==================== EMPTY STATE ====================

  /// Empty state icon container
  static const double emptyIconContainerSize = 80.0;
  static const double emptyIconSize = 48.0;
  static const double emptyIconRadius = 20.0;
  static const Color emptyIconBackground = Color(0xFFF3F4F6); // Gray 100
  static const Color emptyIconColor = Color(0xFF9CA3AF); // Gray 400

  /// Empty state CTA button
  static const Color emptyCTABackground = Color(0xFFE91E63); // Pink
  static const Color emptyCTAText = Colors.white;
  static const double emptyCTAPaddingVertical = 12.0;
  static const double emptyCTAPaddingHorizontal = 24.0;

  // ==================== GRID VIEW ====================

  /// Grid specifications
  static const int gridColumnsMobile = 1;
  static const int gridColumnsTablet = 2;
  static const int gridColumnsDesktop = 4;
  static const double gridSpacing = 12.0;
  static const double gridMinCardWidth = 280.0;

  // ==================== RESPONSIVE BREAKPOINTS ====================

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  /// Get grid columns based on screen width
  static int getGridColumns(double width) {
    if (width >= desktopBreakpoint) return gridColumnsDesktop;
    if (width >= tabletBreakpoint) return gridColumnsTablet;
    return gridColumnsMobile;
  }

  // ==================== ANIMATIONS ====================

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  /// Curves
  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveEntry = Curves.easeOut;
  static const Curve animationCurveExit = Curves.easeIn;

  // ==================== SPACING ====================

  /// Consistent spacing from AdminConstants
  static const double spaceXS = AdminConstants.spaceXs; // 4px
  static const double spaceSM = AdminConstants.spaceSm; // 8px
  static const double spaceMD = AdminConstants.spaceMd; // 16px
  static const double spaceLG = AdminConstants.spaceLg; // 24px
  static const double spaceXL = AdminConstants.spaceXl; // 32px

  // ==================== TYPOGRAPHY ====================

  /// Card text styles
  static TextStyle get itemNameStyle => AdminTypography.cardTitle;
  static TextStyle get categoryLabelStyle => AdminTypography.caption.copyWith(
    color: AdminColors.textSecondary,
  );
  static TextStyle get stockNumberStyle => AdminTypography.body1.copyWith(
    fontWeight: FontWeight.w600,
  );
  static TextStyle get stockPercentageStyle => AdminTypography.body2.copyWith(
    fontWeight: FontWeight.bold,
  );
  static TextStyle get metadataStyle => AdminTypography.caption.copyWith(
    color: AdminColors.textSecondary,
  );
  static TextStyle get buttonTextStyle => AdminTypography.button;

  /// Section headers
  static TextStyle get sectionTitleStyle => AdminTypography.h4;
  static TextStyle get statsNumberStyle => AdminTypography.statNumber;
  static TextStyle get statsLabelStyle => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}

/// Helper class untuk category colors
class CategoryColors {
  final Color primary;
  final Color background;
  final IconData icon;
  final String label;

  const CategoryColors({
    required this.primary,
    required this.background,
    required this.icon,
    required this.label,
  });
}

/// Helper class untuk status colors
class StatusColors {
  final Color color;
  final Color background;
  final String label;
  final IconData icon;

  const StatusColors({
    required this.color,
    required this.background,
    required this.label,
    required this.icon,
  });
}

