// lib/screens/cleaner/available_requests_list_screen.dart
// Full screen untuk menampilkan available requests (pending self-assign)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/request.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../shared/request_detail/request_detail_screen.dart';

class AvailableRequestsListScreen extends ConsumerStatefulWidget {
  const AvailableRequestsListScreen({super.key});

  @override
  ConsumerState<AvailableRequestsListScreen> createState() =>
      _AvailableRequestsListScreenState();
}

class _AvailableRequestsListScreenState
    extends ConsumerState<AvailableRequestsListScreen> {
  String _filterType = 'all'; // 'all', 'urgent', 'normal'

  @override
  Widget build(BuildContext context) {
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
              setState(() => _filterType = value);
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
          if (_filterType == 'urgent') {
            filteredRequests =
                requests.where((r) => r.isUrgent).toList();
          } else if (_filterType == 'normal') {
            filteredRequests =
                requests.where((r) => !r.isUrgent).toList();
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
                if (_filterType != 'all')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: AppTheme.info.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          _filterType == 'urgent'
                              ? Icons.warning
                              : Icons.access_time,
                          size: 16,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Menampilkan: ${_filterType == 'urgent' ? 'Urgent' : 'Normal'} (${filteredRequests.length})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => _filterType = 'all'),
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
