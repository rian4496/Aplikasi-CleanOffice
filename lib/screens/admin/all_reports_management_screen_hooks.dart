// lib/screens/admin/all_reports_management_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../shared/report_detail/report_detail_screen.dart';

/// All Reports Management Screen - Admin screen with filter, search, and responsive layout
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class AllReportsManagementScreen extends HookConsumerWidget {
  const AllReportsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management
    final filterStatus = useState<ReportStatus?>(null);
    final showUrgentOnly = useState(false);
    final searchQuery = useState('');

    // ✅ HOOKS: Auto-disposed search controller
    final searchController = useTextEditingController();

    // ✅ HOOKS: Listen to search controller changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final departmentId = ref.watch(currentUserDepartmentProvider);
    final allReportsAsync = ref.watch(allReportsProvider(departmentId));
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop
          ? _buildMobileAppBar(filterStatus, showUrgentOnly)
          : null,

      // ==================== DRAWER (Mobile Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== BODY ====================
      body: isDesktop
          ? _buildDesktopLayout(
              context,
              ref,
              allReportsAsync,
              filterStatus,
              showUrgentOnly,
              searchQuery,
              searchController,
            )
          : _buildMobileLayout(
              context,
              ref,
              allReportsAsync,
              filterStatus,
              showUrgentOnly,
              searchQuery,
              searchController,
            ),
    );
  }

  // ==================== STATIC HELPERS: APP BAR ====================

  /// Build mobile app bar with filter menu
  static AppBar _buildMobileAppBar(
    ValueNotifier<ReportStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
  ) {
    return AppBar(
      title: const Text(
        'Kelola Laporan',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Filter button
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          tooltip: 'Filter',
          onSelected: (value) {
            if (value == 'urgent') {
              showUrgentOnly.value = !showUrgentOnly.value;
            } else if (value == 'all') {
              filterStatus.value = null;
            } else {
              filterStatus.value = ReportStatus.values.firstWhere(
                (s) => s.toFirestore() == value,
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'all',
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 20,
                    color: filterStatus.value == null
                        ? AppTheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Semua Status'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            ...ReportStatus.values.map((status) {
              return PopupMenuItem(
                value: status.toFirestore(),
                child: Row(
                  children: [
                    Icon(
                      status.icon,
                      size: 20,
                      color: filterStatus.value == status
                          ? AppTheme.primary
                          : status.color,
                    ),
                    const SizedBox(width: 12),
                    Text(status.displayName),
                  ],
                ),
              );
            }),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'urgent',
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 20,
                    color: showUrgentOnly.value ? AppTheme.error : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Urgent Saja'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== STATIC HELPERS: LAYOUTS ====================

  /// Build desktop layout with sidebar
  static Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Report>> allReportsAsync,
    ValueNotifier<ReportStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
    ValueNotifier<String> searchQuery,
    TextEditingController searchController,
  ) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'reports_management'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background)
              _buildDesktopHeader(),

              // Scrollable Content
              Expanded(
                child: Column(
                  children: [
                    // Search bar
                    _buildSearchBar(searchController, searchQuery, context, ref),

                    // Filter chips
                    if (filterStatus.value != null || showUrgentOnly.value)
                      _buildFilterChips(filterStatus, showUrgentOnly),

                    // Reports list
                    Expanded(
                      child: _buildReportsList(
                        context,
                        ref,
                        allReportsAsync,
                        filterStatus.value,
                        showUrgentOnly.value,
                        searchQuery.value,
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

  /// Build mobile layout without sidebar
  static Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Report>> allReportsAsync,
    ValueNotifier<ReportStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
    ValueNotifier<String> searchQuery,
    TextEditingController searchController,
  ) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(searchController, searchQuery, context, ref),

        // Filter chips
        if (filterStatus.value != null || showUrgentOnly.value)
          _buildFilterChips(filterStatus, showUrgentOnly),

        // Reports list
        Expanded(
          child: _buildReportsList(
            context,
            ref,
            allReportsAsync,
            filterStatus.value,
            showUrgentOnly.value,
            searchQuery.value,
          ),
        ),
      ],
    );
  }

  // ==================== STATIC HELPERS: UI COMPONENTS ====================

  /// Build desktop header (Blue bar with title)
  static Widget _buildDesktopHeader() {
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

            // Filter button (placeholder)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
              onPressed: () {},
              tooltip: 'Filter',
            ),
            const SizedBox(width: 8),

            // Notification Icon (placeholder)
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 22),
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

  /// Build mobile drawer menu
  static Widget _buildMobileDrawer(BuildContext context) {
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

  /// Build search bar
  static Widget _buildSearchBar(
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
    BuildContext context,
    WidgetRef ref,
  ) {
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
                controller: searchController,
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
                  searchQuery.value = value;
                },
              ),
            ),
            // Clear button (if searching)
            if (searchQuery.value.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () {
                  searchController.clear();
                  searchQuery.value = '';
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
                onTap: () => _showFilterDialog(context, ref),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildFilterIconWithBadge(ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter icon with badge
  static Widget _buildFilterIconWithBadge(WidgetRef ref) {
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

  /// Show filter dialog (dropdown style)
  static void _showFilterDialog(BuildContext context, WidgetRef ref) {
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
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                startDate != null
                                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                    : 'Dari',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                side: BorderSide(color: Colors.grey[300]!),
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
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                endDate != null
                                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                    : 'Sampai',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                side: BorderSide(color: Colors.grey[300]!),
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
                            backgroundColor: AppTheme.primary,
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

  /// Build filter chips
  static Widget _buildFilterChips(
    ValueNotifier<ReportStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (filterStatus.value != null)
            Chip(
              avatar: Icon(
                filterStatus.value!.icon,
                size: 16,
                color: Colors.white,
              ),
              label: Text(filterStatus.value!.displayName),
              backgroundColor: filterStatus.value!.color,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () => filterStatus.value = null,
            ),
          if (showUrgentOnly.value)
            Chip(
              avatar: const Icon(Icons.warning, size: 16, color: Colors.white),
              label: const Text('Urgent'),
              backgroundColor: AppTheme.error,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () => showUrgentOnly.value = false,
            ),
        ],
      ),
    );
  }

  /// Build reports list with filtering
  static Widget _buildReportsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Report>> allReportsAsync,
    ReportStatus? filterStatus,
    bool showUrgentOnly,
    String searchQuery,
  ) {
    return allReportsAsync.when(
      data: (reports) {
        // Apply filters
        var filteredReports = reports;

        // Filter by status
        if (filterStatus != null) {
          filteredReports =
              filteredReports.where((r) => r.status == filterStatus).toList();
        }

        // Filter by urgent
        if (showUrgentOnly) {
          filteredReports = filteredReports.where((r) => r.isUrgent).toList();
        }

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          filteredReports = filteredReports.where((r) {
            return r.location.toLowerCase().contains(query) ||
                r.title.toLowerCase().contains(query) ||
                (r.description?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        if (filteredReports.isEmpty) {
          return EmptyStateWidget.custom(
            icon: Icons.inbox_outlined,
            title: 'Tidak ada laporan',
            subtitle: searchQuery.isNotEmpty
                ? 'Tidak ada hasil untuk "$searchQuery"'
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
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              final report = filteredReports[index];
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
                  onTap: () => _showReportDetail(context, report),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(ref, error),
    );
  }

  /// Build error state
  static Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(
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

  /// Show report detail screen
  static void _showReportDetail(BuildContext context, Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }
}
