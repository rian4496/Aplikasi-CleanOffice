// lib/screens/admin/all_requests_management_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../shared/request_detail/request_detail_screen.dart';

/// All Requests Management Screen - Admin screen with filters, search, stats, and responsive layout
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class AllRequestsManagementScreen extends HookConsumerWidget {
  const AllRequestsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management
    final filterStatus = useState<RequestStatus?>(null);
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

    final allRequestsAsync = ref.watch(allRequestsProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop
          ? _buildMobileAppBar(context, ref, filterStatus, showUrgentOnly)
          : null,

      // ==================== DRAWER (Mobile Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== BODY ====================
      body: isDesktop
          ? _buildDesktopLayout(
              context,
              ref,
              allRequestsAsync,
              filterStatus,
              showUrgentOnly,
              searchQuery,
              searchController,
            )
          : _buildMobileLayout(
              context,
              ref,
              allRequestsAsync,
              filterStatus,
              showUrgentOnly,
              searchQuery,
              searchController,
            ),
    );
  }

  // ==================== STATIC HELPERS: APP BAR ====================

  /// Build mobile app bar with filter menu and stats button
  static AppBar _buildMobileAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<RequestStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
  ) {
    return AppBar(
      title: const Text(
        'Kelola Permintaan',
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
              filterStatus.value = RequestStatus.values.firstWhere(
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
            ...RequestStatus.values.map((status) {
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
        // Stats button
        IconButton(
          icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          onPressed: () => _showStatsDialog(context, ref),
          tooltip: 'Statistik',
        ),
      ],
    );
  }

  // ==================== STATIC HELPERS: LAYOUTS ====================

  /// Build desktop layout with sidebar
  static Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Request>> allRequestsAsync,
    ValueNotifier<RequestStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
    ValueNotifier<String> searchQuery,
    TextEditingController searchController,
  ) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'requests_management'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background)
              _buildDesktopHeader(context, ref),

              // Scrollable Content
              Expanded(
                child: Column(
                  children: [
                    // Search bar
                    _buildSearchBar(searchController, searchQuery),

                    // Filter chips
                    if (filterStatus.value != null || showUrgentOnly.value)
                      _buildFilterChips(filterStatus, showUrgentOnly),

                    // Summary stats
                    _buildSummaryStats(allRequestsAsync),

                    // Requests list
                    Expanded(
                      child: _buildRequestsList(
                        context,
                        ref,
                        allRequestsAsync,
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
    AsyncValue<List<Request>> allRequestsAsync,
    ValueNotifier<RequestStatus?> filterStatus,
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

        // Summary stats
        _buildSummaryStats(allRequestsAsync),

        // Requests list
        Expanded(
          child: _buildRequestsList(
            context,
            ref,
            allRequestsAsync,
            filterStatus.value,
            showUrgentOnly.value,
            searchQuery.value,
          ),
        ),
      ],
    );
  }

  // ==================== STATIC HELPERS: UI COMPONENTS ====================

  /// Build desktop header (Blue bar with title and stats button)
  static Widget _buildDesktopHeader(BuildContext context, WidgetRef ref) {
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
              'Kelola Permintaan',
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

            // Stats button
            IconButton(
              icon: const Icon(Icons.analytics_outlined,
                  color: Colors.white, size: 22),
              onPressed: () => _showStatsDialog(context, ref),
              tooltip: 'Statistik',
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
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.room_service_outlined,
          title: 'Kelola Permintaan',
          onTap: () => Navigator.pop(context),
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
          hintText: 'Cari lokasi, requester, atau deskripsi...',
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
    ValueNotifier<RequestStatus?> filterStatus,
    ValueNotifier<bool> showUrgentOnly,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
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

  /// Build summary stats widget
  static Widget _buildSummaryStats(AsyncValue<List<Request>> requestsAsync) {
    return requestsAsync.when(
      data: (requests) {
        final pending =
            requests.where((r) => r.status == RequestStatus.pending).length;
        final active = requests.where((r) => r.status.isActive).length;
        final completed =
            requests.where((r) => r.status == RequestStatus.completed).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem('Pending', pending, AppTheme.warning),
              _buildStatItem('Aktif', active, AppTheme.info),
              _buildStatItem('Selesai', completed, AppTheme.success),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  /// Build stat item for summary
  static Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build requests list with filtering
  static Widget _buildRequestsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Request>> allRequestsAsync,
    RequestStatus? filterStatus,
    bool showUrgentOnly,
    String searchQuery,
  ) {
    return allRequestsAsync.when(
      data: (requests) {
        // Apply filters
        var filteredRequests = requests;

        // Filter by status
        if (filterStatus != null) {
          filteredRequests =
              filteredRequests.where((r) => r.status == filterStatus).toList();
        }

        // Filter by urgent
        if (showUrgentOnly) {
          filteredRequests = filteredRequests.where((r) => r.isUrgent).toList();
        }

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          filteredRequests = filteredRequests.where((r) {
            return r.location.toLowerCase().contains(query) ||
                r.description.toLowerCase().contains(query) ||
                r.requestedByName.toLowerCase().contains(query);
          }).toList();
        }

        if (filteredRequests.isEmpty) {
          return EmptyStateWidget.custom(
            icon: Icons.inbox_outlined,
            title: 'Tidak ada permintaan',
            subtitle: searchQuery.isNotEmpty
                ? 'Tidak ada hasil untuk "$searchQuery"'
                : 'Belum ada permintaan yang sesuai filter',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allRequestsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return RequestCardWidget(
                request: request,
                animationIndex: index,
                compact: false,
                showAssignee: true,
                onTap: () => _showRequestDetail(context, request),
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
            onPressed: () => ref.invalidate(allRequestsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  /// Show request detail screen
  static void _showRequestDetail(BuildContext context, Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: request.id),
      ),
    );
  }

  /// Show stats dialog
  static void _showStatsDialog(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.read(allRequestsProvider);

    requestsAsync.whenData((requests) {
      final total = requests.length;
      final pending =
          requests.where((r) => r.status == RequestStatus.pending).length;
      final assigned =
          requests.where((r) => r.status == RequestStatus.assigned).length;
      final inProgress =
          requests.where((r) => r.status == RequestStatus.inProgress).length;
      final completed =
          requests.where((r) => r.status == RequestStatus.completed).length;
      final cancelled =
          requests.where((r) => r.status == RequestStatus.cancelled).length;
      final urgent = requests.where((r) => r.isUrgent).length;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Statistik Permintaan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Permintaan', total, Colors.grey[700]!),
              const Divider(),
              _buildStatRow('Pending', pending, AppTheme.warning),
              _buildStatRow('Ditugaskan', assigned, AppTheme.secondary),
              _buildStatRow('Dikerjakan', inProgress, AppTheme.info),
              _buildStatRow('Selesai', completed, AppTheme.success),
              _buildStatRow('Dibatalkan', cancelled, AppTheme.error),
              const Divider(),
              _buildStatRow('Urgent', urgent, AppTheme.error),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    });
  }

  /// Build stat row for dialog
  static Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
