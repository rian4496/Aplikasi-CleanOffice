// lib/screens/web_admin/all_reports_management_screen.dart
// Management screen untuk semua reports dengan filter, search, dan actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/web_admin/admin_sidebar.dart';
import '../../widgets/web_admin/advanced_filter_dialog.dart';
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
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_report');
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
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
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
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
          icon: Icons.person_outline,
          title: 'Profil',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/profile');
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
                onTap: _showFilterDialog,
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

  // ==================== FILTER DIALOG (Dropdown Style) ====================
  void _showFilterDialog() {
    final filterState = ref.read(reportFilterProvider);

    // Local state variables
    ReportStatus? selectedStatus = filterState.statusFilter?.isNotEmpty == true
        ? filterState.statusFilter!.first
        : null;
    ReportSortBy selectedSort = filterState.sortBy;
    DateTime? startDate = filterState.startDate;
    DateTime? endDate = filterState.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedStatus = null;
                                selectedSort = ReportSortBy.newest;
                                startDate = null;
                                endDate = null;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 20),

                      // Status dropdown
                      const Text(
                        'Status Laporan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Theme(
                        data: Theme.of(context).copyWith(
                          highlightColor: Colors.grey[200],
                          hoverColor: Colors.grey[100],
                          focusColor: Colors.grey[200],
                          splashColor: Colors.grey[100],
                        ),
                        child: DropdownButtonFormField<ReportStatus?>(
                          initialValue: selectedStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: Colors.white,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.select_all, size: 20, color: Colors.grey),
                                  SizedBox(width: 12),
                                  Text('Semua Status'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.pending,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.pending.icon, size: 20, color: ReportStatus.pending.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.pending.displayName),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.assigned,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.assigned.icon, size: 20, color: ReportStatus.assigned.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.assigned.displayName),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.inProgress,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.inProgress.icon, size: 20, color: ReportStatus.inProgress.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.inProgress.displayName),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.completed,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.completed.icon, size: 20, color: ReportStatus.completed.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.completed.displayName),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.verified,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.verified.icon, size: 20, color: ReportStatus.verified.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.verified.displayName),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportStatus.rejected,
                              child: Row(
                                children: [
                                  Icon(ReportStatus.rejected.icon, size: 20, color: ReportStatus.rejected.color),
                                  const SizedBox(width: 12),
                                  Text(ReportStatus.rejected.displayName),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setModalState(() => selectedStatus = value);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sort dropdown
                      const Text(
                        'Urutkan Berdasarkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Theme(
                        data: Theme.of(context).copyWith(
                          highlightColor: Colors.grey[200],
                          hoverColor: Colors.grey[100],
                          focusColor: Colors.grey[200],
                          splashColor: Colors.grey[100],
                        ),
                        child: DropdownButtonFormField<ReportSortBy>(
                          initialValue: selectedSort,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: ReportSortBy.newest,
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, size: 20, color: Color(0xFF3B82F6)),
                                  SizedBox(width: 12),
                                  Text('Terbaru'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportSortBy.oldest,
                              child: Row(
                                children: [
                                  Icon(Icons.history, size: 20, color: Color(0xFF6B7280)),
                                  SizedBox(width: 12),
                                  Text('Terlama'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportSortBy.urgent,
                              child: Row(
                                children: [
                                  Icon(Icons.priority_high, size: 20, color: Color(0xFFEF4444)),
                                  SizedBox(width: 12),
                                  Text('Urgent'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ReportSortBy.location,
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, size: 20, color: Color(0xFF10B981)),
                                  SizedBox(width: 12),
                                  Text('Lokasi'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedSort = value);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Rentang Tanggal
                      const Text(
                        'Rentang Tanggal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Tanggal Mulai
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setModalState(() => startDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                              label: Text(
                                startDate != null
                                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                    : 'Dari',
                                style: const TextStyle(fontSize: 13, color: Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                side: BorderSide(color: Colors.grey[400]!),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          // Tanggal Akhir
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now(),
                                  firstDate: startDate ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setModalState(() => endDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                              label: Text(
                                endDate != null
                                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                    : 'Sampai',
                                style: const TextStyle(fontSize: 13, color: Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                side: BorderSide(color: Colors.grey[400]!),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Clear date button
                      if (startDate != null || endDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                startDate = null;
                                endDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Hapus Tanggal'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply filters to provider
                              ref.read(reportFilterProvider.notifier).setStatusFilter(
                                selectedStatus != null ? [selectedStatus!] : null,
                              );
                              ref.read(reportFilterProvider.notifier).setSortBy(selectedSort);
                              ref.read(reportFilterProvider.notifier).setDateRange(startDate, endDate);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeAdminRoute,
                  (route) => false,
                ),
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
                  Navigator.pushNamed(context, '/chat');
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
    // Light blue gradient color for active state
    final activeColor = AppTheme.headerGradientStart;
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

