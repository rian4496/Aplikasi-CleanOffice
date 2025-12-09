// lib/screens/admin/admin_dashboard_screen_responsive.dart
// ✅ MULTI-PLATFORM: Responsive Admin Dashboard (Mobile + Desktop/Web)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';

import '../../providers/riverpod/admin_providers.dart' hide currentUserProfileProvider;
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/notification_providers.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../providers/riverpod/dummy_providers.dart';
import '../../providers/riverpod/supabase_report_providers.dart';
import '../../providers/riverpod/connectivity_provider.dart';

import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/offline_banner.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';

// Feature A: Real-time Updates
import '../../widgets/admin/realtime_indicator_widget.dart';

// Feature B: Advanced Filtering
import '../../widgets/admin/advanced_filter_dialog.dart';

import './all_reports_management_screen.dart';
import './all_requests_management_screen.dart';
import './cleaner_management_screen.dart';
import '../chat/conversation_list_screen.dart';

// 🎨 NEW: Modern Dashboard Widgets
import '../../widgets/admin/dashboard/dashboard_stats_grid.dart';
import '../../widgets/admin/dashboard/dashboard_section.dart';
import '../../widgets/admin/charts/weekly_report_chart.dart';
import '../../widgets/admin/cards/top_cleaner_card.dart';
import '../../providers/riverpod/dashboard_stats_provider.dart';
import '../../models/report.dart';

