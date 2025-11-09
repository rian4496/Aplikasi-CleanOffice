// lib/services/analytics_service.dart
// Analytics and data aggregation service for charts

import '../models/report.dart';
import '../models/chart_data.dart';

class AnalyticsService {
  /// Aggregate reports by date for trend analysis
  static TrendData aggregateReportsByDate(
    List<Report> reports,
    ChartTimeRange timeRange,
  ) {
    final startDate = timeRange.startDate;
    final endDate = timeRange.endDate;
    
    // Filter reports by date range
    final filteredReports = reports.where((r) {
      return r.date.isAfter(startDate) && r.date.isBefore(endDate);
    }).toList();
    
    // Initialize maps
    final totalByDate = <DateTime, int>{};
    final completedByDate = <DateTime, int>{};
    final pendingByDate = <DateTime, int>{};
    final urgentByDate = <DateTime, int>{};
    
    // Group by date (day level)
    for (final report in filteredReports) {
      final date = DateTime(report.date.year, report.date.month, report.date.day);
      
      totalByDate[date] = (totalByDate[date] ?? 0) + 1;
      
      if (report.status == ReportStatus.completed || 
          report.status == ReportStatus.verified) {
        completedByDate[date] = (completedByDate[date] ?? 0) + 1;
      }
      
      if (report.status == ReportStatus.pending) {
        pendingByDate[date] = (pendingByDate[date] ?? 0) + 1;
      }
      
      if (report.isUrgent == true) {
        urgentByDate[date] = (urgentByDate[date] ?? 0) + 1;
      }
    }
    
    return TrendData(
      totalReports: totalByDate,
      completedReports: completedByDate,
      pendingReports: pendingByDate,
      urgentReports: urgentByDate,
    );
  }
  
  /// Aggregate reports by location
  static List<LocationStats> aggregateReportsByLocation(List<Report> reports) {
    final locationMap = <String, List<Report>>{};
    
    // Group by location
    for (final report in reports) {
      locationMap.putIfAbsent(report.location, () => []).add(report);
    }
    
    // Calculate stats for each location
    return locationMap.entries.map((entry) {
      final location = entry.key;
      final locationReports = entry.value;
      
      final urgent = locationReports.where((r) => r.isUrgent == true).length;
      final completed = locationReports.where((r) => 
        r.status == ReportStatus.completed || 
        r.status == ReportStatus.verified
      ).length;
      final pending = locationReports.where((r) => 
        r.status == ReportStatus.pending
      ).length;
      
      // Calculate average completion time
      final completedWithTime = locationReports.where((r) => 
        r.completedAt != null
      ).toList();
      
      Duration? avgTime;
      if (completedWithTime.isNotEmpty) {
        final totalMinutes = completedWithTime.fold<int>(0, (sum, r) {
          final duration = r.completedAt!.difference(r.date);
          return sum + duration.inMinutes;
        });
        avgTime = Duration(minutes: totalMinutes ~/ completedWithTime.length);
      }
      
      return LocationStats(
        location: location,
        totalReports: locationReports.length,
        urgentReports: urgent,
        completedReports: completed,
        pendingReports: pending,
        averageCompletionTime: avgTime,
      );
    }).toList()
      ..sort((a, b) => b.totalReports.compareTo(a.totalReports)); // Sort by count
  }
  
