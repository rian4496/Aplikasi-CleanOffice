// lib/screens/cleaner/available_requests_list_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Full screen untuk menampilkan available requests (pending self-assign)

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/request.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../shared/request_detail/request_detail_screen.dart';

/// Screen to display available requests for cleaners to self-assign
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class AvailableRequestsListScreen extends HookConsumerWidget {
  const AvailableRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management
    final filterType = useState<String>('all'); // 'all', 'urgent', 'normal'

    final availableRequestsAsync = ref.watch(availableRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Permintaan Tersedia'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              filterType.value = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 12),
                    Text('Semua'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'urgent',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Urgent Saja'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'normal',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 12),
                    Text('Normal Saja'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: availableRequestsAsync.when(
        data: (requests) {
          // Apply filter
          List<Request> filteredRequests = requests;
          if (filterType.value == 'urgent') {
            filteredRequests = requests.where((r) => r.isUrgent).toList();
          } else if (filterType.value == 'normal') {
            filteredRequests = requests.where((r) => !r.isUrgent).toList();
          }

          if (filteredRequests.isEmpty) {
            return EmptyStateWidget.noRequests();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(availableRequestsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                // Filter info banner
                if (filterType.value != 'all')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: AppTheme.info.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          filterType.value == 'urgent'
                              ? Icons.warning
                              : Icons.access_time,
                          size: 16,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Menampilkan: ${filterType.value == 'urgent' ? 'Urgent' : 'Normal'} (${filteredRequests.length})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => filterType.value = 'all',
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return RequestCardWidget(
                        request: request,
                        animationIndex: index,
                        compact: true,
                        showAssignee: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestDetailScreen(requestId: request.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(availableRequestsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

