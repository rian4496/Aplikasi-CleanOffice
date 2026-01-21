// lib/widgets/web_admin/charts/status_pie_chart.dart
// Pie chart showing status distribution

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../riverpod/chart_providers.dart';

class StatusPieChart extends ConsumerStatefulWidget {
  const StatusPieChart({super.key});

  @override
  ConsumerState<StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends ConsumerState<StatusPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final statusStatsAsync = ref.watch(reportsByStatusProvider);

    return statusStatsAsync.when(
      data: (stats) {
        if (stats.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            Expanded(
              child: PieChart(
                _buildPieChartData(stats),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegend(stats),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  PieChartData _buildPieChartData(List<dynamic> stats) {
    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      borderData: FlBorderData(show: false),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: List.generate(stats.length, (index) {
        final isTouched = index == touchedIndex;
        final stat = stats[index];

        return PieChartSectionData(
          color: stat.color,
          value: stat.count.toDouble(),
          title: isTouched
              ? '${stat.count}\n${stat.percentage.toStringAsFixed(1)}%'
              : '${stat.percentage.toStringAsFixed(0)}%',
          radius: isTouched ? 110 : 100,
          titleStyle: TextStyle(
            fontSize: isTouched ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    stat.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1.3,
        );
      }),
    );
  }

  Widget _buildLegend(List<dynamic> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: stats.map((stat) {
        return _buildLegendItem(
          stat.status,
          stat.count,
          stat.percentage,
          stat.color,
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$count laporan (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada data status',
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

