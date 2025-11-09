// lib/widgets/cleaner/recent_tasks_widget.dart
// 📋 Recent Tasks Widget for Cleaner
// Menampilkan tugas terbaru (Reports + Requests) yang ditugaskan

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../screens/cleaner/report_detail_cleaner_screen.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';

// Task item untuk combined reports & requests
class _TaskItem {
  final String id;
  final String type; // 'report' or 'request'
  final String location;
  final String status;
  final Color statusColor;
  final DateTime date;
  final bool isUrgent;
  final dynamic originalData; // Report atau Request object

  _TaskItem({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.isUrgent,
    required this.originalData,
  });
}

class RecentTasksWidget extends StatelessWidget {
  final List<Report> reports;
  final List<Request> requests;
  final VoidCallback onViewAll;

  const RecentTasksWidget({
    super.key,
    required this.reports,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Combine and sort tasks
    final tasks = _combineTasks();
    final recentTasks = tasks.take(5).toList();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Tugas Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                // View All Button
                TextButton(
                  onPressed: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          if (recentTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tugas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: recentTasks.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 72,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                return _buildTaskItem(context, recentTasks[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, _TaskItem task) {
    return InkWell(
      onTap: () {
        if (task.type == 'report') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CleanerReportDetailScreen(reportId: task.id),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(requestId: task.id),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Type Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: task.type == 'report' 
                    ? Colors.blue[50] 
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                task.type == 'report' 
                    ? Icons.assignment 
                    : Icons.room_service,
                color: task.type == 'report' 
                    ? Colors.blue[700] 
                    : Colors.green[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: task.type == 'report' 
                              ? Colors.blue[100] 
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.type == 'report' ? 'LAPORAN' : 'PERMINTAAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: task.type == 'report' 
                                ? Colors.blue[700] 
                                : Colors.green[700],
                          ),
                        ),
                      ),
                      if (task.isUrgent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.location,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Status and Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: task.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: task.statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.relativeTime(task.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TaskItem> _combineTasks() {
    final List<_TaskItem> tasks = [];

    // Add reports
    for (var report in reports) {
      tasks.add(_TaskItem(
        id: report.id,
        type: 'report',
        location: report.location,
        status: report.status.displayName,
        statusColor: report.status.color,
        date: report.assignedAt ?? report.date,
        isUrgent: report.isUrgent,
        originalData: report,
      ));
    }

    // Add requests
    for (var request in requests) {
      tasks.add(_TaskItem(
        id: request.id,
        type: 'request',
        location: request.location,
        status: request.status.displayName,
        statusColor: request.status.color,
        date: request.assignedAt ?? request.createdAt,
        isUrgent: request.isUrgent,
        originalData: request,
      ));
    }

    // Sort by date (most recent first)
    tasks.sort((a, b) => b.date.compareTo(a.date));

    return tasks;
  }
}
