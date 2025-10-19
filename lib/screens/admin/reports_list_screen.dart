import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../models/report.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../widgets/admin/report_list_item_widget.dart';
import 'verification_screen.dart';

final _logger = AppLogger('ReportsListScreen');

/// Generic reusable screen untuk menampilkan list laporan dengan berbagai filter
/// Digunakan untuk:
/// - Semua laporan
/// - Laporan yang perlu verifikasi
/// - Laporan berdasarkan status tertentu
/// - Laporan urgent
class ReportsListScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends ConsumerState<ReportsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ReportSortBy _sortBy = ReportSortBy.newest;

  @override
  void initState() {
    super.initState();
    _logger.info('Opening reports list: ${widget.title}');

    // Set initial filter jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filterStatus != null) {
        ref
            .read(reportFilterProvider.notifier)
            .setStatusFilter(widget.filterStatus);
      }
      if (widget.departmentId != null) {
        ref
            .read(reportFilterProvider.notifier)
            .setDepartmentFilter(widget.departmentId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Reset filter saat keluar
    ref.read(reportFilterProvider.notifier).reset();
    super.dispose();
  }

  List<Report> _filterReports(List<Report> reports) {
    var filtered = reports;

    // Filter by status jika ada
    if (widget.filterStatus != null) {
      filtered = filtered
          .where((r) => r.status == widget.filterStatus)
          .toList();
    }

    // Filter needs verification
    if (widget.showOnlyNeedsVerification) {
      filtered = filtered
          .where((r) => r.status == ReportStatus.completed)
          .toList();
    }

    // Filter urgent
    if (widget.showOnlyUrgent) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final query = _searchQuery.toLowerCase();
        return r.location.toLowerCase().contains(query) ||
            r.userName.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false) ||
            (r.cleanerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
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

  @override
  Widget build(BuildContext context) {
    // Watch appropriate provider based on configuration
    final AsyncValue<List<Report>> reportsAsync =
        widget.showOnlyNeedsVerification
        ? ref.watch(needsVerificationReportsProvider)
        : widget.showOnlyUrgent
        ? ref.watch(urgentReportsProvider)
        : ref.watch(allReportsProvider(widget.departmentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple[700],
        actions: [
          // Sort button
          PopupMenuButton<ReportSortBy>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (sortBy) {
              setState(() {
                _sortBy = sortBy;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ReportSortBy.newest,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: _sortBy == ReportSortBy.newest
                          ? Colors.deepPurple
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Terbaru',
                      style: TextStyle(
                        fontWeight: _sortBy == ReportSortBy.newest
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortBy.oldest,
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: _sortBy == ReportSortBy.oldest
                          ? Colors.deepPurple
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Terlama',
                      style: TextStyle(
                        fontWeight: _sortBy == ReportSortBy.oldest
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortBy.urgent,
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 20,
                      color: _sortBy == ReportSortBy.urgent
                          ? Colors.deepPurple
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Urgen',
                      style: TextStyle(
                        fontWeight: _sortBy == ReportSortBy.urgent
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ReportSortBy.location,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: _sortBy == ReportSortBy.location
                          ? Colors.deepPurple
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lokasi',
                      style: TextStyle(
                        fontWeight: _sortBy == ReportSortBy.location
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
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
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Reports list
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = _filterReports(reports);

                if (filteredReports.isEmpty) {
                  return _buildEmptyState();
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
                        onTap: () => _navigateToDetail(report),
                      );
                    },
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Tidak ada laporan';
    IconData icon = Icons.inbox_outlined;

    if (_searchQuery.isNotEmpty) {
      message = 'Tidak ditemukan laporan dengan kata kunci "$_searchQuery"';
      icon = Icons.search_off;
    } else if (widget.showOnlyNeedsVerification) {
      message = 'Semua laporan sudah diverifikasi! 🎉';
      icon = Icons.check_circle_outline;
    } else if (widget.showOnlyUrgent) {
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

  Widget _buildLoadingState() {
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

  Widget _buildErrorState(Object error) {
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

  void _navigateToDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(report: report),
      ),
    );
  }
}
