// lib/screens/cleaner/my_tasks_screen.dart
// Full screen untuk menampilkan tugas aktif cleaner (Reports + Requests)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/cleaner/cleaner_report_card.dart';
import '../../widgets/shared/request_card_widget.dart';
import './report_detail_cleaner_screen.dart';
import '../shared/request_detail/request_detail_screen.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
  String _filterType = 'all'; // 'all', 'reports', 'requests'

  @override
  Widget build(BuildContext context) {
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final assignedRequestsAsync = ref.watch(cleanerAssignedRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tugas Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                value: 'reports',
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 20),
                    SizedBox(width: 12),
                    Text('Laporan Saja'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'requests',
                child: Row(
                  children: [
                    Icon(Icons.room_service, size: 20),
                    SizedBox(width: 12),
                    Text('Permintaan Saja'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: activeReportsAsync.when(
        data: (reports) {
          return assignedRequestsAsync.when(
            data: (requests) {
              // Check empty state
              if (reports.isEmpty && requests.isEmpty) {
                return EmptyStateWidget.noTasks();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(cleanerActiveReportsProvider);
                  ref.invalidate(cleanerAssignedRequestsProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Filter info banner
                    if (_filterType != 'all')
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _filterType == 'reports'
                                  ? Icons.assignment
                                  : Icons.room_service,
                              size: 16,
                              color: AppTheme.info,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Menampilkan: ${_filterType == 'reports' ? 'Laporan' : 'Permintaan'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _filterType = 'all'),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      ),

                    // Reports section
                    if (reports.isNotEmpty &&
                        (_filterType == 'all' || _filterType == 'reports')) ...[
                      _buildSectionHeader(
                        'Laporan (${reports.length})',
                        Icons.assignment,
                        AppTheme.info,
                      ),
                      const SizedBox(height: 8),
                      ...reports.asMap().entries.map((entry) {
                        return CleanerReportCard(
                          report: entry.value,
                          animationIndex: entry.key,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CleanerReportDetailScreen(
                                  reportId: entry.value.id,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Requests section
                    if (requests.isNotEmpty &&
                        (_filterType == 'all' ||
                            _filterType == 'requests')) ...[
                      _buildSectionHeader(
                        'Permintaan Layanan (${requests.length})',
                        Icons.room_service,
                        AppTheme.success,
                      ),
                      const SizedBox(height: 8),
                      ...requests.asMap().entries.map((entry) {
                        return RequestCardWidget(
                          request: entry.value,
                          animationIndex: entry.key,
                          compact: true,
                          showAssignee: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestDetailScreen(
                                  requestId: entry.value.id,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(cleanerActiveReportsProvider);
              ref.invalidate(cleanerAssignedRequestsProvider);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
