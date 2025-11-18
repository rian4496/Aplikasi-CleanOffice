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
                    _buildSearchBar(searchController, searchQuery),

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
        _buildSearchBar(searchController, searchQuery),

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
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Cari lokasi, judul, atau deskripsi...',
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
        ),
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
