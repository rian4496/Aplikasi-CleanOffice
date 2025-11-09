// lib/widgets/shared/notification_bell.dart
// Notification bell with badge

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/riverpod/notification_providers.dart';
import 'notification_panel.dart';

class NotificationBell extends ConsumerWidget {
  final Color? iconColor;
  final double? iconSize;

  const NotificationBell({
    super.key,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    return unreadCountAsync.when(
      data: (count) => _buildBell(context, count),
      loading: () => _buildBell(context, 0),
      error: (e, _) => _buildBell(context, 0),
    );
  }

  Widget _buildBell(BuildContext context, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: iconColor ?? Colors.white,
            size: iconSize,
          ),
          tooltip: 'Notifikasi',
          onPressed: () => _showNotificationPanel(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const NotificationPanel(),
    );
  }
}
