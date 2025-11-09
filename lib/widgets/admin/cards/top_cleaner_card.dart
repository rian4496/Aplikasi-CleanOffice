// lib/widgets/admin/cards/top_cleaner_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/report.dart';

class TopCleanerCard extends StatelessWidget {
  final List<Report> allReports;
  final VoidCallback? onViewDetails;

  const TopCleanerCard({
    super.key,
    required this.allReports,
    this.onViewDetails,
  });

  Map<String, dynamic> _calculateTopCleaner() {
    if (allReports.isEmpty) {
      return {
        'name': 'Tidak Ada Data',
        'department': '-',
        'completedCount': 0,
        'rating': 0.0,
        'avgResponseTime': 0,
      };
    }

    // Group reports by cleaner
    final cleanerStats = <String, Map<String, dynamic>>{};

    for (final report in allReports) {
      if (report.cleanerName != null && report.cleanerId != null) {
        final cleanerId = report.cleanerId!;

        if (!cleanerStats.containsKey(cleanerId)) {
          cleanerStats[cleanerId] = {
            'name': report.cleanerName!,
            'completedCount': 0,
            'totalResponseTime': 0,
            'responseCount': 0,
          };
        }

        // Count completed reports
        if (report.status == ReportStatus.completed ||
            report.status == ReportStatus.verified) {
          cleanerStats[cleanerId]!['completedCount'] =
              (cleanerStats[cleanerId]!['completedCount'] as int) + 1;
        }

        // Calculate response time (from assigned to started)
        if (report.assignedAt != null && report.startedAt != null) {
          final responseTime =
              report.startedAt!.difference(report.assignedAt!).inMinutes;
          cleanerStats[cleanerId]!['totalResponseTime'] =
              (cleanerStats[cleanerId]!['totalResponseTime'] as int) +
                  responseTime;
          cleanerStats[cleanerId]!['responseCount'] =
              (cleanerStats[cleanerId]!['responseCount'] as int) + 1;
        }
      }
    }

    if (cleanerStats.isEmpty) {
      return {
        'name': 'Tidak Ada Data',
        'department': '-',
        'completedCount': 0,
        'rating': 0.0,
        'avgResponseTime': 0,
      };
    }

    // Find top performer (most completed reports)
    String topCleanerId = '';
    int maxCompleted = 0;

    cleanerStats.forEach((id, stats) {
      if ((stats['completedCount'] as int) > maxCompleted) {
        maxCompleted = stats['completedCount'] as int;
        topCleanerId = id;
      }
    });

    final topCleaner = cleanerStats[topCleanerId]!;
    final avgResponseTime = (topCleaner['responseCount'] as int) > 0
        ? (topCleaner['totalResponseTime'] as int) /
            (topCleaner['responseCount'] as int)
        : 0;

    // Mock rating (in real app, calculate from user feedback)
    final rating = maxCompleted > 20
        ? 4.9
        : maxCompleted > 15
            ? 4.7
            : maxCompleted > 10
                ? 4.5
                : 4.3;

    return {
      'name': topCleaner['name'] as String,
      'department': 'Dept. Kebersihan', // Mock data
      'completedCount': maxCompleted,
      'rating': rating,
      'avgResponseTime': avgResponseTime.round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final topCleaner = _calculateTopCleaner();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.chartYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppTheme.chartYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Petugas Terbaik Bulan Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Cleaner Info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: Text(
                  topCleaner['name'].toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topCleaner['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topCleaner['department'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          _buildStatRow(
            icon: Icons.check_circle_outline,
            iconColor: AppTheme.success,
            label: 'Laporan Selesai',
            value: '${topCleaner['completedCount']}',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.star_outline,
            iconColor: AppTheme.chartYellow,
            label: 'Rating',
            value: '${topCleaner['rating']}/5.0',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.speed_outlined,
            iconColor: AppTheme.info,
            label: 'Avg. Response Time',
            value: '${topCleaner['avgResponseTime']} menit',
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Detail Performa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
