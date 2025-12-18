// lib/screens/employee/employee_home_screen_enhanced.dart
// 🏠 Employee Home Screen - ENHANCED with new design system
// ✅ HookConsumerWidget
// ✅ Pastel stat cards
// ✅ Performance summary (Ringkasan Kinerja)
// ✅ Bottom navigation (persistent across screens)
// ✅ Modern greeting card

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/design/employee_colors.dart';
import '../../core/design/shared_design_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../widgets/shared/cards/stat_card_base.dart';
import '../../widgets/shared/cards/performance_summary_card.dart';
import '../../widgets/shared/cards/action_card.dart';
import '../../widgets/shared/states/empty_state_widget.dart';
import '../../widgets/shared/states/error_state_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';

class EmployeeHomeScreenEnhanced extends HookConsumerWidget {
  const EmployeeHomeScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: EmployeeColors.background,

      // ==================== APP BAR ====================
      appBar: _buildAppBar(context, scaffoldKey),

      // ==================== END DRAWER (Right Side Menu) ====================
      endDrawer: Drawer(
        child: _buildDrawer(context, ref),
      ),

      // ==================== BODY ====================
      body: RefreshIndicator(
        color: EmployeeColors.primary,
        onRefresh: () async {
          ref.invalidate(employeeReportsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: reportsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: EmployeeColors.primary,
            ),
          ),
          error: (error, stack) => ErrorStateWidget.fetchFailed(
            message: error.toString(),
            onRetry: () => ref.invalidate(employeeReportsProvider),
          ),
          data: (reports) {
            return CustomScrollView(
              slivers: [
                // Greeting Card
                SliverToBoxAdapter(
                  child: _buildGreetingCard(context, ref),
                ),

                // Stat Cards (2x2 Grid - Pastel Colors)
                SliverToBoxAdapter(
                  child: _buildStatCardsGrid(summary),
                ),

                // Ringkasan Kinerja (Performance Summary)
                SliverToBoxAdapter(
                  child: _buildPerformanceSummary(summary),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: _buildQuickActions(context),
                ),

                // Recent Activity
                SliverToBoxAdapter(
                  child: _buildRecentActivity(context, reports),
                ),

                // Bottom padding for nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
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
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo-pemprov-kalsel.png',
            height: 32,
          ),
          const SizedBox(width: 8),
          const Text(
            'CleanOffice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: EmployeeColors.appBarGradient,
        ),
      ),
      actions: [
        // Notification Icon with Badge
        IconButton(
          icon: Badge(
            label: const Text('3'),
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
          icon: Icons.history,
          title: 'Riwayat Laporan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/all_reports');
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
      roleTitle: 'Employee',
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
            backgroundColor: EmployeeColors.primaryPastel,
            child: const Icon(
              Icons.person,
              color: EmployeeColors.primary,
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
                    color: EmployeeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                userProfileAsync.when(
                  data: (profile) => Text(
                    profile?.displayName ?? 'Employee',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EmployeeColors.textPrimary,
                    ),
                  ),
                  loading: () => const Text(
                    'Employee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EmployeeColors.textPrimary,
                    ),
                  ),
                  error: (_, __) => const Text(
                    'Employee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EmployeeColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.fullDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: EmployeeColors.textSecondary,
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
  Widget _buildStatCardsGrid(EmployeeReportsSummary summary) {
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
            label: 'Total Reports',
            value: summary.total.toString(),
            icon: Icons.assignment_rounded,
            colorIndex: 0, // Pink
            trend: '↑ 12%',
            trendUp: true,
            onTap: () {}, // Navigate to reports
          ),
          StatCardBase(
            label: 'Pending',
            value: summary.pending.toString(),
            icon: Icons.schedule_rounded,
            colorIndex: 1, // Blue
          ),
          StatCardBase(
            label: 'Verified',
            value: summary.verified.toString(),
            icon: Icons.verified_rounded,
            colorIndex: 2, // Green
          ),
          StatCardBase(
            label: 'Urgent',
            value: summary.urgent.toString(),
            icon: Icons.priority_high_rounded,
            colorIndex: 3, // Yellow
          ),
        ],
      ),
    );
  }

  // ==================== PERFORMANCE SUMMARY ====================
  Widget _buildPerformanceSummary(EmployeeReportsSummary summary) {
    // Calculate completion rate
    final total = summary.total;
    final completed = summary.completed;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      child: PerformanceSummaryCard(
        completionRate: completionRate,
        primaryColor: EmployeeColors.primary,
        badge: completionRate >= 80 ? 'Maluk' : 'Baik',
        badgeColor: completionRate >= 80 
            ? EmployeeColors.performanceExcellent 
            : EmployeeColors.performanceGood,
        metrics: [
          MetricItem(
            label: 'Menunggu',
            value: summary.pending.toString(),
            color: EmployeeColors.warning,
          ),
          MetricItem(
            label: 'Dalam Proses',
            value: summary.inProgress.toString(),
            color: EmployeeColors.info,
          ),
          MetricItem(
            label: 'Selesai',
            value: summary.completed.toString(),
            color: EmployeeColors.success,
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
              color: EmployeeColors.textPrimary,
            ),
          ),
          const SizedBox(height: SharedDesignConstants.spaceSm),
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  title: 'Create Report',
                  subtitle: 'Quick action →',
                  icon: Icons.description_rounded,
                  iconColor: EmployeeColors.primary,
                  onTap: () => Navigator.pushNamed(context, '/create_report'),
                ),
              ),
              const SizedBox(width: SharedDesignConstants.spaceSm),
              Expanded(
                child: ActionCard(
                  title: 'New Request',
                  subtitle: 'Quick action →',
                  icon: Icons.room_service_rounded,
                  iconColor: EmployeeColors.success,
                  onTap: () => Navigator.pushNamed(context, '/create_request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RECENT ACTIVITY ====================
  Widget _buildRecentActivity(BuildContext context, List reports) {
    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
        child: EmptyStateWidget.noReports(
          onCreateReport: () => Navigator.pushNamed(context, '/create_report'),
        ),
      );
    }

    // Show first 3 recent reports
    final recentReports = reports.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: EmployeeColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/all_reports'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: SharedDesignConstants.spaceSm),
          ...recentReports.map((report) => _buildReportCard(report)),
        ],
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    return Container(
      margin: const EdgeInsets.only(bottom: SharedDesignConstants.spaceSm),
      padding: const EdgeInsets.all(SharedDesignConstants.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SharedDesignConstants.borderRadiusMd,
        border: Border.all(color: EmployeeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: EmployeeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.location ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EmployeeColors.textPrimary,
                  ),
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: EmployeeColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.status.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: EmployeeColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            report.description ?? '',
            style: TextStyle(
              fontSize: 13,
              color: EmployeeColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => Navigator.pushNamed(context, '/all_reports'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.room_service_rounded,
                label: 'Layanan',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => Navigator.pushNamed(context, '/service_requests'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                index: 3,
                currentIndex: currentIndex,
                onTap: () {
                  // Show bottom sheet with more options
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
    final activeColor = EmployeeColors.primary;
    final inactiveColor = EmployeeColors.textTertiary;

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
              color: EmployeeColors.textPrimary,
            ),
          ),
          const SizedBox(height: SharedDesignConstants.spaceMd),
          // Menu items
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/analytics');
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
              foregroundColor: EmployeeColors.error,
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
              backgroundColor: EmployeeColors.error,
            ),
          );
        }
      }
    }
  }
}

