import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/riverpod/notification_providers.dart';
import '../../../../models/notification_model.dart';

class NotificationCenterScreen extends HookConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterMode = useState('all'); // all, unread
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat Notifikasi',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau semua aktivitas dan pembaruan sistem di sini',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(markAllNotificationsAsReadProvider.future);
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Tandai Semua Dibaca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    elevation: 0,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // TABS & LIST
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // Filter Tabs
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Semua', 'all', filterMode),
                        const SizedBox(width: 24),
                        _buildTab('Belum Dibaca', 'unread', filterMode),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Content Area
                  Expanded(
                    child: notificationsAsync.when(
                      data: (notifications) {
                        // Filter Logic
                        final filteredList = filterMode.value == 'unread'
                            ? notifications.where((n) => !n.read).toList()
                            : notifications;

                        if (filteredList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  filterMode.value == 'unread' ? 'Tidak ada notifikasi baru' : 'Belum ada notifikasi',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () {
                            return ref.refresh(userNotificationsProvider.future);
                          },
                          child: ListView.separated(
                            itemCount: filteredList.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) {
                              final notification = filteredList[idx];
                              return _NotificationItem(notification: notification);
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Gagal memuat: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, ValueNotifier<String> currentMode) {
    final isSelected = currentMode.value == value;
    return InkWell(
      onTap: () => currentMode.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isSelected ? const Border(bottom: BorderSide(color: AppTheme.primary, width: 2)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : Colors.grey[500],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: notification.read ? 0 : 2,
      color: notification.read ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Mark as Read
          if (!notification.read) {
            ref.read(markNotificationAsReadProvider(notification.id));
          }
          // Navigate if data present (e.g., procurement_detail)
           if (notification.data != null && notification.data!.containsKey('route')) {
              context.push(notification.data!['route']);
           }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.icon, color: notification.iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread Dot
              if (!notification.read)
                Container(
                  margin: const EdgeInsets.only(left: 12, top: 8),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
