// lib/screens/web_admin/dashboard/activity_log_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../providers/riverpod/admin_dashboard_provider.dart';

class ActivityLogScreen extends HookConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivitiesAsync = ref.watch(allActivitiesProvider);
    final searchController = useTextEditingController();
    final searchTerm = useState('');

    return AdminLayoutWrapper(
      title: 'Riwayat Aktivitas',
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider.withOpacity(0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Search
              Row(
                children: [
                   IconButton(
                    onPressed: () => context.go('/admin/dashboard'),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
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
                        return _buildActivityTile(context, activity);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, Map<String, dynamic> activity) {
    Color dotColor = Colors.grey;
    if (activity['type'] == 'maintenance') dotColor = Colors.orange;
    if (activity['type'] == 'procurement') dotColor = Colors.blue;
    if (activity['status'] == 'completed' || activity['status'] == 'approved') dotColor = Colors.green;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: dotColor.withOpacity(0.1),
        child: Icon(
          activity['type'] == 'maintenance' ? Icons.build : Icons.shopping_cart,
          color: dotColor,
          size: 20,
        ),
      ),
      title: Text(
        activity['title'] ?? '-',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(activity['subtitle'] ?? '-'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDate(activity['timestamp'] as DateTime?),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          _buildStatusBadge(activity['status']?.toString() ?? '-'),
        ],
      ),
      onTap: () {
        if (activity['type'] == 'maintenance') {
           final id = activity['id'];
           if (id != null) context.go('/admin/helpdesk/detail/$id');
         } else if (activity['type'] == 'procurement') {
           final id = activity['id'];
           if (id != null) context.go('/admin/procurement/detail/$id');
         }
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'pending') color = Colors.orange;
    if (status == 'approved' || status == 'completed') color = Colors.green;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
