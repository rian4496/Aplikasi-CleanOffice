// lib/screens/web_admin/verification_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';

/// Screen untuk verifikasi laporan yang sudah selesai dikerjakan
/// Admin dapat menyetujui atau menolak laporan
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class VerificationScreen extends HookConsumerWidget {
  final Report report;

  const VerificationScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Auto-disposed controller
    final notesController = useTextEditingController();

    // ✅ HOOKS: State management
    final isProcessing = useState(false);

    // ✅ HOOKS: Validation - navigate away if report doesn't need verification
    useEffect(() {
      if (!report.needsVerification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Laporan ini tidak memerlukan verifikasi. Status: ${report.status.displayName}'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        });
      }
      return null;
    }, const []);

    // Jangan render jika tidak perlu verifikasi
    if (!report.needsVerification) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verifikasi Laporan')),
        body: const Center(child: Text('Tidak perlu verifikasi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Laporan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dengan status
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 12),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    report.location,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy HH:mm').format(report.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (report.isUrgent) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Colors.red[900],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LAPORAN URGEN',
                            style: TextStyle(
                              color: Colors.red[900],
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
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Laporan
                  if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        report.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 64),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Informasi Detail
                  _buildDetailSection('Pelapor', report.userName, Icons.person),
                  if (report.userEmail != null)
                    _buildDetailSection(
                      'Email',
                      report.userEmail!,
                      Icons.email,
                    ),

                  const SizedBox(height: 16),

                  if (report.cleanerName != null)
                    _buildDetailSection(
                      'Petugas',
                      report.cleanerName!,
                      Icons.engineering,
                    ),

                  if (report.description != null &&
                      report.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      'Deskripsi',
                      report.description!,
                      Icons.description,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Timeline
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Timeline',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTimelineItem(
                            'Dibuat',
                            report.date,
                            Icons.add_circle_outline,
                            Colors.blue,
                          ),
                          if (report.assignedAt != null)
                            _buildTimelineItem(
                              'Ditugaskan',
                              report.assignedAt!,
                              Icons.assignment_ind,
                              Colors.orange,
                            ),
                          if (report.startedAt != null)
                            _buildTimelineItem(
                              'Mulai Dikerjakan',
                              report.startedAt!,
                              Icons.play_circle_outline,
                              Colors.purple,
                            ),
                          if (report.completedAt != null)
                            _buildTimelineItem(
                              'Selesai',
                              report.completedAt!,
                              Icons.check_circle_outline,
                              Colors.green,
                              isLast: true,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Catatan Verifikasi
                  const Text(
                    'Catatan (Opsional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan jika diperlukan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    enabled: !isProcessing.value,
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing.value
                              ? null
                              : () => _handleReject(
                                    context,
                                    ref,
                                    report,
                                    notesController,
                                    isProcessing,
                                  ),
                          icon: const Icon(Icons.close),
                          label: const Text('Tolak'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing.value
                              ? null
                              : () => _handleApprove(
                                    context,
                                    ref,
                                    report,
                                    notesController,
                                    isProcessing,
                                  ),
                          icon: const Icon(Icons.check),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build detail section with icon
  static Widget _buildDetailSection(
      String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.deepPurple[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(content, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  /// Build timeline item
  static Widget _buildTimelineItem(
    String label,
    DateTime time,
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
              child: Icon(icon, size: 16, color: color),
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
                  DateFormat('dd MMM yyyy, HH:mm').format(time),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== ACTION HANDLERS ====================

  /// Handle approve action
  static Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    Report report,
    TextEditingController notesController,
    ValueNotifier<bool> isProcessing,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Laporan'),
        content: const Text('Apakah Anda yakin ingin menyetujui laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SETUJUI'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isProcessing.value = true;

    try {
      final actions = ref.read(verificationActionsProvider);
      await actions.approveReport(
        report,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Handle reject action
  /// ⚠️ BUSINESS LOGIC: Notes required for rejection
  static Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    Report report,
    TextEditingController notesController,
    ValueNotifier<bool> isProcessing,
  ) async {
    if (notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon berikan alasan penolakan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Laporan'),
        content: const Text(
          'Apakah Anda yakin ingin menolak laporan ini? '
          'Petugas harus mengerjakan ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('TOLAK'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isProcessing.value = true;

    try {
      final actions = ref.read(verificationActionsProvider);
      await actions.rejectReport(
        report,
        reason: notesController.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan ditolak'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isProcessing.value = false;
    }
  }
}

