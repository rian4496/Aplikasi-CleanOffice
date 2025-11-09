// lib/widgets/employee/request_overview_widget.dart
// 📊 Request Overview Widget - FIXED NULL-SAFETY VERSION
// Shows stats similar to web dashboard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';

class RequestOverviewWidget extends ConsumerWidget {
  final List<Report> reports;

  const RequestOverviewWidget({
    super.key,
    required this.reports,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Request Overview',
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
                      'Completion Rate',
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
                // Status Breakdown
                Expanded(
                  child: _buildStatsColumn(
                    'Status Breakdown',
                    [
                      _StatItem('Pending', stats.pending, Colors.orange[700]!),
                      _StatItem('Assigned', stats.assigned, Colors.purple[700]!),
                      _StatItem('In Progress', stats.inProgress, Colors.blue[700]!),
                      _StatItem('Completed', stats.completed, Colors.green[700]!),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Quick Stats
                Expanded(
                  child: _buildStatsColumn(
                    'Quick Stats',
                    [
                      _StatItem('Total', stats.total, AppTheme.primary),
                      _StatItem('Verified', stats.verified, Colors.teal[700]!),
                      _StatItem('Rejected', stats.rejected, Colors.red[700]!),
                      _StatItem('Urgent', stats.urgent, Colors.amber[700]!),
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

  _OverviewStats _calculateStats() {
    final total = reports.length;
    final pending = reports.where((r) => r.status == ReportStatus.pending).length;
    final assigned = reports.where((r) => r.status == ReportStatus.assigned).length;
    final inProgress = reports.where((r) => r.status == ReportStatus.inProgress).length;
    final completed = reports.where((r) => r.status == ReportStatus.completed).length;
    final verified = reports.where((r) => r.status == ReportStatus.verified).length;
    final rejected = reports.where((r) => r.status == ReportStatus.rejected).length;
    final urgent = reports.where((r) => r.isUrgent).length;

    // Completion rate: (completed + verified) / total
    final completionRate = total > 0 
        ? (((completed + verified) / total) * 100).round() 
        : 0;

    return _OverviewStats(
      completionRate: completionRate,
      total: total,
      pending: pending,
      assigned: assigned,
      inProgress: inProgress,
      completed: completed,
      verified: verified,
      rejected: rejected,
      urgent: urgent,
    );
  }
}

// ==================== HELPER CLASSES ====================

/// Data class untuk stats overview (type-safe, non-nullable)
class _OverviewStats {
  final int completionRate;
  final int total;
  final int pending;
  final int assigned;
  final int inProgress;
  final int completed;
  final int verified;
  final int rejected;
  final int urgent;

  const _OverviewStats({
    required this.completionRate,
    required this.total,
    required this.pending,
    required this.assigned,
    required this.inProgress,
    required this.completed,
    required this.verified,
    required this.rejected,
    required this.urgent,
  });
}

/// Data class untuk stat item
class _StatItem {
  final String label;
  final int value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);
}