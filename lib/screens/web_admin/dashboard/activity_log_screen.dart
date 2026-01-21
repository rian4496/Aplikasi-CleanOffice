// lib/screens/web_admin/dashboard/activity_log_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../riverpod/admin_dashboard_provider.dart';
import '../transactions/helpdesk/ticket_detail_dialog.dart';

class ActivityLogScreen extends HookConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivitiesAsync = ref.watch(allActivitiesProvider);
    final searchController = useTextEditingController();
    final searchTerm = useState('');

    final isMobile = MediaQuery.of(context).size.width < 600;

    return AdminLayoutWrapper(
      title: 'Riwayat Aktivitas',
      child: Container(
        margin: EdgeInsets.all(isMobile ? 12 : 24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Search
              if (isMobile) 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + Title Row for Mobile
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/admin/dashboard');
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Kembali',
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Semua Aktivitas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari aktivitas...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        isDense: true,
                      ),
                      onChanged: (val) => searchTerm.value = val,
                    ),
                  ],
                )
              else 
                Row(
                  children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go('/admin/dashboard');
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Kembali Ke Dashboard',
                      ),
                    const SizedBox(width: 8),
                    const Text(
                      'Semua Aktivitas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari aktivitas...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        onChanged: (val) => searchTerm.value = val,
                      ),
                    ),
                  ],
                ),
                
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: allActivitiesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (activities) {
                    // Filter
                    final filtered = activities.where((a) {
                      final term = searchTerm.value.toLowerCase();
                      final title = (a['title'] ?? '').toString().toLowerCase();
                      final subtitle = (a['subtitle'] ?? '').toString().toLowerCase();
                      return title.contains(term) || subtitle.contains(term);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('Tidak ada aktivitas ditemukan'));
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final activity = filtered[index];
                        return _buildActivityTile(context, activity, isMobile);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, Map<String, dynamic> activity, bool isMobile) {
    Color dotColor = Colors.grey;
    IconData icon = Icons.notifications;
    final type = activity['type'] ?? 'other';
    final status = activity['status'] ?? 'open';

    if (type == 'maintenance') {
      dotColor = Colors.orange;
      icon = Icons.build;
    } else if (type == 'procurement') {
      dotColor = Colors.blue;
      icon = Icons.shopping_cart;
    } else if (type == 'kerusakan') {
      dotColor = Colors.red;
      icon = Icons.build_circle;
    } else if (type == 'kebersihan') {
      dotColor = Colors.green;
      icon = Icons.cleaning_services;
    } else if (type == 'stok') {
      dotColor = Colors.orange;
      icon = Icons.inventory_2;
    }

    // Font Sizes based on Mobile
    final double titleSize = isMobile ? 12.0 : 14.0;
    final double subtitleSize = isMobile ? 11.0 : 13.0;
    final double dateSize = isMobile ? 10.0 : 11.0;

    return InkWell(
      onTap: () {
        final id = activity['id'];
        if (id == null) return;

        if (type == 'maintenance' || ['kerusakan', 'kebersihan', 'stok'].contains(type)) {
           showDialog(
             context: context,
             builder: (_) => TicketDetailDialog(ticketId: id),
           );
        } else if (type == 'procurement') {
           context.go('/admin/procurement/detail/$id');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: dotColor.withValues(alpha: 0.1),
              radius: isMobile ? 16 : 20, // Smaller icon on mobile
              child: Icon(icon, color: dotColor, size: isMobile ? 16 : 20),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          activity['title'] ?? '-',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: titleSize),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(activity['timestamp'] as DateTime?),
                        style: TextStyle(fontSize: dateSize, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity['subtitle'] ?? '-',
                          style: TextStyle(fontSize: subtitleSize, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status.toString(), isMobile),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, [bool isMobile = false]) {
    Color color = Colors.grey;
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'open') color = Colors.orange;
    if (s == 'approved' || s == 'completed' || s == 'selesai') color = Colors.green;
    if (s == 'rejected' || s == 'ditolak') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: isMobile ? 9 : 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    // Shorten format for mobile
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
