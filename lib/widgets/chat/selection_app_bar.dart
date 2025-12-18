// lib/widgets/chat/selection_app_bar.dart
// AppBar untuk mode selection seperti WhatsApp

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/chat_selection_provider.dart';

/// AppBar untuk mode selection di Chat List
class SelectionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onMarkRead;

  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onDelete,
    required this.onPin,
    required this.onMute,
    required this.onMarkRead,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.grey[800],
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onClose,
      ),
      title: Text(
        '$selectedCount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Pin/Unpin
        IconButton(
          icon: const Icon(Icons.push_pin_outlined, color: Colors.white),
          onPressed: onPin,
          tooltip: 'Pin',
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: onDelete,
          tooltip: 'Hapus',
        ),
        // Mute/Unmute
        IconButton(
          icon: const Icon(Icons.notifications_off_outlined, color: Colors.white),
          onPressed: onMute,
          tooltip: 'Bisukan',
        ),
        // Mark as read/unread
        IconButton(
          icon: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
          onPressed: onMarkRead,
          tooltip: 'Tandai Dibaca',
        ),
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            // Handle additional options
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'select_all',
              child: Text('Pilih Semua'),
            ),
          ],
        ),
      ],
    );
  }
}

