import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../models/ticket.dart';
import '../../riverpod/ticket_providers.dart';
import '../../core/theme/app_theme.dart';

class KasubbagApprovalDashboard extends HookConsumerWidget {
  const KasubbagApprovalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTicketsAsync = ref.watch(kasubbagApprovalQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(kasubbagApprovalQueueProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.deepPurple.withValues(alpha: 0.05),
            child: Row(
              children: [
                _StatCard(
                  title: 'Menunggu Approval',
                  value: pendingTicketsAsync.when(
                    loading: () => '-',
                    error: (_, __) => '!',
                    data: (tickets) => tickets.length.toString(),
                  ),
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Hari Ini',
                  value: pendingTicketsAsync.when(
                    loading: () => '-',
                    error: (_, __) => '!',
                    data: (tickets) {
                      final today = DateTime.now();
                      return tickets.where((t) =>
                        t.createdAt.year == today.year &&
                        t.createdAt.month == today.month &&
                        t.createdAt.day == today.day
                      ).length.toString();
                    },
                  ),
                  color: Colors.blue,
                  icon: Icons.today,
                ),
              ],
            ),
          ),

          // Pending List
          Expanded(
            child: pendingTicketsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
                        const SizedBox(height: 16),
                        Text(
                          'Semua request sudah diproses!',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _ApprovalCard(
                      ticket: ticket,
                      onApprove: () => _handleApproval(context, ref, ticket, true),
                      onReject: () => _handleApproval(context, ref, ticket, false),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApproval(BuildContext context, WidgetRef ref, Ticket ticket, bool approved) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approved ? 'Approve Request?' : 'Reject Request?'),
        content: Text('Tiket: ${ticket.ticketNumber}\nJudul: ${ticket.title}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: approved ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(approved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.updateTicketStatus(
        ticket.id,
        approved ? TicketStatus.approved : TicketStatus.rejected,
        approvedBy: userId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket ${ticket.ticketNumber} ${approved ? 'disetujui' : 'ditolak'}!')),
        );
        ref.invalidate(kasubbagApprovalQueueProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({required this.ticket, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('Stock Request', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  ticket.ticketNumber,
                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title + Description
            Text(ticket.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            if (ticket.description != null && ticket.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(ticket.description!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],

            // Quantity if stock request
            if (ticket.requestedQuantity != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Qty: ${ticket.requestedQuantity}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Footer: Date + Actions
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Setujui'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
