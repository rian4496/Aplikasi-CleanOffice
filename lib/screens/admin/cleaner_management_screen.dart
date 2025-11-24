// lib/screens/admin/cleaner_management_screen.dart
// Management screen untuk kelola petugas kebersihan

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
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
  String _sortBy = 'name'; // 'name', 'tasks', 'performance'

  @override
  Widget build(BuildContext context) {
    final cleanersAsync = ref.watch(availableCleanersProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildMobileAppBar() : null,

      // ==================== DRAWER (Mobile Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

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
      actions: [
        // Sort button
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.white),
          tooltip: 'Urutkan',
          onSelected: (value) {
            setState(() => _sortBy = value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'name',
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha,
                    size: 20,
                    color:
                        _sortBy == 'name' ? AppTheme.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Nama'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'tasks',
              child: Row(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 20,
                    color:
                        _sortBy == 'tasks' ? AppTheme.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Jumlah Tugas'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'performance',
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 20,
                    color: _sortBy == 'performance'
                        ? AppTheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Performa'),
                ],
              ),
            ),
          ],
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
                child: cleanersAsync.when(
                  data: (cleaners) {
                    if (cleaners.isEmpty) {
                      return EmptyStateWidget.custom(
                        icon: Icons.people_outline,
                        title: 'Tidak ada petugas',
                        subtitle: 'Belum ada petugas kebersihan terdaftar',
                      );
                    }

                    // Sort cleaners
                    var sortedCleaners = List<CleanerProfile>.from(cleaners);
                    switch (_sortBy) {
                      case 'name':
                        sortedCleaners.sort((a, b) => a.name.compareTo(b.name));
                        break;
                      case 'tasks':
                        sortedCleaners
                            .sort((a, b) => b.activeTaskCount.compareTo(a.activeTaskCount));
                        break;
                      case 'performance':
                        // Sort by rating (calculated from active tasks)
                        // Fewer active tasks = more efficient
                        sortedCleaners.sort((a, b) {
                          // Calculate simple performance score
                          // Fewer active tasks = better (more efficient)
                          final aScore = a.activeTaskCount;
                          final bScore = b.activeTaskCount;
                          return aScore.compareTo(bScore);
                        });
                        break;
                    }

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
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: sortedCleaners.length,
                              itemBuilder: (context, index) {
                                final cleaner = sortedCleaners[index];
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
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(AsyncValue<List<CleanerProfile>> cleanersAsync) {
    return cleanersAsync.when(
      data: (cleaners) {
        if (cleaners.isEmpty) {
          return EmptyStateWidget.custom(
            icon: Icons.people_outline,
            title: 'Tidak ada petugas',
            subtitle: 'Belum ada petugas kebersihan terdaftar',
          );
        }

        // Sort cleaners
        var sortedCleaners = List<CleanerProfile>.from(cleaners);
        switch (_sortBy) {
          case 'name':
            sortedCleaners.sort((a, b) => a.name.compareTo(b.name));
            break;
          case 'tasks':
            sortedCleaners
                .sort((a, b) => b.activeTaskCount.compareTo(a.activeTaskCount));
            break;
          case 'performance':
            // Sort by rating (calculated from active tasks)
            // Fewer active tasks = more efficient
            sortedCleaners.sort((a, b) {
              // Calculate simple performance score
              // Fewer active tasks = better (more efficient)
              final aScore = a.activeTaskCount;
              final bScore = b.activeTaskCount;
              return aScore.compareTo(bScore);
            });
            break;
        }

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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedCleaners.length,
                  itemBuilder: (context, index) {
                    final cleaner = sortedCleaners[index];
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

            // Sort button
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: Colors.white, size: 22),
              tooltip: 'Urutkan',
              onSelected: (value) {
                setState(() => _sortBy = value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_by_alpha,
                        size: 20,
                        color: _sortBy == 'name' ? AppTheme.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Text('Nama'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'tasks',
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 20,
                        color: _sortBy == 'tasks' ? AppTheme.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Text('Jumlah Tugas'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'performance',
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 20,
                        color: _sortBy == 'performance' ? AppTheme.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Text('Performa'),
                    ],
                  ),
                ),
              ],
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
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports_management');
          },
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
          onTap: () => Navigator.pop(context),
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
                onTap: () => Navigator.pop(context),
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
