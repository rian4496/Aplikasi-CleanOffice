// lib/models/analytics_data_freezed.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_data_freezed.freezed.dart';

/// Date range option for analytics filtering
enum DateRangeOption {
  last7Days,
  last30Days,
  last90Days,
  custom,
}

extension DateRangeOptionExtension on DateRangeOption {
  String get label {
    switch (this) {
      case DateRangeOption.last7Days:
        return '7 Hari Terakhir';
      case DateRangeOption.last30Days:
        return '30 Hari Terakhir';
      case DateRangeOption.last90Days:
        return '90 Hari Terakhir';
      case DateRangeOption.custom:
        return 'Custom Range';
    }
  }

  int get days {
    switch (this) {
      case DateRangeOption.last7Days:
        return 7;
      case DateRangeOption.last30Days:
        return 30;
      case DateRangeOption.last90Days:
        return 90;
      case DateRangeOption.custom:
        return 0; // Will be calculated from custom dates
    }
  }
}

/// KPI (Key Performance Indicator) data model
@freezed
class KPIData with _$KPIData {
  const KPIData._();

  const factory KPIData({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    double? trendPercentage, // Positive = up, Negative = down
    String? comparisonText, // "vs last month"
  }) = _KPIData;

  bool get isTrendPositive => trendPercentage != null && trendPercentage! > 0;
  bool get isTrendNegative => trendPercentage != null && trendPercentage! < 0;
}

/// Trend data point for line charts
@freezed
class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    required DateTime date,
    required double value,
    required String label,
  }) = _TrendDataPoint;
}

/// Department analytics data
@freezed
class DepartmentAnalytics with _$DepartmentAnalytics {
  const factory DepartmentAnalytics({
    required String departmentId,
    required String departmentName,
    required int totalReports,
    required int completedReports,
    required int pendingReports,
    required double completionRate,
    required Duration averageResponseTime,
  }) = _DepartmentAnalytics;

  factory DepartmentAnalytics.empty(String id, String name) {
    return DepartmentAnalytics(
      departmentId: id,
      departmentName: name,
      totalReports: 0,
      completedReports: 0,
      pendingReports: 0,
      completionRate: 0.0,
      averageResponseTime: Duration.zero,
    );
  }
}

/// Cleaner performance data for comparison table
@freezed
class CleanerPerformanceAnalytics with _$CleanerPerformanceAnalytics {
  const CleanerPerformanceAnalytics._();

  const factory CleanerPerformanceAnalytics({
    required String cleanerId,
    required String cleanerName,
    String? photoUrl,
    required int totalTasksCompleted,
    required int totalTasksAssigned,
    required double completionRate,
    required Duration averageCompletionTime,
    required double rating,
    required int rank,
  }) = _CleanerPerformanceAnalytics;

  factory CleanerPerformanceAnalytics.empty(String id, String name) {
    return CleanerPerformanceAnalytics(
      cleanerId: id,
      cleanerName: name,
      totalTasksCompleted: 0,
      totalTasksAssigned: 0,
      completionRate: 0.0,
      averageCompletionTime: Duration.zero,
      rating: 0.0,
      rank: 0,
    );
  }

  String get completionTimeFormatted {
    if (averageCompletionTime.inHours > 0) {
      return '${averageCompletionTime.inHours}h ${averageCompletionTime.inMinutes % 60}m';
    }
    return '${averageCompletionTime.inMinutes}m';
  }
}

/// Status distribution data for pie chart
@freezed
class StatusDistribution with _$StatusDistribution {
  const factory StatusDistribution({
    required String status,
    required int count,
    required double percentage,
    required Color color,
  }) = _StatusDistribution;
}

/// Complete analytics summary
@freezed
class AnalyticsSummary with _$AnalyticsSummary {
  const AnalyticsSummary._();

  const factory AnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required int totalReports,
    required int completedReports,
    required int pendingReports,
    required int inProgressReports,
    required int needsVerificationReports,
    required double completionRate,
    required Duration averageResponseTime,
    required Duration averageCompletionTime,
    required List<TrendDataPoint> dailyTrend,
    required List<StatusDistribution> statusDistribution,
    required List<DepartmentAnalytics> departmentAnalytics,
    required List<CleanerPerformanceAnalytics> cleanerPerformance,
  }) = _AnalyticsSummary;

  factory AnalyticsSummary.empty() {
    final now = DateTime.now();
    return AnalyticsSummary(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
      totalReports: 0,
      completedReports: 0,
      pendingReports: 0,
      inProgressReports: 0,
      needsVerificationReports: 0,
      completionRate: 0.0,
      averageResponseTime: Duration.zero,
      averageCompletionTime: Duration.zero,
      dailyTrend: [],
      statusDistribution: [],
      departmentAnalytics: [],
      cleanerPerformance: [],
    );
  }

  String get dateRangeText {
    final formatter = _formatDate;
    return '${formatter(startDate)} - ${formatter(endDate)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
