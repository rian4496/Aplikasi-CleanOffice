// lib/riverpod/dashboard_stats_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/stat_card_data.dart';
import '../../core/theme/app_theme.dart';
import 'admin_providers.dart';
import 'report_providers.dart';
import 'request_providers.dart';

/// Provider for dashboard statistics cards
final dashboardStatsProvider = Provider<List<StatCardData>>((ref) {
  // Watch all necessary providers
  final departmentId = ref.watch(currentUserDepartmentProvider);
  final allReportsAsync = ref.watch(allReportsProvider(departmentId));
  final allRequestsAsync = ref.watch(allRequestsProvider);

  // Get counts from providers
  final needsVerificationCount = ref.watch(needsVerificationCountProvider);
  final todayReportsCount = ref.watch(todayReportsCountProvider);

  // Extract data or use defaults
  final allReports = allReportsAsync.asData?.value ?? [];
  final allRequests = allRequestsAsync.asData?.value ?? [];

  // Calculate metrics
  final totalReportsToday = todayReportsCount;

  final needsVerification = needsVerificationCount;

  final activeRequests =
      allRequests.where((r) => r.status.name != 'completed').length;

  final completedReports = allReports
      .where((r) => r.status.name == 'completed' || r.status.name == 'verified')
      .length;

  final completionRate = allReports.isNotEmpty
      ? ((completedReports / allReports.length) * 100).toInt()
      : 0;

  // Calculate trends (mock data for now - you can implement real comparison later)
  final totalReportsTrend = totalReportsToday > 5 ? 12 : -5;
  final verificationTrend = needsVerification < 10 ? 8 : -3;
  final requestsTrend = activeRequests > 0 ? 5 : 0;
  final completionTrend = completionRate > 80 ? 3 : -2;

  return [
    // 1. Total Laporan Hari Ini
    StatCardData(
      label: 'Total Laporan',
      sublabel: 'Hari Ini',
      value: totalReportsToday,
      percentage: completionRate.toDouble(),
      accentColor: AppTheme.blueAccent,
      icon: LucideIcons.clipboardList,
      comparisonValue: totalReportsTrend,
      isPositiveTrend: true,
    ),

    // 2. Perlu Verifikasi
    StatCardData(
      label: 'Perlu Verifikasi',
      sublabel: 'Minggu Ini',
      value: needsVerification,
      percentage: allReports.isNotEmpty
          ? ((needsVerification / allReports.length) * 100)
          : 0,
      accentColor: AppTheme.orangeAccent,
      icon: LucideIcons.alertTriangle,
      comparisonValue: verificationTrend,
      isPositiveTrend: false, // Lower is better for pending items
    ),

    // 3. Permintaan Aktif
    StatCardData(
      label: 'Permintaan Aktif',
      sublabel: 'Bulan Ini',
      value: activeRequests,
      percentage: allRequests.isNotEmpty
          ? ((activeRequests / allRequests.length) * 100)
          : 0,
      accentColor: AppTheme.greenAccent,
      icon: LucideIcons.bellRing,
      comparisonValue: requestsTrend,
      isPositiveTrend: true,
    ),

    // 4. Tingkat Penyelesaian
    StatCardData(
      label: 'Tingkat Penyelesaian',
      sublabel: 'Performance',
      value: completionRate,
      percentage: completionRate.toDouble(),
      accentColor: AppTheme.purpleAccent,
      icon: LucideIcons.trendingUp,
      comparisonValue: completionTrend,
      isPositiveTrend: true,
    ),
  ];
});