  /// Aggregate reports by status for pie chart
  static List<StatusStats> aggregateReportsByStatus(List<Report> reports) {
    final statusMap = <ReportStatus, int>{};
    
    // Count by status
    for (final report in reports) {
      statusMap[report.status] = (statusMap[report.status] ?? 0) + 1;
    }
    
    final total = reports.length;
    
    // Convert to StatusStats
    return statusMap.entries.map((entry) {
      return StatusStats(
        status: entry.key.displayName,
        count: entry.value,
        percentage: total > 0 ? (entry.value / total) * 100 : 0,
        color: entry.key.color,
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count)); // Sort by count
  }
  
  /// Calculate cleaner performance metrics
  static List<CleanerPerformance> calculateCleanerPerformance(
    List<Report> reports,
  ) {
    // Filter only completed/verified reports with cleaner assigned
    final completedReports = reports.where((r) => 
      (r.status == ReportStatus.completed || 
       r.status == ReportStatus.verified) &&
      r.cleanerId != null
    ).toList();
    
    final cleanerMap = <String, List<Report>>{};
    
    // Group by cleaner
    for (final report in completedReports) {
      final cleanerId = report.cleanerId!;
      cleanerMap.putIfAbsent(cleanerId, () => []).add(report);
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Calculate performance for each cleaner
    return cleanerMap.entries.map((entry) {
      final cleanerId = entry.key;
      final cleanerReports = entry.value;
      
      // Get cleaner name from first report
      final cleanerName = cleanerReports.first.cleanerName ?? 'Unknown';
      
      // Count by time period
      final todayCount = cleanerReports.where((r) => 
        r.completedAt != null && r.completedAt!.isAfter(today)
      ).length;
      
      final weekCount = cleanerReports.where((r) =>
        r.completedAt != null && r.completedAt!.isAfter(weekStart)
      ).length;
      
      final monthCount = cleanerReports.where((r) =>
        r.completedAt != null && r.completedAt!.isAfter(monthStart)
      ).length;
      
      // Calculate average completion time
      final reportsWithTime = cleanerReports.where((r) =>
        r.completedAt != null && r.startedAt != null
      ).toList();
      
      Duration? avgTime;
      if (reportsWithTime.isNotEmpty) {
        final totalMinutes = reportsWithTime.fold<int>(0, (sum, r) {
          final duration = r.completedAt!.difference(r.startedAt!);
          return sum + duration.inMinutes;
        });
        avgTime = Duration(minutes: totalMinutes ~/ reportsWithTime.length);
      }
      
      // Calculate rating based on performance metrics
      // Rating formula: 40% completion rate + 30% speed + 30% consistency
      double rating = 5.0; // Base rating
      
      // 1. Completion rate (max 4 points)
      if (monthCount > 0) {
        final completionRate = monthCount / 30; // Average per day this month
        rating += (completionRate * 2).clamp(0.0, 4.0);
      }
      
      // 2. Speed bonus (max 0.5 points) - faster completion time = bonus
      if (avgTime != null) {
        final avgMinutes = avgTime.inMinutes;
        if (avgMinutes < 30) {
          rating += 0.5;
        } else if (avgMinutes < 60) {
          rating += 0.3;
        } else if (avgMinutes < 120) {
          rating += 0.1;
        }
      }
      
      // 3. Consistency bonus (max 0.5 points) - work every day
      if (todayCount > 0 && weekCount >= 5) rating += 0.5;
      
      // Cap at 10.0
      rating = rating.clamp(0.0, 10.0);
      
      return CleanerPerformance(
        cleanerId: cleanerId,
        cleanerName: cleanerName,
        totalCompleted: cleanerReports.length,
        completedToday: todayCount,
        completedThisWeek: weekCount,
        completedThisMonth: monthCount,
        averageCompletionTime: avgTime,
        rating: double.parse(rating.toStringAsFixed(1)),
      );
    }).toList()
      ..sort((a, b) => b.totalCompleted.compareTo(a.totalCompleted)); // Sort by total
  }
  
  /// Get top N cleaners by performance
  static List<CleanerPerformance> getTopCleaners(
    List<Report> reports, {
    int limit = 10,
  }) {
    final allPerformance = calculateCleanerPerformance(reports);
    return allPerformance.take(limit).toList();
  }
  
  /// Calculate summary statistics
  static Map<String, dynamic> calculateSummaryStats(List<Report> reports) {
    final total = reports.length;
    final completed = reports.where((r) => 
      r.status == ReportStatus.completed || 
      r.status == ReportStatus.verified
    ).length;
    final pending = reports.where((r) => 
      r.status == ReportStatus.pending
    ).length;
    final urgent = reports.where((r) => r.isUrgent == true).length;
    
    final completionRate = total > 0 ? (completed / total) * 100 : 0;
    
    // Average completion time
    final completedWithTime = reports.where((r) =>
      r.completedAt != null
    ).toList();
    
    Duration? avgTime;
    if (completedWithTime.isNotEmpty) {
      final totalMinutes = completedWithTime.fold<int>(0, (sum, r) {
        final duration = r.completedAt!.difference(r.date);
        return sum + duration.inMinutes;
      });
      avgTime = Duration(minutes: totalMinutes ~/ completedWithTime.length);
    }
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'urgent': urgent,
      'completionRate': completionRate,
      'averageCompletionTime': avgTime,
    };
  }
}
