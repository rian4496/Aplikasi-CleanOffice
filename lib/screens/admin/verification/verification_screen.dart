// lib/screens/admin/verification/verification_screen.dart
// ✅ Verification Screen
// Admin verifies completed reports with before/after image comparison

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/admin/layout/mobile_admin_app_bar.dart';
import '../../../widgets/admin/verification/image_comparison_widget.dart';
import '../../../models/report.dart';
import '../../../providers/riverpod/report_providers.dart';

class VerificationScreen extends HookConsumerWidget {
  final String reportId;

  const VerificationScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportByIdProvider(reportId));
    final adminNotes = useState('');
    final isProcessing = useState(false);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: MobileAdminAppBar(
        title: 'Verifikasi Laporan',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reportAsync.when(
        data: (report) => _buildVerificationContent(
          context,
          ref,
          report,
          adminNotes,
          isProcessing,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildVerificationContent(
    BuildContext context,
    WidgetRef ref,
    Report? report,
    ValueNotifier<String> adminNotes,
    ValueNotifier<bool> isProcessing,
  ) {
    if (report == null) {
      return _buildNotFoundState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // Space for buttons
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Info Card
          Container(
            margin: const EdgeInsets.all(AdminConstants.spaceMd),
            padding: const EdgeInsets.all(AdminConstants.spaceMd),
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: AdminConstants.borderRadiusCard,
              boxShadow: AdminConstants.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Report #${report.id}',
                        style: AdminTypography.h4,
                      ),
                    ),
                    _buildStatusBadge(report.status),
                  ],
                ),
                const SizedBox(height: AdminConstants.spaceSm),
                _buildInfoRow(Icons.location_on, report.location),
                _buildInfoRow(Icons.business, report.department),
                _buildInfoRow(
                  Icons.calendar_today,
                  DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                      .format(report.createdAt),
                ),
                if (report.cleanerId != null)
                  _buildInfoRow(Icons.person, 'Cleaner: ${report.cleanerId}'),
              ],
            ),
          ),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
              vertical: AdminConstants.spaceSm,
            ),
            child: Text(
              'Perbandingan Foto',
              style: AdminTypography.h5,
            ),
          ),

          // Image Comparison
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
            ),
            child: ImageComparisonWidget(
              beforeImages: report.images,
              afterImages: report.completionImages,
              height: 250,
            ),
          ),

          const SizedBox(height: AdminConstants.spaceLg),

          // Cleaner Notes (Read-only)
          if (report.completionNotes != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminConstants.spaceMd,
              ),
              child: Text(
                'Catatan Petugas Kebersihan',
                style: AdminTypography.h5,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AdminConstants.spaceMd,
              ),
              padding: const EdgeInsets.all(AdminConstants.spaceMd),
              decoration: BoxDecoration(
                color: AdminColors.surface,
                borderRadius: AdminConstants.borderRadiusCard,
                boxShadow: AdminConstants.shadowCard,
              ),
              child: Text(
                report.completionNotes!,
                style: AdminTypography.body2,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceLg),
          ],

          // Admin Notes (Optional Input)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
            ),
            child: Text(
              'Catatan Admin (Opsional)',
              style: AdminTypography.h5,
            ),
          ),
          const SizedBox(height: AdminConstants.spaceSm),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
            ),
            child: TextField(
              onChanged: (value) => adminNotes.value = value,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan jika diperlukan...',
                filled: true,
                fillColor: AdminColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = AdminColors.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      ),
      child: Text(
        status,
        style: AdminTypography.badge.copyWith(color: color),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AdminConstants.spaceXs),
      child: Row(
        children: [
          Icon(icon, size: AdminConstants.iconXs, color: AdminColors.textSecondary),
          const SizedBox(width: AdminConstants.spaceSm),
          Expanded(
            child: Text(
              text,
              style: AdminTypography.body2.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Gagal Memuat Laporan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            Text(
              error.toString(),
              style: TextStyle(color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AdminColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Laporan Tidak Ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Sticky bottom actions
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Report report,
    String adminNotes,
    ValueNotifier<bool> isProcessing,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.spaceMd),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Approve Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isProcessing.value
                    ? null
                    : () => _handleApprove(context, ref, report.id, adminNotes, isProcessing),
                icon: const Icon(Icons.check_circle),
                label: Text(
                  'SETUJUI',
                  style: AdminTypography.buttonLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            // Reject Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isProcessing.value
                    ? null
                    : () => _handleReject(context, ref, report.id, adminNotes, isProcessing),
                icon: const Icon(Icons.cancel),
                label: Text(
                  'TOLAK',
                  style: AdminTypography.buttonLarge,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.error,
                  side: const BorderSide(color: AdminColors.error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    String reportId,
    String notes,
    ValueNotifier<bool> isProcessing,
  ) async {
    isProcessing.value = true;
    try {
      // TODO: Implement actual verification API call
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disetujui'),
            backgroundColor: AdminColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    String reportId,
    String notes,
    ValueNotifier<bool> isProcessing,
  ) async {
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon tambahkan catatan untuk penolakan'),
          backgroundColor: AdminColors.warning,
        ),
      );
      return;
    }

    isProcessing.value = true;
    try {
      // TODO: Implement actual rejection API call
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan ditolak'),
            backgroundColor: AdminColors.error,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }
}

// Provider extension
extension VerificationScreenProviders on WidgetRef {
  // Get bottom sheet with action buttons
  void showVerificationActions(
    BuildContext context,
    Report report,
    String adminNotes,
    ValueNotifier<bool> isProcessing,
  ) {
    final screen = VerificationScreen(reportId: report.id);
    showModalBottomSheet(
      context: context,
      builder: (context) => screen._buildActionButtons(
        context,
        this,
        report,
        adminNotes,
        isProcessing,
      ),
    );
  }
}
