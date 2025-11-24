// lib/screens/admin/all_reports_management_screen.dart
// Management screen untuk semua reports dengan filter, search, dan actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/admin/advanced_filter_dialog.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';
import '../shared/report_detail/report_detail_screen.dart';

class AllReportsManagementScreen extends ConsumerStatefulWidget {
  const AllReportsManagementScreen({super.key});

  @override
  ConsumerState<AllReportsManagementScreen> createState() =>
      _AllReportsManagementScreenState();
}

class _AllReportsManagementScreenState
    extends ConsumerState<AllReportsManagementScreen> {
  // Scaffold key for endDrawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Local search query (synced to provider)
  String _searchQuery = '';

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departmentId = ref.watch(currentUserDepartmentProvider);
    // Use filteredReportsProvider untuk mendapatkan hasil dengan filter & sort
    final filteredReportsAsync = ref.watch(filteredReportsProvider);
    final filterState = ref.watch(reportFilterProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Sync search query ke provider
    if (_searchQuery != (filterState.searchQuery ?? '')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reportFilterProvider.notifier).setSearchQuery(_searchQuery);
      });
    }

    // Sync department filter
    if (departmentId != filterState.departmentFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reportFilterProvider.notifier).setDepartmentFilter(departmentId);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildMobileAppBar() : null,

      // ==================== DRAWER (Mobile Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== END DRAWER (Mobile Only) ====================
      endDrawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== BODY ====================
      body: isDesktop ? _buildDesktopLayout(filteredReportsAsync) : _buildMobileLayout(filteredReportsAsync),

      // ==================== BOTTOM NAV BAR (Mobile Only) ====================
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,

      // ====================FAB (Mobile Only) ====================
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_report');
              },
              backgroundColor: const Color(0xFF5D5FEF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // ==================== MOBILE APP BAR ====================
  AppBar _buildMobileAppBar() {
    return AppBar(
      title: const Text(
        'Kelola Laporan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false, // Hapus tombol back
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Notification Icon
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Navigate to notifications
            Navigator.pushNamed(context, '/notifications');
          },
          tooltip: 'Notifikasi',
        ),
        // Drawer Menu Icon (endDrawer)
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          tooltip: 'Menu',
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B5AFF), Color(0xFF5D5FEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(AsyncValue<List<Report>> filteredReportsAsync) {
    final filterState = ref.watch(reportFilterProvider);

    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'reports_management'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background with Search)
              _buildDesktopHeader(),

              // Scrollable Content
              Expanded(
                child: Column(
                  children: [
                    // Search bar
                    _buildSearchBar(),

                    // Active filter chips (jika ada filter aktif)
                    if (!filterState.isEmpty) _buildActiveFilterChips(filterState),

                    // Reports list
                    Expanded(
                      child: filteredReportsAsync.when(
                        data: (reports) {
                          if (reports.isEmpty) {
                            return EmptyStateWidget.custom(
                              icon: Icons.inbox_outlined,
                              title: 'Tidak ada laporan',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                                  : 'Belum ada laporan yang sesuai filter',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              final departmentId = ref.read(currentUserDepartmentProvider);
                              ref.invalidate(allReportsProvider(departmentId));
                              await Future.delayed(const Duration(milliseconds: 500));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final report = reports[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: report.status.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        report.status.icon,
                                        color: report.status.color,
                                      ),
                                    ),
                                    title: Text(
                                      report.location,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${report.userName} • ${DateFormatter.relativeTime(report.date)}',
                                    ),
                                    trailing: report.isUrgent
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.error,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'URGENT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Icon(Icons.chevron_right, color: Colors.grey[400]),
                                    onTap: () => _showReportDetail(report),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => _buildErrorState(error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(AsyncValue<List<Report>> filteredReportsAsync) {
    final filterState = ref.watch(reportFilterProvider);

    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Active filter chips (jika ada filter aktif)
        if (!filterState.isEmpty) _buildActiveFilterChips(filterState),

        // Reports list
        Expanded(
          child: filteredReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final departmentId = ref.read(currentUserDepartmentProvider);
                  ref.invalidate(allReportsProvider(departmentId));
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: report.status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            report.status.icon,
                            color: report.status.color,
                          ),
                        ),
                        title: Text(
                          report.location,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${report.userName} • ${DateFormatter.relativeTime(report.date)}',
                        ),
                        trailing: report.isUrgent
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Icon(Icons.chevron_right, color: Colors.grey[400]),
                        onTap: () => _showReportDetail(report),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => _buildEmptyState(), // Tampilkan empty state saat loading
            error: (error, stack) => _buildEmptyState(), // Tampilkan empty state saat error juga
          ),
        ),
      ],
    );
  }

  // ==================== ACTIVE FILTER CHIPS ====================
  Widget _buildActiveFilterChips(ReportFilterState filterState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Sort chip
            if (filterState.sortBy != ReportSortBy.newest)
              _buildActiveChip(
                label: _getSortLabel(filterState.sortBy),
                icon: Icons.sort,
                onRemove: () {
                  ref.read(reportFilterProvider.notifier).setSortBy(ReportSortBy.newest);
                },
              ),
            // Status chips
            if (filterState.statusFilter != null && filterState.statusFilter!.isNotEmpty)
              _buildActiveChip(
                label: 'Status: ${filterState.statusFilter!.length}',
                icon: Icons.filter_list,
                onRemove: () {
                  ref.read(reportFilterProvider.notifier).setStatusFilter(null);
                },
              ),
            // Urgent chip
            if (filterState.showUrgentOnly)
              _buildActiveChip(
                label: 'Urgent',
                icon: Icons.priority_high,
                color: AppTheme.error,
                onRemove: () {
                  ref.read(reportFilterProvider.notifier).toggleUrgentFilter();
                },
              ),
            // Date range chip
            if (filterState.startDate != null || filterState.endDate != null)
              _buildActiveChip(
                label: 'Tanggal',
                icon: Icons.calendar_today,
                onRemove: () {
                  ref.read(reportFilterProvider.notifier).setDateRange(null, null);
                },
              ),
            // Clear all
            if (filterState.activeFilterCount > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(reportFilterProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Hapus Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16, color: color ?? AppTheme.primary),
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: (color ?? AppTheme.primary).withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: color ?? AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        deleteIconColor: color ?? AppTheme.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _getSortLabel(ReportSortBy sortBy) {
    switch (sortBy) {
      case ReportSortBy.newest:
        return 'Terbaru';
      case ReportSortBy.oldest:
        return 'Terlama';
      case ReportSortBy.urgent:
        return 'Urgent';
      case ReportSortBy.location:
        return 'Lokasi';
    }
  }

  // ==================== FILTER ICON WITH BADGE ====================
  Widget _buildFilterIconWithBadge() {
    final filterState = ref.watch(reportFilterProvider);
    final activeCount = filterState.activeFilterCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.tune, color: Colors.grey[600], size: 22),
        if (activeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                activeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // ==================== EMPTY STATE (Persis seperti Screenshot 724) ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon dokumen besar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Belum ada laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3674),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Laporan yang Anda buat akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Tombol "+ Buat Laporan" (Pink)
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create report screen
                Navigator.pushNamed(context, '/create_report');
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Buat Laporan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63), // Pink color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DESKTOP HEADER (Blue Bar with Search) ====================
  Widget _buildDesktopHeader() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Title
            const Text(
              'Kelola Laporan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Filter button
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
              onPressed: () {
                // Show filter menu
              },
              tooltip: 'Filter',
            ),
            const SizedBox(width: 8),

            // Notification Icon (placeholder)
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              onPressed: () {},
            ),
            const SizedBox(width: 16),

            // Profile Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MOBILE DRAWER ====================
  Widget _buildMobileDrawer(BuildContext context) {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        DrawerMenuItem(
          icon: Icons.analytics,
          title: 'Analytics',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/analytics');
          },
        ),
        DrawerMenuItem(
          icon: Icons.assignment_outlined,
          title: 'Kelola Laporan',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.room_service_outlined,
          title: 'Kelola Permintaan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/requests_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.people_outline,
          title: 'Kelola Petugas',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/cleaner_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.settings_outlined,
          title: 'Pengaturan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
      onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
      roleTitle: 'Administrator',
    );
  }

  // ==================== SEARCH BAR (Seperti Screenshot) ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Search icon
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.search, color: Colors.grey[400], size: 22),
            ),
            // Search input
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari laporan...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            // Clear button (if searching)
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            // Divider
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
            ),
            // Filter icon button with badge
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const AdvancedFilterDialog(),
                  );
                },
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildFilterIconWithBadge(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ==================== ERROR STATE ====================

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final departmentId = ref.read(currentUserDepartmentProvider);
              ref.invalidate(allReportsProvider(departmentId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ==================== SHOW REPORT DETAIL ====================

  void _showReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => Navigator.pop(context), // Kembali ke Dashboard
              ),
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: true, // Active karena ini screen Laporan
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Chat segera hadir')),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  AdminMoreBottomSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF5D5FEF);
    final inactiveColor = Colors.grey[600]!;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
