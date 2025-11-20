// lib/screens/cleaner/cleaner_home_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../providers/riverpod/notification_providers.dart';

import '../../widgets/cleaner/stats_card_widget.dart';
import '../../widgets/cleaner/tasks_overview_widget.dart';
import '../../widgets/cleaner/recent_tasks_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/navigation/cleaner_bottom_nav.dart';

import './pending_reports_list_screen.dart';
import './available_requests_list_screen.dart';
import './my_tasks_screen.dart';
import './create_cleaning_report_screen.dart';
import '../../widgets/navigation/cleaner_more_bottom_sheet.dart';

/// Cleaner Home Screen - Dashboard for cleaner role
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class CleanerHomeScreen extends HookConsumerWidget {
  const CleanerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Scaffold key for drawer control
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    final cleanerStats = ref.watch(cleanerStatsProvider);
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final assignedRequestsAsync = ref.watch(cleanerAssignedRequestsProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],

      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Notification Icon
          _buildNotificationIcon(context, ref),
          // Menu Icon
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      // ==================== DRAWER ====================
      endDrawer: Drawer(
        child: _buildDrawer(context),
      ),

      // ==================== BODY ====================
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cleanerActiveReportsProvider);
          ref.invalidate(cleanerAssignedRequestsProvider);
          ref.invalidate(cleanerStatsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            // ==================== HEADER ====================
            SliverToBoxAdapter(
              child: _buildHeader(ref),
            ),

            // ==================== STATS CARDS ====================
            SliverToBoxAdapter(
              child: _buildStatsCards(cleanerStats),
            ),

            // ==================== TASKS OVERVIEW & RECENT ====================
            SliverToBoxAdapter(
              child: _buildRecentActivity(
                context,
                activeReportsAsync,
                assignedRequestsAsync,
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),

      // ==================== SPEED DIAL FAB ====================
      // ==================== BOTTOM NAVIGATION ====================
      bottomNavigationBar: CleanerBottomNav(
        currentIndex: 0, // Home screen
        onTap: (index) => _handleBottomNavTap(context, index),
      ),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build notification icon with unread count badge
  static Widget _buildNotificationIcon(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        unreadCountAsync.when(
          data: (count) {
            if (count > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Build drawer menu for cleaner
  static Widget _buildDrawer(BuildContext context) {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.home_outlined,
          title: 'Beranda',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.inventory_2,
          title: 'Inventaris Alat',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/inventory');
          },
        ),
        DrawerMenuItem(
          icon: Icons.task_alt,
          title: 'Tugas Saya',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyTasksScreen()),
            );
          },
        ),
        DrawerMenuItem(
          icon: Icons.history,
          title: 'Riwayat Laporan',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur segera hadir')),
            );
          },
        ),
        DrawerMenuItem(
          icon: Icons.person_outline,
          title: 'Profil',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppConstants.profileRoute);
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
      onLogout: () => _handleLogout(context),
      roleTitle: 'Petugas Kebersihan',
    );
  }

  /// Build header with time-based greeting
  static Widget _buildHeader(WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          userProfileAsync.when(
            data: (profile) => Text(
              profile?.displayName ?? user?.displayName ?? 'Petugas Kebersihan',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            loading: () => const Text(
              'Petugas Kebersihan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            error: (e, _) => const Text(
              'Petugas Kebersihan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.fullDate(DateTime.now()),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats cards showing cleaner work summary
  static Widget _buildStatsCards(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              icon: Icons.assignment_outlined,
              label: 'Ditugaskan',
              value: (stats['assigned'] ?? 0).toString(),
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsCard(
              icon: Icons.pending_actions_outlined,
              label: 'Proses',
              value: (stats['inProgress'] ?? 0).toString(),
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsCard(
              icon: Icons.check_circle_outline,
              label: 'Selesai',
              value: (stats['completed'] ?? 0).toString(),
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  /// Build recent activity section (tasks overview + recent tasks)
  static Widget _buildRecentActivity(
    BuildContext context,
    AsyncValue activeReportsAsync,
    AsyncValue assignedRequestsAsync,
  ) {
    return activeReportsAsync.when(
      data: (reports) {
        return assignedRequestsAsync.when(
          data: (requests) {
            return Column(
              children: [
                // Tasks Overview
                TasksOverviewWidget(
                  reports: reports as List<Report>,
                  requests: List.from(requests),
                ),

                // Recent Tasks
                RecentTasksWidget(
                  reports: reports,
                  requests: List.from(requests),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyTasksScreen(),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  // ==================== NAVIGATION HANDLERS ====================

  /// Handle bottom navigation tap
  static void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on Home - do nothing
        break;
      case 1:
        // Laporan - Navigate to create cleaning report
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateCleaningReportScreen(),
          ),
        );
        break;
      case 2:
        // Inbox - Navigate to inbox (pending reports + available requests)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingReportsListScreen(),
          ),
        );
        break;
      case 3:
        // More - Show bottom sheet with more menu options
        CleanerMoreBottomSheet.show(context);
        break;
    }
  }

  // ==================== ACTION HANDLERS ====================

  /// Handle logout with confirmation
  /// TODO (Phase 5): Replace Navigator with go_router
  static Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}
