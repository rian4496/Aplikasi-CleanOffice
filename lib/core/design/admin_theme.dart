// lib/core/design/admin_theme.dart
// 🎨 Admin Role - Theme Configuration
// Complete theme setup for Admin role

import 'package:flutter/material.dart';
import 'admin_colors.dart';
import 'admin_typography.dart';
import 'admin_constants.dart';

/// Admin theme configuration
class AdminTheme {
  AdminTheme._(); // Private constructor

  /// Get ThemeData for Admin
  static ThemeData getTheme() {
    return ThemeData(
      // ==================== COLOR SCHEME ====================
      colorScheme: ColorScheme.light(
        primary: AdminColors.primary,
        primaryContainer: AdminColors.primaryLight,
        secondary: AdminColors.info,
        secondaryContainer: AdminColors.cardBlueBg,
        surface: AdminColors.surface,
        surfaceContainerHighest: AdminColors.background,
        error: AdminColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AdminColors.textPrimary,
        onError: Colors.white,
      ),

      // ==================== SCAFFOLD ====================
      scaffoldBackgroundColor: AdminColors.background,
      
      // ==================== APP BAR ====================
      appBarTheme: AppBarTheme(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AdminTypography.h3.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ==================== CARDS ====================
      cardTheme: CardTheme(
        color: AdminColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AdminConstants.borderRadiusCard,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // ==================== BUTTONS ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spaceLg,
            vertical: AdminConstants.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminConstants.buttonRadius),
          ),
          textStyle: AdminTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spaceLg,
            vertical: AdminConstants.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminConstants.buttonRadius),
          ),
          side: const BorderSide(color: AdminColors.primary),
          textStyle: AdminTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AdminColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spaceMd,
            vertical: AdminConstants.spaceSm,
          ),
          textStyle: AdminTypography.button,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
        ),
      ),

      // ==================== INPUT ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          borderSide: const BorderSide(color: AdminColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
          borderSide: const BorderSide(color: AdminColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spaceMd,
          vertical: AdminConstants.spaceMd,
        ),
        hintStyle: AdminTypography.body2.copyWith(
          color: AdminColors.textSecondary,
        ),
      ),

      // ==================== CHIP ====================
      chipTheme: ChipThemeData(
        backgroundColor: AdminColors.surface,
        selectedColor: AdminColors.primaryLight,
        disabledColor: AdminColors.background,
        padding: const EdgeInsets.symmetric(
          horizontal: AdminConstants.spaceMd,
          vertical: AdminConstants.spaceSm,
        ),
        labelStyle: AdminTypography.body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminConstants.chipRadius),
          side: const BorderSide(color: AdminColors.border),
        ),
      ),

      // ==================== BOTTOM NAV ====================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AdminColors.surface,
        selectedItemColor: AdminColors.primary,
        unselectedItemColor: AdminColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ==================== DIVIDER ====================
      dividerColor: AdminColors.divider,
      dividerTheme: const DividerThemeData(
        color: AdminColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ==================== ICON ====================
      iconTheme: const IconThemeData(
        color: AdminColors.textPrimary,
        size: AdminConstants.iconMd,
      ),

      // ==================== TEXT THEME ====================
      textTheme: TextTheme(
        displayLarge: AdminTypography.h1,
        displayMedium: AdminTypography.h2,
        displaySmall: AdminTypography.h3,
        headlineMedium: AdminTypography.h4,
        headlineSmall: AdminTypography.h5,
        titleLarge: AdminTypography.h3,
        titleMedium: AdminTypography.cardTitle,
        titleSmall: AdminTypography.body1,
        bodyLarge: AdminTypography.body1,
        bodyMedium: AdminTypography.body2,
        bodySmall: AdminTypography.caption,
        labelLarge: AdminTypography.button,
        labelSmall: AdminTypography.overline,
      ),

      // ==================== MISC ====================
      fontFamily: AdminTypography.fontFamily,
      useMaterial3: true,
    );
  }
}
