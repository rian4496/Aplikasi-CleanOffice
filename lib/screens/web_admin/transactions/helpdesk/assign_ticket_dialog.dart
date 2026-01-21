import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/ticket.dart';
import '../../../../../riverpod/user_providers.dart';
import '../../../../../riverpod/ticket_providers.dart';
import '../../../../../models/user_role.dart';
import '../../../../../core/design/admin_colors.dart';

class AssignTicketDialog extends ConsumerStatefulWidget {
  final Ticket ticket;

  const AssignTicketDialog({super.key, required this.ticket});

  @override
  ConsumerState<AssignTicketDialog> createState() => _AssignTicketDialogState();
}

class _AssignTicketDialogState extends ConsumerState<AssignTicketDialog> {
  String? _selectedUserId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider);

    return AlertDialog(
      title: const Text('Assign Staff'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: usersAsync.when(
          data: (users) {
            // Filter logic
            final targetRole = _getTargetRole(widget.ticket.type);
            final eligibleUsers = users.where((u) => u.role == targetRole).toList();

            if (eligibleUsers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada pegawai dengan role "${targetRole}" ditemukan.',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih ${targetRole} untuk menangani tiket ini:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: eligibleUsers.length,
                    itemBuilder: (context, index) {
                      final user = eligibleUsers[index];
                      final isSelected = _selectedUserId == user.uid;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AdminColors.primary : AdminColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AdminColors.primary, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: AdminColors.primary) : null,
                          selected: isSelected,
                          selectedTileColor: AdminColors.primary.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? AdminColors.primary : Colors.transparent, 
                              width: 1
                            )
                          ),
                          onTap: () {
                            setState(() {
                              _selectedUserId = user.uid;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SizedBox(height: 100, child: Center(child: Text('Error: $err'))),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context), 
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _selectedUserId == null || _isSubmitting 
            ? null 
            : () async {
                setState(() => _isSubmitting = true);
                try {
                  await ref.read(ticketRepositoryProvider).assignTicket(widget.ticket.id, _selectedUserId!);
                  if (mounted) Navigator.pop(context, true); // Return true on success
                } catch (e) {
                  setState(() => _isSubmitting = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal assign: $e')));
                  }
                }
              },
          child: _isSubmitting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text('Assign'),
        ),
      ],
    );
  }

  // Helper to determine target role
  String _getTargetRole(TicketType type) {
    switch (type) {
      case TicketType.kerusakan: return UserRole.teknisi;
      case TicketType.kebersihan: return UserRole.cleaner;
      default: return UserRole.employee; // Default fallback
    }
  }
}
