// lib/screens/admin/admin_dashboard_screen_responsive.dart
// ✅ MULTI-PLATFORM: Responsive Admin Dashboard (Mobile + Desktop/Web)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';

import '../../providers/riverpod/admin_providers.dart' hide currentUserProfileProvider;
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/notification_providers.dart';
import '../../providers/riverpod/request_providers.dart';

import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/custom_speed_dial.dart';
import '../../widgets/admin/admin_overview_widget.dart';
import '../../widgets/admin/recent_activities_widget.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../widgets/admin/admin_sidebar.dart';

// Feature A: Real-time Updates
import '../../services/realtime_service.dart';
import '../../widgets/admin/realtime_indicator_widget.dart';

// Feature B: Advanced Filtering
import '../../widgets/admin/advanced_filter_dialog.dart';

import './all_reports_management_screen.dart';
import './all_requests_management_screen.dart';
import './cleaner_management_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    
    // Feature A: Start real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(realtimeServiceProvider).startAutoRefresh(
        interval: const Duration(seconds: 30), // 30s interval
      );
    });
  }

  @override
  void dispose() {
    // Stop real-time updates
    ref.read(realtimeServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,
      
      // ==================== APP BAR ====================
      appBar: _buildAppBar(context),

      // ==================== SIDEBAR (Desktop Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer()) : null,
      endDrawer: !isDesktop ? Drawer(child: _buildMobileDrawer()) : null,

      // ==================== BODY ====================
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),

      // ==================== SPEED DIAL (Mobile/Tablet Only) ====================
      floatingActionButton: isMobile ? _buildSpeedDial() : null,
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
      leading: !isDesktop
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          : null,
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
        // Feature B: Filter button
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const AdvancedFilterDialog(),
          ),
          tooltip: 'Advanced Filters',
        ),
        _buildNotificationIcon(),
        if (!isDesktop)
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        // Profile Avatar untuk Desktop
        if (isDesktop) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
        const SizedBox(width: 16),
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
        
        // Main Content
        Expanded(
          child: _buildDesktopContent(),
        ),
      ],
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

                  // Right Column (30%) - Recent Reports
                  Expanded(
                    flex: 30,
                    child: _buildRecentReports(allReportsAsync),
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
    final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final cleanersAsync = ref.watch(availableCleanersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Stats Cards (2x2 Grid)
          SliverToBoxAdapter(
            child: _buildMobileStats(
              needsVerificationAsync,
              allRequestsAsync,
              cleanersAsync,
            ),
          ),

          // Overview + Recent Activities + Analytics
          SliverToBoxAdapter(
            child: needsVerificationAsync.when(
              data: (reports) {
                return allRequestsAsync.when(
                  data: (requests) {
                    return cleanersAsync.when(
                      data: (cleaners) {
                        return Column(
                          children: [
                            // Overview
                            AdminOverviewWidget(
                              reports: reports,
                              requests: requests,
                              totalCleaners: cleaners.length,
                            ),
                            
                            // Analytics
                            _buildAnalyticsSection(reports: reports, requests: requests),
                            
                            // Recent Activities
                            RecentActivitiesWidget(
                              reports: reports,
                              requests: requests,
                              onViewAll: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllReportsManagementScreen(),
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
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: isDesktop
            ? null
            : const BorderRadius.only(
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
              profile?.displayName ?? user?.displayName ?? 'Administrator',
              style: TextStyle(
                fontSize: ResponsiveHelper.headingFontSize(context),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            loading: () => const Text(
              'Administrator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            error: (e, _) => const Text(
              'Administrator',
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

  // ==================== MOBILE STATS (REFINED) ====================
  Widget _buildMobileStats(
    AsyncValue needsVerificationAsync,
    AsyncValue allRequestsAsync,
    AsyncValue cleanersAsync,
  ) {
    return needsVerificationAsync.when(
      data: (reports) {
        final verificationCount = reports.where((r) =>
          r.status.name == 'needsVerification'
        ).length;
        final pendingCount = reports.where((r) =>
          r.status.name == 'pending'
        ).length;
        final requestsCount = allRequestsAsync.asData?.value.length ?? 0;
        final cleanersCount = cleanersAsync.asData?.value.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.description_outlined,
                      color: AppTheme.primary,
                      label: 'Laporan Masuk',
                      value: verificationCount.toString(),
                      onTap: () => _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions_outlined,
                      color: AppTheme.warning,
                      label: 'Pending',
                      value: pendingCount.toString(),
                      onTap: () => _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.room_service_outlined,
                      color: AppTheme.info,
                      label: 'Total Permintaan',
                      value: requestsCount.toString(),
                      onTap: () => _navigateToScreen(const AllRequestsManagementScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people_outline,
                      color: AppTheme.success,
                      label: 'Petugas Aktif',
                      value: cleanersCount.toString(),
                      onTap: () => _navigateToScreen(const CleanerManagementScreen()),
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
          icon: Icons.assignment_outlined,
          title: 'Kelola Laporan',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllReportsManagementScreen(),
              ),
            );
          },
        ),
        DrawerMenuItem(
          icon: Icons.room_service_outlined,
          title: 'Kelola Permintaan',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllRequestsManagementScreen(),
              ),
            );
          },
        ),
        DrawerMenuItem(
          icon: Icons.people_outline,
          title: 'Kelola Petugas',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CleanerManagementScreen(),
              ),
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
      roleTitle: 'Administrator',
    );
  }

  // ==================== SPEED DIAL ====================
  Widget _buildSpeedDial() {
    return CustomSpeedDial(
      mainButtonColor: AppTheme.primary,
      actions: [
        SpeedDialAction(
          icon: Icons.verified_user,
          label: 'Verifikasi',
          backgroundColor: SpeedDialColors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllReportsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.assignment,
          label: 'Kelola Laporan',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllReportsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Kelola Permintaan',
          backgroundColor: SpeedDialColors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllRequestsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.people,
          label: 'Kelola Petugas',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CleanerManagementScreen(),
            ),
          ),
        ),
      ],
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

  /// Modern Stats Cards (2x2 Grid) - Cleaning Management Stats
  Widget _buildModernStats(AsyncValue allReportsAsync) {
    return allReportsAsync.when(
      data: (reports) {
        final totalReports = reports.length;
        final completedReports = reports.where((r) =>
          r.status.name == 'completed' || r.status.name == 'verified'
        ).length;
        final pendingReports = reports.where((r) =>
          r.status.name == 'pending' || r.status.name == 'needsVerification'
        ).length;
        final requestsCount = ref.watch(allRequestsProvider).asData?.value.length ?? 0;

        // Calculate completion rate & percentages
        final completionRate = totalReports > 0
          ? ((completedReports / totalReports) * 100).toInt()
          : 0;

        final pendingPercentage = totalReports > 0
          ? ((pendingReports / totalReports) * 100).clamp(0, 100).toInt()
          : 0;

        final requestsPercentage = requestsCount > 0
          ? ((requestsCount / (requestsCount + 10)) * 100).clamp(0, 100).toInt()
          : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // First Row
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      label: 'Total Laporan',
                      sublabel: 'Hari Ini',
                      value: totalReports.toString(),
                      percentage: completionRate,
                      color: AppTheme.blueAccent,
                      onTap: () => _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernStatCard(
                      label: 'Perlu Verifikasi',
                      sublabel: 'Minggu Ini',
                      value: pendingReports.toString(),
                      percentage: pendingPercentage,
                      color: AppTheme.orangeAccent,
                      onTap: () => _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Second Row
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      label: 'Permintaan Aktif',
                      sublabel: 'Bulan Ini',
                      value: requestsCount.toString(),
                      percentage: requestsPercentage,
                      color: AppTheme.greenAccent,
                      onTap: () => _navigateToScreen(const AllRequestsManagementScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernStatCard(
                      label: 'Tingkat Penyelesaian',
                      sublabel: 'Performance',
                      value: '$completionRate%',
                      percentage: completionRate,
                      color: AppTheme.purpleAccent,
                      onTap: () => _navigateToScreen(const CleanerManagementScreen()),
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
  }

  // ==================== STAT CARD (REFINED) ====================
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Stat Card dengan Progress Bar (Design Referensi)
  Widget _buildModernStatCard({
    required String label,
    required String sublabel,
    required String value,
    required int percentage,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Label + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Value (Large Number)
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Progress Bar + Percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
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
  Widget _buildAnalyticsSection({required List<dynamic> reports, required List<dynamic> requests}) {
    // 1. Calculate report status counts
    final statusCounts = <String, int>{
      'Pending': 0,
      'In Progress': 0,
      'Completed': 0,
    };

    for (var report in reports) {
      final status = report.status.name;
      if (status == 'pending' || status == 'needsVerification') {
        statusCounts['Pending'] = (statusCounts['Pending'] ?? 0) + 1;
      } else if (status == 'inProgress' || status == 'assigned') {
        statusCounts['In Progress'] = (statusCounts['In Progress'] ?? 0) + 1;
      } else if (status == 'completed' || status == 'verified') {
        statusCounts['Completed'] = (statusCounts['Completed'] ?? 0) + 1;
      }
    }

    // 2. Create bar chart data
    final barGroups = <BarChartGroupData>[
      _makeGroupData(0, statusCounts['Pending']?.toDouble() ?? 0, AppTheme.warning),
      _makeGroupData(1, statusCounts['In Progress']?.toDouble() ?? 0, AppTheme.info),
      _makeGroupData(2, statusCounts['Completed']?.toDouble() ?? 0, AppTheme.success),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (statusCounts.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(), // Add 20% buffer
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Pending';
                            break;
                          case 1:
                            text = 'Progress';
                            break;
                          case 2:
                            text = 'Done';
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                      },
                      reservedSize: 38,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
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
      await FirebaseAuth.instance.signOut();
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
