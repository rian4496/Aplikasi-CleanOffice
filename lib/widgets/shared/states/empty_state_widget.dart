import 'package:flutter/material.dart';
import '../../../core/design/shared_design_constants.dart';

/// Empty State Widget
/// Displays when no data is available
/// Used across all modules for consistent empty states
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// Predefined empty state for no reports
  factory EmptyStateWidget.noReports({
    VoidCallback? onCreateReport,
  }) {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: 'Belum ada laporan',
      subtitle: 'Laporan yang Anda buat akan muncul di sini',
      actionLabel: onCreateReport != null ? 'Buat Laporan' : null,
      onAction: onCreateReport,
    );
  }

  /// Predefined empty state for no tasks
  factory EmptyStateWidget.noTasks({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.task_outlined,
      title: 'Belum ada tugas',
      subtitle: 'Tugas yang tersedia akan muncul di sini',
      actionLabel: onAction != null ? 'Refresh' : null,
      onAction: onAction,
    );
  }

  /// Predefined empty state for no data
  factory EmptyStateWidget.noData({
    required String message,
  }) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'Tidak ada data',
      subtitle: message,
    );
  }

  /// Predefined empty state for search no results
  factory EmptyStateWidget.noSearchResults({
    required String query,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Tidak ada hasil',
      subtitle: 'Tidak ditemukan hasil untuk "$query"',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SharedDesignConstants.space2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor ?? const Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: SharedDesignConstants.spaceLg),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3674),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: SharedDesignConstants.spaceXs),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            // Action button (optional)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SharedDesignConstants.spaceLg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63), // Pink
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

