// lib/widgets/cleaner/cleaner_performance_card.dart
// Performance metrics card for cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/report.dart';
import '../../core/theme/app_theme.dart';

class CleanerPerformanceCard extends ConsumerWidget {
  final List<Report> allReports;

  const CleanerPerformanceCard({
    super.key,
    required this.allReports,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = _calculateStats();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppTheme.success),
                const SizedBox(width: 8),
                const Text(
                  'Performa Saya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(stats['score']!).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: _getScoreColor(stats['score']!),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats['score']!.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: _getScoreColor(stats['score']!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Hari Ini',
                    stats['today']!.toInt().toString(),
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Minggu Ini',
                    stats['week']!.toInt().toString(),
                    Icons.calendar_view_week,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Bulan Ini',
                    stats['month']!.toInt().toString(),
                    Icons.calendar_month,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Rata-rata Waktu',
              stats['avgTime'] as String,
              Icons.timer,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Total Selesai',
              stats['total']!.toInt().toString(),
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final completed = allReports.where((r) =>
      r.status == ReportStatus.completed || 
      r.status == ReportStatus.verified
    ).toList();

    final todayCount = completed.where((r) => 
      r.completedAt != null && r.completedAt!.isAfter(today)
    ).length;

    final weekCount = completed.where((r) =>
      r.completedAt != null && r.completedAt!.isAfter(weekStart)
    ).length;

    final monthCount = completed.where((r) =>
      r.completedAt != null && r.completedAt!.isAfter(monthStart)
    ).length;

    // Calculate average time
    final withTime = completed.where((r) => 
      r.completedAt != null && r.startedAt != null
    ).toList();

    String avgTime = '-';
    if (withTime.isNotEmpty) {
      final totalMinutes = withTime.fold<int>(0, (sum, r) {
        final duration = r.completedAt!.difference(r.startedAt!);
        return sum + duration.inMinutes;
      });
      final avgMinutes = totalMinutes ~/ withTime.length;
      final hours = avgMinutes ~/ 60;
      final minutes = avgMinutes % 60;
      avgTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    }

    // Calculate performance score (0-10)
    double score = 5.0; // Base score
    if (monthCount >= 50) {
      score += 2.0;
    } else if (monthCount >= 30) {
      score += 1.5;
    } else if (monthCount >= 20) {
      score += 1.0;
    }

    if (weekCount >= 10) {
      score += 1.5;
    } else if (weekCount >= 5) {
      score += 1.0;
    }

    if (todayCount >= 3) {
      score += 1.0;
    } else if (todayCount >= 1) {
      score += 0.5;
    }

    score = score.clamp(0, 10);

    return {
      'today': todayCount.toDouble(),
      'week': weekCount.toDouble(),
      'month': monthCount.toDouble(),
      'total': completed.length.toDouble(),
      'avgTime': avgTime,
      'score': score,
    };
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}
