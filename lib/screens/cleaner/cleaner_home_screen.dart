// lib/screens/cleaner/cleaner_home_screen.dart
// ✅ REFACTORED: Clean single-page layout (like Employee)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../widgets/shared/custom_speed_dial.dart';

import './pending_reports_list_screen.dart';
import './available_requests_list_screen.dart';
import './my_tasks_screen.dart';
import './create_cleaning_report_screen.dart';

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cleanerStats = ref.watch(cleanerStatsProvider);
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final assignedRequestsAsync = ref.watch(cleanerAssignedRequestsProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      
      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Notification Icon
          _buildNotificationIcon(),
          // Menu Icon
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      // ==================== DRAWER ====================
      endDrawer: Drawer(
        child: _buildDrawer(),
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
              child: _buildHeader(),
            ),

            // ==================== STATS CARDS ====================
            SliverToBoxAdapter(
              child: _buildStatsCards(cleanerStats),
            ),

            // ==================== TASKS OVERVIEW & RECENT ====================
            SliverToBoxAdapter(
              child: _buildRecentActivity(
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
      floatingActionButton: _buildSpeedDial(),
    );
  }

  // ==================== NOTIFICATION ICON ====================

  Widget _buildNotificationIcon() {
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

  // ==================== DRAWER MENU ====================

  Widget _buildDrawer() {
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
      onLogout: () => _handleLogout(),
      roleTitle: 'Petugas Kebersihan',
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
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
              profile?.displayName ?? 'Petugas Kebersihan',
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

  // ==================== STATS CARDS ====================

  Widget _buildStatsCards(Map<String, int> stats) {
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

  // ==================== TASKS OVERVIEW & RECENT ====================

  Widget _buildRecentActivity(
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

  // ==================== SPEED DIAL ====================

  Widget _buildSpeedDial() {
    return CustomSpeedDial(
      mainButtonColor: AppTheme.primary,
      actions: [
        // Inventaris Alat (Blue) - NEW!
        SpeedDialAction(
          icon: Icons.inventory_2,
          label: 'Inventaris Alat',
          backgroundColor: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/inventory'),
        ),
        
        // Tugas Saya (Purple)
        SpeedDialAction(
          icon: Icons.task_alt,
          label: 'Tugas Saya',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyTasksScreen()),
          ),
        ),
        
        // Ambil Permintaan (Green)
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Ambil Permintaan',
          backgroundColor: SpeedDialColors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AvailableRequestsListScreen(),
            ),
          ),
        ),
        
        // Laporan Masuk (Orange)
        SpeedDialAction(
          icon: Icons.inbox,
          label: 'Laporan Masuk',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PendingReportsListScreen(),
            ),
          ),
        ),
        
        // Buat Laporan (Blue)
        SpeedDialAction(
          icon: Icons.add,
          label: 'Buat Laporan',
          backgroundColor: SpeedDialColors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCleaningReportScreen(),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== LOGOUT ====================

  Future<void> _handleLogout() async {
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

    if (shouldLogout == true && mounted) {
      try {
        await ref.read(authActionsProvider.notifier).logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        if (mounted) {
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
