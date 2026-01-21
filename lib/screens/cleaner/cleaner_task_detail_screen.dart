// lib/screens/cleaner/cleaner_task_detail_screen.dart
// Detail screen for cleaner to view ticket and confirm completion

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ticket.dart';
import '../../riverpod/ticket_providers.dart';
import '../../riverpod/auth_providers.dart';

class CleanerTaskDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const CleanerTaskDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<CleanerTaskDetailScreen> createState() => _CleanerTaskDetailScreenState();
}

class _CleanerTaskDetailScreenState extends ConsumerState<CleanerTaskDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketByIdProvider(widget.ticketId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Tugas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }
          return _buildContent(ticket);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildContent(Ticket ticket) {
    final isClaimed = ticket.status == TicketStatus.claimed;
    final isInProgress = ticket.status == TicketStatus.inProgress;
    final isCompleted = ticket.status == TicketStatus.completed;
    final isUrgent = ticket.priority == TicketPriority.urgent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          _buildStatusBanner(ticket),
          const SizedBox(height: 16),

          // Main Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    if (isUrgent)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red[700]),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        ticket.title,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ticket Number
                _buildInfoRow(Icons.confirmation_number_outlined, 'No. Tiket', ticket.ticketNumber),
                const SizedBox(height: 8),

                // Location
                if (ticket.locationName != null)
                  _buildInfoRow(Icons.place_outlined, 'Lokasi', ticket.locationName!),
                const SizedBox(height: 8),

                // Created At
                _buildInfoRow(
                  Icons.access_time,
                  'Dibuat',
                  DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
                ),
                const SizedBox(height: 8),

                // Claimed At
                if (ticket.claimedAt != null)
                  _buildInfoRow(
                    Icons.assignment_turned_in_outlined,
                    'Diambil',
                    DateFormat('dd MMM yyyy, HH:mm').format(ticket.claimedAt!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text(
                  ticket.description ?? 'Tidak ada deskripsi',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          if (!isCompleted) ...[
            if (isClaimed)
              _buildActionButton(
                label: 'Mulai Pengerjaan',
                icon: Icons.play_arrow_rounded,
                color: Colors.blue,
                onPressed: () => _updateStatus(TicketStatus.inProgress),
              ),
            if (isInProgress)
              _buildActionButton(
                label: 'Konfirmasi Selesai',
                icon: Icons.check_circle_outlined,
                color: Colors.green,
                onPressed: () => _showPhotoProofDialog(),
              ),
          ],

          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Text(
                    'Tugas ini sudah selesai',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Ticket ticket) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (ticket.status) {
      case TicketStatus.claimed:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'Diambil - Belum Dimulai';
        icon = Icons.assignment_outlined;
        break;
      case TicketStatus.inProgress:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Dalam Pengerjaan';
        icon = Icons.engineering_outlined;
        break;
      case TicketStatus.completed:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Selesai';
        icon = Icons.check_circle_outlined;
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        label = ticket.status.displayName;
        icon = Icons.info_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
        Expanded(
          child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _updateStatus(TicketStatus newStatus) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.updateTicketStatus(widget.ticketId, newStatus);
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(cleanerTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == TicketStatus.inProgress ? 'Pengerjaan dimulai!' : 'Tugas selesai!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhotoProofDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoProofBottomSheet(
        onSubmit: (imageBytes) => _completeWithProof(imageBytes),
      ),
    );
  }

  Future<void> _completeWithProof(Uint8List imageBytes) async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('User tidak terautentikasi');

      final repo = ref.read(ticketRepositoryProvider);
      await repo.resolveTicket(
        ticketId: widget.ticketId,
        userId: userId,
        note: 'Selesai',
        imageBytes: imageBytes,
      );
      
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(cleanerTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas selesai dengan bukti foto!'), backgroundColor: Colors.green),
        );
        context.pop(); // Go back to task list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// Photo Proof Bottom Sheet
class _PhotoProofBottomSheet extends StatefulWidget {
  final Future<void> Function(Uint8List imageBytes) onSubmit;

  const _PhotoProofBottomSheet({required this.onSubmit});

  @override
  State<_PhotoProofBottomSheet> createState() => _PhotoProofBottomSheetState();
}

class _PhotoProofBottomSheetState extends State<_PhotoProofBottomSheet> {
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Konfirmasi Selesai',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload foto sebagai bukti penyelesaian tugas',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Photo picker area
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _imageBytes != null ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Tap untuk ambil foto',
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _imageBytes != null && !_isLoading ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Allow choosing from camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (_imageBytes == null) return;
    setState(() => _isLoading = true);
    try {
      Navigator.pop(context); // Close bottom sheet first
      await widget.onSubmit(_imageBytes!);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}

