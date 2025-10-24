// lib/screens/shared/report_detail/widgets/report_timeline.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/report.dart';

/// Timeline of report progress
class ReportTimeline extends StatelessWidget {
  final Report report;

  const ReportTimeline({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Created
            _buildTimelineItem(
              label: 'Dilaporkan',
              dateTime: report.date,
              icon: Icons.add_circle_outline,
              color: AppTheme.info,
            ),

            // Assigned
            if (report.assignedAt != null)
              _buildTimelineItem(
                label: 'Diterima Petugas',
                dateTime: report.assignedAt!,
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),

            // Started
            if (report.startedAt != null)
              _buildTimelineItem(
                label: 'Mulai Dikerjakan',
                dateTime: report.startedAt!,
                icon: Icons.play_circle_outline,
                color: AppTheme.warning,
              ),

            // Completed
            if (report.completedAt != null)
              _buildTimelineItem(
                label: 'Selesai',
                dateTime: report.completedAt!,
                icon: Icons.done_all,
                color: Colors.purple,
              ),

            // Verified
            if (report.verifiedAt != null)
              _buildTimelineItem(
                label: 'Diverifikasi',
                dateTime: report.verifiedAt!,
                icon: Icons.verified,
                color: Colors.green[700]!,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String label,
    required DateTime dateTime,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            // Icon circle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),

            // Line connector
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormatter.fullDateTime(dateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
