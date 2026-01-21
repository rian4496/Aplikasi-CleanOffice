// lib/screens/teknisi/teknisi_task_detail_screen.dart
// Task detail screen for Teknisi - shows damage ticket with asset info

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../models/ticket.dart';
import '../../riverpod/ticket_providers.dart' show ticketRepositoryProvider, ticketByIdProvider, teknisiInboxProvider;
import '../../riverpod/teknisi_providers.dart';
import '../../riverpod/auth_providers.dart';

class TeknisiTaskDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TeknisiTaskDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TeknisiTaskDetailScreen> createState() => _TeknisiTaskDetailScreenState();
}

class _TeknisiTaskDetailScreenState extends ConsumerState<TeknisiTaskDetailScreen> {
  static const primaryOrange = Color(0xFFF97316);
  
  File? _resolutionImage;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketByIdProvider(widget.ticketId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: ticketAsync.when(
          data: (t) => Text(
            '#${t?.ticketNumber ?? ''}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            onPressed: () => ref.invalidate(ticketByIdProvider(widget.ticketId)),
          ),
        ],
      ),
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }
          return _buildContent(context, ticket);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Ticket ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          _buildStatusBanner(ticket),
          const SizedBox(height: 16),

          // Title & Priority
          _buildTitleCard(ticket),
          const SizedBox(height: 16),

          // Asset Information
          if (ticket.assetId != null) ...[
            _buildAssetCard(ticket),
            const SizedBox(height: 16),
          ],

          // Description
          _buildDescriptionCard(ticket),
          const SizedBox(height: 16),

          // Attached Image
          if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty) ...[
            _buildImageCard(ticket),
            const SizedBox(height: 16),
          ],

          // Location Info
          if (ticket.locationName != null) ...[
            _buildLocationCard(ticket),
            const SizedBox(height: 16),
          ],

          // Created Info
          _buildCreatedInfoCard(ticket),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, ticket),
          
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Ticket ticket) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    switch (ticket.status) {
      case TicketStatus.open:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.inbox_rounded;
        message = 'Tiket ini menunggu untuk diambil';
        break;
      case TicketStatus.claimed:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.assignment_ind_rounded;
        message = 'Tiket sudah diambil, siap dikerjakan';
        break;
      case TicketStatus.inProgress:
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        icon = Icons.engineering_rounded;
        message = 'Sedang dalam pengerjaan';
        break;
      case TicketStatus.completed:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_rounded;
        message = 'Tiket telah selesai';
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        icon = Icons.info_outline;
        message = ticket.status.displayName;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.status.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(Ticket ticket) {
    final isUrgent = ticket.priority == TicketPriority.urgent || ticket.priority == TicketPriority.high;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.build_circle_rounded, color: primaryOrange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Laporan Kerusakan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryOrange,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_rounded, size: 14, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Urgent',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'ASET TERKAIT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.computer, color: primaryOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.assetName ?? 'Aset',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'ID: ${ticket.assetId}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESKRIPSI',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ticket.description ?? 'Tidak ada deskripsi',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FOTO LAMPIRAN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showFullscreenImage(context, ticket.imageUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ticket.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOKASI',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.locationName!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedInfoCard(Ticket ticket) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dilaporkan oleh', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                    Text(ticket.createdByName ?? 'User', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal Laporan', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                    Text(dateFormat.format(ticket.createdAt), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Ticket ticket) {
    final user = ref.read(currentUserProvider).value;

    // Open ticket - can be claimed
    if (ticket.status == TicketStatus.open) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _claimTicket(ticket),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_isLoading ? 'Memproses...' : 'Ambil Tugas Ini'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    // Claimed - can start work
    if (ticket.status == TicketStatus.claimed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _startWork(ticket),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_isLoading ? 'Memproses...' : 'Mulai Pengerjaan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    // In Progress - can complete with photo
    if (ticket.status == TicketStatus.inProgress) {
      return Column(
        children: [
          // Resolution Image Picker
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUKTI PENYELESAIAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                if (_resolutionImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _resolutionImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _resolutionImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 32, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 8),
                            Text(
                              'Ambil Foto Bukti',
                              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Catatan penyelesaian (opsional)...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _completeTask(ticket),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(_isLoading ? 'Memproses...' : 'Selesaikan Tugas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    // Completed - show resolution
    if (ticket.status == TicketStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tugas ini telah selesai',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      setState(() => _resolutionImage = File(picked.path));
    }
  }

  Future<void> _claimTicket(Ticket ticket) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(ticketRepositoryProvider).claimTicket(ticket.id, user.uid);
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(teknisiInboxProvider);
      ref.invalidate(teknisiTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiket berhasil diambil!'), backgroundColor: Colors.green),
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

  Future<void> _startWork(Ticket ticket) async {
    setState(() => _isLoading = true);
    try {
      // Use updateTicketStatus to change from claimed to in_progress
      await ref.read(ticketRepositoryProvider).updateTicketStatus(ticket.id, TicketStatus.inProgress);
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(teknisiTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengerjaan dimulai!'), backgroundColor: Colors.purple),
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

  Future<void> _completeTask(Ticket ticket) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    try {
      // Read image bytes if image is selected
      Uint8List? imageBytes;
      if (_resolutionImage != null) {
        imageBytes = await _resolutionImage!.readAsBytes();
      } else {
        // Require image for completion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon ambil foto bukti penyelesaian'), backgroundColor: Colors.orange),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      await ref.read(ticketRepositoryProvider).resolveTicket(
        ticketId: ticket.id,
        userId: user.uid,
        note: _notesController.text.isNotEmpty ? _notesController.text : 'Selesai',
        imageBytes: imageBytes,
      );
      ref.invalidate(ticketByIdProvider(widget.ticketId));
      ref.invalidate(teknisiTasksProvider);
      ref.invalidate(teknisiTicketStatsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas selesai!'), backgroundColor: Colors.green),
        );
        context.pop();
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

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
