// lib/riverpod/chart_providers.dart
// Providers for chart data with Riverpod code generation

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/chart_data.dart';
import '../../services/analytics_service.dart';
import 'admin_providers.dart';

part 'chart_providers.g.dart';

// ==================== CHART TIME RANGE ====================

/// Selected time range for charts
@riverpod
class ChartTimeRangeNotifier extends _$ChartTimeRangeNotifier {
  @override
  ChartTimeRange build() => ChartTimeRange.thirtyDays;
  
  void setTimeRange(ChartTimeRange range) {
    state = range;
  }
}

// ==================== TREND DATA ====================

/// Reports trend data over time
@riverpod
Future<TrendData> reportsTrendData(Ref ref) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  final timeRange = ref.watch(chartTimeRangeProvider);
  
  return allReportsAsync.when(
    data: (reports) {
      return AnalyticsService.aggregateReportsByDate(reports, timeRange);
    },
    loading: () => const TrendData(
      totalReports: {},
      completedReports: {},
      pendingReports: {},
      urgentReports: {},
    ),
    error: (_, _) => const TrendData(
      totalReports: {},
      completedReports: {},
      pendingReports: {},
      urgentReports: {},
    ),
  );
}

// ==================== LOCATION STATS ====================

/// Reports aggregated by location
@riverpod
Future<List<LocationStats>> reportsByLocation(Ref ref) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  
  return allReportsAsync.when(
    data: (reports) {
      return AnalyticsService.aggregateReportsByLocation(reports);
    },
    loading: () => [],
    error: (_, _) => [],
  );
}

// ==================== STATUS STATS ====================

/// Reports aggregated by status
@riverpod
Future<List<StatusStats>> reportsByStatus(Ref ref) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  
  return allReportsAsync.when(
    data: (reports) {
      return AnalyticsService.aggregateReportsByStatus(reports);
    },
    loading: () => [],
    error: (_, _) => [],
  );
}

// ==================== CLEANER PERFORMANCE ====================

/// Top cleaners by performance
@riverpod
Future<List<CleanerPerformance>> topCleaners(Ref ref, {int limit = 10}) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  
  return allReportsAsync.when(
    data: (reports) {
      return AnalyticsService.getTopCleaners(reports, limit: limit);
    },
    loading: () => [],
    error: (_, _) => [],
  );
}

// ==================== SUMMARY STATS ====================

/// Summary statistics
@riverpod
Future<Map<String, dynamic>> summaryStats(Ref ref) async {
  final allReportsAsync = ref.watch(needsVerificationReportsProvider);
  
  return allReportsAsync.when(
    data: (reports) {
      return AnalyticsService.calculateSummaryStats(reports);
    },
    loading: () => {},
    error: (_, _) => {},
  );
}

