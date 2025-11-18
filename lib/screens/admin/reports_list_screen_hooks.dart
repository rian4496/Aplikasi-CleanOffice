// lib/screens/admin/reports_list_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Generic reusable screen for displaying filtered list of reports

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../models/report.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../widgets/admin/report_list_item_widget.dart';
import 'verification_screen.dart';

/// Generic reusable screen untuk menampilkan list laporan dengan berbagai filter
/// Digunakan untuk:
/// - Semua laporan
/// - Laporan yang perlu verifikasi
/// - Laporan berdasarkan status tertentu
/// - Laporan urgent
///
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class ReportsListScreen extends HookConsumerWidget {
  final String title;
  final ReportStatus? filterStatus;
  final bool showOnlyNeedsVerification;
  final bool showOnlyUrgent;
  final String? departmentId;

  const ReportsListScreen({
    super.key,
    required this.title,
    this.filterStatus,
    this.showOnlyNeedsVerification = false,
    this.showOnlyUrgent = false,
    this.departmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Logger
    final logger = useMemoized(() => AppLogger('ReportsListScreen'));

    // ✅ HOOKS: Auto-disposed controller
    final searchController = useTextEditingController();

    // ✅ HOOKS: State management
    final searchQuery = useState('');
    final sortBy = useState(ReportSortBy.newest);

    // ✅ HOOKS: Initialize filters on mount
    useEffect(() {
      logger.info('Opening reports list: $title');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (filterStatus != null) {
          ref.read(reportFilterProvider.notifier).setStatusFilter(filterStatus);
        }
        if (departmentId != null) {
          ref.read(reportFilterProvider.notifier).setDepartmentFilter(departmentId);
        }
      });

      // Cleanup: reset filter on dispose
      return () {
        ref.read(reportFilterProvider.notifier).reset();
      };
    }, const []);

    // Watch appropriate provider based on configuration
    final AsyncValue<List<Report>> reportsAsync = showOnlyNeedsVerification
        ? ref.watch(needsVerificationReportsProvider)
        : showOnlyUrgent
            ? ref.watch(urgentReportsProvider)
            : ref.watch(allReportsProvider(departmentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple[700],
        actions: [
          // Sort button
          PopupMenuButton<ReportSortBy>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (newSortBy) {
              sortBy.value = newSortBy;
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(
                value: ReportSortBy.newest,
                icon: Icons.access_time,
                label: 'Terbaru',
                currentSort: sortBy.value,
              ),
              _buildSortMenuItem(
                value: ReportSortBy.oldest,
                icon: Icons.history,
                label: 'Terlama',
                currentSort: sortBy.value,
              ),
              _buildSortMenuItem(
                value: ReportSortBy.urgent,
                icon: Icons.priority_high,
                label: 'Urgen',
                currentSort: sortBy.value,
              ),
              _buildSortMenuItem(
                value: ReportSortBy.location,
                icon: Icons.location_on,
                label: 'Lokasi',
                currentSort: sortBy.value,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
              ),
              onChanged: (value) {
                searchQuery.value = value;
              },
            ),
          ),

          // Reports list
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = _filterReports(
                  reports,
                  filterStatus,
                  showOnlyNeedsVerification,
                  showOnlyUrgent,
                  searchQuery.value,
                  sortBy.value,
                );

                if (filteredReports.isEmpty) {
                  return _buildEmptyState(
                    searchQuery.value,
                    showOnlyNeedsVerification,
                    showOnlyUrgent,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allReportsProvider);
                    ref.invalidate(needsVerificationReportsProvider);
                    ref.invalidate(urgentReportsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return ReportListItem(
                        report: report,
                        onTap: () => _navigateToDetail(context, report),
                      );
                    },
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(context, ref, error),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATIC HELPERS ====================

  /// Build sort menu item
  static PopupMenuItem<ReportSortBy> _buildSortMenuItem({
    required ReportSortBy value,
    required IconData icon,
    required String label,
    required ReportSortBy currentSort,
  }) {
    final isSelected = value == currentSort;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.deepPurple : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Filter reports based on criteria
  static List<Report> _filterReports(
    List<Report> reports,
    ReportStatus? filterStatus,
    bool showOnlyNeedsVerification,
    bool showOnlyUrgent,
    String searchQuery,
    ReportSortBy sortBy,
  ) {
    var filtered = reports;

    // Filter by status jika ada
    if (filterStatus != null) {
      filtered = filtered.where((r) => r.status == filterStatus).toList();
    }

    // Filter needs verification
    if (showOnlyNeedsVerification) {
      filtered =
          filtered.where((r) => r.status == ReportStatus.completed).toList();
    }

    // Filter urgent
    if (showOnlyUrgent) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final query = searchQuery.toLowerCase();
        return r.location.toLowerCase().contains(query) ||
            r.userName.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false) ||
            (r.cleanerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case ReportSortBy.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ReportSortBy.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ReportSortBy.urgent:
        filtered.sort((a, b) {
          if (a.isUrgent == b.isUrgent) return b.date.compareTo(a.date);
          return a.isUrgent ? -1 : 1;
        });
        break;
      case ReportSortBy.location:
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
    }

    return filtered;
  }

  /// Build empty state
  static Widget _buildEmptyState(
    String searchQuery,
    bool showOnlyNeedsVerification,
    bool showOnlyUrgent,
  ) {
    String message = 'Tidak ada laporan';
    IconData icon = Icons.inbox_outlined;

    if (searchQuery.isNotEmpty) {
      message = 'Tidak ditemukan laporan dengan kata kunci "$searchQuery"';
      icon = Icons.search_off;
    } else if (showOnlyNeedsVerification) {
      message = 'Semua laporan sudah diverifikasi! 🎉';
      icon = Icons.check_circle_outline;
    } else if (showOnlyUrgent) {
      message = 'Tidak ada laporan urgent';
      icon = Icons.priority_high;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  static Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppConstants.defaultPadding),
          Text('Memuat laporan...', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// Build error state
  static Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(allReportsProvider);
                ref.invalidate(needsVerificationReportsProvider);
                ref.invalidate(urgentReportsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to verification screen
  static void _navigateToDetail(BuildContext context, Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(report: report),
      ),
    );
  }
}
