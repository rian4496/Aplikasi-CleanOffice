// lib/utils/admin_route_helper.dart
// 📍 Admin Route Helper
// Helper functions for navigating to admin screens

import 'package:flutter/material.dart';
import '../screens/admin/dashboard/admin_dashboard_mobile_screen.dart';
import '../screens/admin/reports/reports_list_screen.dart';
import '../screens/admin/verification/verification_screen.dart';
import '../screens/admin/analytics/analytics_screen.dart';
import '../screens/admin/cleaners/cleaners_management_screen.dart';

class AdminRoutes {
  static const String dashboardMobile = '/admin/dashboard-mobile';
  static const String reports = '/admin/reports';
  static const String cleaners = '/admin/cleaners';
  static const String analyticsNew = '/admin/analytics-new';

  /// Navigate to mobile dashboard
  static void goToDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardMobileScreen(),
      ),
    );
  }

  /// Navigate to reports list
  static void goToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsListScreen(),
      ),
    );
  }

  /// Navigate to verification screen
  static void goToVerification(BuildContext context, String reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(reportId: reportId),
      ),
    );
  }

  /// Navigate to analytics
  static void goToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalyticsScreen(),
      ),
    );
  }

  /// Navigate to cleaners management
  static void goToCleaners(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CleanersManagementScreen(),
      ),
    );
  }
}
