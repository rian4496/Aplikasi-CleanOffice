// lib/screens/employee/report_history_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import 'report_detail_employee_screen.dart';

/// Report History Screen - List of all employee reports with filtering
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class ReportHistoryScreen extends HookConsumerWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management for filter
    final selectedStatus = useState<ReportStatus?>(null);

    final summaryState = ref.watch(employeeReportsSummaryProvider);
    final reportsAsync = ref.watch(employeeReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(summaryState),

          // Filter Chips
          _buildFilterChips(selectedStatus),

          const SizedBox(height: 8),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                // Filter by status if selected
                final filteredReports = selectedStatus.value == null
                    ? reports
                    : reports
                        .where((r) => r.status == selectedStatus.value)
                        .toList();

                if (filteredReports.isEmpty) {
                  return _buildEmptyState(selectedStatus.value);
                }

                // Sort by date (newest first)
                final sortedReports = List<Report>.from(filteredReports)
                  ..sort((a, b) => b.date.compareTo(a.date));

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(employeeReportsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: sortedReports.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(context, sortedReports[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(ref, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build summary cards showing report counts
  static Widget _buildSummaryCards(EmployeeReportsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: AppTheme.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total',
              summary.total.toString(),
              Icons.description,
              AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              summary.pending.toString(),
              Icons.schedule,
              AppTheme.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Proses',
              summary.inProgress.toString(),
              Icons.autorenew,
              AppTheme.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Selesai',
              summary.completed.toString(),
              Icons.check_circle,
              AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual summary card
  static Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chips for status filtering
  static Widget _buildFilterChips(ValueNotifier<ReportStatus?> selectedStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', null, selectedStatus),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', ReportStatus.pending, selectedStatus),
            const SizedBox(width: 8),
            _buildFilterChip('Diterima', ReportStatus.assigned, selectedStatus),
            const SizedBox(width: 8),
            _buildFilterChip('Dikerjakan', ReportStatus.inProgress, selectedStatus),
            const SizedBox(width: 8),
            _buildFilterChip('Selesai', ReportStatus.completed, selectedStatus),
            const SizedBox(width: 8),
            _buildFilterChip('Verified', ReportStatus.verified, selectedStatus),
          ],
        ),
      ),
    );
  }

  /// Build individual filter chip
  static Widget _buildFilterChip(
    String label,
    ReportStatus? status,
    ValueNotifier<ReportStatus?> selectedStatus,
  ) {
    final isSelected = selectedStatus.value == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        selectedStatus.value = selected ? status : null;
      },
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Build report card
  static Widget _buildReportCard(BuildContext context, Report report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailEmployeeScreen(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Location + Status Badge
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: report.status.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: TextStyle(
                        color: report.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (report.description != null && report.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    report.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Metadata Row
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  // Date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.format(report.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Urgent badge
                  if (report.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 12,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cleaner name
                  if (report.cleanerName != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.cleanerName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                  // Completion photo indicator
                  if (report.completionImageUrl != null &&
                      report.completionImageUrl!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 12,
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Foto Bukti',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
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

  /// Build empty state
  static Widget _buildEmptyState(ReportStatus? selectedStatus) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            selectedStatus == null
                ? 'Belum ada laporan'
                : 'Tidak ada laporan dengan status ini',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan yang Anda buat akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  static Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(employeeReportsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
