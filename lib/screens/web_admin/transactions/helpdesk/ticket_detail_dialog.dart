import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../riverpod/ticket_providers.dart';
import '../../../../../riverpod/auth_providers.dart';
import 'helpdesk_components.dart';
import 'assign_ticket_dialog.dart';
import 'resolve_ticket_dialog.dart';

class TicketDetailDialog extends ConsumerWidget {
  final String ticketId;

  const TicketDetailDialog({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketByIdProvider(ticketId));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 900, // Wide dialog for detail panel
        height: 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: ticketAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (ticket) {
            if (ticket == null) {
              return const Center(child: Text('Tiket tidak ditemukan'));
            }

            final usersMapAsync = ref.watch(usersMapProvider);
            final usersMap = usersMapAsync.maybeWhen(
              data: (data) => data,
              orElse: () => <String, String>{},
            );

            return HelpdeskDetailPanel(
              ticket: ticket,
              usersMap: usersMap,
              onClose: () => Navigator.of(context).pop(),
              onDelete: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Hapus Tiket?'),
                    content: const Text('Tindakan ini tidak dapat dibatalkan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(ticketControllerProvider).deleteTicket(ticketId);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              onAssign: () {
                showDialog(
                  context: context,
                  builder: (_) => AssignTicketDialog(ticket: ticket),
                );
              },
              onResolve: () {
                showDialog(
                  context: context,
                  builder: (_) => ResolveTicketDialog(ticket: ticket),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
