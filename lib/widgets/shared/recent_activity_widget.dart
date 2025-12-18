// lib/widgets/shared/recent_activity_widget.dart
// Reusable widget untuk menampilkan recent activities

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../screens/shared/report_detail/report_detail_screen.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';

/// Activity type enum
enum ActivityType { report, request }

/// Activity item model
class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final String location;
  final DateTime date;
  final String status;
  final Color statusColor;
  final bool isUrgent;
  final dynamic data; // Store original Report or Request object

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
    this.isUrgent = false,
    this.data,
  });

  /// Create from Report
  factory ActivityItem.fromReport(Report report) {
    return ActivityItem(
      id: report.id,
      type: ActivityType.report,
      title: report.title,
      location: report.location,
      date: report.completedAt ?? report.date,
      status: report.status.displayName,
      statusColor: report.status.color,
      isUrgent: report.isUrgent,
      data: report,
    );
  }

  /// Create from Request
  factory ActivityItem.fromRequest(Request request) {
    return ActivityItem(
      id: request.id,
      type: ActivityType.request,
      title: 'Permintaan Layanan',
      location: request.location,
      date: request.completedAt ?? request.createdAt,
      status: request.status.displayName,
      statusColor: request.status.color,
      isUrgent: request.isUrgent,
      data: request,
    );
  }
}

/// Recent Activity Widget
/// Menampilkan list aktivitas terbaru (reports & requests)
class RecentActivityWidget extends StatelessWidget {
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;
  final int maxItems;

  const RecentActivityWidget({
    super.key,
    required this.activities,
    this.onViewAll,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity list
          if (displayActivities.isEmpty)
            _buildEmptyState()
          else
            ...displayActivities.map((activity) {
              return _buildActivityCard(context, activity);
            }),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: activity.isUrgent
            ? const BorderSide(color: AppTheme.error, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (activity.type == ActivityType.report) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(report: activity.data),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestDetailScreen(requestId: activity.id),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity.statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.type == ActivityType.report
                      ? Icons.assignment
                      : Icons.room_service,
                  color: activity.statusColor,
                  size: 20,
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
                        Expanded(
                          child: Text(
                            activity.location,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activity.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: activity.statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: activity.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.relativeTime(activity.date),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada aktivitas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

