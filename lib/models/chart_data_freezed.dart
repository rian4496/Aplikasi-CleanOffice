// lib/models/chart_data_freezed.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data_freezed.freezed.dart';

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

// ==================== CHART DATA POINT ====================

/// Single data point for charts
@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    required DateTime date,
    required double value,
    String? label,
    Color? color,
    Map<String, dynamic>? metadata,
  }) = _ChartDataPoint;
}

// ==================== CHART DATA SERIES ====================

/// Series of data points for multi-line charts
@freezed
class ChartDataSeries with _$ChartDataSeries {
  const ChartDataSeries._();

  const factory ChartDataSeries({
    required String name,
    required List<ChartDataPoint> points,
    required Color color,
    @Default(true) bool showDots,
    @Default(false) bool showArea,
  }) = _ChartDataSeries;
  
  double get maxValue => points.isEmpty 
      ? 0 
      : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  
  double get average => points.isEmpty
      ? 0
      : points.map((p) => p.value).reduce((a, b) => a + b) / points.length;
}

// ==================== LOCATION STATS ====================

/// Statistics for a specific location
@freezed
class LocationStats with _$LocationStats {
  const LocationStats._();

  const factory LocationStats({
    required String location,
    required int totalReports,
    @Default(0) int urgentReports,
    @Default(0) int completedReports,
    @Default(0) int pendingReports,
    Duration? averageCompletionTime,
  }) = _LocationStats;
  
  double get completionRate => totalReports > 0
      ? (completedReports / totalReports) * 100
      : 0;
}

// ==================== STATUS STATS ====================

/// Statistics by report status
@freezed
class StatusStats with _$StatusStats {
  const factory StatusStats({
    required String status,
    required int count,
    required double percentage,
    required Color color,
  }) = _StatusStats;
}

// ==================== CLEANER PERFORMANCE ====================

/// Performance metrics for a cleaner
@freezed
class CleanerPerformanceChart with _$CleanerPerformanceChart {
  const CleanerPerformanceChart._();

  const factory CleanerPerformanceChart({
    required String cleanerId,
    required String cleanerName,
    required int totalCompleted,
    @Default(0) int completedToday,
    @Default(0) int completedThisWeek,
    @Default(0) int completedThisMonth,
    Duration? averageCompletionTime,
    @Default(0.0) double rating,
  }) = _CleanerPerformanceChart;
  
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
}

// ==================== CHART CONFIG ====================

/// Configuration for chart display
@freezed
class ChartConfig with _$ChartConfig {
  const factory ChartConfig({
    @Default(ChartTimeRange.thirtyDays) ChartTimeRange timeRange,
    @Default(true) bool showGrid,
    @Default(true) bool showLegend,
    @Default(true) bool showTooltips,
    @Default(true) bool animated,
    double? maxY,
    double? minY,
  }) = _ChartConfig;
}

// ==================== TREND DATA ====================

/// Aggregated trend data for reports over time
@freezed
class TrendData with _$TrendData {
  const TrendData._();

  const factory TrendData({
    required Map<DateTime, int> totalReports,
    required Map<DateTime, int> completedReports,
    required Map<DateTime, int> pendingReports,
    required Map<DateTime, int> urgentReports,
  }) = _TrendData;
  
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
}
