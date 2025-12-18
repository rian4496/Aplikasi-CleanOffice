// lib/screens/web_admin/cleaner_management_screen.dart
// Management screen untuk kelola petugas kebersihan

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Added go_router
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_profile.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../providers/riverpod/notification_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
// import '../../widgets/web_admin/admin_sidebar.dart'; // Removed Sidebar

class CleanerManagementScreen extends ConsumerStatefulWidget {
  const CleanerManagementScreen({super.key});

  @override
  ConsumerState<CleanerManagementScreen> createState() =>
      _CleanerManagementScreenState();
}

class _CleanerManagementScreenState
    extends ConsumerState<CleanerManagementScreen> {
  // Scaffold key for endDrawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _sortBy = 'name'; // 'name', 'tasks', 'performance'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final cleanersAsync = ref.watch(availableCleanersProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // If Desktop, we are inside AdminShellLayout which handles the sidebar and top header.
    // We only provide the content.
    if (isDesktop) {
        return _buildDesktopLayout(cleanersAsync);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: _buildMobileAppBar(),

      // ==================== END DRAWER (Mobile Only) ====================
      endDrawer: Drawer(child: _buildEndDrawer(context)),

      // ==================== BODY ====================
      body: _buildMobileLayout(cleanersAsync),

      // ==================== FLOATING ACTION BUTTON ====================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCleanerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Petugas'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  // ==================== MOBILE APP BAR ====================
  AppBar _buildMobileAppBar() {
    return AppBar(
      title: const Text(
        'Kelola Petugas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, 
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
  Widget _buildDesktopLayout(AsyncValue<List<CleanerProfile>> cleanersAsync) {
    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Page Header (Standardized)
          _buildPageHeader(),

          // Scrollable Content
          Expanded(
              child: Column(
                children: [
                  // Search bar - always visible
                  _buildSearchBar(),

                  // Content area
                  Expanded(
                    child: cleanersAsync.when(
                      data: (cleaners) {
                        if (cleaners.isEmpty) {
                          return EmptyStateWidget.custom(
                            icon: Icons.people_outline,
                            title: 'Tidak ada petugas',
                            subtitle: 'Belum ada petugas kebersihan terdaftar',
                          );
                        }

                        // Filter and sort cleaners
                        final filteredCleaners = _filterAndSortCleaners(cleaners);

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(availableCleanersProvider);
                            await Future.delayed(const Duration(milliseconds: 500));
                          },
                          child: Column(
                            children: [
                              // Summary stats
                              _buildSummaryStats(cleaners),

                              // Cleaners list
                              Expanded(
                                child: filteredCleaners.isEmpty
                                    ? EmptyStateWidget.custom(
                                        icon: Icons.search_off,
                                        title: 'Petugas tidak ditemukan',
                                        subtitle: 'Coba kata kunci pencarian lain',
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: filteredCleaners.length,
                                        itemBuilder: (context, index) {
                                          final cleaner = filteredCleaners[index];
                                          return _buildCleanerCard(cleaner, index);
                                        },
                                      ),
                              ),
                            ],
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
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(AsyncValue<List<CleanerProfile>> cleanersAsync) {
    return Column(
      children: [
        // Search bar - always visible
        _buildSearchBar(),

        // Content area
        Expanded(
          child: cleanersAsync.when(
            data: (cleaners) {
              if (cleaners.isEmpty) {
                return EmptyStateWidget.custom(
                  icon: Icons.people_outline,
                  title: 'Tidak ada petugas',
                  subtitle: 'Belum ada petugas kebersihan terdaftar',
                );
              }

              // Filter and sort cleaners
              final filteredCleaners = _filterAndSortCleaners(cleaners);

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(availableCleanersProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: Column(
                  children: [
                    // Summary stats
                    _buildSummaryStats(cleaners),

                    // Cleaners list
                    Expanded(
                      child: filteredCleaners.isEmpty
                          ? EmptyStateWidget.custom(
                              icon: Icons.search_off,
                              title: 'Petugas tidak ditemukan',
                              subtitle: 'Coba kata kunci pencarian lain',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredCleaners.length,
                              itemBuilder: (context, index) {
                                final cleaner = filteredCleaners[index];
                                return _buildCleanerCard(cleaner, index);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  // ==================== PAGE HEADER (White Bar) ====================
  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Petugas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Manajemen data dan performa petugas kebersihan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showAddCleanerDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Petugas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR WITH FILTER ====================
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
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.search, color: Colors.grey[600], size: 22),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari petugas...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () => setState(() => _searchQuery = ''),
              ),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showFilterDialog,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.tune,
                    color: Colors.grey[600],
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FILTER DIALOG ====================
  void _showFilterDialog() {
    String selectedSort = _sortBy;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter & Urutkan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedSort = 'name';
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 20),

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
                        child: DropdownButtonFormField<String>(
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
                              value: 'name',
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 20, color: Color(0xFF3B82F6)),
                                  SizedBox(width: 12),
                                  Text('Nama A-Z'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'tasks',
                              child: Row(
                                children: [
                                  Icon(Icons.assignment, size: 20, color: Color(0xFFF59E0B)),
                                  SizedBox(width: 12),
                                  Text('Jumlah Tugas'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'performance',
                              child: Row(
                                children: [
                                  Icon(Icons.trending_up, size: 20, color: Color(0xFF10B981)),
                                  SizedBox(width: 12),
                                  Text('Performa'),
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

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _sortBy = selectedSort);
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

  // ==================== FILTER & SEARCH ====================
  List<CleanerProfile> _filterAndSortCleaners(List<CleanerProfile> cleaners) {
    var filtered = cleaners.where((cleaner) {
      if (_searchQuery.isEmpty) return true;
      return cleaner.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'tasks':
        filtered.sort((a, b) => b.activeTaskCount.compareTo(a.activeTaskCount));
        break;
      case 'performance':
        filtered.sort((a, b) => a.activeTaskCount.compareTo(b.activeTaskCount));
        break;
    }

    return filtered;
  }

  // ==================== END DRAWER (More Menu) ====================
  Widget _buildEndDrawer(BuildContext context) {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
             context.go('/admin/dashboard'); // Use GoRouter
          },
        ),
        DrawerMenuItem(
          icon: Icons.person_outline,
          title: 'Profil',
          onTap: () {
            Navigator.pop(context);
             context.go('/profile');
          },
        ),
        DrawerMenuItem(
          icon: Icons.settings_outlined,
          title: 'Pengaturan',
          onTap: () {
            Navigator.pop(context);
             context.go('/settings');
          },
        ),
      ],
      onLogout: () => context.go('/login'),
      roleTitle: 'Administrator',
    );
  }

  // ==================== SUMMARY STATS ====================

  Widget _buildSummaryStats(List<CleanerProfile> cleaners) {
    final totalCleaners = cleaners.length;
    final activeCleaners =
        cleaners.where((c) => c.activeTaskCount > 0).length;
    final availableCleaners =
        cleaners.where((c) => c.activeTaskCount == 0).length;
    final totalTasks =
        cleaners.fold<int>(0, (sum, c) => sum + c.activeTaskCount);

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Total', totalCleaners, Icons.people, AppTheme.primary),
              _buildStatItem(
                  'Aktif', activeCleaners, Icons.work, AppTheme.info),
              _buildStatItem('Tersedia', availableCleaners, Icons.check_circle,
                  AppTheme.success),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment, color: AppTheme.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Tugas Aktif: $totalTasks',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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

  // ==================== CLEANER CARD ====================

  Widget _buildCleanerCard(CleanerProfile cleaner, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showCleanerDetail(cleaner),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: cleaner.photoUrl != null
                      ? NetworkImage(cleaner.photoUrl!)
                      : null,
                  child: cleaner.photoUrl == null
                      ? Icon(Icons.person, size: 32, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleaner.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tugas aktif: ${cleaner.activeTaskCount}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildWorkloadIndicator(cleaner.activeTaskCount),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cleaner.activeTaskCount == 0
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cleaner.activeTaskCount == 0
                            ? Icons.check_circle
                            : Icons.access_time_filled,
                        size: 14,
                        color: cleaner.activeTaskCount == 0
                            ? AppTheme.success
                            : AppTheme.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cleaner.activeTaskCount == 0 ? 'Tersedia' : 'Sibuk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cleaner.activeTaskCount == 0
                              ? AppTheme.success
                              : AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkloadIndicator(int taskCount) {
    double percentage = (taskCount / 5).clamp(0.0, 1.0);
    Color color = percentage < 0.5
        ? AppTheme.success
        : percentage < 0.8
            ? AppTheme.warning
            : AppTheme.error;

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(availableCleanersProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showAddCleanerDialog() {
    // Implement Add Cleaner Dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Tambah Petugas akan segera hadir')),
    );
  }

  void _showCleanerDetail(CleanerProfile cleaner) {
    // Implement Cleaner Detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detail ${cleaner.name}')),
    );
  }
}

