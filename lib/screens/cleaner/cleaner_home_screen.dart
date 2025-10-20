// lib/screens/cleaner/cleaner_home_screen.dart - WITH END DRAWER, BUILDER, and MODIFIED LOGOUT DIALOG

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../providers/riverpod/notification_providers.dart';

import '../../widgets/cleaner/stats_card_widget.dart';
import '../../widgets/cleaner/request_card_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

import 'request_detail_screen.dart';
import 'create_cleaning_report_screen.dart';

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  // GlobalKey TIDAK diperlukan jika menggunakan Builder
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey, // <-- TIDAK DIPERLUKAN LAGI
      backgroundColor: AppTheme.background,
      endDrawer: _buildDrawer(context), // Drawer tetap di endDrawer
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableRequestsProvider);
          ref.invalidate(cleanerAssignedRequestsProvider);
          ref.invalidate(cleanerStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(), // AppBar ada di sini, sudah diubah
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableRequestsTab(),
                  _buildMyTasksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ==================== DRAWER MENU ====================
  // (Kode _buildDrawer tetap sama)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: DrawerMenuWidget(
        menuItems: [
          DrawerMenuItem(
            icon: Icons.home_outlined,
            title: 'Beranda',
            onTap: () => Navigator.pop(context),
          ),
          DrawerMenuItem(
            icon: Icons.task_alt,
            title: 'Tugas Saya',
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
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
      ),
    );
  }

  // ==================== SLIVER HEADER (MODIFIED WITH BUILDER) ====================

  Widget _buildSliverHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false, // <-- Tetap false
      backgroundColor: AppTheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        // Notification icon with badge (tetap sama)
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              tooltip: 'Notifikasi',
            ),
            if (unreadCount > 0)
              Positioned(
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
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Gunakan Builder untuk IconButton
        Builder(
          builder: (buttonContext) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(buttonContext).openEndDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        userProfileAsync.when(
                          data: (profile) => Text(
                            profile?.displayName ?? 'Petugas Kebersihan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => Container(
                            height: 24,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(77),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          error: (error, stackTrace) => const Text(
                            'Petugas Kebersihan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormatter.fullDate(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 14,
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
      ),
    );
  }

  // ==================== STATS CARDS ====================
  // (Kode _buildStatsCards dan helpernya tetap sama)
  Widget _buildStatsCards() {
    final cleanerStats = ref.watch(cleanerStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatsCardWithDelay(
            index: 0,
            icon: Icons.assignment_outlined,
            label: 'Ditugaskan',
            value: (cleanerStats['assigned'] ?? 0).toString(),
            color: AppTheme.info,
          ),
          const SizedBox(width: 8),
          _buildStatsCardWithDelay(
            index: 1,
            icon: Icons.pending_actions_outlined,
            label: 'Proses',
            value: (cleanerStats['inProgress'] ?? 0).toString(),
            color: AppTheme.warning,
          ),
          const SizedBox(width: 8),
          _buildStatsCardWithDelay(
            index: 2,
            icon: Icons.check_circle_outline,
            label: 'Selesai',
            value: (cleanerStats['completed'] ?? 0).toString(),
            color: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCardWithDelay({
    required int index,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Opacity(
            opacity: animValue,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - animValue)),
              child: child,
            ),
          );
        },
        child: StatsCard(
          icon: icon,
          label: label,
          value: value,
          color: color,
        ),
      ),
    );
  }

  // ==================== TAB BAR ====================
  // (Kode _buildTabBar tetap sama)
  Widget _buildTabBar() {
    final availableRequests = ref.watch(availableRequestsProvider);
    final assignedRequests = ref.watch(cleanerAssignedRequestsProvider);

    final availableCount = availableRequests.maybeWhen(
      data: (requests) => requests.length,
      orElse: () => 0,
    );

    final assignedCount = assignedRequests.maybeWhen(
      data: (requests) => requests.length,
      orElse: () => 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // Adjusted alpha
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Permintaan Baru'),
                if (availableCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      availableCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tugas Saya'),
                if (assignedCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      assignedCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ==================== TAB VIEWS ====================
  // (Kode _buildAvailableRequestsTab dan _buildMyTasksTab tetap sama)
   Widget _buildAvailableRequestsTab() {
    final availableRequests = ref.watch(availableRequestsProvider);

    return availableRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyStateWidget.noRequests();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return RequestCard(
              location: request['location'] as String? ?? 'Lokasi tidak diketahui',
              description: request['description'] as String? ?? '',
              isUrgent: request['isUrgent'] as bool? ?? false,
              animationIndex: index,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestDetailScreen(requestId: request['id'] as String),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTasksTab() {
    final assignedRequests = ref.watch(cleanerAssignedRequestsProvider);

    return assignedRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyStateWidget.noTasks();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return RequestCard(
              location: request['location'] as String? ?? 'Lokasi tidak diketahui',
              description: request['description'] as String? ?? '',
              isUrgent: request['isUrgent'] as bool? ?? false,
              animationIndex: index,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestDetailScreen(requestId: request['id'] as String),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }


  // ==================== FAB ====================
  // (Kode _buildFAB tetap sama)
  Widget _buildFAB(BuildContext context) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCleaningReportScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ==================== LOGOUT (MODIFIED DIALOG BUTTON) ====================

  Future<void> _handleLogout(BuildContext context) async {
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
          // VVV MODIFIKASI: Ubah ElevatedButton menjadi TextButton VVV
          TextButton( // <-- Ubah dari ElevatedButton
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom( // <-- Gunakan style TextButton
              foregroundColor: AppTheme.error, // <-- Atur warna teks jadi merah
            ),
            child: const Text('KELUAR'),
          ),
          // ^^^ MODIFIKASI ^^^
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
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

} // Penutup class state