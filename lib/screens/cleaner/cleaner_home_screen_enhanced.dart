// lib/screens/cleaner/cleaner_home_screen_enhanced.dart
// 🏠 Cleaner Home Screen - ENHANCED with new design system
// ✅ HookConsumerWidget
// ✅ Pastel stat cards
// ✅ Performance summary (Ringkasan Kinerja)
// ✅ Bottom navigation (persistent across screens)
// ✅ Modern greeting card
// ✅ Blue theme (sama seperti Employee & Admin)

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/design/employee_colors.dart'; // Use blue theme
import '../../core/design/shared_design_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/shared/cards/stat_card_base.dart';
import '../../widgets/shared/cards/performance_summary_card.dart';
import '../../widgets/shared/cards/action_card.dart';
import '../../widgets/shared/states/empty_state_widget.dart';
import '../../widgets/shared/states/error_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';

class CleanerHomeScreenEnhanced extends HookConsumerWidget {
  const CleanerHomeScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: CleanerColors.background,

      // ==================== APP BAR ====================
      appBar: _buildAppBar(context, scaffoldKey),

      // ==================== END DRAWER (Right Side Menu) ====================
      endDrawer: Drawer(
        child: _buildDrawer(context, ref),
      ),

      // ==================== BODY ====================
      body: RefreshIndicator(
        color: CleanerColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            // Greeting Card
            SliverToBoxAdapter(
              child: _buildGreetingCard(context, ref),
            ),

            // Stat Cards (2x2 Grid - Pastel Colors)
            SliverToBoxAdapter(
              child: _buildStatCardsGrid(),
            ),

            // Ringkasan Kinerja (Performance Summary)
            SliverToBoxAdapter(
              child: _buildPerformanceSummary(),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),

            // Recent Activity
            SliverToBoxAdapter(
              child: _buildRecentTasks(context),
            ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),

      // ==================== BOTTOM NAVIGATION ====================
      bottomNavigationBar: _buildBottomNavBar(context, 0), // Home is active
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'CleanOffice',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: CleanerColors.appBarGradient,
        ),
      ),
      actions: [
        // Notification Icon with Badge
        IconButton(
          icon: Badge(
            label: const Text('2'),
            child: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          tooltip: 'Notifikasi',
        ),
        // Drawer Menu Icon
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          tooltip: 'Menu',
        ),
      ],
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.home,
          title: 'Beranda',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.task_alt,
          title: 'Tugas Saya',
          onTap: () {
            Navigator.pop(context);
            // Navigate to tasks screen
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
      onLogout: () => _handleLogout(context, ref),
      roleTitle: 'Cleaner',
    );
  }

  // ==================== GREETING CARD ====================
  Widget _buildGreetingCard(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final hour = DateTime.now().hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      margin: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SharedDesignConstants.borderRadiusMd,
        boxShadow: SharedDesignConstants.shadowCard,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: CleanerColors.primaryPastel,
            child: const Icon(
              Icons.person,
              color: CleanerColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: SharedDesignConstants.spaceMd),
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 12,
                    color: CleanerColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                userProfileAsync.when(
                  data: (profile) => Text(
                    profile?.displayName ?? 'Cleaner',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CleanerColors.textPrimary,
                    ),
                  ),
                  loading: () => const Text(
                    'Cleaner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CleanerColors.textPrimary,
                    ),
                  ),
                  error: (_, __) => const Text(
                    'Cleaner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CleanerColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.fullDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: CleanerColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STAT CARDS GRID (2x2 Pastel) ====================
  Widget _buildStatCardsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SharedDesignConstants.spaceMd,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: SharedDesignConstants.spaceMd,
        crossAxisSpacing: SharedDesignConstants.spaceMd,
        childAspectRatio: 1.1,
        children: [
          StatCardBase(
            label: 'Total Tasks',
            value: '24',
            icon: Icons.assignment_turned_in_rounded,
            colorIndex: 0, // Green
            trend: '↑ 8%',
            trendUp: true,
            onTap: () {}, // Navigate to tasks
          ),
          StatCardBase(
            label: 'Active',
            value: '8',
            icon: Icons.play_circle_outline_rounded,
            colorIndex: 1, // Blue
          ),
          StatCardBase(
            label: 'Completed',
            value: '15',
            icon: Icons.check_circle_rounded,
            colorIndex: 2, // Teal
          ),
          StatCardBase(
            label: 'Bonus',
            value: '+150',
            icon: Icons.star_rounded,
            colorIndex: 3, // Yellow
          ),
        ],
      ),
    );
  }

  // ==================== PERFORMANCE SUMMARY ====================
  Widget _buildPerformanceSummary() {
    // Mock data - replace with actual provider
    final completionRate = 85.0;

    return Padding(
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      child: PerformanceSummaryCard(
        completionRate: completionRate,
        primaryColor: CleanerColors.primary,
        badge: completionRate >= 80 ? 'Excellent' : 'Good',
        badgeColor: completionRate >= 80 
            ? CleanerColors.performanceExcellent 
            : CleanerColors.performanceGood,
        metrics: [
          MetricItem(
            label: 'Available',
            value: '5',
            color: CleanerColors.info,
          ),
          MetricItem(
            label: 'In Progress',
            value: '3',
            color: CleanerColors.warning,
          ),
          MetricItem(
            label: 'Done',
            value: '15',
            color: CleanerColors.success,
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SharedDesignConstants.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CleanerColors.textPrimary,
            ),
          ),
          const SizedBox(height: SharedDesignConstants.spaceSm),
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  title: 'View Tasks',
                  subtitle: 'Quick action →',
                  icon: Icons.task_alt,
                  iconColor: CleanerColors.primary,
                  onTap: () {
                    // Navigate to tasks screen
                  },
                ),
              ),
              const SizedBox(width: SharedDesignConstants.spaceSm),
              Expanded(
                child: ActionCard(
                  title: 'Scan QR',
                  subtitle: 'Quick action →',
                  icon: Icons.qr_code_scanner,
                  iconColor: CleanerColors.info,
                  onTap: () {
                    // Open QR scanner
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RECENT TASKS ====================
  Widget _buildRecentTasks(BuildContext context) {
    // Mock data - replace with actual provider
    final hasT asks = true;

    if (!hasTasks) {
      return Padding(
        padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
        child: EmptyStateWidget.noReports(
          onCreateReport: () {},
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CleanerColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all tasks
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: SharedDesignConstants.spaceSm),
          _buildTaskCard('Ruang Meeting A', 'In Progress'),
          _buildTaskCard('Toilet Lt. 2', 'Completed'),
          _buildTaskCard('Lobi Utama', 'Available'),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String location, String status) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = CleanerColors.success;
        break;
      case 'In Progress':
        statusColor = CleanerColors.warning;
        break;
      default:
        statusColor = CleanerColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: SharedDesignConstants.spaceSm),
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SharedDesignConstants.borderRadiusMd,
        border: Border.all(color: CleanerColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 20,
            color: CleanerColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CleanerColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: SharedDesignConstants.shadowBottomNav,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SharedDesignConstants.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.task_alt_rounded,
                label: 'Tasks',
                index: 1,
                currentIndex: currentIndex,
                onTap: () {
                  // Navigate to tasks screen
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
                index: 2,
                currentIndex: currentIndex,
                onTap: () {
                  // Open QR scanner
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.more_horiz_rounded,
                label: 'More',
                index: 3,
                currentIndex: currentIndex,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildMoreBottomSheet(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    VoidCallback? onTap,
  }) {
    final isActive = index == currentIndex;
    final activeColor = CleanerColors.primary;
    final inactiveColor = CleanerColors.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: onTap ?? () {},
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

  // ==================== MORE BOTTOM SHEET ====================
  Widget _buildMoreBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SharedDesignConstants.spaceMd),
          // Title
          const Text(
            'More Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CleanerColors.textPrimary,
            ),
          ),
          const SizedBox(height: SharedDesignConstants.spaceMd),
          // Menu items
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(height: SharedDesignConstants.spaceSm),
        ],
      ),
    );
  }

  // ==================== LOGOUT ====================
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: CleanerColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await ref.read(authActionsProvider.notifier).logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal keluar: $e'),
              backgroundColor: CleanerColors.error,
            ),
          );
        }
      }
    }
  }
}
