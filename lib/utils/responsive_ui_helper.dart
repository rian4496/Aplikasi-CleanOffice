// lib/utils/responsive_ui_helper.dart

import 'package:flutter/material.dart';
import 'package:aplikasi_cleanoffice/core/utils/responsive_helper.dart';

/// Utility class untuk menangani responsive UI patterns
/// Web: Dialogs, Side Panels, Modals
/// Mobile: Full Screens, Bottom Sheets
class ResponsiveUIHelper {
  /// Determine if should use dialog/modal based on platform
  /// Returns true untuk desktop/web, false untuk mobile
  static bool shouldUseDialog(BuildContext context) {
    return ResponsiveHelper.isDesktop(context);
  }

  /// Show detail view dengan platform-specific pattern
  /// - Web: Dialog modal
  /// - Mobile: Full screen navigation atau Bottom Sheet
  static Future<T?> showDetailView<T>({
    required BuildContext context,
    required Widget mobileScreen,
    required Widget webDialog,
    bool useBottomSheet = false,
  }) {
    if (shouldUseDialog(context)) {
      // Web: Show dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (context) => webDialog,
      );
    } else {
      // Mobile: Navigate to full screen or show bottom sheet
      if (useBottomSheet) {
        return showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => mobileScreen,
        );
      } else {
        return Navigator.push<T>(
          context,
          MaterialPageRoute(builder: (context) => mobileScreen),
        );
      }
    }
  }

  /// Show form view dengan platform-specific pattern
  /// - Web: Centered dialog
  /// - Mobile: Full screen navigation
  static Future<T?> showFormView<T>({
    required BuildContext context,
    required Widget mobileScreen,
    required Widget webDialog,
  }) {
    if (shouldUseDialog(context)) {
      // Web: Show centered dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.9,
            child: webDialog,
          ),
        ),
      );
    } else {
      // Mobile: Navigate to full screen
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => mobileScreen),
      );
    }
  }

  /// Show quick action dengan platform-specific pattern
  /// - Web: Small/Medium dialog
  /// - Mobile: Bottom sheet
  static Future<T?> showQuickAction<T>({
    required BuildContext context,
    required Widget content,
    double? webDialogWidth,
  }) {
    if (shouldUseDialog(context)) {
      // Web: Show dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: webDialogWidth ?? 500,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: content,
          ),
        ),
      );
    } else {
      // Mobile: Show bottom sheet
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: content,
        ),
      );
    }
  }

  /// Show confirmation dialog (same on all platforms)
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Get appropriate padding based on platform
  static EdgeInsets getPlatformPadding(BuildContext context) {
    return EdgeInsets.all(
      shouldUseDialog(context) ? 24.0 : 16.0,
    );
  }

  /// Get appropriate spacing based on platform
  static double getPlatformSpacing(BuildContext context) {
    return shouldUseDialog(context) ? 20.0 : 16.0;
  }

  /// Navigate to screen dengan platform-specific pattern
  /// - Web: Navigate normal (sudah di web, tidak perlu dialog untuk navigasi)
  /// - Mobile: Navigate normal
  /// Gunakan method ini untuk navigasi biasa yang tidak memerlukan dialog
  static Future<T?> navigateToScreen<T>({
    required BuildContext context,
    required Widget screen,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Show wide dialog untuk screen dengan banyak konten (tabs, list, etc)
  /// - Web: Wide dialog (900px)
  /// - Mobile: Full screen navigation
  static Future<T?> showWideDialog<T>({
    required BuildContext context,
    required Widget mobileScreen,
    required Widget webDialog,
  }) {
    if (shouldUseDialog(context)) {
      // Web: Show wide dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (context) => webDialog,
      );
    } else {
      // Mobile: Navigate to full screen
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (context) => mobileScreen),
      );
    }
  }
}

