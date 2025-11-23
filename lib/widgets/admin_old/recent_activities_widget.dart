// lib/widgets/admin/recent_activities_widget.dart
// 📋 Recent Activities Widget for Admin
// Menampilkan aktivitas terbaru yang perlu perhatian admin

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../screens/shared/report_detail/report_detail_screen.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/riverpod/selection_providers.dart';

// Activity item untuk admin
class _ActivityItem {
  final String id;
  final String type; // 'report' or 'request'
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final DateTime date;
  final bool needsAction;
  final dynamic data; // Original Report or Request object

  _ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.date,
    required this.needsAction,
    this.data,
  });
}

class RecentActivitiesWidget extends ConsumerWidget {
  final List<Report> reports;
  final List<Request> requests;
  final VoidCallback onViewAll;

  const RecentActivitiesWidget({
    super.key,
    required this.reports,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get recent activities that need attention
    final activities = _getRecentActivities();
    final recentActivities = activities.take(6).toList();
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(selectedReportIdsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    Icon(Icons.notifications_active, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Aktivitas Terbaru',
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

          // Activities List
          if (recentActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Semua sudah ditangani',
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
              itemCount: recentActivities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 64,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                final isSelected = selectedIds.contains(activity.id);
                
                return _buildActivityItem(
                  context, 
                  ref, 
                  activity, 
                  selectionMode, 
                  isSelected
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, 
    WidgetRef ref, 
    _ActivityItem activity, 
    bool selectionMode, 
    bool isSelected
  ) {
    return InkWell(
      onLongPress: () {
        if (activity.type == 'report') { // Only allow selecting reports for now
          if (!selectionMode) {
            ref.read(selectionModeProvider.notifier).state = true;
          }
          toggleReportSelection(ref, activity.id);
        }
      },
      onTap: () {
        if (selectionMode) {
          if (activity.type == 'report') {
            toggleReportSelection(ref, activity.id);
          }
          return;
        }
        
        if (activity.type == 'report' && activity.data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: activity.data),
            ),
          );
        } else if (activity.type == 'request') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(requestId: activity.id),
            ),
          );
        }
      },
      child: Container(
        color: isSelected ? AppTheme.primary.withOpacity(0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Selection Checkbox
            if (selectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (activity.type == 'report') {
                      toggleReportSelection(ref, activity.id);
                    }
                  },
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
            // Icon with badge
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: activity.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activity.icon,
                    color: activity.statusColor,
                    size: 24,
                  ),
                ),
                if (activity.needsAction)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activity.needsAction)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PERLU AKSI',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Status and Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: activity.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: activity.statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.relativeTime(activity.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
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

  List<_ActivityItem> _getRecentActivities() {
    final List<_ActivityItem> activities = [];

    // Add reports that need verification (completed status)
    for (var report in reports) {
      if (report.status == ReportStatus.completed) {
        activities.add(_ActivityItem(
          id: report.id,
          type: 'report',
          title: report.location,
          subtitle: 'Oleh: ${report.cleanerName ?? "Unknown"}',
          status: 'Perlu Verifikasi',
          statusColor: AppTheme.warning,
          icon: Icons.verified_user,
          date: report.completedAt ?? report.date,
          needsAction: true,
          data: report,
        ));
      } else if (report.status == ReportStatus.pending) {
        activities.add(_ActivityItem(
          id: report.id,
          type: 'report',
          title: report.location,
          subtitle: 'Dari: ${report.userName}',
          status: 'Belum Ditugaskan',
          statusColor: AppTheme.error,
          icon: Icons.assignment_late,
          date: report.date,
          needsAction: true,
          data: report,
        ));
      }
    }

    // Add pending requests
    for (var request in requests) {
      if (request.status == RequestStatus.pending) {
        activities.add(_ActivityItem(
          id: request.id,
          type: 'request',
          title: request.location,
          subtitle: 'Dari: ${request.requestedByName}',
          status: 'Perlu Ditugaskan',
          statusColor: AppTheme.info,
          icon: Icons.room_service,
          date: request.createdAt,
          needsAction: true,
        ));
      } else if (request.status == RequestStatus.completed) {
        activities.add(_ActivityItem(
          id: request.id,
          type: 'request',
          title: request.location,
          subtitle: 'Selesai oleh: ${request.assignedToName ?? "Unknown"}',
          status: 'Selesai',
          statusColor: AppTheme.success,
          icon: Icons.check_circle,
          date: request.completedAt ?? request.createdAt,
          needsAction: false,
        ));
      }
    }

    // Sort by date and priority (needs action first)
    activities.sort((a, b) {
      if (a.needsAction != b.needsAction) {
        return a.needsAction ? -1 : 1;
      }
      return b.date.compareTo(a.date);
    });

    return activities;
  }
}
