// lib/screens/employee/employee_home_screen.dart
// ✅ COMPLETE Employee Home Screen dengan Riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ReportStatus? _selectedStatusFilter;
  bool _showUrgentOnly = false;
  String _sortBy = 'newest'; // newest, oldest, urgent, location
  
  // Undo functionality
  Report? _lastDeletedReport; // Simpan report yang dihapus untuk undo

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== FILTERED & SORTED REPORTS ====================

  List<Report> _getFilteredAndSortedReports(List<Report> reports) {
    var filtered = reports;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final query = _searchQuery.toLowerCase();
        return report.location.toLowerCase().contains(query) ||
            report.title.toLowerCase().contains(query) ||
            (report.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((r) => r.status == _selectedStatusFilter).toList();
    }

    // Apply urgent filter
    if (_showUrgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'urgent':
        filtered.sort((a, b) {
          if (a.isUrgent && !b.isUrgent) return -1;
          if (!a.isUrgent && b.isUrgent) return 1;
          return b.date.compareTo(a.date);
        });
        break;
      case 'location':
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return filtered;
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context, userProfileAsync),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeReportsProvider);
          ref.invalidate(currentUserProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header dengan nama user
            SliverToBoxAdapter(
              child: _buildHeader(userProfileAsync),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildStatsCards(summary),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildQuickActions(),
              ),
            ),

            // Search & Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchAndFilter(),
              ),
            ),

            // Active Filters Chips
            if (_selectedStatusFilter != null || _showUrgentOnly)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildActiveFilters(),
                ),
              ),

            // Reports List
            reportsAsync.when(
              data: (reports) {
                final filteredReports = _getFilteredAndSortedReports(reports);
                return _buildReportsList(filteredReports);
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ==================== APP BAR ====================

  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue userProfileAsync) {
    return AppBar(
      title: const Text(AppStrings.employeeHomeTitle),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(AsyncValue userProfileAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: userProfileAsync.when(
        data: (profile) {
          final name = profile?.displayName ?? 'User';
          final greeting = _getGreeting();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 60),
        error: (_, _) => const SizedBox(height: 60),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // ==================== STATS CARDS ====================

  Widget _buildStatsCards(EmployeeReportsSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            title: AppStrings.progressSent,
            count: summary.pending,
            color: AppTheme.warning,
            icon: Icons.schedule,
            onTap: () {
              setState(() {
                _selectedStatusFilter = ReportStatus.pending;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            title: AppStrings.progressInProgress,
            count: summary.inProgress,
            color: AppTheme.info,
            icon: Icons.pending_actions,
            onTap: () {
              setState(() {
                _selectedStatusFilter = ReportStatus.inProgress;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            title: AppStrings.progressCompleted,
            count: summary.completed,
            color: AppTheme.success,
            icon: Icons.check_circle,
            onTap: () {
              setState(() {
                _selectedStatusFilter = ReportStatus.completed;
              });
            },
          ),
        ),
      ],
    );
  }

  // ==================== QUICK ACTIONS ====================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Buat Laporan',
            color: AppTheme.primary,
            onTap: () => Navigator.pushNamed(context, '/create_report'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.priority_high,
            label: AppStrings.quickActionUrgent,
            color: AppTheme.error,
            onTap: () {
              setState(() {
                _showUrgentOnly = !_showUrgentOnly;
              });
            },
            isActive: _showUrgentOnly,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.sort,
            label: 'Urutkan',
            color: AppTheme.secondary,
            onTap: _showSortDialog,
          ),
        ),
      ],
    );
  }

  // ==================== SEARCH & FILTER ====================

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: AppStrings.searchReports,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedStatusFilter != null
                      ? AppTheme.primary
                      : Colors.grey.shade300,
                  width: _selectedStatusFilter != null ? 2 : 1,
                ),
              ),
              child: Icon(
                Icons.filter_list,
                color: _selectedStatusFilter != null
                    ? AppTheme.primary
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== ACTIVE FILTERS ====================

  Widget _buildActiveFilters() {
    return Wrap(
      spacing: 8,
      children: [
        if (_selectedStatusFilter != null)
          Chip(
            label: Text(_selectedStatusFilter!.displayName),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _selectedStatusFilter = null;
              });
            },
            backgroundColor: _selectedStatusFilter!.color.withValues(alpha: 0.1),
            labelStyle: TextStyle(color: _selectedStatusFilter!.color),
          ),
        if (_showUrgentOnly)
          Chip(
            label: const Text('Urgen'),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _showUrgentOnly = false;
              });
            },
            backgroundColor: AppTheme.error.withValues(alpha: 0.1),
            labelStyle: const TextStyle(color: AppTheme.error),
          ),
      ],
    );
  }

  // ==================== REPORTS LIST ====================

  Widget _buildReportsList(List<Report> reports) {
    if (reports.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final report = reports[index];
            return _ReportCard(
              report: report,
              onTap: () => _showReportDetail(report),
              onDelete: () => _deleteReport(report),
            );
          },
          childCount: reports.length,
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.emptySearchTitle
                  : AppStrings.emptyStateTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.emptySearchSubtitle
                  : AppStrings.emptyStateSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/create_report'),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.createFirstReportButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== LOADING STATE ====================

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ==================== ERROR STATE ====================

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.errorGeneric,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(employeeReportsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FAB ====================

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/create_report'),
      icon: const Icon(Icons.add),
      label: const Text('Buat Laporan'),
      backgroundColor: AppTheme.primary,
    );
  }

  // ==================== DIALOGS ====================

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urutkan Berdasarkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SortOption(
              title: AppStrings.sortByNewest,
              icon: Icons.schedule,
              isSelected: _sortBy == 'newest',
              onTap: () {
                setState(() => _sortBy = 'newest');
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByOldest,
              icon: Icons.history,
              isSelected: _sortBy == 'oldest',
              onTap: () {
                setState(() => _sortBy = 'oldest');
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByUrgent,
              icon: Icons.priority_high,
              isSelected: _sortBy == 'urgent',
              onTap: () {
                setState(() => _sortBy = 'urgent');
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: AppStrings.sortByLocation,
              icon: Icons.location_on,
              isSelected: _sortBy == 'location',
              onTap: () {
                setState(() => _sortBy = 'location');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FilterOption(
              title: AppStrings.filterAll,
              icon: Icons.all_inclusive,
              color: AppTheme.primary,
              isSelected: _selectedStatusFilter == null,
              onTap: () {
                setState(() => _selectedStatusFilter = null);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.filterPending,
              icon: ReportStatus.pending.icon,
              color: ReportStatus.pending.color,
              isSelected: _selectedStatusFilter == ReportStatus.pending,
              onTap: () {
                setState(() => _selectedStatusFilter = ReportStatus.pending);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.filterInProgress,
              icon: ReportStatus.inProgress.icon,
              color: ReportStatus.inProgress.color,
              isSelected: _selectedStatusFilter == ReportStatus.inProgress,
              onTap: () {
                setState(() => _selectedStatusFilter = ReportStatus.inProgress);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              title: AppStrings.filterCompleted,
              icon: ReportStatus.completed.icon,
              color: ReportStatus.completed.color,
              isSelected: _selectedStatusFilter == ReportStatus.completed,
              onTap: () {
                setState(() => _selectedStatusFilter = ReportStatus.completed);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetail(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ReportDetailSheet(
          report: report,
          scrollController: scrollController,
          onDelete: () {
            Navigator.pop(context);
            _deleteReport(report);
          },
        ),
      ),
    );
  }

  // ==================== DELETE REPORT ====================

  Future<void> _deleteReport(Report report) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteReport),
        content: const Text(AppStrings.deleteReportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final actions = ref.read(employeeActionsProvider);
      await actions.deleteReport(report.id);

      if (!mounted) return;

      // Save deleted report for undo
      setState(() {
        _lastDeletedReport = report;
      });

      // Show success snackbar with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.reportDeleted),
          duration: const Duration(seconds: 5), // Kasih waktu 5 detik untuk undo
          action: SnackBarAction(
            label: AppStrings.undo,
            onPressed: () {
              // ✅ UNDO: Restore deleted report
              if (_lastDeletedReport != null) {
                _restoreReport(_lastDeletedReport!);
              }
            },
          ),
        ),
      ).closed.then((reason) {
        // Auto-clear setelah SnackBar hilang (jika tidak di-undo)
        if (reason != SnackBarClosedReason.action && mounted) {
          setState(() {
            _lastDeletedReport = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.errorDeleteFailed}: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // ==================== RESTORE DELETED REPORT (UNDO) ====================

  Future<void> _restoreReport(Report report) async {
    try {
      final actions = ref.read(employeeActionsProvider);
      
      // Recreate the report with same data
      await actions.createReport(
        location: report.location,
        description: report.description ?? '',
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Laporan berhasil dipulihkan'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the saved report
      setState(() {
        _lastDeletedReport = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulihkan laporan: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}

// ==================== CUSTOM WIDGETS ====================

class _StatsCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatsCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? color.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Location & Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(report.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: report.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          report.status.icon,
                          size: 16,
                          color: report.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: report.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (report.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  report.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Footer: Urgent badge & Actions
              const SizedBox(height: 12),
              Row(
                children: [
                  if (report.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high, size: 14, color: AppTheme.error),
                          SizedBox(width: 4),
                          Text(
                            'URGEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (report.status == ReportStatus.pending)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                      onPressed: onDelete,
                      tooltip: AppStrings.deleteReport,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppTheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      onTap: onTap,
    );
  }
}

class _ReportDetailSheet extends StatelessWidget {
  final Report report;
  final ScrollController scrollController;
  final VoidCallback onDelete;

  const _ReportDetailSheet({
    required this.report,
    required this.scrollController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: report.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(report.status.icon, size: 20, color: report.status.color),
                  const SizedBox(width: 8),
                  Text(
                    report.status.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: report.status.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location
          Text(
            report.location,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(report.date),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          if (report.isUrgent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.priority_high, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text(
                    'Laporan URGEN - Perlu ditangani segera',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Description
          if (report.description != null) ...[
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Image
          if (report.imageUrl != null) ...[
            const Text(
              'Foto Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Cleaner Info
          if (report.cleanerName != null) ...[
            const Text(
              'Petugas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.info,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    report.cleanerName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Delete button (only for pending status)
          if (report.status == ReportStatus.pending) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text(AppStrings.deleteReport),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}