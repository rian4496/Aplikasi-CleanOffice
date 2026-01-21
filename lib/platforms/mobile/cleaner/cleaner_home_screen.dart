// lib/platforms/mobile/cleaner/cleaner_home_screen.dart
// ✅ FULL REPLICA: Cleaner Dashboard (copced from Admin Dashboard structure)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_helper.dart';

import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/cleaner_providers.dart';
import '../../../riverpod/notification_providers.dart';
import '../../../riverpod/connectivity_provider.dart';
import '../../../models/report.dart';

import '../../../widgets/shared/drawer_menu_widget.dart';
import '../../../widgets/shared/offline_banner.dart';
import '../navigation/cleaner_more_bottom_sheet.dart';

import '../../chat/conversation_list_screen.dart';
import './cleaner_inbox_screen.dart';
import './pending_reports_list_screen.dart';
import './available_requests_list_screen.dart';
import './inbox_screen.dart';
import './create_cleaning_report_screen.dart';
import '../../inventory/inventory_list_screen.dart';
import './cleaner_statistics_screen.dart';

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: _buildAppBar(context),

      // ==================== END DRAWER (Mobile Right Side Menu) ====================
      endDrawer: Drawer(child: _buildMobileDrawer()),

      // ==================== BODY (with Offline Banner) ====================
      body: _OfflineBannerBody(
        child: _buildMobileLayout(),
      ),

      // ==================== BOTTOM NAV (Mobile Only) ====================
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        // Notification Icon
        _buildNotificationIcon(),
        // Menu Icon
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
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

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final assignedRequestsAsync = ref.watch(cleanerAssignedRequestsProvider);
    final statsAsync = ref.watch(cleanerStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cleanerActiveReportsProvider);
        ref.invalidate(cleanerAssignedRequestsProvider);
        ref.invalidate(cleanerStatsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Header
          // Header wrapped in SliverSafeArea to prevent status bar overlap
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: _buildHeader(),
            ),
          ),

          // Stats Cards (3 in a row)
          SliverToBoxAdapter(
            child: _buildMobileStats(statsAsync),
          ),

          // Ringkasan Kinerja Section (NEW)
          SliverToBoxAdapter(
            child: _buildRingkasanKinerja(statsAsync),
          ),

          // Quick Actions Section
          SliverToBoxAdapter(
            child: _buildQuickActions(),
          ),

          // Recent Activities Section
          SliverToBoxAdapter(
            child: _buildMobileRecentActivities(activeReportsAsync),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER (MOCKUP STYLE - Gradient + White Overlap Card) ====================
  Widget _buildHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();

    return SizedBox(
      height: 105,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient header dengan curve di bawah
          Container(
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // White greeting card - posisi pas di tengah batas gradient
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Greeting text (hitam) di kiri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userProfileAsync.when(
                          data: (profile) => Text(
                            '$greeting, ${profile?.displayName ?? 'Petugas'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          loading: () => const Text(
                            'Selamat Pagi, Petugas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          error: (e, _) => const Text(
                            'Selamat Pagi, Petugas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.fullDate(DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile avatar di kanan
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryLight,
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATS CARDS - 3 in a row ====================
  Widget _buildMobileStats(Map<String, int> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Card 1: Ditugaskan
          Expanded(
            child: _buildStatCard(
              icon: Icons.assignment_rounded,
              label: 'Ditugaskan',
              value: stats['assigned'] ?? 0,
              bgColor: const Color(0xFFFFF1F2), // Rose 50
              iconColor: const Color(0xFFBE123C), // Rose 700
            ),
          ),
          const SizedBox(width: 8),
          // Card 2: Dalam Proses
          Expanded(
            child: _buildStatCard(
              icon: Icons.pending_actions_rounded,
              label: 'Proses',
              value: stats['inProgress'] ?? 0,
              bgColor: const Color(0xFFFEFCE8), // Yellow 50
              iconColor: const Color(0xFFA16207), // Yellow 700
            ),
          ),
          const SizedBox(width: 8),
          // Card 3: Selesai
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_rounded,
              label: 'Selesai',
              value: stats['completed'] ?? 0,
              bgColor: const Color(0xFFF0FDF4), // Green 50
              iconColor: const Color(0xFF15803D), // Green 700
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon - keeps pastel color
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RINGKASAN KINERJA ====================
  Widget _buildRingkasanKinerja(Map<String, int> stats) {
    final total = (stats['assigned'] ?? 0) + (stats['inProgress'] ?? 0) + (stats['completed'] ?? 0);
    final completed = stats['completed'] ?? 0;
    final completionRate = total > 0 ? (completed / total) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Kinerja',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tingkat Penyelesaian Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tingkat Penyelesaian',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  Text(
                    '${(completionRate * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success, // Green color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success), // Green color
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Tugas dan Metrik
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Tugas (Left Column)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Tugas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow('Menunggu', stats['assigned'] ?? 0, Colors.orange),
                    const SizedBox(height: 8),
                    _buildStatusRow('Dalam Proses', stats['inProgress'] ?? 0, Colors.blue),
                    const SizedBox(height: 8),
                    _buildStatusRow('Selesai', stats['completed'] ?? 0, Colors.green),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Metrik (Right Column)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metrik',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricRow('Waktu Rata-rata', '${stats['avgWorkTimeMinutes'] ?? 0} menit'),
                    const SizedBox(height: 8),
                    _buildMetricRow('Bulan Ini', '${stats['completedThisMonth'] ?? 0} tugas'),
                    const SizedBox(height: 8),
                    _buildMetricRow('Hari Ini', '${stats['completedToday'] ?? 0} selesai'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionItem(
                icon: Icons.inventory_2_rounded,
                label: 'Inventaris',
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const InventoryListScreen(),
                )),
              ),
              _buildQuickActionItem(
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                color: AppTheme.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CleanerStatisticsScreen(),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE RECENT ACTIVITIES ====================
  Widget _buildMobileRecentActivities(AsyncValue<List<Report>> reportsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyTasksScreen(),
                  ),
                ),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return _buildEmptyActivities();
              }
              final recentReports = reports.take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return _buildActivityItem(report);
                },
              );
            },
            loading: () => _buildEmptyActivities(),
            error: (e, _) => _buildEmptyActivities(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada aktivitas',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(dynamic report) {
    Color statusColor;
    String statusText;
    
    switch (report.status.name) {
      case 'inProgress':
        statusColor = Colors.orange;
        statusText = 'Proses';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Baru';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.cleaning_services, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.location ?? 'Lokasi tidak diketahui',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                report.description ?? '-',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE DRAWER ====================
  Widget _buildMobileDrawer() {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () => Navigator.pop(context),
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

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.inbox_rounded,
                label: 'Inbox',
                isActive: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CleanerInboxScreen(),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversationListScreen(),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  CleanerMoreBottomSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppTheme.primary : Colors.grey[600]!;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _handleLogout() async {
    // Confirmation handled by DrawerMenuWidget
    await ref.read(authActionsProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }
}

// ==================== OFFLINE BANNER BODY ====================
class _OfflineBannerBody extends ConsumerWidget {
  final Widget child;
  const _OfflineBannerBody({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider);
    
    return Column(
      children: [
        if (!isConnected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red[700],
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Anda sedang offline',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

