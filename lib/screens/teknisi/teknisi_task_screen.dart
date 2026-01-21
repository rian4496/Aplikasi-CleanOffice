// lib/screens/cleaner/cleaner_task_screen.dart
// Screen to display tickets claimed/in-progress by the current cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/ticket.dart';
import '../../riverpod/teknisi_providers.dart';
import '../../riverpod/ticket_providers.dart';

class TeknisiTaskScreen extends ConsumerWidget {
  const TeknisiTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(teknisiTasksProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Tugas Saya', style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada tugas yang diambil',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ambil tiket dari Inbox untuk memulai',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teknisiTasksProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TaskCard(ticket: tickets[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final Ticket ticket;

  const _TaskCard({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrgent = ticket.priority == TicketPriority.urgent;
    final isClaimed = ticket.status == TicketStatus.claimed;
    final isInProgress = ticket.status == TicketStatus.inProgress;
    
    final statusColor = isClaimed ? Colors.orange : Colors.blue;
    final statusLabel = isClaimed ? 'Diambil' : 'Dalam Pengerjaan';

    return InkWell(
      onTap: () => context.push('/teknisi/task/${ticket.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? Colors.red.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          if (ticket.locationName != null)
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  ticket.locationName!,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          const SizedBox(height: 4),

          // Date + Urgent Badge
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'URGENT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isClaimed) ...[
                // Start button: claimed → in_progress
                ElevatedButton.icon(
                  onPressed: () => _updateStatus(context, ref, TicketStatus.inProgress),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                  label: const Text('Mulai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (isInProgress) ...[
                // Navigate to detail to complete with photo proof
                ElevatedButton.icon(
                  onPressed: () => context.push('/teknisi/task/${ticket.id}'),
                  icon: const Icon(Icons.check_circle_outlined, size: 18, color: Colors.white),
                  label: const Text('Selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, TicketStatus newStatus) async {
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.updateTicketStatus(ticket.id, newStatus);
      ref.invalidate(teknisiTasksProvider); // Refresh list
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == TicketStatus.inProgress 
                ? 'Tiket dimulai!' 
                : 'Tiket selesai!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
