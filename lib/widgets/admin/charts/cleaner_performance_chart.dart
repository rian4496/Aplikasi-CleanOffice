// lib/widgets/admin/charts/cleaner_performance_chart.dart
// Horizontal bar chart showing top cleaner performance

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../providers/riverpod/chart_providers.dart';

class CleanerPerformanceChart extends ConsumerWidget {
  const CleanerPerformanceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topCleanersAsync = ref.watch(topCleanersProvider(limit: 10));

    return topCleanersAsync.when(
      data: (cleaners) {
        if (cleaners.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top 10 Cleaner Terbaik',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  _buildBarChartData(cleaners, context),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(height: 16),
              _buildPerformanceInfo(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  BarChartData _buildBarChartData(
    List<dynamic> cleaners,
    BuildContext context,
  ) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100, // Performance score is 0-100
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final cleaner = cleaners[group.x.toInt()];
            final avgTime = cleaner.averageCompletionTime;
            final avgHours = avgTime != null
                ? '${avgTime.inHours}h ${avgTime.inMinutes % 60}m'
                : 'N/A';

            return BarTooltipItem(
              '${cleaner.cleanerName}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Score: ${cleaner.performanceScore.toStringAsFixed(1)}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Total: ${cleaner.totalCompleted}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Bulan ini: ${cleaner.completedThisMonth}\n',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Rata-rata waktu: $avgHours',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 100,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < cleaners.length) {
                final cleaner = cleaners[value.toInt()];
                final name = cleaner.cleanerName;
                final displayName = name.length > 15
                    ? '${name.substring(0, 15)}...'
                    : name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    displayName,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.right,
                  ),
                );
              }
              return const SizedBox();
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
        drawVerticalLine: true,
        drawHorizontalLine: false,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      barGroups: List.generate(cleaners.length, (index) {
        final cleaner = cleaners[index];
        final score = cleaner.performanceScore;

        // Color gradient based on performance score
        Color barColor;
        if (score >= 80) {
          barColor = Colors.green;
        } else if (score >= 60) {
          barColor = Colors.lightGreen;
        } else if (score >= 40) {
          barColor = Colors.amber;
        } else {
          barColor = Colors.orange;
        }

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: score,
              color: barColor,
              width: 16,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPerformanceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Score dihitung dari:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          _buildInfoRow('40%', 'Total laporan diselesaikan'),
          _buildInfoRow('30%', 'Kecepatan penyelesaian'),
          _buildInfoRow('30%', 'Rating dari pengguna'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String percentage, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage - ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 11),
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
          Icon(Icons.leaderboard, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada data performa cleaner',
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
