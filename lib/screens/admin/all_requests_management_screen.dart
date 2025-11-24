// lib/screens/admin/all_requests_management_screen.dart
// Management screen untuk semua requests dengan assign/reassign cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';
import '../shared/request_detail/request_detail_screen.dart';

class AllRequestsManagementScreen extends ConsumerStatefulWidget {
  const AllRequestsManagementScreen({super.key});

  @override
  ConsumerState<AllRequestsManagementScreen> createState() =>
      _AllRequestsManagementScreenState();
}

class _AllRequestsManagementScreenState
    extends ConsumerState<AllRequestsManagementScreen> {
  // Scaffold key for endDrawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter state
  RequestStatus? _filterStatus;
  bool _showUrgentOnly = false;
  String _searchQuery = '';

  // Date range filter
  DateTime? _startDate;
  DateTime? _endDate;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildMobileAppBar() : null,

      // ==================== END DRAWER (Mobile Only) ====================
      endDrawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== FAB (Mobile Only) ====================
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/create_request'),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      // ==================== BODY ====================
      body: isDesktop ? _buildDesktopLayout(allRequestsAsync) : _buildMobileLayout(allRequestsAsync),

      // ==================== BOTTOM NAV BAR (Mobile Only) ====================
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  // ==================== MOBILE APP BAR ====================
  AppBar _buildMobileAppBar() {
    return AppBar(
      title: const Text(
        'Permintaan Layanan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Notification Icon
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          tooltip: 'Notifikasi',
        ),
        // Menu button untuk buka endDrawer
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
  Widget _buildDesktopLayout(AsyncValue<List<Request>> allRequestsAsync) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'requests_management'),

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
                    _buildSearchBar(),

                    // Filter chips
                    if (_filterStatus != null || _showUrgentOnly || _startDate != null || _endDate != null)
                      _buildFilterChips(),

                    // Summary stats
                    _buildSummaryStats(allRequestsAsync),

                    // Requests list
                    Expanded(
                      child: allRequestsAsync.when(
                        data: (requests) => _buildRequestsList(requests),
                        loading: () => _buildEmptyState(), // Empty state saat loading
                        error: (error, stack) => _buildEmptyState(), // Empty state saat error juga
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
  Widget _buildMobileLayout(AsyncValue<List<Request>> allRequestsAsync) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Filter chips
        if (_filterStatus != null || _showUrgentOnly || _startDate != null || _endDate != null) _buildFilterChips(),

        // Summary stats
        _buildSummaryStats(allRequestsAsync),

        // Requests list
        Expanded(
          child: allRequestsAsync.when(
            data: (requests) => _buildRequestsList(requests),
            loading: () => _buildEmptyState(), // Empty state saat loading
            error: (error, stack) => _buildEmptyState(), // Empty state saat error juga
          ),
        ),
      ],
    );
  }

  // ==================== EMPTY STATE (Default saat loading/kosong) ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon permintaan besar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.room_service_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Belum ada permintaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3674),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Permintaan layanan yang dibuat akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Tombol "+ Buat Permintaan" (Pink)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/create_request');
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Buat Permintaan',
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
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== REQUESTS LIST ====================
  Widget _buildRequestsList(List<Request> requests) {
    // Apply filters
    var filteredRequests = requests;

    // Filter by status
    if (_filterStatus != null) {
      filteredRequests = filteredRequests
          .where((r) => r.status == _filterStatus)
          .toList();
    }

    // Filter by urgent
    if (_showUrgentOnly) {
      filteredRequests = filteredRequests.where((r) => r.isUrgent).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredRequests = filteredRequests.where((r) {
        return r.location.toLowerCase().contains(query) ||
            r.description.toLowerCase().contains(query) ||
            r.requestedByName.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
      filteredRequests = filteredRequests.where((r) {
        return r.createdAt.isAfter(startOfDay) ||
            r.createdAt.isAtSameMomentAs(startOfDay);
      }).toList();
    }
    if (_endDate != null) {
      final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      filteredRequests = filteredRequests.where((r) {
        return r.createdAt.isBefore(endOfDay) ||
            r.createdAt.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    if (filteredRequests.isEmpty) {
      // Jika ada filter/search aktif, tampilkan pesan spesifik
      if (_searchQuery.isNotEmpty || _filterStatus != null || _startDate != null || _endDate != null) {
        return EmptyStateWidget.custom(
          icon: Icons.search_off_outlined,
          title: 'Tidak ada hasil',
          subtitle: _searchQuery.isNotEmpty
              ? 'Tidak ada hasil untuk "$_searchQuery"'
              : 'Tidak ada permintaan yang sesuai filter',
          actionLabel: 'Reset Filter',
          onAction: () => setState(() {
            _searchQuery = '';
            _searchController.clear();
            _filterStatus = null;
            _startDate = null;
            _endDate = null;
          }),
        );
      }
      // Default empty state
      return _buildEmptyState();
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
            onTap: () => _showRequestDetail(request),
          );
        },
      ),
    );
  }

  // ==================== DESKTOP HEADER (Blue Bar) ====================
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
              'Permintaan Layanan',
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
                // Filter functionality is in the filter chips
              },
              tooltip: 'Filter',
            ),
            const SizedBox(width: 8),

            // Stats button
            IconButton(
              icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 22),
              onPressed: () => _showStatsDialog(),
              tooltip: 'Statistik',
            ),
            const SizedBox(width: 8),

            // Create request button
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create_request'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Permintaan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),

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
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.room_service_outlined,
          title: 'Permintaan Layanan',
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

  // ==================== SEARCH BAR (Seperti Kelola Laporan) ====================

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
                  hintText: 'Cari permintaan...',
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
                onTap: () => _showFilterBottomSheet(),
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

  // ==================== FILTER ICON WITH BADGE ====================
  Widget _buildFilterIconWithBadge() {
    int activeCount = 0;
    if (_filterStatus != null) activeCount++;
    if (_showUrgentOnly) activeCount++;
    if (_startDate != null || _endDate != null) activeCount++;

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

  // ==================== FILTER BOTTOM SHEET ====================
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Filter & Sortir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterStatus = null;
                          _showUrgentOnly = false;
                          _startDate = null;
                          _endDate = null;
                        });
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Filter options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status filter
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: _filterStatus == null,
                          onTap: () {
                            setState(() => _filterStatus = null);
                            setModalState(() {});
                          },
                        ),
                        ...RequestStatus.values.map((status) {
                          return _buildFilterChip(
                            label: status.displayName,
                            isSelected: _filterStatus == status,
                            color: status.color,
                            onTap: () {
                              setState(() => _filterStatus = status);
                              setModalState(() {});
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Rentang Tanggal
                    const Text(
                      'Rentang Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                                setModalState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startDate != null
                                          ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                          : 'Dari',
                                      style: TextStyle(
                                        color: _startDate != null ? Colors.black87 : Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (_startDate != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _startDate = null);
                                        setModalState(() {});
                                      },
                                      child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Date
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                                setModalState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                          : 'Sampai',
                                      style: TextStyle(
                                        color: _endDate != null ? Colors.black87 : Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (_endDate != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _endDate = null);
                                        setModalState(() {});
                                      },
                                      child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Apply button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppTheme.primary) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppTheme.primary) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==================== FILTER CHIPS ====================

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterStatus != null)
            Chip(
              avatar: Icon(
                _filterStatus!.icon,
                size: 16,
                color: Colors.white,
              ),
              label: Text(_filterStatus!.displayName),
              backgroundColor: _filterStatus!.color,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () => setState(() => _filterStatus = null),
            ),
          if (_showUrgentOnly)
            Chip(
              avatar: const Icon(Icons.warning, size: 16, color: Colors.white),
              label: const Text('Urgent'),
              backgroundColor: AppTheme.error,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () => setState(() => _showUrgentOnly = false),
            ),
          if (_startDate != null || _endDate != null)
            Chip(
              avatar: const Icon(Icons.date_range, size: 16, color: Colors.white),
              label: Text(_getDateRangeLabel()),
              backgroundColor: AppTheme.info,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.white),
              onDeleted: () => setState(() {
                _startDate = null;
                _endDate = null;
              }),
            ),
        ],
      ),
    );
  }

  String _getDateRangeLabel() {
    final dateFormat = DateFormat('dd/MM/yy');
    if (_startDate != null && _endDate != null) {
      return '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      return 'Dari ${dateFormat.format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Sampai ${dateFormat.format(_endDate!)}';
    }
    return '';
  }

  // ==================== SUMMARY STATS ====================

  Widget _buildSummaryStats(AsyncValue<List<Request>> requestsAsync) {
    return requestsAsync.when(
      data: (requests) {
        final pending = requests.where((r) => r.status == RequestStatus.pending).length;
        final active = requests.where((r) => r.status.isActive).length;
        final completed = requests.where((r) => r.status == RequestStatus.completed).length;

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

  Widget _buildStatItem(String label, int value, Color color) {
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

  // ==================== SHOW REQUEST DETAIL ====================

  void _showRequestDetail(Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: request.id),
      ),
    );
  }

  // ==================== SHOW STATS DIALOG ====================

  void _showStatsDialog() {
    final requestsAsync = ref.read(allRequestsProvider);

    requestsAsync.whenData((requests) {
      final total = requests.length;
      final pending = requests.where((r) => r.status == RequestStatus.pending).length;
      final assigned = requests.where((r) => r.status == RequestStatus.assigned).length;
      final inProgress = requests.where((r) => r.status == RequestStatus.inProgress).length;
      final completed = requests.where((r) => r.status == RequestStatus.completed).length;
      final cancelled = requests.where((r) => r.status == RequestStatus.cancelled).length;
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

  Widget _buildStatRow(String label, int value, Color color) {
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
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/reports_management');
                },
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
                  fontSize: 12,
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
