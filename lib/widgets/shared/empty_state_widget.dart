import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared Empty State Widget - Universal untuk semua role
/// Bisa dipakai di Employee, Cleaner, Admin
/// 
/// Usage Simple:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox,
///   title: 'Tidak ada data',
///   subtitle: 'Data akan muncul di sini',
/// )
/// ```
/// 
/// Usage dengan Action Button:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.task_alt,
///   title: 'Belum ada tugas',
///   subtitle: 'Mulai dengan membuat tugas baru',
///   actionLabel: 'Buat Tugas',
///   onAction: () => Navigator.push(...),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Icon yang ditampilkan
  final IconData icon;
  
  /// Judul/title utama
  final String title;
  
  /// Subtitle/deskripsi
  final String subtitle;
  
  /// Label untuk action button (optional)
  final String? actionLabel;
  
  /// Callback untuk action button (optional)
  final VoidCallback? onAction;
  
  /// Custom icon size (default: 64)
  final double? iconSize;
  
  /// Custom icon color (default: AppTheme.textHint)
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize,
    this.iconColor,
  });

  /// Factory: Empty state untuk "no reports"
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

  /// Factory: Empty state untuk "no search results"
  factory EmptyStateWidget.noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Tidak ditemukan',
      subtitle: 'Coba gunakan kata kunci yang berbeda',
    );
  }

  /// Factory: Empty state untuk "no tasks"
  factory EmptyStateWidget.noTasks({
    VoidCallback? onCreateTask,
  }) {
    return EmptyStateWidget(
      icon: Icons.task_alt,
      title: 'Tidak ada tugas',
      subtitle: 'Tugas yang ditugaskan akan muncul di sini',
      actionLabel: onCreateTask != null ? 'Buat Tugas' : null,
      onAction: onCreateTask,
    );
  }

  /// Factory: Empty state untuk "no requests"
  factory EmptyStateWidget.noRequests() {
    return const EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'Tidak ada permintaan',
      subtitle: 'Permintaan baru akan muncul di sini',
    );
  }

  /// Factory: Empty state untuk "no notifications"
  factory EmptyStateWidget.noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'Tidak ada notifikasi',
      subtitle: 'Anda akan menerima notifikasi di sini',
    );
  }

  /// Factory: Empty state untuk "no history"
  factory EmptyStateWidget.noHistory() {
    return const EmptyStateWidget(
      icon: Icons.history,
      title: 'Belum ada riwayat',
      subtitle: 'Riwayat aktivitas akan muncul di sini',
    );
  }

  /// Factory: Custom empty state
  factory EmptyStateWidget.custom({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              size: iconSize ?? 64,
              color: iconColor ?? AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action Button (optional)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
}

/// Loading Empty State - Untuk menampilkan loading skeleton
class LoadingEmptyState extends StatelessWidget {
  final String? message;

  const LoadingEmptyState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error Empty State - Untuk menampilkan error
class ErrorEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const ErrorEmptyState({
    super.key,
    this.title = 'Terjadi kesalahan',
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}