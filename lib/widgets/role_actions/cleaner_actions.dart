// lib/screens/shared/report_detail/widgets/role_actions/cleaner_actions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/logging/app_logger.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../models/report.dart';
import '../../../../../providers/riverpod/auth_providers.dart';
import '../../../../../providers/riverpod/cleaner_providers.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../../../../widgets/completion_photo_dialog.dart';

final _logger = AppLogger('CleanerActions');

/// Action buttons for Cleaner role
class CleanerActions extends ConsumerStatefulWidget {
  final Report report;
  final String? currentUserId;

  const CleanerActions({
    super.key,
    required this.report,
    this.currentUserId,
  });

  @override
  ConsumerState<CleanerActions> createState() => _CleanerActionsState();
}

class _CleanerActionsState extends ConsumerState<CleanerActions> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final currentUserId = widget.currentUserId;

    // If completed/verified, show info only
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
        onPressed: _isProcessing ? null : _acceptReport,
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
          onPressed: _isProcessing ? null : _startReport,
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
          onPressed: _isProcessing ? null : _completeReport,
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
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _acceptReport() async {
    final confirmed = await _showConfirmDialog(
      title: 'Terima Laporan',
      content: 'Apakah Anda yakin ingin menerima laporan ini?',
      actionText: 'TERIMA',
      actionColor: AppTheme.success,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.acceptReport(widget.report.id);

      if (!mounted) return;
      _showSuccessSnackbar('Laporan berhasil diterima');
      Navigator.pop(context); // Go back after action
    } on DatabaseException catch (e) {
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
      title: 'Mulai Pengerjaan',
      content: 'Apakah Anda siap memulai pengerjaan?',
      actionText: 'MULAI',
      actionColor: AppTheme.warning,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.startReport(widget.report.id);

      if (!mounted) return;
      _showSuccessSnackbar('Pengerjaan dimulai');
    } on DatabaseException catch (e) {
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
    // Step 1: Show photo dialog
    final photoFile = await CompletionPhotoDialog.show(
      context,
      title: 'Upload Foto Bukti',
      description: 'Upload foto sebagai bukti bahwa laporan sudah diselesaikan',
    );

    // User cancelled
    if (photoFile == null) {
      _logger.info('User cancelled photo upload');
      return;
    }

    // Step 2: Confirm completion
    final confirmed = await _showConfirmDialog(
      title: 'Tandai Selesai',
      content: 'Apakah Anda yakin pekerjaan sudah selesai?',
      actionText: 'SELESAI',
      actionColor: Colors.purple,
    );

    if (!confirmed) return;

    // Step 3: Upload photo & Complete
    setState(() => _isProcessing = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Show uploading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Mengupload foto...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Upload photo to Firebase Storage
      final storageService = ref.read(storageServiceProvider);
      final imageBytes = await photoFile.readAsBytes();

      final uploadResult = await storageService.uploadImage(
        bytes: imageBytes,
        bucket: SupabaseConfig.reportImagesBucket,
        userId: userId,
      );

      // Clear uploading snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      // Check upload result
      if (!uploadResult.isSuccess || uploadResult.data == null) {
        throw Exception(uploadResult.error ?? 'Upload gagal');
      }

      final photoUrl = uploadResult.data!;
      _logger.info('Photo uploaded: $photoUrl');

      // Complete report with photo URL
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.completeReportWithProof(widget.report.id, photoUrl);

      if (!mounted) return;
      _showSuccessSnackbar('Laporan berhasil diselesaikan dengan foto bukti!');

      // Go back after completion
      Navigator.pop(context);
    } on DatabaseException catch (e) {
      _logger.error('Complete report error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      _logger.error('Unexpected error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        _showErrorSnackbar('Gagal: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ==================== HELPER METHODS ====================

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
    required String actionText,
    required Color actionColor,
  }) async {
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
            Expanded(child: Text(message)),
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

