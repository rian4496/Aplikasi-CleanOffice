// lib/widgets/web_admin/charts/reports_trend_chart.dart
// Line chart showing reports trend over time

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../models/chart_data.dart';
import '../../../providers/riverpod/chart_providers.dart';

class ReportsTrendChart extends ConsumerWidget {
  const ReportsTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendDataAsync = ref.watch(reportsTrendDataProvider);
    final timeRange = ref.watch(chartTimeRangeProvider);

    return trendDataAsync.when(
      data: (trendData) {
        final series = trendData.toChartSeries();
        
        if (series.isEmpty || series.first.points.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeRangeSelector(context, ref, timeRange),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: LineChart(
                  _buildLineChartData(series, context),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(series),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildTimeRangeSelector(
    BuildContext context,
    WidgetRef ref,
    ChartTimeRange currentRange,
  ) {
    return Wrap(
      spacing: 8,
      children: ChartTimeRange.values.map((range) {
        final isSelected = range == currentRange;
        return ChoiceChip(
          label: Text(range.label),
          selected: isSelected,
          onSelected: (_) {
            ref.read(chartTimeRangeProvider.notifier).setTimeRange(range);
          },
        );
      }).toList(),
    );
  }

  LineChartData _buildLineChartData(
    List<ChartDataSeries> series,
    BuildContext context,
  ) {
    final allPoints = series.expand((s) => s.points).toList();
    if (allPoints.isEmpty) return LineChartData();

    final maxY = allPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minDate = allPoints.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = allPoints.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateInterval(minDate, maxDate),
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
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
      minX: minDate.millisecondsSinceEpoch.toDouble(),
      maxX: maxDate.millisecondsSinceEpoch.toDouble(),
      minY: 0,
      maxY: (maxY * 1.2).ceilToDouble(),
      lineBarsData: series.map((s) => _buildLineChartBarData(s)).toList(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = DateTime.fromMillisecondsSinceEpoch(
                spot.x.toInt(),
              );
              final seriesName = series[spot.barIndex].name;
              return LineTooltipItem(
                '$seriesName\n${DateFormat('dd MMM').format(date)}\n${spot.y.toInt()} laporan',
                TextStyle(
                  color: spot.bar.color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(ChartDataSeries series) {
    return LineChartBarData(
      spots: series.points
          .map((p) => FlSpot(
                p.date.millisecondsSinceEpoch.toDouble(),
                p.value,
              ))
          .toList(),
      isCurved: true,
      color: series.color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: series.showDots,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: series.color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: series.showArea,
        color: series.color.withValues(alpha: 0.1),
      ),
    );
  }

  double _calculateInterval(DateTime minDate, DateTime maxDate) {
    final days = maxDate.difference(minDate).inDays;
    if (days <= 7) return Duration(days: 1).inMilliseconds.toDouble();
    if (days <= 30) return Duration(days: 5).inMilliseconds.toDouble();
    if (days <= 90) return Duration(days: 15).inMilliseconds.toDouble();
    return Duration(days: 30).inMilliseconds.toDouble();
  }

  Widget _buildLegend(List<ChartDataSeries> series) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: series.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: s.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              s.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada data untuk ditampilkan',
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

