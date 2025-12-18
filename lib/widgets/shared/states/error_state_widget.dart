import 'package:flutter/material.dart';
import '../../../core/design/shared_design_constants.dart';

/// Error State Widget
/// Displays error messages with retry option
/// Used across all modules for consistent error handling
class ErrorStateWidget extends StatelessWidget {
  final ErrorType type;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.type,
    this.message,
    this.onRetry,
  });

  /// Network error (offline)
  factory ErrorStateWidget.network({
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      type: ErrorType.network,
      onRetry: onRetry,
    );
  }

  /// Permission denied
  factory ErrorStateWidget.permission({
    String? message,
  }) {
    return ErrorStateWidget(
      type: ErrorType.permission,
      message: message,
    );
  }

  /// Data fetch failed
  factory ErrorStateWidget.fetchFailed({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      type: ErrorType.fetchFailed,
      message: message,
      onRetry: onRetry,
    );
  }

  /// Timeout
  factory ErrorStateWidget.timeout({
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      type: ErrorType.timeout,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getErrorConfig(type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SharedDesignConstants.space2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              config.icon,
              size: 64,
              color: config.color,
            ),

            const SizedBox(height: SharedDesignConstants.spaceLg),

            // Title
            Text(
              config.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: SharedDesignConstants.spaceXs),

            // Subtitle
            Text(
              message ?? config.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button (optional)
            if (onRetry != null) ...[
              const SizedBox(height: SharedDesignConstants.spaceLg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Blue
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

  ErrorConfig _getErrorConfig(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return ErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: 'Tidak ada koneksi internet',
          subtitle: 'Periksa koneksi Anda dan coba lagi',
          color: const Color(0xFFF59E0B), // Amber
        );
      case ErrorType.permission:
        return ErrorConfig(
          icon: Icons.lock_outline,
          title: 'Akses ditolak',
          subtitle: 'Anda tidak memiliki izin untuk mengakses halaman ini',
          color: const Color(0xFFEF4444), // Red
        );
      case ErrorType.fetchFailed:
        return ErrorConfig(
          icon: Icons.error_outline,
          title: 'Terjadi kesalahan',
          subtitle: 'Gagal memuat data',
          color: const Color(0xFFEF4444), // Red
        );
      case ErrorType.timeout:
        return ErrorConfig(
          icon: Icons.access_time,
          title: 'Waktu habis',
          subtitle: 'Permintaan memakan waktu terlalu lama',
          color: const Color(0xFFF59E0B), // Amber
        );
      case ErrorType.unknown:
        return ErrorConfig(
          icon: Icons.help_outline,
          title: 'Terjadi kesalahan',
          subtitle: 'Silakan coba lagi nanti',
          color: const Color(0xFF6B7280), // Gray
        );
    }
  }
}

/// Error type enum
enum ErrorType {
  network,
  permission,
  fetchFailed,
  timeout,
  unknown,
}

/// Error configuration
class ErrorConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const ErrorConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

