// lib/widgets/web_admin/charts/weekly_report_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/report.dart';

class WeeklyReportChart extends StatelessWidget {
  final List<Report> reports;
  final bool isDesktop;

  const WeeklyReportChart({
    super.key,
    required this.reports,
    this.isDesktop = false,
  });

  Map<String, Map<String, int>> _calculateWeeklyData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));
    final weekData = <String, Map<String, int>>{};

    // Initialize 7 days with their dates
    final dayDates = <String, DateTime>{};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayName = DateFormat('EEE', 'id_ID').format(date);
      weekData[dayName] = {
        'pending': 0,
        'inProgress': 0,
        'completed': 0,
        'needsVerification': 0,
      };
      dayDates[dayName] = date;
    }

    // Count reports by day and status
    for (final report in reports) {
      final reportDate = DateTime(report.date.year, report.date.month, report.date.day);
      
      // Check if report is within the 7-day range
      if (reportDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
          reportDate.isBefore(today.add(const Duration(days: 1)))) {
        final dayName = DateFormat('EEE', 'id_ID').format(report.date);
        if (weekData.containsKey(dayName)) {
          final statusKey = _getStatusKey(report.status);
          weekData[dayName]![statusKey] = weekData[dayName]![statusKey]! + 1;
        }
      }
    }

    return weekData;
  }

  String _getStatusKey(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inProgress:
      case ReportStatus.assigned:
        return 'inProgress';
      case ReportStatus.completed:
      case ReportStatus.verified:
        return 'completed';
      default:
        return 'needsVerification';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyData();
    final days = weeklyData.keys.toList();

    return Container(
      height: isDesktop ? 300 : 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(weeklyData) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = days[group.x.toInt()];
                final data = weeklyData[day]!;
                final statusNames = ['Pending', 'Sedang Dikerjakan', 'Selesai', 'Perlu Verifikasi'];
                final values = data.values.toList();

                return BarTooltipItem(
                  '$day\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '${statusNames[rodIndex]}: ${values[rodIndex]}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: isDesktop ? 12 : 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 11 : 9,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.divider,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _buildBarGroups(weeklyData, days),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    Map<String, Map<String, int>> weeklyData,
    List<String> days,
  ) {
    return List.generate(days.length, (index) {
      final day = days[index];
      final data = weeklyData[day]!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['pending']!.toDouble(),
            color: AppTheme.chartPink,
            width: isDesktop ? 12 : 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data['inProgress']!.toDouble(),
            color: AppTheme.chartNavy,
            width: isDesktop ? 12 : 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data['completed']!.toDouble(),
            color: AppTheme.chartMint,
            width: isDesktop ? 12 : 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data['needsVerification']!.toDouble(),
            color: AppTheme.chartYellow,
            width: isDesktop ? 12 : 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 2,
      );
    });
  }

  double _calculateMaxY(Map<String, Map<String, int>> weeklyData) {
    double max = 0;
    for (final data in weeklyData.values) {
      final total = data.values.reduce((a, b) => a + b).toDouble();
      if (total > max) max = total;
    }
    return max > 0 ? max : 10;
  }
}

/// Legend widget for the chart
class WeeklyReportChartLegend extends StatelessWidget {
  final bool isHorizontal;

  const WeeklyReportChartLegend({
    super.key,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _LegendItem(color: AppTheme.chartPink, label: 'Pending'),
      _LegendItem(color: AppTheme.chartNavy, label: 'Sedang Dikerjakan'),
      _LegendItem(color: AppTheme.chartMint, label: 'Selesai'),
      _LegendItem(color: AppTheme.chartYellow, label: 'Perlu Verifikasi'),
    ];

    if (isHorizontal) {
      return Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: items,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: item,
        )).toList(),
      );
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

