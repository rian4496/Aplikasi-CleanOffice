// lib/screens/sim_aset/asset_maintenance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket.dart';
import '../../providers/riverpod/ticket_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';

class AssetMaintenanceHistoryScreen extends ConsumerWidget {
  final String assetId;
  final String assetName;

  const AssetMaintenanceHistoryScreen({
    super.key, 
    required this.assetId,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsByAssetProvider(assetId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Maintenance',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary, // Explicit color
              ),
            ),
            Text(
              assetName,
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary, // Explicit color
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0, // Clean look
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat maintenance',
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
              return _HistoryCard(ticket: ticket);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(ticketsByAssetProvider(assetId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Ticket ticket;

  const _HistoryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = Colors.blue;
        break;
      case TicketStatus.claimed:
      case TicketStatus.inProgress:
        statusColor = Colors.orange;
        break;
      case TicketStatus.completed:
      case TicketStatus.approved:
        statusColor = Colors.green;
        break;
      case TicketStatus.rejected:
      case TicketStatus.cancelled:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: statusColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                     ticket.status.displayName,
                     style: TextStyle(
                       color: statusColor,
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                     ),
                   ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(ticket.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Dibuat oleh: ${ticket.createdBy ?? "User"}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
