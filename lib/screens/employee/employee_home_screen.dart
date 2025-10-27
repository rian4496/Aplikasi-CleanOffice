// lib/screens/employee/employee_home_screen.dart
// ✅ COMPLETE Employee Home Screen dengan Riverpod
// ✅ UPDATED: Dengan endDrawer, no title, no profile icon, white icons
// ✅ UPDATED: Sort & Filter digabung jadi satu dialog di tengah layar
// ✅ REMOVED: Tombol "Urgen" di quick actions
// ✅ ADDED: Item "Minta Layanan" di drawer
// ✅ UPDATED: Jarak antara header dan card stats pakai return Padding
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../providers/riverpod/notification_providers.dart';

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
      endDrawer: _buildEndDrawer(context), // ✅ ADDED: endDrawer
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeReportsProvider);
          ref.invalidate(currentUserProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header dengan nama user
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5), // ✅ Jarak dari sisi kiri/kanan dan atas/bawah
                child: _buildHeader(userProfileAsync),
              ),
            ),
            // Stats Cards - Dibungkus Padding untuk jarak
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30), // ✅ Jarak dari sisi kiri/kanan dan atas/bawah
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
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // ✅ Notification icon dengan badge counter
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
            // Badge untuk unread count
            Consumer(
              builder: (context, ref, child) {
                final unreadCount = ref.watch(unreadNotificationCountProvider);
                if (unreadCount == 0) return const SizedBox();
                return Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        // Hamburger menu icon untuk buka endDrawer
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: 'Menu',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==================== END DRAWER ====================
  Widget _buildEndDrawer(BuildContext context) {
    return Drawer(
      child: DrawerMenuWidget(
        menuItems: [
          DrawerMenuItem(
            icon: Icons.home,
            title: 'Beranda',
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          DrawerMenuItem(
            icon: Icons.cleaning_services,
            title: 'Minta Layanan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/create_request');
            },
          ),
          DrawerMenuItem(
            icon: Icons.description,
            title: 'Riwayat Laporan', // ✅ CHANGED: from "Laporan Saya"
            onTap: () {
              Navigator.pop(context);
              // Already on home screen, just scroll to top or refresh
              ref.invalidate(employeeReportsProvider);
            },
          ),
          DrawerMenuItem(
            icon: Icons.person,
            title: 'Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          DrawerMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        onLogout: () => _handleLogout(context),
      ),
    );
  }

  // ==================== LOGOUT HANDLER ====================
  Future<void> _handleLogout(BuildContext context) async {
    // Close drawer first
    Navigator.pop(context);

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        // Perform logout using Riverpod provider
        await ref.read(authActionsProvider.notifier).logout();
        // Navigate to login screen
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
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
         data: (profile) { // ✅ PERBAIKAN: Gunakan named parameter `data`
          final name = profile?.displayName ?? 'User';
          final greeting = _getGreeting();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
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
    if (hour < 12) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
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
            icon: Icons.add_circle,
            label: 'Buat Laporan',
            color: AppTheme.primary,
            onTap: () => Navigator.pushNamed(context, '/create_report'),
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
            decoration: InputDecoration(
              hintText: AppStrings.searchReports,
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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // ✅ TAMBAHKAN TOMBOL DI SINI
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortAndFilterOptions, // Gabungan sort & filter
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Wrap(
      spacing: 8,
      children: [
        if (_selectedStatusFilter != null)
          Chip(
            label: Text(_selectedStatusFilter!.displayName),
            backgroundColor: _selectedStatusFilter!.color.withValues(alpha: 0.1),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _selectedStatusFilter = null;
              });
            },
          ),
        if (_showUrgentOnly)
          Chip(
            label: const Text('Urgen Saja'),
            backgroundColor: AppTheme.error.withValues(alpha: 0.1),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _showUrgentOnly = false;
              });
            },
          ),
      ],
    );
  }

  // ==================== REPORTS LIST ====================
  Widget _buildReportsList(List<Report> reports) {
    if (reports.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: SingleChildScrollView( // ✅ FIXED: Wrap dengan SingleChildScrollView untuk fix overflow
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? AppStrings.emptySearchTitle
                      : AppStrings.emptyStateTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? AppStrings.emptySearchSubtitle
                      : AppStrings.emptyStateSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
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

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final report = reports[index];
            return _ReportCard(
              report: report,
              onTap: () => _showReportDetail(report),
            );
          },
          childCount: reports.length,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.errorGeneric,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(employeeReportsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                ),
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
      foregroundColor: Colors.white,
    );
  }

  // ==================== DIALOGS & SHEETS ====================

  // Sort & Filter Options sebagai Dialog
  void _showSortAndFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pengaturan Tampilan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Section: Urutkan Berdasarkan
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SortOption(
                title: AppStrings.sortByNewest,
                icon: Icons.access_time,
                isSelected: _sortBy == 'newest',
                onTap: () {
                  setState(() {
                    _sortBy = 'newest';
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _SortOption(
                title: AppStrings.sortByOldest,
                icon: Icons.history,
                isSelected: _sortBy == 'oldest',
                onTap: () {
                  setState(() {
                    _sortBy = 'oldest';
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _SortOption(
                title: AppStrings.sortByUrgent,
                icon: Icons.priority_high,
                isSelected: _sortBy == 'urgent',
                onTap: () {
                  setState(() {
                    _sortBy = 'urgent';
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _SortOption(
                title: AppStrings.sortByLocation,
                icon: Icons.location_on,
                isSelected: _sortBy == 'location',
                onTap: () {
                  setState(() {
                    _sortBy = 'location';
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              const SizedBox(height: 24),

              // Section: Filter Status
              const Text(
                'Filter Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _FilterOption(
                title: AppStrings.filterAll,
                icon: Icons.all_inbox,
                color: AppTheme.textPrimary,
                isSelected: _selectedStatusFilter == null,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter = null;
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _FilterOption(
                title: AppStrings.filterPending,
                icon: Icons.schedule,
                color: AppTheme.warning,
                isSelected: _selectedStatusFilter == ReportStatus.pending,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter = ReportStatus.pending;
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _FilterOption(
                title: AppStrings.filterInProgress,
                icon: Icons.pending_actions,
                color: AppTheme.info,
                isSelected: _selectedStatusFilter == ReportStatus.inProgress,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter = ReportStatus.inProgress;
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
              _FilterOption(
                title: AppStrings.filterCompleted,
                icon: Icons.check_circle,
                color: AppTheme.success,
                isSelected: _selectedStatusFilter == ReportStatus.completed,
                onTap: () {
                  setState(() {
                    _selectedStatusFilter = ReportStatus.completed;
                  });
                  Navigator.pop(context); // Tutup dialog
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ❌ REMOVED: _showSortOptions() dan _showFilterOptions() karena sudah digabung

  void _showReportDetail(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ReportDetailSheet(
          report: report,
          scrollController: scrollController,
          onDelete: () => _deleteReport(report),
        ),
      ),
    );
  }

  Future<void> _deleteReport(Report report) async {
    Navigator.pop(context); // Close detail sheet
    final shouldDelete = await showDialog<bool>(
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

    if (shouldDelete == true && mounted) {
      try {
        // ✅ FIXED: Use employeeActionsProvider instead of .notifier
        await ref.read(employeeActionsProvider).deleteReport(report.id);
        setState(() {
          _lastDeletedReport = report;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppStrings.reportDeleted),
              action: SnackBarAction(
                label: AppStrings.undo,
                onPressed: () => _undoDelete(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.errorDeleteFailed}: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _undoDelete() async {
    if (_lastDeletedReport != null) {
      try {
        // ✅ FIXED: Use proper restore method with soft delete
        await ref.read(employeeActionsProvider).restoreReport(_lastDeletedReport!.id);
        _lastDeletedReport = null;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dikembalikan'),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengembalikan: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}

// ==================== STATS CARD WIDGET ====================
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== QUICK ACTION BUTTON ====================
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REPORT CARD ====================
class _ReportCard extends StatefulWidget {
  final Report report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? Colors.grey.shade300 : Colors.grey.shade200,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppTheme.primary.withValues(alpha: 0.1),
            highlightColor: AppTheme.primary.withValues(alpha: 0.05),
            hoverColor: AppTheme.primary.withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Status Badge & Urgent Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.report.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.report.status.icon,
                              size: 16,
                              color: widget.report.status.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.report.status.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.report.status.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.report.isUrgent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.priority_high, size: 14, color: AppTheme.error),
                              SizedBox(width: 4),
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
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.report.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Description
                  if (widget.report.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.report.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // ✅ ADDED: Divider sebelum footer
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Footer: Date & Cleaner info
                  Row(
                    children: [
                      // ✅ UPDATED: Date dengan format jam (dd MMM yyyy, HH:mm)
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(widget.report.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      // Cleaner info (if assigned)
                      if (widget.report.cleanerName != null) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.report.cleanerName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.info,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SORT OPTION ====================
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
      leading: Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
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