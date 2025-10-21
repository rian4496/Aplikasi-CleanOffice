// lib/screens/cleaner/cleaner_report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';

final _logger = AppLogger('CleanerReportDetailScreen');

class CleanerReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;

  const CleanerReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<CleanerReportDetailScreen> createState() =>
      _CleanerReportDetailScreenState();
}

class _CleanerReportDetailScreenState
    extends ConsumerState<CleanerReportDetailScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDetailProvider(widget.reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: AppTheme.primary,
      ),
      body: reportAsync.when(
        data: (report) {
          if (report == null) {
            return _buildNotFoundState();
          }
          return _buildContent(report);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildContent(Report report) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(report),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image if exists
                if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                  _buildImage(report.imageUrl!),

                if (report.imageUrl != null)
                  const SizedBox(height: 16),

                // Info sections
                _buildInfoSection(
                  'Lokasi',
                  report.location,
                  Icons.location_on,
                  AppTheme.primary,
                ),
                const SizedBox(height: 16),

                _buildInfoSection(
                  'Deskripsi',
                  report.description ?? '-',
                  Icons.description,
                  AppTheme.info,
                ),
                const SizedBox(height: 16),

                _buildInfoSection(
                  'Dilaporkan Oleh',
                  report.userName,
                  Icons.person,
                  AppTheme.secondary,
                ),
                const SizedBox(height: 16),

                if (report.userEmail != null)
                  _buildInfoSection(
                    'Email Pelapor',
                    report.userEmail!,
                    Icons.email,
                    AppTheme.textSecondary,
                  ),

                if (report.userEmail != null)
                  const SizedBox(height: 16),

                _buildInfoSection(
                  'Tanggal Laporan',
                  _formatDateTime(report.date),
                  Icons.calendar_today,
                  AppTheme.warning,
                ),

                const SizedBox(height: 24),

                // Timeline
                _buildTimeline(report),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(report, currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Report report) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: report.status.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (report.isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.priority_high, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.location,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
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
            height: 250,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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

  Widget _buildTimeline(Report report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Dibuat',
              report.date,
              Icons.add_circle_outline,
              AppTheme.info,
            ),
            if (report.assignedAt != null)
              _buildTimelineItem(
                'Ditugaskan',
                report.assignedAt!,
                Icons.assignment_ind,
                AppTheme.success,
              ),
            if (report.startedAt != null)
              _buildTimelineItem(
                'Mulai Dikerjakan',
                report.startedAt!,
                Icons.play_circle_outline,
                AppTheme.warning,
              ),
            if (report.completedAt != null)
              _buildTimelineItem(
                'Selesai',
                report.completedAt!,
                Icons.check_circle,
                Colors.purple,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    DateTime timestamp,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
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
                  DateFormatter.fullDateTime(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Report report, String? currentUserId) {
    // If completed/verified, no actions
    if (report.status == ReportStatus.completed ||
        report.status == ReportStatus.verified) {
      return _buildInfoCard(
        'Laporan ini sudah diselesaikan',
        Icons.check_circle,
        AppTheme.success,
      );
    }

    // If pending, show Accept button
    if (report.status == ReportStatus.pending) {
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _acceptReport(),
        icon: const Icon(Icons.check),
        label: const Text('Terima Laporan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
        ),
      );
    }

    // If assigned/in_progress and assigned to current user
    if (report.cleanerId == currentUserId) {
      if (report.status == ReportStatus.assigned) {
        return ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _startReport(),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Mulai Pengerjaan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warning,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
          ),
        );
      } else if (report.status == ReportStatus.inProgress) {
        return ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _completeReport(),
          icon: const Icon(Icons.done),
          label: const Text('Tandai Selesai'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
          ),
        );
      }
    }

    // If assigned to someone else
    if (report.cleanerId != null && report.cleanerId != currentUserId) {
      return _buildInfoCard(
        'Laporan ini sedang ditangani petugas lain',
        Icons.info_outline,
        AppTheme.info,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(String message, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Laporan tidak ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormatter.fullDateTime(dateTime);
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _acceptReport() async {
    final confirmed = await _showConfirmDialog(
      'Terima Laporan',
      'Apakah Anda yakin ingin menerima laporan ini?',
      'TERIMA',
      AppTheme.success,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.acceptReport(widget.reportId);

      if (!mounted) return;
      _showSuccessSnackbar('Laporan berhasil diterima');
    } on FirestoreException catch (e) {
      _logger.error('Accept report error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _startReport() async {
    final confirmed = await _showConfirmDialog(
      'Mulai Pengerjaan',
      'Apakah Anda siap memulai pengerjaan?',
      'MULAI',
      AppTheme.warning,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.startReport(widget.reportId);

      if (!mounted) return;
      _showSuccessSnackbar('Pengerjaan dimulai');
    } on FirestoreException catch (e) {
      _logger.error('Start report error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeReport() async {
    final confirmed = await _showConfirmDialog(
      'Tandai Selesai',
      'Apakah Anda yakin pekerjaan sudah selesai?',
      'SELESAI',
      Colors.purple,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.completeReport(widget.reportId);

      if (!mounted) return;
      _showSuccessSnackbar('Laporan berhasil diselesaikan!');

      // Go back after completion
      Navigator.pop(context);
    } on FirestoreException catch (e) {
      _logger.error('Complete report error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(actionText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}