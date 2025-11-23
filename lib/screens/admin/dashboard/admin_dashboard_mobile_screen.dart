// lib/screens/admin/dashboard/admin_dashboard_mobile_screen.dart
// 🏠 Admin Dashboard - Mobile First
// New refactored admin dashboard with mobile-first approach

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/admin/layout/mobile_admin_app_bar.dart';
import '../../../widgets/admin/layout/admin_bottom_nav.dart';
import '../../../widgets/admin/layout/quick_actions_fab.dart';
import '../../../widgets/admin/cards/greeting_card.dart';
import '../../../widgets/admin/cards/pastel_stat_card.dart';
import '../../../widgets/admin/lists/activities_section.dart';
import '../../../models/user_profile.dart';
import '../../../providers/riverpod/auth_providers.dart';
import '../../../providers/riverpod/admin_providers.dart';

class AdminDashboardMobileScreen extends ConsumerStatefulWidget {
  const AdminDashboardMobileScreen({super.key});

  @override
  ConsumerState<AdminDashboardMobileScreen> createState() =>
      _AdminDashboardMobileScreenState();
}

class _AdminDashboardMobileScreenState
    extends ConsumerState<AdminDashboardMobileScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(adminDashboardDataProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: MobileAdminAppBar(
        title: 'Dashboard',
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open drawer or menu
          },
        ),
        onNotificationTap: () {
          // Navigate to notifications
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          ref.invalidate(adminDashboardDataProvider);
        },
        child: userAsync.when(
          data: (user) => _buildDashboardContent(user, dashboardAsync),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          _handleNavigation(index);
        },
      ),
      floatingActionButton: QuickActionsFAB(
        actions: [
          FABAction(
            icon: Icons.add_task,
            label: 'Buat Laporan',
            onTap: () {
              // Navigate to create report
            },
          ),
          FABAction(
            icon: Icons.calendar_today,
            label: 'Buat Permintaan',
            onTap: () {
              // Navigate to create request
            },
            color: AdminColors.info,
          ),
          FABAction(
            icon: Icons.check_circle,
            label: 'Verifikasi',
            onTap: () {
              // Navigate to verification
            },
            color: AdminColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(UserProfile user, AsyncValue dashboardData) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Card
          GreetingCard(
            userName: user.name ?? 'Admin',
            compact: true,
          ),

          const SizedBox(height: AdminConstants.spaceSm),

          // Stats Grid (2x2)
          _buildStatsGrid(dashboardData),

          const SizedBox(height: AdminConstants.spaceMd),

          // Recent Activities
          dashboardData.when(
            data: (data) => _buildActivitiesSection(data),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AsyncValue dashboardData) {
    return dashboardData.when(
      data: (data) {
        // Get stats from dashboard data
        final totalReports = data['totalReports'] ?? 0;
        final pendingReports = data['pendingReports'] ?? 0;
        final totalRequests = data['totalRequests'] ?? 0;
        final activeCleaners = data['activeCleaners'] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.screenPaddingHorizontal,
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AdminConstants.gridGap,
            mainAxisSpacing: AdminConstants.gridGap,
            childAspectRatio: AdminConstants.getStatCardAspectRatio(
              MediaQuery.of(context).size.width,
            ),
            children: [
              // Reports Card
              PastelStatCard(
                icon: Icons.description,
                label: 'Laporan Masuk',
                value: totalReports.toString(),
                trend: '+12%',
                trendUp: true,
                progress: 0.75,
                backgroundColor: AdminColors.cardPinkBg,
                foregroundColor: AdminColors.cardPinkDark,
                onTap: () {
                  // Navigate to reports
                },
              ),

              // Pending Card
              PastelStatCard(
                icon: Icons.pending_actions,
                label: 'Pending',
                value: pendingReports.toString(),
                progress: 0.4,
                backgroundColor: AdminColors.cardYellowBg,
                foregroundColor: AdminColors.cardYellowDark,
                onTap: () {
                  // Navigate to pending reports
                },
              ),

              // Requests Card
              PastelStatCard(
                icon: Icons.notifications_active,
                label: 'Permintaan',
                value: totalRequests.toString(),
                trend: '+5',
                trendUp: true,
                progress: 0.6,
                backgroundColor: AdminColors.cardBlueBg,
                foregroundColor: AdminColors.cardBlueDark,
                onTap: () {
                  // Navigate to requests
                },
              ),

              // Cleaners Card
              PastelStatCard(
                icon: Icons.people,
                label: 'Petugas Aktif',
                value: activeCleaners.toString(),
                progress: 0.9,
                backgroundColor: AdminColors.cardGreenBg,
                foregroundColor: AdminColors.cardGreenDark,
                onTap: () {
                  // Navigate to cleaners
                },
              ),
            ],
          ),
        );
      },
      loading: () => _buildStatsGridSkeleton(),
      error: (_, __) => _buildStatsGridError(),
    );
  }

  Widget _buildActivitiesSection(Map<String, dynamic> data) {
    // TODO: Get real activities from data
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
      onViewAll: () {
        // Navigate to all activities
      },
    );
  }

  Widget _buildStatsGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AdminConstants.gridGap,
        mainAxisSpacing: AdminConstants.gridGap,
        childAspectRatio: 1.2,
        children: List.generate(
          4,
          (index) => Container(
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: AdminConstants.borderRadiusCard,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGridError() {
    return Padding(
      padding: const EdgeInsets.all(AdminConstants.spaceLg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AdminColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            Text(
              'Gagal memuat data statistik',
              style: const TextStyle(color: AdminColors.textSecondary),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(adminDashboardDataProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            Text(
              'Terjadi Kesalahan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            Text(
              error.toString(),
              style: const TextStyle(color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        // Navigate to reports
        break;
      case 2:
        // Navigate to requests
        break;
      case 3:
        // Show more menu
        _showMoreMenu();
        break;
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminConstants.radiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AdminConstants.spaceMd),
              decoration: BoxDecoration(
                color: AdminColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kelola Petugas'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to cleaners management
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AdminColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AdminColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                // Logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
