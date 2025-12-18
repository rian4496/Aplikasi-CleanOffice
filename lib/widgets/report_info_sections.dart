// lib/screens/shared/report_detail/widgets/report_info_sections.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/report.dart';

/// Info sections: Location, Description, Reporter, Date
class ReportInfoSections extends StatelessWidget {
  final Report report;

  const ReportInfoSections({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Location
        _buildInfoCard(
          label: 'Lokasi',
          value: report.location,
          icon: Icons.location_on,
          color: AppTheme.primary,
        ),

        const SizedBox(height: 16),

        // Description
        if (report.description != null && report.description!.isNotEmpty)
          _buildInfoCard(
            label: 'Deskripsi',
            value: report.description!,
            icon: Icons.description,
            color: AppTheme.info,
          ),

        if (report.description != null && report.description!.isNotEmpty)
          const SizedBox(height: 16),

        // Reporter
        _buildInfoCard(
          label: 'Dilaporkan Oleh',
          value: report.userName,
          icon: Icons.person,
          color: AppTheme.secondary,
        ),

        const SizedBox(height: 16),

        // Email (if exists)
        if (report.userEmail != null && report.userEmail!.isNotEmpty)
          _buildInfoCard(
            label: 'Email Pelapor',
            value: report.userEmail!,
            icon: Icons.email,
            color: AppTheme.textSecondary,
          ),

        if (report.userEmail != null && report.userEmail!.isNotEmpty)
          const SizedBox(height: 16),

        // Date
        _buildInfoCard(
          label: 'Tanggal Laporan',
          value: DateFormatter.fullDateTime(report.date),
          icon: Icons.calendar_today,
          color: AppTheme.warning,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

