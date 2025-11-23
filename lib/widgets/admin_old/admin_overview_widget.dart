// lib/widgets/admin/admin_overview_widget.dart
// 📊 Admin Overview Widget
// Menampilkan statistik keseluruhan sistem (Reports, Requests, Cleaners)

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/request.dart';

class AdminOverviewWidget extends StatelessWidget {
  final List<Report> reports;
  final List<Request> requests;
  final int totalCleaners;

  const AdminOverviewWidget({
    super.key,
    required this.reports,
    required this.requests,
    required this.totalCleaners,
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
                Icon(Icons.dashboard, color: AppTheme.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Ringkasan Sistem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // System Health
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kesehatan Sistem',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          stats.systemHealth >= 80 ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: stats.systemHealth >= 80 
                              ? AppTheme.success 
                              : AppTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.systemHealth}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: stats.systemHealth >= 80 
                                ? AppTheme.success 
                                : AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.systemHealth / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      stats.systemHealth >= 80
                          ? AppTheme.success
                          : stats.systemHealth >= 60
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

          // Stats Grid - 3 columns
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Reports Column
                Expanded(
                  child: _buildStatsColumn(
                    'Laporan',
                    [
                      _StatItem('Total', stats.totalReports, AppTheme.primary),
                      _StatItem('Pending', stats.reportsPending, Colors.orange[700]!),
                      _StatItem('Proses', stats.reportsInProgress, Colors.blue[700]!),
                      _StatItem('Verifikasi', stats.reportsNeedVerification, Colors.purple[700]!),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Requests Column
                Expanded(
                  child: _buildStatsColumn(
                    'Permintaan',
                    [
                      _StatItem('Total', stats.totalRequests, AppTheme.info),
                      _StatItem('Pending', stats.requestsPending, Colors.amber[700]!),
                      _StatItem('Aktif', stats.requestsActive, Colors.indigo[700]!),
                      _StatItem('Selesai', stats.requestsCompleted, Colors.green[700]!),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // System Column
                Expanded(
                  child: _buildStatsColumn(
                    'Sistem',
                    [
                      _StatItem('Petugas', totalCleaners, Colors.purple[700]!),
                      _StatItem('Urgent', stats.urgentTotal, Colors.red[700]!),
                      _StatItem('Hari Ini', stats.completedToday, Colors.teal[700]!),
                      _StatItem('Verified', stats.reportsVerified, Colors.cyan[700]!),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.value}',
                      style: TextStyle(
                        fontSize: 14,
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

  _AdminStats _calculateStats() {
    // Reports stats
    final totalReports = reports.length;
    final reportsPending = reports.where((r) => r.status == ReportStatus.pending).length;
    final reportsInProgress = reports.where((r) => r.status == ReportStatus.inProgress).length;
    final reportsNeedVerification = reports.where((r) => r.status == ReportStatus.completed).length;
    final reportsVerified = reports.where((r) => r.status == ReportStatus.verified).length;
    final reportsUrgent = reports.where((r) => r.isUrgent).length;

    // Requests stats
    final totalRequests = requests.length;
    final requestsPending = requests.where((r) => r.status == RequestStatus.pending).length;
    final requestsActive = requests.where((r) => r.status.isActive).length;
    final requestsCompleted = requests.where((r) => r.status == RequestStatus.completed).length;
    final requestsUrgent = requests.where((r) => r.isUrgent).length;

    // Today's completions
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final completedToday = reports.where((r) {
      return r.completedAt != null && 
             r.completedAt!.isAfter(startOfDay) &&
             r.completedAt!.isBefore(today);
    }).length + requests.where((r) {
      return r.completedAt != null && 
             r.completedAt!.isAfter(startOfDay) &&
             r.completedAt!.isBefore(today);
    }).length;

    // Urgent total
    final urgentTotal = reportsUrgent + requestsUrgent;

    // System Health calculation
    // Based on: pending items, verification queue, active tasks distribution
    final totalItems = totalReports + totalRequests;
    final problemItems = reportsPending + requestsPending + reportsNeedVerification;
    final systemHealth = totalItems > 0
        ? ((1 - (problemItems / totalItems)) * 100).round()
        : 100;

    return _AdminStats(
      systemHealth: systemHealth.clamp(0, 100),
      totalReports: totalReports,
      reportsPending: reportsPending,
      reportsInProgress: reportsInProgress,
      reportsNeedVerification: reportsNeedVerification,
      reportsVerified: reportsVerified,
      totalRequests: totalRequests,
      requestsPending: requestsPending,
      requestsActive: requestsActive,
      requestsCompleted: requestsCompleted,
      urgentTotal: urgentTotal,
      completedToday: completedToday,
    );
  }
}

// ==================== HELPER CLASSES ====================

class _AdminStats {
  final int systemHealth;
  final int totalReports;
  final int reportsPending;
  final int reportsInProgress;
  final int reportsNeedVerification;
  final int reportsVerified;
  final int totalRequests;
  final int requestsPending;
  final int requestsActive;
  final int requestsCompleted;
  final int urgentTotal;
  final int completedToday;

  const _AdminStats({
    required this.systemHealth,
    required this.totalReports,
    required this.reportsPending,
    required this.reportsInProgress,
    required this.reportsNeedVerification,
    required this.reportsVerified,
    required this.totalRequests,
    required this.requestsPending,
    required this.requestsActive,
    required this.requestsCompleted,
    required this.urgentTotal,
    required this.completedToday,
  });
}

class _StatItem {
  final String label;
  final int value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);
}
