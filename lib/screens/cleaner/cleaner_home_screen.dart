import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';

// ✅ FIXED: Import semua widget yang diperlukan
import '../../widgets/cleaner/stats_card_widget.dart';
import '../../widgets/cleaner/request_card_widget.dart';
import '../../widgets/cleaner/drawer_menu_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

import 'request_detail_screen.dart';
import 'create_cleaning_report_screen.dart';

/// Cleaner Home Screen - POLISHED VERSION
/// ✅ All imports fixed
/// ✅ Using reusable widgets
/// ✅ Enhanced animations
/// ✅ Better UX
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // ✅ ENHANCED: FAB animation
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
      backgroundColor: AppTheme.background,
      // ✅ FIXED: Pakai DrawerMenuWidget
      endDrawer: _buildDrawerWithWidget(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableRequestsProvider);
          ref.invalidate(cleanerAssignedRequestsProvider);
          ref.invalidate(cleanerStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(),
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

  // ==================== DRAWER MENU (FIXED!) ====================

  /// ✅ FIXED: Sekarang pakai DrawerMenuWidget dari widget terpisah
  Widget _buildDrawerWithWidget(BuildContext context) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur segera hadir')),
              );
            },
          ),
        ],
        onLogout: () => _handleLogout(context),
        roleTitle: 'Petugas Kebersihan',
      ),
    );
  }

  // ==================== SLIVER HEADER ====================

  Widget _buildSliverHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
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
                  // ✅ ENHANCED: Fade animation untuk text
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
                            color: Colors.white.withValues(alpha: 0.9),
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
                              color: Colors.white.withValues(alpha: 0.3),
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
                            color: Colors.white.withValues(alpha: 0.8),
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

  // ==================== STATS CARDS (POLISHED!) ====================

  Widget _buildStatsCards() {
    final cleanerStats = ref.watch(cleanerStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ✅ ENHANCED: Stagger animation delay untuk each card
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

  /// ✅ ENHANCED: Stats card dengan stagger animation
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

  // ==================== TAB BAR WITH BADGE COUNT ====================

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
            color: Colors.black.withValues(alpha: 0.05),
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
                  // ✅ ENHANCED: Pulse animation untuk badge
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.95, end: 1.05),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
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

  Widget _buildAvailableRequestsTab() {
    final availableRequests = ref.watch(availableRequestsProvider);

    return availableRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          // ✅ FIXED: Pakai EmptyStateWidget dari shared
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
      loading: () => _buildShimmerLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildMyTasksTab() {
    final assignedRequests = ref.watch(cleanerAssignedRequestsProvider);

    return assignedRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          // ✅ FIXED: Pakai EmptyStateWidget dari shared
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
      loading: () => _buildShimmerLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  // ==================== STATES (POLISHED!) ====================

  /// ✅ ENHANCED: Shimmer loading animation
  Widget _buildShimmerLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
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
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Shimmer effect untuk icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, shimmerValue, child) {
                      return Opacity(
                        opacity: shimmerValue,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return ErrorEmptyState(
      title: 'Terjadi kesalahan',
      subtitle: error.toString(),
      onRetry: () {
        ref.invalidate(availableRequestsProvider);
        ref.invalidate(cleanerAssignedRequestsProvider);
      },
    );
  }

  // ==================== FAB (POLISHED!) ====================

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
      ),
    );
  }

  // ==================== LOGOUT ====================

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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('KELUAR'),
          ),
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
}