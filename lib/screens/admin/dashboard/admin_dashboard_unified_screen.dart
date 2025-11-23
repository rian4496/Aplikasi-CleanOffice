// lib/screens/admin/dashboard/admin_dashboard_unified_screen.dart
// 🏠 Admin Dashboard - Unified Responsive
// Single screen that works on both mobile and desktop

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/admin/layout/admin_layout_wrapper.dart';
import '../../../widgets/admin/layout/quick_actions_fab.dart';
import '../../../widgets/admin/cards/greeting_card.dart';
import '../../../widgets/admin/cards/pastel_stat_card.dart';
import '../../../widgets/admin/lists/activities_section.dart';
import '../../../providers/riverpod/admin_dashboard_provider.dart';
import '../../../providers/riverpod/auth_providers.dart';

class AdminDashboardUnifiedScreen extends HookConsumerWidget {
  const AdminDashboardUnifiedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(adminDashboardDataProvider);
    final currentNavIndex = useState(0);

    return AdminLayoutWrapper(
      title: 'Dashboard',
      currentNavIndex: currentNavIndex.value,
      onNavigationChanged: (index) {
        currentNavIndex.value = index;
        _handleNavigation(context, index);
      },
      onNotificationTap: () {
        // Navigate to notifications
      },
      onSearch: (query) {
        // Handle search
      },
      floatingActionButton: QuickActionsFAB(
        actions: [
          FABAction(
            icon: Icons.add_task,
            label: 'Buat Laporan',
            onTap: () {},
          ),
          FABAction(
            icon: Icons.calendar_today,
            label: 'Buat Permintaan',
            onTap: () {},
            color: AdminColors.info,
          ),
          FABAction(
            icon: Icons.check_circle,
            label: 'Verifikasi',
            onTap: () {},
            color: AdminColors.success,
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardDataProvider);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= AdminConstants.tabletBreakpoint;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? AdminConstants.spaceLg : AdminConstants.spaceMd,
              ),
              child: userAsync.when(
                data: (user) => _buildDashboardContent(
                  context,
                  user?.name ?? 'Admin',
                  dashboardAsync,
                  isDesktop,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(ref),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    String userName,
    AsyncValue dashboardData,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Card (mobile only, desktop has it in AppBar)
        if (!isDesktop) ...[
          GreetingCard(userName: userName, compact: true),
          const SizedBox(height: AdminConstants.spaceMd),
        ],

        // Stats Grid
        dashboardData.when(
          data: (data) => _buildStatsGrid(data, isDesktop),
          loading: () => _buildStatsGridSkeleton(isDesktop),
          error: (_, __) => _buildStatsGridError(),
        ),

        const SizedBox(height: AdminConstants.spaceLg),

        // Activities Section
        dashboardData.when(
          data: (data) => _buildActivitiesSection(data, isDesktop),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data, bool isDesktop) {
    final stats = [
      {
        'icon': Icons.description,
        'label': 'Laporan Masuk',
        'value': data['totalReports']?.toString() ?? '0',
        'trend': '+12%',
        'trendUp': true,
        'progress': 0.75,
        'bgColor': AdminColors.cardPinkBg,
        'fgColor': AdminColors.cardPinkDark,
      },
      {
        'icon': Icons.pending_actions,
        'label': 'Pending',
        'value': data['pendingReports']?.toString() ?? '0',
        'progress': 0.4,
        'bgColor': AdminColors.cardYellowBg,
        'fgColor': AdminColors.cardYellowDark,
      },
      {
        'icon': Icons.notifications_active,
        'label': 'Permintaan',
        'value': data['totalRequests']?.toString() ?? '0',
        'trend': '+5',
        'trendUp': true,
        'progress': 0.6,
        'bgColor': AdminColors.cardBlueBg,
        'fgColor': AdminColors.cardBlueDark,
      },
      {
        'icon': Icons.people,
        'label': 'Petugas Aktif',
        'value': data['activeCleaners']?.toString() ?? '0',
        'progress': 0.9,
        'bgColor': AdminColors.cardGreenBg,
        'fgColor': AdminColors.cardGreenDark,
      },
    ];

    if (isDesktop) {
      // Desktop: 1x4 horizontal layout
      return Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AdminConstants.gridGap),
              child: PastelStatCard(
                icon: stat['icon'] as IconData,
                label: stat['label'] as String,
                value: stat['value'] as String,
                trend: stat['trend'] as String?,
                trendUp: stat['trendUp'] as bool? ?? false,
                progress: stat['progress'] as double,
                backgroundColor: stat['bgColor'] as Color,
                foregroundColor: stat['fgColor'] as Color,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Mobile: 2x2 grid
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AdminConstants.gridGap,
        mainAxisSpacing: AdminConstants.gridGap,
        childAspectRatio: 1.2,
        children: stats.map((stat) {
          return PastelStatCard(
            icon: stat['icon'] as IconData,
            label: stat['label'] as String,
            value: stat['value'] as String,
            trend: stat['trend'] as String?,
            trendUp: stat['trendUp'] as bool? ?? false,
            progress: stat['progress'] as double,
            backgroundColor: stat['bgColor'] as Color,
            foregroundColor: stat['fgColor'] as Color,
          );
        }).toList(),
      );
    }
  }

  Widget _buildActivitiesSection(Map<String, dynamic> data, bool isDesktop) {
    final mockActivities = [
      ActivityData(
        icon: Icons.check_circle,
        iconColor: AdminColors.success,
        title: 'Report #123 - Diverifikasi',
        subtitle: 'Ruang Meeting A-1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ActivityData(
        icon: Icons.assignment,
        iconColor: AdminColors.info,
        title: 'Request #45 - Ditugaskan',
        subtitle: 'Assigned to John Doe',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ActivityData(
        icon: Icons.verified,
        iconColor: AdminColors.success,
        title: 'Report #122 - Selesai',
        subtitle: 'Toilet Lantai 2',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];

    return ActivitiesSection(
      activities: mockActivities,
      onViewAll: () {},
    );
  }

  Widget _buildStatsGridSkeleton(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AdminConstants.gridGap,
      mainAxisSpacing: AdminConstants.gridGap,
      childAspectRatio: isDesktop ? 2.5 : 1.2,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: AdminConstants.borderRadiusCard,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildStatsGridError() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AdminColors.error),
          const SizedBox(height: AdminConstants.spaceMd),
          const Text('Gagal memuat statistik'),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AdminColors.error),
          const SizedBox(height: AdminConstants.spaceMd),
          const Text('Terjadi Kesalahan'),
          const SizedBox(height: AdminConstants.spaceSm),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(adminDashboardDataProvider);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Navigation logic
  }
}
