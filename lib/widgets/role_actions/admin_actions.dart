// lib/widgets/role_actions/admin_actions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ FIXED: Import paths untuk lokasi lib/widgets/role_actions/ (naik 2 level)
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';

final _logger = AppLogger('AdminActions');

/// Action buttons for Admin role
class AdminActions extends ConsumerStatefulWidget {
  final Report report;
  final String? currentUserId;

  const AdminActions({
    super.key,
    required this.report,
    this.currentUserId,
  });

  @override
  ConsumerState<AdminActions> createState() => _AdminActionsState();
}

class _AdminActionsState extends ConsumerState<AdminActions> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    // If already verified or rejected, show info
    if (report.status == ReportStatus.verified) {
      return _buildInfoCard(
        'Laporan ini sudah diverifikasi',
        Icons.verified,
        AppTheme.success,
      );
    }

    if (report.status == ReportStatus.rejected) {
      return _buildInfoCard(
        'Laporan ini telah ditolak',
        Icons.cancel,
        AppTheme.error,
      );
    }

    // If completed, show verify/reject buttons
    if (report.status == ReportStatus.completed) {
      return Column(
        children: [
          // Info message
          Card(
            color: Colors.blue.withValues(alpha: 0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Laporan sudah diselesaikan. Verifikasi atau tolak laporan ini.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              // Reject Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _rejectReport,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Verify Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _verifyReport,
                  icon: const Icon(Icons.verified),
                  label: const Text('Verifikasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // For other statuses, show status info
    return _buildStatusInfo(report.status);
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

  Widget _buildStatusInfo(ReportStatus status) {
    String message;
    IconData icon;
    Color color;

    switch (status) {
      case ReportStatus.pending:
        message = 'Laporan menunggu untuk diterima petugas';
        icon = Icons.schedule;
        color = AppTheme.warning;
        break;
      case ReportStatus.assigned:
        message = 'Laporan sudah diterima petugas';
        icon = Icons.person_add;
        color = AppTheme.info;
        break;
      case ReportStatus.inProgress:
        message = 'Laporan sedang dikerjakan';
        icon = Icons.construction;
        color = AppTheme.info;
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildInfoCard(message, icon, color);
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _verifyReport() async {
    // Show dialog to input verification notes
    final notes = await _showNotesDialog(
      title: 'Verifikasi Laporan',
      hint: 'Catatan verifikasi (opsional)',
      isRequired: false,
    );

    if (notes == null) return; // User cancelled

    setState(() => _isProcessing = true);

    try {
      // ✅ FIXED: Gunakan verificationActionsProvider yang sudah ada
      final actions = ref.read(verificationActionsProvider);
      
      // ✅ FIXED: Gunakan method approveReport() dengan report object
      await actions.approveReport(
        widget.report,
        notes: notes.isEmpty ? null : notes,
      );

      if (!mounted) return;
      _showSuccessSnackbar('Laporan berhasil diverifikasi');
      Navigator.pop(context); // Go back after action
    } on DatabaseException catch (e) {
      _logger.error('Verify report error', e);
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

  Future<void> _rejectReport() async {
    // Show dialog to input rejection reason (required)
    final reason = await _showNotesDialog(
      title: 'Tolak Laporan',
      hint: 'Alasan penolakan (wajib)',
      isRequired: true,
    );

    if (reason == null) return; // User cancelled

    setState(() => _isProcessing = true);

    try {
      // ✅ FIXED: Gunakan verificationActionsProvider yang sudah ada
      final actions = ref.read(verificationActionsProvider);
      
      // ✅ FIXED: Gunakan method rejectReport() dengan report object
      await actions.rejectReport(
        widget.report,
        reason: reason,
      );

      if (!mounted) return;
      _showSuccessSnackbar('Laporan ditolak');
      Navigator.pop(context); // Go back after action
    } on DatabaseException catch (e) {
      _logger.error('Reject report error', e);
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

  // ==================== HELPER METHODS ====================

  Future<String?> _showNotesDialog({
    required String title,
    required String hint,
    required bool isRequired,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return 'Field ini wajib diisi';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('KIRIM'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
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