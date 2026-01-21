// lib/widgets/shared/notification_panel.dart
// Notification panel/drawer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/notification_model.dart';
import '../../riverpod/notification_providers.dart';
import '../../riverpod/report_providers.dart';
import '../../screens/shared/report_detail/report_detail_screen.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context, ref),
          const Divider(),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildNotificationList(context, ref, notifications);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () async {
            await ref.read(markAllNotificationsAsReadProvider.future);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua notifikasi ditandai dibaca')),
              );
            }
          },
          child: const Text('Tandai Semua Dibaca'),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    // Group by date
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final todayNotifs = notifications.where((n) => n.createdAt.isAfter(todayStart)).toList();
    final yesterdayNotifs = notifications
        .where((n) => n.createdAt.isBefore(todayStart) && n.createdAt.isAfter(yesterdayStart))
        .toList();
    final olderNotifs = notifications.where((n) => n.createdAt.isBefore(yesterdayStart)).toList();

    return ListView(
      children: [
        if (todayNotifs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Hari Ini',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...todayNotifs.map((n) => _buildNotificationCard(context, ref, n)),
        ],
        if (yesterdayNotifs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Kemarin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...yesterdayNotifs.map((n) => _buildNotificationCard(context, ref, n)),
        ],
        if (olderNotifs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Lebih Lama',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...olderNotifs.map((n) => _buildNotificationCard(context, ref, n)),
        ],
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.read ? null : Colors.blue.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.type.color.withValues(alpha: 0.2),
          child: Icon(
            notification.type.icon,
            color: notification.type.color,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: !notification.read
            ? const Icon(Icons.circle, size: 12, color: Colors.blue)
            : null,
        onTap: () async {
          if (!notification.read) {
            await ref.read(markNotificationAsReadProvider(notification.id).future);
          }
          
          if (context.mounted) {
            Navigator.pop(context);
            
            // Navigate based on notification data
            final data = notification.data;
            if (data != null) {
              if (data.containsKey('reportId')) {
                // Navigate to report detail
                final reportId = data['reportId'] as String;
                // Get report first, then navigate
                final report = await ref.read(reportByIdProvider(reportId).future);
                if (report != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailScreen(report: report),
                    ),
                  );
                }
              } else if (data.containsKey('requestId')) {
                // Navigate to request detail
                final requestId = data['requestId'] as String;
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetailScreen(requestId: requestId),
                    ),
                  );
                }
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
    }
  }
}

