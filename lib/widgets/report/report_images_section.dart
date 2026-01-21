// lib/screens/shared/report_detail/widgets/report_images_section.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';

/// Images section: Problem Photo + Completion Photo
class ReportImagesSection extends StatelessWidget {
  final Report report;

  const ReportImagesSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // Show problem image if exists
    if (report.imageUrl != null && report.imageUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Foto Masalah',
            Icons.photo_library,
            AppTheme.error,
          ),
          const SizedBox(height: 12),
          _buildImage(report.imageUrl!),
          const SizedBox(height: 16),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gagal memuat gambar'),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

/// Completion Photo Section (shown after report completed)
class ReportCompletionPhotoSection extends StatelessWidget {
  final Report report;

  const ReportCompletionPhotoSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.completionImageUrl == null ||
        report.completionImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(
          'Foto Bukti Penyelesaian',
          Icons.check_circle,
          AppTheme.success,
        ),
        const SizedBox(height: 12),

        // Cleaner Info (if available)
        if (report.cleanerName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCleanerInfo(),
          ),

        // Completion Image
        _buildImage(report.completionImageUrl!),

        const SizedBox(height: 12),

        // Verified Badge
        _buildVerifiedBadge(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCleanerInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.success.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: AppTheme.success,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diselesaikan oleh:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                report.cleanerName!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (report.completedAt != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.format(report.completedAt!),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                DateFormatter.time(report.completedAt!),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gagal memuat gambar'),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified,
            color: AppTheme.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pekerjaan telah diselesaikan dan difoto sebagai bukti',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

