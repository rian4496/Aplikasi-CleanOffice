// lib/platforms/mobile/cleaner/my_tasks_screen.dart
// 📋 My Tasks Screen - Shows cleaner's assigned and active tasks
// Displays both pending and in-progress reports for the current cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/report.dart';
import '../../../riverpod/cleaner_providers.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.modernBg,
        appBar: AppBar(
          title: const Text(
            'Tugas Saya',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Ditugaskan'),
              Tab(text: 'Proses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TaskList(status: ReportStatus.assigned),
            _TaskList(status: ReportStatus.inProgress),
            _TaskList(status: ReportStatus.completed),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final ReportStatus status;

  const _TaskList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(cleanerActiveReportsProvider);

    return reportsAsync.when(
      data: (allReports) {
        // Filter by status
        final reports = allReports.where((r) => r.status == status).toList();

        if (reports.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(cleanerActiveReportsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _TaskCard(report: reports[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error: $e', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (status) {
      case ReportStatus.assigned:
        message = 'Tidak ada tugas yang ditugaskan';
        icon = Icons.assignment_outlined;
        break;
      case ReportStatus.inProgress:
        message = 'Tidak ada tugas dalam proses';
        icon = Icons.pending_actions_outlined;
        break;
      case ReportStatus.completed:
        message = 'Belum ada tugas selesai';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Tidak ada tugas';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Report report;

  const _TaskCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/cleaner/report/${report.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: report.status.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(report.status),
                      color: report.status.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.description ?? 'Tidak ada deskripsi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Urgent Badge
                  if (report.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  // Date
                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.relativeTime(report.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: TextStyle(
                        color: report.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.schedule;
      case ReportStatus.assigned:
        return Icons.assignment_ind;
      case ReportStatus.inProgress:
        return Icons.build;
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.verified:
        return Icons.verified;
      default:
        return Icons.info;
    }
  }
}
