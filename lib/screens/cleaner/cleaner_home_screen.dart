// lib/screens/cleaner/cleaner_home_screen.dart - WITH 3 TAB SYSTEM (FIXED)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../providers/riverpod/notification_providers.dart';

import '../../widgets/cleaner/stats_card_widget.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

import '../shared/request_detail/request_detail_screen.dart';
import 'report_detail_cleaner_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 TABS!

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
      endDrawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingReportsProvider);
          ref.invalidate(availableRequestsProvider);
          ref.invalidate(cleanerActiveReportsProvider);
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
                  _buildPendingReportsTab(), // TAB 1: Laporan Masuk
                  _buildAvailableRequestsTab(), // TAB 2: Permintaan Layanan
                  _buildMyTasksTab(), // TAB 3: Tugas Saya
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
              _tabController.animateTo(2);
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

  // ==================== SLIVER HEADER ====================

  Widget _buildSliverHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
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

  // ==================== TAB BAR (3 TABS!) ====================

  Widget _buildTabBar() {
    final pendingReports = ref.watch(pendingReportsProvider);
    final availableRequests = ref.watch(availableRequestsProvider);
    final activeReports = ref.watch(cleanerActiveReportsProvider);
    final assignedRequests = ref.watch(cleanerAssignedRequestsProvider);

    final pendingCount = pendingReports.maybeWhen(
      data: (reports) => reports.length,
      orElse: () => 0,
    );

    final requestsCount = availableRequests.maybeWhen(
      data: (requests) => requests.length,
      orElse: () => 0,
    );

    final activeReportsCount = activeReports.maybeWhen(
      data: (reports) => reports.length,
      orElse: () => 0,
    );

    final assignedRequestsCount = assignedRequests.maybeWhen(
      data: (requests) => requests.length,
      orElse: () => 0,
    );

    final myTasksCount = activeReportsCount + assignedRequestsCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(
            child: _buildTabWithBadge('Laporan Masuk', pendingCount, AppTheme.error),
          ),
          Tab(
            child: _buildTabWithBadge('Permintaan', requestsCount, AppTheme.info),
          ),
          Tab(
            child: _buildTabWithBadge('Tugas Saya', myTasksCount, AppTheme.warning),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count, Color badgeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==================== TAB 1: PENDING REPORTS ====================

  Widget _buildPendingReportsTab() {
    final pendingReports = ref.watch(pendingReportsProvider);

    return pendingReports.when(
      data: (reports) {
        if (reports.isEmpty) {
          // ✅ FIX: Gunakan EmptyStateWidget.custom
          return EmptyStateWidget.custom(
            icon: Icons.inbox_outlined,
            title: 'Belum ada laporan masuk',
            subtitle: 'Laporan dari karyawan akan muncul di sini',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  // ==================== TAB 2: AVAILABLE REQUESTS ====================

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
            return RequestCardWidget(
              request: request, //Passing full request object           
              animationIndex: index,
              compact: true,
              showAssignee: false, //Cleaner tidak perlu lihat assignee
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestDetailScreen(requestId: request.id),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  // ==================== TAB 3: MY TASKS ====================

  Widget _buildMyTasksTab() {
    final activeReports = ref.watch(cleanerActiveReportsProvider);
    final assignedRequests = ref.watch(cleanerAssignedRequestsProvider);

    return activeReports.when(
      data: (reports) {
        return assignedRequests.when(
          data: (requests) {
            if (reports.isEmpty && requests.isEmpty) {
              return EmptyStateWidget.noTasks();
            }

            // Combine reports and requests
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (reports.isNotEmpty) ...[
                  _buildSectionHeader('Laporan (${reports.length})'),
                  const SizedBox(height: 8),
                  ...reports.asMap().entries.map((entry) {
                    return _buildReportCard(entry.value, entry.key);
                  }),
                  const SizedBox(height: 16),
                ],
                if (requests.isNotEmpty) ...[
                  _buildSectionHeader('Permintaan Layanan (${requests.length})'),
                  const SizedBox(height: 8),
                  ...requests.asMap().entries.map((entry) {
                    final request = entry.value;
                    return RequestCardWidget(
                      request: request, //Passing full request object
                      animationIndex: entry.key,
                      compact: true,
                      showAssignee: false, //Clener tidak perlu lihat assignee
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestDetailScreen(
                              requestId: request.id,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  // ==================== HELPER: REPORT CARD ====================

  Widget _buildReportCard(Report report, int index) {
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
          side: report.isUrgent
              ? const BorderSide(color: AppTheme.error, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CleanerReportDetailScreen(reportId: report.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: report.imageUrl != null
                      ? Image.network(
                          report.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.location,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (report.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: report.status.color.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              report.status.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: report.status.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.relativeTime(report.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  // ==================== ERROR STATE ====================

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(pendingReportsProvider);
              ref.invalidate(availableRequestsProvider);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ==================== FAB ====================

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