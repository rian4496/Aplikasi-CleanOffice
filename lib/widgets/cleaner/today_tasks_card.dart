// lib/widgets/cleaner/today_tasks_card.dart
// Today's tasks card for cleaner dashboard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/report.dart';
import '../../core/theme/app_theme.dart';

class TodayTasksCard extends ConsumerWidget {
  final List<Report> todayTasks;

  const TodayTasksCard({
    super.key,
    required this.todayTasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgentCount = todayTasks.where((r) => r.isUrgent == true).length;
    final completedCount = todayTasks.where((r) => 
      r.status == ReportStatus.completed || 
      r.status == ReportStatus.verified
    ).length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Tugas Hari Ini',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (urgentCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$urgentCount Urgent',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.assignment,
                    label: 'Total',
                    value: '${todayTasks.length}',
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Selesai',
                    value: '$completedCount',
                    color: Colors.greenAccent,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: '${todayTasks.length - completedCount}',
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            if (todayTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to task list
                  Navigator.pushNamed(context, '/cleaner/tasks');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Tugas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

