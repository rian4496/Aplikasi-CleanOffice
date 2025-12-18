import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/ticket.dart';
import '../../providers/riverpod/ticket_providers.dart';
import '../../core/theme/app_theme.dart';

class InboxScreen extends HookConsumerWidget {
  final String role; // 'teknisi' or 'cleaner'

  const InboxScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = role == 'teknisi'
        ? ref.watch(teknisiInboxProvider)
        : ref.watch(cleanerInboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'teknisi' ? 'Inbox Kerusakan' : 'Inbox Kebersihan',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: role == 'teknisi' ? Colors.orange : Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (role == 'teknisi') {
                ref.invalidate(teknisiInboxProvider);
              } else {
                ref.invalidate(cleanerInboxProvider);
              }
            },
          ),
        ],
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    role == 'teknisi' ? Icons.build_circle_outlined : Icons.cleaning_services_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tiket',
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[600]),
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
              return _TicketCard(
                ticket: ticket,
                onClaim: () => _claimTicket(context, ref, ticket),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ticket/new'),
        icon: const Icon(Icons.add),
        label: const Text('Lapor Baru'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _claimTicket(BuildContext context, WidgetRef ref, Ticket ticket) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.claimTicket(ticket.id, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket ${ticket.ticketNumber} berhasil diambil!')),
        );
        // Refresh inbox
        if (role == 'teknisi') {
          ref.invalidate(teknisiInboxProvider);
        } else {
          ref.invalidate(cleanerInboxProvider);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onClaim;

  const _TicketCard({required this.ticket, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final bool canClaim = ticket.status == TicketStatus.open;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to detail or expand
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket Number + Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(ticket.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getPriorityColor(ticket.priority).withOpacity(0.3)),
                    ),
                    child: Text(
                      ticket.priority.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(ticket.priority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ticket.ticketNumber,
                    style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  _StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                ticket.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description
              if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ticket.description!,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Date + Claim Button
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  if (canClaim)
                    ElevatedButton.icon(
                      onPressed: onClaim,
                      icon: const Icon(Icons.assignment_turned_in, size: 16),
                      label: const Text('Ambil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sudah Diambil',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low: return Colors.grey;
      case TicketPriority.normal: return Colors.blue;
      case TicketPriority.high: return Colors.orange;
      case TicketPriority.urgent: return Colors.red;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.claimed:
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.completed:
      case TicketStatus.approved:
        color = Colors.green;
        break;
      case TicketStatus.rejected:
      case TicketStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
