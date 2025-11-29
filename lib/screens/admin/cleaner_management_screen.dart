// lib/screens/admin/cleaner_management_screen.dart
// Management screen untuk kelola petugas kebersihan

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildMobileAppBar() : null,

      // ==================== END DRAWER (Mobile Only) ====================
      endDrawer: !isDesktop ? Drawer(child: _buildEndDrawer(context)) : null,

      // ==================== BODY ====================
      body: isDesktop ? _buildDesktopLayout(cleanersAsync) : _buildMobileLayout(cleanersAsync),

      // ==================== BOTTOM NAV BAR (Mobile Only) ====================
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  // ==================== MOBILE APP BAR ====================
  AppBar _buildMobileAppBar() {
    return AppBar(
      title: const Text(
        'Kelola Petugas',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Hapus tombol drawer kiri
      actions: [
        // Menu button to open endDrawer
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          tooltip: 'Menu',
        ),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(AsyncValue<List<CleanerProfile>> cleanersAsync) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'cleaner_management'),

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
        ),
      ],
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
              'Kelola Petugas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

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
            // Search icon
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.search, color: Colors.grey[400], size: 22),
            ),
            // Search input
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
            // Clear button (if searching)
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () => setState(() => _searchQuery = ''),
              ),
            // Divider
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
            ),
            // Filter icon button
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
                      // Header
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

                      // Apply button
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
    // Apply search filter
    var filtered = cleaners.where((cleaner) {
      if (_searchQuery.isEmpty) return true;
      return cleaner.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Apply sorting
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
            Navigator.pushNamedAndRemoveUntil(context, AppConstants.homeAdminRoute, (route) => false);
          },
        ),
        DrawerMenuItem(
          icon: Icons.analytics_outlined,
          title: 'Analitik',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/analytics');
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
      roleTitle: 'Menu',
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
                            : Icons.work,
                        size: 16,
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

  // ==================== WORKLOAD INDICATOR ====================

  Widget _buildWorkloadIndicator(int taskCount) {
    Color color;
    String label;

    if (taskCount == 0) {
      color = AppTheme.success;
      label = 'Bebas';
    } else if (taskCount <= 2) {
      color = AppTheme.info;
      label = 'Ringan';
    } else if (taskCount <= 4) {
      color = AppTheme.warning;
      label = 'Sedang';
    } else {
      color = AppTheme.error;
      label = 'Penuh';
    }

    return Row(
      children: [
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (taskCount / 6).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            onPressed: () => ref.invalidate(availableCleanersProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ==================== SHOW CLEANER DETAIL ====================

  void _showCleanerDetail(CleanerProfile cleaner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: cleaner.photoUrl != null
                        ? NetworkImage(cleaner.photoUrl!)
                        : null,
                    child: cleaner.photoUrl == null
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleaner.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Petugas Kebersihan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Tugas Aktif',
                      cleaner.activeTaskCount.toString(),
                      Icons.assignment,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      'Status',
                      cleaner.activeTaskCount == 0 ? 'Tersedia' : 'Sibuk',
                      cleaner.activeTaskCount == 0
                          ? Icons.check_circle
                          : Icons.work,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      'ID',
                      cleaner.id,
                      Icons.badge,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Show coming soon message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur detail performa sedang dalam pengembangan'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Lihat Performa Detail'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeAdminRoute,
                  (route) => false,
                ),
              ),
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/reports_management',
                ),
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
    const activeColor = Color(0xFF5D5FEF);
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
