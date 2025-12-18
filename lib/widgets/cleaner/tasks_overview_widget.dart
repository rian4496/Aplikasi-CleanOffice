// lib/widgets/cleaner/tasks_overview_widget.dart
// 📊 Tasks Overview Widget for Cleaner
// Menampilkan statistik tugas cleaner (Reports + Requests)

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/request.dart';

class TasksOverviewWidget extends StatelessWidget {
  final List<Report> reports;
  final List<Request> requests;

  const TasksOverviewWidget({
    super.key,
    required this.reports,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Ringkasan Tugas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Completion Rate
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tingkat Penyelesaian',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${stats.completionRate}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.completionRate / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      stats.completionRate >= 70
                          ? AppTheme.success
                          : stats.completionRate >= 40
                              ? Colors.orange
                              : AppTheme.error,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Laporan Stats
                Expanded(
                  child: _buildStatsColumn(
                    'Laporan',
                    [
                      _StatItem('Ditugaskan', stats.reportsAssigned, Colors.blue[700]!),
                      _StatItem('Dikerjakan', stats.reportsInProgress, Colors.orange[700]!),
                      _StatItem('Selesai', stats.reportsCompleted, Colors.green[700]!),
                      _StatItem('Urgent', stats.reportsUrgent, Colors.red[700]!),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Permintaan Stats
                Expanded(
                  child: _buildStatsColumn(
                    'Permintaan',
                    [
                      _StatItem('Ditugaskan', stats.requestsAssigned, Colors.purple[700]!),
                      _StatItem('Dikerjakan', stats.requestsInProgress, Colors.indigo[700]!),
                      _StatItem('Selesai', stats.requestsCompleted, Colors.teal[700]!),
                      _StatItem('Urgent', stats.requestsUrgent, Colors.amber[700]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(String title, List<_StatItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.value}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  _TasksStats _calculateStats() {
    // Reports stats
    final reportsAssigned = reports.where((r) => r.status == ReportStatus.assigned).length;
    final reportsInProgress = reports.where((r) => r.status == ReportStatus.inProgress).length;
    final reportsCompleted = reports.where((r) => r.status == ReportStatus.completed).length;
    final reportsUrgent = reports.where((r) => r.isUrgent).length;

    // Requests stats
    final requestsAssigned = requests.where((r) => r.status == RequestStatus.assigned).length;
    final requestsInProgress = requests.where((r) => r.status == RequestStatus.inProgress).length;
    final requestsCompleted = requests.where((r) => r.status == RequestStatus.completed).length;
    final requestsUrgent = requests.where((r) => r.isUrgent).length;

    // Total stats
    final totalActive = reportsAssigned + reportsInProgress + requestsAssigned + requestsInProgress;
    final totalCompleted = reportsCompleted + requestsCompleted;
    final total = totalActive + totalCompleted;

    // Completion rate
    final completionRate = total > 0 
        ? ((totalCompleted / total) * 100).round() 
        : 0;

    return _TasksStats(
      completionRate: completionRate,
      reportsAssigned: reportsAssigned,
      reportsInProgress: reportsInProgress,
      reportsCompleted: reportsCompleted,
      reportsUrgent: reportsUrgent,
      requestsAssigned: requestsAssigned,
      requestsInProgress: requestsInProgress,
      requestsCompleted: requestsCompleted,
      requestsUrgent: requestsUrgent,
    );
  }
}

// ==================== HELPER CLASSES ====================

class _TasksStats {
  final int completionRate;
  final int reportsAssigned;
  final int reportsInProgress;
  final int reportsCompleted;
  final int reportsUrgent;
  final int requestsAssigned;
  final int requestsInProgress;
  final int requestsCompleted;
  final int requestsUrgent;

  const _TasksStats({
    required this.completionRate,
    required this.reportsAssigned,
    required this.reportsInProgress,
    required this.reportsCompleted,
    required this.reportsUrgent,
    required this.requestsAssigned,
    required this.requestsInProgress,
    required this.requestsCompleted,
    required this.requestsUrgent,
  });
}

class _StatItem {
  final String label;
  final int value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);
}

