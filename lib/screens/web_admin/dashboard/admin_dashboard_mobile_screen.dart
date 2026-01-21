
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_helper.dart';

// Adjust these imports to match your project structure in this branch
import '../../../riverpod/admin_providers.dart' hide currentUserProfileProvider;
import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/notification_providers.dart';
import '../../../riverpod/request_providers.dart';
import '../../../riverpod/dummy_providers.dart';
import '../../../riverpod/report_providers.dart'; 
import '../../../riverpod/connectivity_provider.dart';

import '../../../widgets/shared/drawer_menu_widget.dart';
import '../../../widgets/shared/offline_banner.dart';
// import '../../../widgets/admin/admin_sidebar.dart'; // Mobile usually doesn't need sidebar
import '../../../widgets/navigation/admin_more_bottom_sheet.dart';

// Feature A: Real-time Updates
import '../../../widgets/web_admin/realtime_indicator_widget.dart'; 

import '../all_reports_management_screen.dart'; 
// import './all_requests_management_screen.dart';
// import './cleaner_management_screen.dart';
import '../../chat/conversation_list_screen.dart';

import '../../../widgets/admin/charts/weekly_report_chart.dart'; // We just restored this
import '../../../models/report.dart';

class AdminDashboardMobileScreen extends ConsumerStatefulWidget {
  const AdminDashboardMobileScreen({super.key});

  @override
  ConsumerState<AdminDashboardMobileScreen> createState() =>
      _AdminDashboardMobileScreenState();
}

class _AdminDashboardMobileScreenState extends ConsumerState<AdminDashboardMobileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // 🔥 TOGGLE: Set to true to use dummy data instead of live data
  static const bool USE_DUMMY_DATA = false; 

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    // Determine data providers
    // NOTE: In main branch it used needsVerificationReportsProvider, etc.
    // Ensure these exist in this branch's admin_providers.dart or similar.
    // If names changed, we need to adapt.
    
    // final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);
    // final allRequestsAsync = ref.watch(allRequestsProvider);
    // final cleanersAsync = ref.watch(availableCleanersProvider);
    // final allReportsAsync = ref.watch(allReportsProvider);

    // Using layout from main: _buildMobileLayout()
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,
      
      // ==================== APP BAR (Mobile Only) ====================
      appBar: _buildAppBar(context),

      // ==================== END DRAWER (Mobile Right Side Menu) ====================
      endDrawer: Drawer(child: _buildMobileDrawer()),

      // ==================== BODY ====================
      // _OfflineBannerBody might be in main, check if available here or skip
      body: _buildMobileLayout(),

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
        // Notification icon
        _buildNotificationIcon(),
        // Hamburger menu on the right for mobile
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

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
    final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final cleanersAsync = ref.watch(availableCleanersProvider);
    // Admin dashboard should see ALL reports, so pass null for departmentId
    // This ensures no department filtering is applied
    final allReportsAsync = ref.watch(allReportsProvider(null));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        ref.invalidate(allReportsProvider(null));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Stats Cards (3 in a row)
          SliverToBoxAdapter(
            child: _buildMobileStats(
              allReportsAsync,
              needsVerificationAsync,
              cleanersAsync,
            ),
          ),

          // Weekly Trends Section
          SliverToBoxAdapter(
            child: _buildMobileWeeklyTrends(allReportsAsync),
          ),

          // Recent Activities Section
          SliverToBoxAdapter(
            child: _buildMobileRecentActivities(allReportsAsync),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER (MOCKUP STYLE) ====================
  Widget _buildHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();

    return SizedBox(
      height: 105, 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient header
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

          // White greeting card
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
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userProfileAsync.when(
                          data: (profile) => Text(
                            '$greeting, ${profile?.displayName ?? 'Admin'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          loading: () => const Text(
                            'Selamat Pagi, Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          error: (e, _) => const Text(
                            'Selamat Pagi, Admin',
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

  // ==================== STATS CARDS ====================
  Widget _buildMobileStats(
    AsyncValue allReportsAsync,
    AsyncValue needsVerificationAsync,
    AsyncValue cleanersAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Card 1: Total Laporan
          Expanded(
            child: _buildStatCard(
              icon: Icons.assignment_rounded,
              label: 'Total Laporan',
              asyncValue: allReportsAsync,
              bgColor: const Color(0xFFFFF1F2), // Rose 50
              iconColor: const Color(0xFFBE123C), // Rose 700
            ),
          ),
          const SizedBox(width: 8),
          // Card 2: Menunggu Verifikasi
          Expanded(
            child: _buildStatCard(
              icon: Icons.pending_actions_rounded,
              label: 'Verifikasi',
              asyncValue: needsVerificationAsync,
              bgColor: const Color(0xFFFEFCE8), // Yellow 50
              iconColor: const Color(0xFFA16207), // Yellow 700
            ),
          ),
          const SizedBox(width: 8),
          // Card 3: Cleaner Aktif
          Expanded(
            child: _buildStatCard(
              icon: Icons.cleaning_services_rounded,
              label: 'Cleaner',
              asyncValue: cleanersAsync,
              bgColor: const Color(0xFFF0FDF4), // Green 50
              iconColor: const Color(0xFF15803D), // Green 700
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required AsyncValue asyncValue,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          asyncValue.when(
            data: (data) {
              final count = (data is List) ? data.length : 0;
              return Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
            loading: () => const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Text(
              '-',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== WEEKLY TRENDS ====================
  Widget _buildMobileWeeklyTrends(AsyncValue reportsAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'Weekly Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '7 hari terakhir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reportsAsync.when(
            data: (reports) {
              final reportList = reports.whereType<Report>().toList();
              return Column(
                children: [
                  WeeklyReportChart(
                    reports: reportList,
                    isDesktop: false,
                  ),
                  const SizedBox(height: 12),
                  const WeeklyReportChartLegend(),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 250,
              child: Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RECENT ACTIVITIES ====================
  Widget _buildMobileRecentActivities(AsyncValue reportsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                    builder: (context) => AllReportsManagementScreen(),
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
            loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 150,
              child: Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Belum ada aktivitas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(dynamic report) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/report_detail',
          arguments: report,
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: report.status.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              report.status.icon,
              color: report.status.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title ?? 'Laporan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Location with icon
                if (report.location != null && report.location.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          report.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 2),
                // Creator name with icon
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        report.userName ?? 'Anonim',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.relativeTime(report.date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: report.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  report.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: report.status.color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Category badge (Kebersihan/Kerusakan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: report.categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  report.reportCategory,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: report.categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DRAWER ====================
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
      roleTitle: 'Administrator',
      // currentRoute: 'dashboard',
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authActionsProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllReportsManagementScreen(),
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
                    builder: (context) => ConversationListScreen(),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  AdminMoreBottomSheet.show(context);
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
    final activeColor = AppTheme.headerGradientStart;
    final inactiveColor = Colors.grey[600]!;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
}