// 🎛️ DEVELOPMENT: Mock Data Toggle
// Set to true to show layout preview with sample data
// Set to false to use real data from providers
const bool USE_MOCK_DATA = true;

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // 🔥 TOGGLE: Set to true to use dummy data instead of live data
  static const bool USE_DUMMY_DATA = false;  // ← DISABLED: Pakai data real

  @override
  void dispose() {
    // Dispose handled by Riverpod automatically
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,
      // AppBar dan body terpisah - tidak perlu extend

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildAppBar(context) : null,

      // ==================== END DRAWER (Mobile Right Side Menu) ====================
      endDrawer: !isDesktop ? Drawer(child: _buildMobileDrawer()) : null,

      // ==================== BODY (with Offline Banner) ====================
      body: _OfflineBannerBody(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),

      // ==================== BOTTOM NAV (Mobile Only) ====================
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

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
      title: isDesktop
          ? Row(
              children: [
                const SizedBox(width: 8),
                // Search Bar untuk Desktop
                Expanded(
                  flex: 2,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Live indicator
                const RealtimeIndicatorCompact(),
                const SizedBox(width: 16),
              ],
            )
          : null,
      actions: [
        // Notification icon
        _buildNotificationIcon(),
        // Hamburger menu on the right for mobile
        if (!isDesktop)
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        const SizedBox(width: 8),
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

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'dashboard'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background with Search)
              _buildDesktopHeader(),
              // Scrollable Content
              Expanded(
                child: _buildDesktopContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP HEADER (Blue Bar with Search) ====================
  Widget _buildDesktopHeader() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Search Bar
            Expanded(
              flex: 2,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                height: 46,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search here...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Live indicator
            const RealtimeIndicatorCompact(),
            const SizedBox(width: 24),

            // Filter button
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const AdvancedFilterDialog(),
              ),
              tooltip: 'Advanced Filters',
            ),
            const SizedBox(width: 8),

            // Notification Icon
            _buildNotificationIcon(),
            const SizedBox(width: 16),

            // Profile Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContent() {
    // Use needsVerificationReportsProvider as the main data source
    final allReportsAsync = ref.watch(needsVerificationReportsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Modern Header with User Info
          SliverToBoxAdapter(
            child: _buildModernHeader(),
          ),

          // Stats Cards (4 cards horizontal)
          SliverToBoxAdapter(
            child: _buildModernStats(allReportsAsync),
          ),

          // Main Content - Two Columns
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (70%) - Progress Overview + Quick Actions
                  Expanded(
                    flex: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics Section
                        _buildAnalyticsSection(reports: allReportsAsync.asData?.value ?? [], requests: []),

                        const SizedBox(height: 24),

                        // Quick Actions Section
                        _buildQuickActions(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Column (30%) - Top Cleaner + Recent Reports
                  Expanded(
                    flex: 30,
                    child: Column(
                      children: [
                        // 🎨 NEW: Top Cleaner Performance Card
                        TopCleanerCard(
                          allReports: allReportsAsync.asData?.value ?? [],
                          onViewDetails: () {
                            _navigateToScreen(const CleanerManagementScreen());
                          },
                        ),
                        const SizedBox(height: 24),
                        // Recent Reports
                        _buildRecentReports(allReportsAsync),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    // Use dummy or real providers based on toggle
    final needsVerificationAsync = ref.watch(
      USE_DUMMY_DATA ? dummyNeedsVerificationReportsProvider(null) : needsVerificationReportsProvider
    );
    final allRequestsAsync = ref.watch(
      USE_DUMMY_DATA ? dummyAllRequestsProvider(null) : allRequestsProvider
    );
    final cleanersAsync = ref.watch(
      USE_DUMMY_DATA ? dummyCleanersProvider(null) : availableCleanersProvider
    );
    final allReportsAsync = ref.watch(allReportsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        ref.invalidate(allReportsProvider);
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

  // ==================== HEADER (MOCKUP STYLE - Gradient + White Overlap Card) ====================
  Widget _buildHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();

    // Card height ~76px (padding 14*2 + content ~48)
    // Untuk card di tengah batas gradient: gradient harus cover setengah card
    // Gradient: 70px, card top: 32px -> card overlap 38px di gradient, 38px di bawah
    return SizedBox(
      height: 105, // Kurangi gap dengan stat cards
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient header dengan curve di bawah
          Container(
            height: 70, // Tinggi gradient - card akan overlap di tengah batasnya
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
            top: 32, // Card dimulai di 32px, gradient berakhir di 70px, jadi ~38px overlap
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
                  // Greeting text (hitam) di kiri
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

  // ==================== MOCKUP STAT CARD (PASTEL DESIGN) ====================
  Widget _buildMockupStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon at top
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          // Large value
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE STATS (REFINED) ====================
  // TEMPORARILY DISABLED - Method was broken, needs rebuild
  // TODO: Rebuild this method properly with correct structure
  /*
  Widget _buildMobileStats(
        // Pastel colors sesuai mockup
        const Color pastelPink = Color(0xFFFFE4E1);    // Reports - pink/salmon
        const Color pastelBlue = Color(0xFFE3F2FD);    // Pending - light blue
        const Color pastelYellow = Color(0xFFFFF8E1);  // Requests - cream/yellow
        const Color pastelGreen = Color(0xFFE8F5E9);   // Cleaners - mint green

        const Color iconPink = Color(0xFFE57373);
        const Color iconBlue = Color(0xFF64B5F6);
        const Color iconYellow = Color(0xFFFFB74D);
        const Color iconGreen = Color(0xFF81C784);

        return Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMockupStatCard(
                      label: 'Reports',
                      value: reports.length.toString(),
                      icon: Icons.description_outlined,
                      bgColor: pastelPink,
                      iconColor: iconPink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMockupStatCard(
                      label: 'Pending',
                      value: pendingCount.toString(),
                      icon: Icons.hourglass_empty_rounded,
                      bgColor: pastelBlue,
                      iconColor: iconBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMockupStatCard(
                      label: 'Requests',
                      value: requestsCount.toString(),
                      icon: Icons.assignment_outlined,
                      bgColor: pastelYellow,
                      iconColor: iconYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMockupStatCard(
                      label: 'Cleaners',
                      value: cleanersCount.toString(),
                      icon: Icons.people_outline_rounded,
                      bgColor: pastelGreen,
                      iconColor: iconGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $e'),
        ),
      ),
    );
  */
  
  // STATS CARDS - 3 in a row
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

  /// Build individual stat card
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
        color: Colors.white, // White background
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
          // Icon - keeps pastel color
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor, // Pastel background for icon
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          // Value - black text
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
          // Label - dark grey text
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


  // ==================== MOBILE WEEKLY TRENDS ====================
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

  // ==================== MOBILE RECENT ACTIVITIES ====================
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
                    builder: (context) => const AllReportsManagementScreen(),
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
                  report.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  report.location,
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
              const SizedBox(height: 2),
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
            ],
          ),
        ],
      ),
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
      roleTitle: 'Administrator',
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
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
                    builder: (context) => const AllReportsManagementScreen(),
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
    // Light blue gradient color for active state
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

  // ==================== NAVIGATION HELPER ====================
  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  // ==================== MODERN WEB LAYOUT METHODS ====================

  /// Modern Header with User Info
  Widget _buildModernHeader() {
    final greeting = _getGreeting();
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ADMIN',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.fullDate(now),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎨 NEW: Modern Stats Cards using DashboardStatsGrid
  Widget _buildModernStats(AsyncValue allReportsAsync) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final stats = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DashboardStatsGrid(
        stats: stats,
        isDesktop: isDesktop,
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add,
                  label: 'Create New Report',
                  color: AppTheme.primary,
                  onTap: () => Navigator.pushNamed(context, '/create_report'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.list_alt,
                  label: 'View All Reports',
                  color: AppTheme.info,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllReportsManagementScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.access_time,
                  label: 'Pending Reports',
                  color: AppTheme.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllReportsManagementScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.data_object,
                  label: 'Generate Sample Data',
                  color: Colors.deepPurple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ini dinonaktifkan sementara')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Reports Section (Right Column)
  Widget _buildRecentReports(AsyncValue allReportsAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recent Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllReportsManagementScreen(),
                  ),
                ),
                child: const Text('Lihat Semua >'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          allReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Semua sudah ditangani',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show latest 5 reports
              final recentReports = reports.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return _buildRecentReportItem(report);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportItem(dynamic report) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/report_detail',
          arguments: report,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: report.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                report.status.icon,
                color: report.status.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.location,
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
            const SizedBox(width: 8),
            Text(
              DateFormatter.relativeTime(report.date),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ANALYTICS SECTION (NEW) ====================
  /// 🎨 NEW: Weekly Report Chart using WeeklyReportChart widget
  Widget _buildAnalyticsSection({required List<dynamic> reports, required List<dynamic> requests}) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Convert dynamic list to List<Report>
    final reportList = reports.whereType<Report>().toList();

    return DashboardSection(
      title: 'Riwayat Laporan Mingguan',
      subtitle: '7 hari terakhir',
      child: Column(
        children: [
          WeeklyReportChart(
            reports: reportList,
            isDesktop: isDesktop,
          ),
          const SizedBox(height: 16),
          const WeeklyReportChartLegend(),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authActionsProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }
}

// ==================== OFFLINE BANNER BODY ====================
/// Widget wrapper yang menampilkan banner offline di atas body
class _OfflineBannerBody extends ConsumerWidget {
  final Widget child;

  const _OfflineBannerBody({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Import connectivity provider
    final isConnected = ref.watch(
      connectivityProvider,
    );

    return Column(
      children: [
        // Offline Banner
        if (!isConnected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Anda sedang offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        // Main content
        Expanded(child: child),
      ],
    );
  }
}
