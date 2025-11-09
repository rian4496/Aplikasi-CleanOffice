// lib/models/chart_data.dart
// Data models for charts and analytics

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// ==================== CHART DATA POINT ====================

/// Single data point for charts
class ChartDataPoint extends Equatable {
  final DateTime date;
  final double value;
  final String? label;
  final Color? color;
  final Map<String, dynamic>? metadata;
  
  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.color,
    this.metadata,
  });
  
  @override
  List<Object?> get props => [date, value, label, color, metadata];
}

// ==================== CHART DATA SERIES ====================

/// Series of data points for multi-line charts
class ChartDataSeries extends Equatable {
  final String name;
  final List<ChartDataPoint> points;
  final Color color;
  final bool showDots;
  final bool showArea;
  
  const ChartDataSeries({
    required this.name,
    required this.points,
    required this.color,
    this.showDots = true,
    this.showArea = false,
  });
  
  double get maxValue => points.isEmpty 
      ? 0 
      : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  
  double get average => points.isEmpty
      ? 0
      : points.map((p) => p.value).reduce((a, b) => a + b) / points.length;
  
  @override
  List<Object?> get props => [name, points, color, showDots, showArea];
}

// ==================== CHART TIME RANGE ====================

/// Time range selector for charts
enum ChartTimeRange {
  sevenDays('7 Hari', 7),
  thirtyDays('30 Hari', 30),
  ninetyDays('90 Hari', 90),
  all('Semua', 0);
  
  final String label;
  final int days;
  
  const ChartTimeRange(this.label, this.days);
  
  DateTime get startDate {
    if (days == 0) return DateTime(2000, 1, 1); // Very old date for "all"
    return DateTime.now().subtract(Duration(days: days));
  }
  
  DateTime get endDate => DateTime.now();
}

// ==================== LOCATION STATS ====================

/// Statistics for a specific location
class LocationStats extends Equatable {
  final String location;
  final int totalReports;
  final int urgentReports;
  final int completedReports;
  final int pendingReports;
  final Duration? averageCompletionTime;
  
  const LocationStats({
    required this.location,
    required this.totalReports,
    this.urgentReports = 0,
    this.completedReports = 0,
    this.pendingReports = 0,
    this.averageCompletionTime,
  });
  
  double get completionRate => totalReports > 0
      ? (completedReports / totalReports) * 100
      : 0;
  
  @override
  List<Object?> get props => [
        location,
        totalReports,
        urgentReports,
        completedReports,
        pendingReports,
        averageCompletionTime,
      ];
}

// ==================== STATUS STATS ====================

/// Statistics by report status
class StatusStats extends Equatable {
  final String status;
  final int count;
  final double percentage;
  final Color color;
  
  const StatusStats({
    required this.status,
    required this.count,
    required this.percentage,
    required this.color,
  });
  
  @override
  List<Object?> get props => [status, count, percentage, color];
}

// ==================== CLEANER PERFORMANCE ====================

/// Performance metrics for a cleaner
class CleanerPerformance extends Equatable {
  final String cleanerId;
  final String cleanerName;
  final int totalCompleted;
  final int completedToday;
  final int completedThisWeek;
  final int completedThisMonth;
  final Duration? averageCompletionTime;
  final double rating;
  
  const CleanerPerformance({
    required this.cleanerId,
    required this.cleanerName,
    required this.totalCompleted,
    this.completedToday = 0,
    this.completedThisWeek = 0,
    this.completedThisMonth = 0,
    this.averageCompletionTime,
    this.rating = 0.0,
  });
  
  /// Performance score (0-100)
  double get performanceScore {
    double score = 0;
    
    // Completion count (40 points)
    score += (totalCompleted.clamp(0, 100) / 100) * 40;
    
    // Speed (30 points) - faster is better
    if (averageCompletionTime != null) {
      final hours = averageCompletionTime!.inHours;
      if (hours <= 2) {
        score += 30;
      } else if (hours <= 4) {
        score += 20;
      } else if (hours <= 8) {
        score += 10;
      }
    }
    
    // Rating (30 points)
    score += rating * 3;
    
    return score.clamp(0, 100);
  }
  
  @override
  List<Object?> get props => [
        cleanerId,
        cleanerName,
        totalCompleted,
        completedToday,
        completedThisWeek,
        completedThisMonth,
        averageCompletionTime,
        rating,
      ];
}

// ==================== CHART CONFIG ====================

/// Configuration for chart display
class ChartConfig extends Equatable {
  final ChartTimeRange timeRange;
  final bool showGrid;
  final bool showLegend;
  final bool showTooltips;
  final bool animated;
  final double? maxY;
  final double? minY;
  
  const ChartConfig({
    this.timeRange = ChartTimeRange.thirtyDays,
    this.showGrid = true,
    this.showLegend = true,
    this.showTooltips = true,
    this.animated = true,
    this.maxY,
    this.minY,
  });
  
  ChartConfig copyWith({
    ChartTimeRange? timeRange,
    bool? showGrid,
    bool? showLegend,
    bool? showTooltips,
    bool? animated,
    double? maxY,
    double? minY,
  }) {
    return ChartConfig(
      timeRange: timeRange ?? this.timeRange,
      showGrid: showGrid ?? this.showGrid,
      showLegend: showLegend ?? this.showLegend,
      showTooltips: showTooltips ?? this.showTooltips,
      animated: animated ?? this.animated,
      maxY: maxY ?? this.maxY,
      minY: minY ?? this.minY,
    );
  }
  
  @override
  List<Object?> get props => [
        timeRange,
        showGrid,
        showLegend,
        showTooltips,
        animated,
        maxY,
        minY,
      ];
}

// ==================== TREND DATA ====================

/// Aggregated trend data for reports over time
class TrendData extends Equatable {
  final Map<DateTime, int> totalReports;
  final Map<DateTime, int> completedReports;
  final Map<DateTime, int> pendingReports;
  final Map<DateTime, int> urgentReports;
  
  const TrendData({
    required this.totalReports,
    required this.completedReports,
    required this.pendingReports,
    required this.urgentReports,
  });
  
  /// Convert to chart data series
  List<ChartDataSeries> toChartSeries() {
    return [
      ChartDataSeries(
        name: 'Total',
        color: Colors.blue,
        points: totalReports.entries
            .map((e) => ChartDataPoint(date: e.key, value: e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      ),
      ChartDataSeries(
        name: 'Completed',
        color: Colors.green,
        points: completedReports.entries
            .map((e) => ChartDataPoint(date: e.key, value: e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      ),
      ChartDataSeries(
        name: 'Pending',
        color: Colors.orange,
        points: pendingReports.entries
            .map((e) => ChartDataPoint(date: e.key, value: e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      ),
      ChartDataSeries(
        name: 'Urgent',
        color: Colors.red,
        points: urgentReports.entries
            .map((e) => ChartDataPoint(date: e.key, value: e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      ),
    ];
  }
  
  @override
  List<Object?> get props => [
        totalReports,
        completedReports,
        pendingReports,
        urgentReports,
      ];
}
