import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/sidebar_navigation.dart';
import '../../widgets/modern_stat_card.dart';
import '../../widgets/web_admin/admin_overview_widget.dart';
import '../../widgets/web_admin/admin_analytics_widget.dart';
import '../../widgets/web_admin/recent_activities_widget.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/admin_providers.dart' hide currentUserProfileProvider;
import '../../providers/riverpod/admin_stats_provider.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/web_admin/global_search_bar.dart';
import '../../widgets/web_admin/filter_chips_widget.dart';
import '../../widgets/web_admin/advanced_filter_dialog.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/web_admin/batch_action_bar.dart';
import '../../services/batch_service.dart';
import '../../providers/riverpod/selection_providers.dart';
import '../../services/realtime_service.dart';

class ModernDashboardScreen extends HookConsumerWidget {
  const ModernDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real-time updates are handled automatically by StreamProviders

    // Data Providers
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final departmentId = ref.watch(currentUserDepartmentProvider);
    final adminStatsAsync = ref.watch(adminStatsProvider);
    
    // Watch ALL data for overview (still needed for detailed widgets)
    final allReportsAsync = ref.watch(allReportsProvider(departmentId));
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final cleanersAsync = ref.watch(availableCleanersProvider);

    // Sidebar Items
    final sidebarItems = [
      const SidebarItem(title: 'MAIN', icon: Icons.abc, route: '', isHeader: true),
      const SidebarItem(title: 'Dashboard', icon: Icons.grid_view_rounded, route: '/admin/dashboard'),
      const SidebarItem(title: 'Reports', icon: Icons.assignment_rounded, route: '/admin/reports'),
      const SidebarItem(title: 'Requests', icon: Icons.room_service_rounded, route: '/admin/requests'),
      const SidebarItem(title: 'Cleaners', icon: Icons.people_rounded, route: '/admin/cleaners'),
      const SidebarItem(title: 'SETTINGS', icon: Icons.abc, route: '', isHeader: true),
      const SidebarItem(title: 'Profile', icon: Icons.person_rounded, route: '/profile'),
      const SidebarItem(title: 'Settings', icon: Icons.settings_rounded, route: '/settings'),
    ];

    return MainLayout(
      currentRoute: '/admin/dashboard',
      sidebarItems: sidebarItems,
      headerTitle: 'Dashboard',
      headerSubtitle: 'Overview & Statistics',
      userPhotoUrl: userProfileAsync.value?.photoURL,
      onLogout: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'), // Title Case
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Keluar', style: TextStyle(color: Colors.red)), // Title Case
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          await ref.read(authActionsProvider.notifier).logout();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
      // Mobile Navigation Logic
      bottomNavIndex: 0, // 0 = Home/Dashboard
      onBottomNavTap: (index) {
        switch (index) {
          case 0: break; // Dashboard
          case 1: context.go('/admin/reports'); break;
          case 2: context.go('/admin/requests'); break;
          case 3: break; // More (handled by MainLayout)
        }
      },

      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stats Grid (Keep the modern look)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  final crossAxisCount = isMobile ? 2 : 4;
                  final childAspectRatio = isMobile ? 1.2 : 1.4;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                    children: [
                      ModernStatCard(
                        label: 'Laporan Masuk',
                        value: adminStatsAsync.when(
                          data: (s) => s.needsVerificationCount.toString(),
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                        subValue: '+12%',
                        icon: Icons.description_rounded,
                        accentColor: AppTheme.primary,
                      ),
                      ModernStatCard(
                        label: 'Pending',
                        value: adminStatsAsync.when(
                          data: (s) => s.pendingReportsCount.toString(),
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                        icon: Icons.pending_actions_rounded,
                        accentColor: AppTheme.warning,
                      ),
                      ModernStatCard(
                        label: 'Permintaan',
                        value: adminStatsAsync.when(
                          data: (s) => s.totalRequestsCount.toString(),
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                        subValue: '+5%',
                        icon: Icons.room_service_rounded,
                        accentColor: AppTheme.info,
                      ),
                      ModernStatCard(
                        label: 'Petugas Aktif',
                        value: adminStatsAsync.when(
                          data: (s) => s.activeCleanersCount.toString(),
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                        icon: Icons.people_rounded,
                        accentColor: AppTheme.success,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 2. Filter Chips
              const FilterChipsWidget(),
              const SizedBox(height: 24),

              // 3. Analytics Widget
              allReportsAsync.when(
                data: (reports) {
                  return allRequestsAsync.when(
                    data: (requests) {
                      return cleanersAsync.when(
                        data: (cleaners) => AdminAnalyticsWidget(
                          reports: reports,
                          requests: requests,
                          totalCleaners: cleaners.length,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 24),

              // 4. Recent Activities
              allReportsAsync.when(
                data: (reports) {
                  return allRequestsAsync.when(
                    data: (requests) {
                      return RecentActivitiesWidget(
                        reports: reports.take(5).toList(),
                        requests: requests.take(5).toList(),
                        onViewAll: () => context.go('/admin/reports'),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),

          // Batch Action Bar (overlay)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BatchActionBar(),
          ),
        ],
      ),
    );
  }
}

