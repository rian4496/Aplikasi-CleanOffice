// lib/widgets/cleaner/ticket_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../riverpod/cleaner_providers.dart';

import '../../riverpod/auth_providers.dart';
import '../../widgets/completion_photo_dialog.dart';
import '../../services/storage_service.dart';
import '../../core/config/supabase_config.dart';
import '../../riverpod/supabase_service_providers.dart';

class TicketDetailDialog extends ConsumerStatefulWidget {
  final Report report;

  const TicketDetailDialog({super.key, required this.report});

  @override
  ConsumerState<TicketDetailDialog> createState() => _TicketDetailDialogState();
}

class _TicketDetailDialogState extends ConsumerState<TicketDetailDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            
            // Content Scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    _buildInfoRow(Icons.location_on_outlined, 'Lokasi', widget.report.location),
                    const SizedBox(height: 16),
                    // Date
                    _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal', DateFormatter.fullDateTime(widget.report.date)),
                    const SizedBox(height: 16),
                    // Reported By
                    _buildInfoRow(Icons.person_outline_rounded, 'Pelapor', widget.report.userName),
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      'Deskripsi Masalah',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        widget.report.description ?? 'Tidak ada deskripsi',
                        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
                      ),
                    ),
                    
                    // Image if available
                    if (widget.report.imageUrl != null && widget.report.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Foto Lampiran',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.report.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(
                            height: 100,
                            color: Colors.grey[100],
                            alignment: Alignment.center,
                            child: const Text('Gagal memuat gambar'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Footer Action
            _buildActionFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.report.status == ReportStatus.completed ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.report.status == ReportStatus.completed ? Icons.check_circle_outlined : Icons.assignment_outlined,
              color: widget.report.status == ReportStatus.completed ? const Color(0xFF16A34A) : const Color(0xFF3B82F6),
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Tiket',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  widget.report.status.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                    color: widget.report.status.color
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter() {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isAssignedToMe = widget.report.cleanerId == currentUserId;
    
    // Logic buttons
    String? primaryButtonLabel;
    VoidCallback? primaryAction;
    Color primaryColor = const Color(0xFF3B82F6);
    
    if (widget.report.status == ReportStatus.pending) {
      primaryButtonLabel = 'Ambil Tiket';
      primaryAction = _handleTakeTicket;
    } else if (widget.report.status == ReportStatus.assigned && isAssignedToMe) {
      primaryButtonLabel = 'Mulai Pengerjaan';
      primaryAction = _handleStartWork;
      primaryColor = AppTheme.warning;
    } else if (widget.report.status == ReportStatus.inProgress && isAssignedToMe) {
      primaryButtonLabel = 'Tandai Selesai';
      primaryAction = _handleCompleteWork;
      primaryColor = Colors.purple;
    } else if (widget.report.status == ReportStatus.completed) {
      primaryButtonLabel = 'Sudah Selesai';
      primaryAction = null; // Disabled or just show info
      primaryColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Tutup', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
          ),
          if (primaryButtonLabel != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : (primaryAction ?? () {}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(primaryButtonLabel, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleTakeTicket() async {
    setState(() => _isProcessing = true);
    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.acceptReport(widget.report.id);
      await actions.startReport(widget.report.id);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket diambil & sedang dikerjakan', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleStartWork() async {
    setState(() => _isProcessing = true);
    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.startReport(widget.report.id);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mulai pengerjaan...', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCompleteWork() async {
    // 1. Photo Dialog
    final photoFile = await CompletionPhotoDialog.show(context, title: 'Upload Bukti', description: 'Foto bukti pekerjaan selesai');
    if (photoFile == null) return;

    setState(() => _isProcessing = true);
    try {
      // 2. Upload
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('User info not found');
      
      final storageService = ref.read(storageServiceProvider);
      final imageBytes = await photoFile.readAsBytes();
      final uploadResult = await storageService.uploadImage(
        bytes: imageBytes, 
        bucket: SupabaseConfig.reportImagesBucket, 
        userId: userId
      );
      
      if (!uploadResult.isSuccess || uploadResult.data == null) throw Exception(uploadResult.error ?? 'Upload gagal');

      // 3. Complete
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.completeReportWithProof(widget.report.id, uploadResult.data!);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan selesai!', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
