// lib/widgets/web_admin/charts/location_bar_chart.dart
// Bar chart showing reports by location

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../riverpod/chart_providers.dart';

class LocationBarChart extends ConsumerWidget {
  const LocationBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationStatsAsync = ref.watch(reportsByLocationProvider);

    return locationStatsAsync.when(
      data: (stats) {
        if (stats.isEmpty) {
          return _buildEmptyState();
        }

        // Limit to top 10 locations for better readability
        final topLocations = stats.take(10).toList();

        return Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: Column(
            children: [
              Expanded(
                child: BarChart(
                  _buildBarChartData(topLocations, context),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  BarChartData _buildBarChartData(
    List<dynamic> stats,
    BuildContext context,
  ) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: stats.isEmpty
          ? 10
          : stats.map((s) => s.totalReports).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final stat = stats[group.x.toInt()];
            return BarTooltipItem(
              '${stat.location}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Total: ${stat.totalReports}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Selesai: ${stat.completedReports}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Pending: ${stat.pendingReports}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Urgent: ${stat.urgentReports}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < stats.length) {
                final location = stats[value.toInt()].location;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      location.length > 15 ? '${location.substring(0, 15)}...' : location,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      barGroups: List.generate(stats.length, (index) {
        final stat = stats[index];
        final urgentRatio = stat.totalReports > 0
            ? stat.urgentReports / stat.totalReports
            : 0.0;

        // Color based on urgency level
        Color barColor;
        if (urgentRatio > 0.5) {
          barColor = Colors.red;
        } else if (urgentRatio > 0.3) {
          barColor = Colors.orange;
        } else if (urgentRatio > 0.1) {
          barColor = Colors.amber;
        } else {
          barColor = Colors.blue;
        }

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: stat.totalReports.toDouble(),
              color: barColor,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: stats.map((s) => s.totalReports).reduce((a, b) => a > b ? a : b).toDouble(),
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Urgent Tinggi (>50%)', Colors.red),
        _buildLegendItem('Urgent Sedang (30-50%)', Colors.orange),
        _buildLegendItem('Urgent Rendah (10-30%)', Colors.amber),
        _buildLegendItem('Normal (<10%)', Colors.blue),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada data lokasi',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

