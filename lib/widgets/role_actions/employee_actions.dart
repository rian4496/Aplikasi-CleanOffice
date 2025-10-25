// lib/widgets/role_actions/employee_actions.dart

import 'package:flutter/material.dart';

// ✅ FIXED: Import paths untuk lokasi lib/widgets/role_actions/ (naik 2 level)
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';

/// Action section for Employee role (usually just info, no actions)
class EmployeeActions extends StatelessWidget {
  final Report report;
  final String? currentUserId;

  const EmployeeActions({
    super.key,
    required this.report,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Check if report is still pending (can be edited/deleted from home screen)
    if (report.status == ReportStatus.pending) {
      return _buildInfoCard(
        'Laporan Anda menunggu untuk diterima petugas',
        Icons.schedule,
        AppTheme.warning,
      );
    }

    // If assigned to cleaner
    if (report.status == ReportStatus.assigned) {
      return _buildInfoCard(
        'Laporan Anda telah diterima dan akan segera dikerjakan',
        Icons.person_add,
        AppTheme.info,
      );
    }

    // If in progress
    if (report.status == ReportStatus.inProgress) {
      return _buildInfoCard(
        'Laporan Anda sedang dikerjakan oleh petugas',
        Icons.construction,
        AppTheme.info,
      );
    }

    // If completed
    if (report.status == ReportStatus.completed) {
      return _buildInfoCard(
        'Laporan Anda telah diselesaikan oleh petugas',
        Icons.check_circle,
        AppTheme.success,
      );
    }

    // If verified
    if (report.status == ReportStatus.verified) {
      return _buildInfoCard(
        'Laporan Anda telah diverifikasi dan selesai',
        Icons.verified,
        Colors.green[700]!,
      );
    }

    // If rejected
    if (report.status == ReportStatus.rejected) {
      return _buildInfoCard(
        'Laporan Anda ditolak. Silakan hubungi admin untuk info lebih lanjut.',
        Icons.cancel,
        AppTheme.error,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(String message, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      elevation: 0,
      // ✅ FIXED: Gunakan 'shape' bukan 'border' untuk Card widget
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}