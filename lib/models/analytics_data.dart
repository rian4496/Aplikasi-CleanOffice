// lib/models/analytics_data.dart
// Data models for Analytics Dashboard

import 'package:flutter/material.dart';

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
class KPIData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? trendPercentage; // Positive = up, Negative = down
  final String? comparisonText; // "vs last month"

  const KPIData({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trendPercentage,
    this.comparisonText,
  });

  bool get isTrendPositive => trendPercentage != null && trendPercentage! > 0;
  bool get isTrendNegative => trendPercentage != null && trendPercentage! < 0;
}

/// Trend data point for line charts
class TrendDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const TrendDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

/// Department analytics data
class DepartmentAnalytics {
  final String departmentId;
  final String departmentName;
  final int totalReports;
  final int completedReports;
  final int pendingReports;
  final double completionRate;
  final Duration averageResponseTime;

  const DepartmentAnalytics({
    required this.departmentId,
    required this.departmentName,
    required this.totalReports,
    required this.completedReports,
    required this.pendingReports,
    required this.completionRate,
    required this.averageResponseTime,
  });

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
class CleanerPerformance {
  final String cleanerId;
  final String cleanerName;
  final String? photoUrl;
  final int totalTasksCompleted;
  final int totalTasksAssigned;
  final double completionRate;
  final Duration averageCompletionTime;
  final double rating;
  final int rank;

  const CleanerPerformance({
    required this.cleanerId,
    required this.cleanerName,
    this.photoUrl,
    required this.totalTasksCompleted,
    required this.totalTasksAssigned,
    required this.completionRate,
    required this.averageCompletionTime,
    required this.rating,
    required this.rank,
  });

  factory CleanerPerformance.empty(String id, String name) {
    return CleanerPerformance(
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
class StatusDistribution {
  final String status;
  final int count;
  final double percentage;
  final Color color;

  const StatusDistribution({
    required this.status,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

/// Complete analytics summary
class AnalyticsSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalReports;
  final int completedReports;
  final int pendingReports;
  final int inProgressReports;
  final int needsVerificationReports;
  final double completionRate;
  final Duration averageResponseTime;
  final Duration averageCompletionTime;
  final List<TrendDataPoint> dailyTrend;
  final List<StatusDistribution> statusDistribution;
  final List<DepartmentAnalytics> departmentAnalytics;
  final List<CleanerPerformance> cleanerPerformance;

  const AnalyticsSummary({
    required this.startDate,
    required this.endDate,
    required this.totalReports,
    required this.completedReports,
    required this.pendingReports,
    required this.inProgressReports,
    required this.needsVerificationReports,
    required this.completionRate,
    required this.averageResponseTime,
    required this.averageCompletionTime,
    required this.dailyTrend,
    required this.statusDistribution,
    required this.departmentAnalytics,
    required this.cleanerPerformance,
  });

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
