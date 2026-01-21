// lib/screens/employee/employee_home_screen.dart
// 🏠 Employee Dashboard - Admin-style design (Refactored)
// Matches AdminDashboardMobileScreen style

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/employee_providers.dart';
import '../../riverpod/notification_providers.dart'; 
import '../../riverpod/connectivity_provider.dart';

import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/notification_bell.dart'; 
import '../../widgets/admin/charts/weekly_report_chart.dart'; // Reusing charts if available

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    // Data Providers
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summaryAsync = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,
      
      // ==================== APP BAR ====================
      appBar: _buildAppBar(context),

      // ==================== END DRAWER ====================
      endDrawer: Drawer(child: _buildDrawer()),

      // ==================== BODY ====================
      body: _OfflineBannerBody(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeeReportsProvider);
            // ref.invalidate(employeeReportsSummaryProvider); // If available
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Stats Cards
              SliverToBoxAdapter(child: _buildStats(summaryAsync)),

              // Quick Actions (Employee Specific)
              SliverToBoxAdapter(child: _buildQuickActions()),

              // Recent Activities (Reports)
              SliverToBoxAdapter(child: _buildRecentActivities(reportsAsync)),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      // ==================== BOTTOM NAV ====================
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
        // Notification Icon using common widget or custom logic
        const NotificationBell(iconColor: Colors.white), 
        
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        const SizedBox(width: 8),
      ],
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
                            '$greeting, ${profile?.displayName ?? 'Karyawan'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => const Text(
                            'Selamat Pagi...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          error: (e, _) => const Text(
                            'Selamat Pagi',
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
  Widget _buildStats(EmployeeReportsSummary summary) {
    // Determine verification/assigned count if tracked
    // For now we just use the summary object fields

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Card 1: Terkirim (Pending)
          Expanded(
            child: _buildStatCard(
              icon: Icons.send_rounded,
              label: 'Terkirim',
              count: summary.pending,
              bgColor: const Color(0xFFFFF7ED), // Orange 50
              iconColor: const Color(0xFFF97316), // Orange 500
            ),
          ),
          const SizedBox(width: 8),
          // Card 2: Dikerjakan (In Progress)
          Expanded(
            child: _buildStatCard(
              icon: Icons.autorenew_rounded,
              label: 'Proses',
              count: summary.inProgress,
              bgColor: const Color(0xFFEFF6FF), // Blue 50
              iconColor: const Color(0xFF3B82F6), // Blue 500
            ),
          ),
          const SizedBox(width: 8),
          // Card 3: Selesai
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_rounded,
              label: 'Selesai',
              count: summary.completed,
              bgColor: const Color(0xFFF0FDF4), // Green 50
              iconColor: const Color(0xFF22C55E), // Green 500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
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
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard(
                icon: Icons.add_circle_outline,
                label: 'Buat Laporan',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/create_report'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                icon: Icons.room_service_outlined,
                label: 'Minta Layanan', // Request Stock/Service
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/create_request'),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT ACTIVITIES ====================
  Widget _buildRecentActivities(AsyncValue<List<Report>> reportsAsync) {
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
                'Laporan Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                 onPressed: () => Navigator.pushNamed(context, '/all_reports'),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return _buildEmptyState();
              }
              // Show top 5 reports
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Belum ada laporan',
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

  Widget _buildActivityItem(Report report) {
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
                
                // Location row
                if (report.location.isNotEmpty)
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
                // Date row
                Text(
                  DateFormatter.relativeTime(report.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Labels Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status Badge
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
               // Category Badge
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
  Widget _buildDrawer() {
    return DrawerMenuWidget(
      roleTitle: 'Karyawan',
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard_outlined,
          title: 'Beranda',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.person_outline,
          title: 'Profil',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/profile');
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
    );
  }

  Future<void> _handleLogout() async {
    // Show dialog confirmation
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

    if (confirmed == true) {
      await ref.read(authActionsProvider.notifier).logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
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
              _buildNavItem(Icons.home_rounded, 'Beranda', true, () {}),
              _buildNavItem(Icons.assignment_rounded, 'Laporan', false, () => Navigator.pushNamed(context, '/all_reports')),
               // Chat or Support
              _buildNavItem(Icons.chat_bubble_rounded, 'Chat', false, () => Navigator.pushNamed(context, '/chat')),
              _buildNavItem(Icons.more_horiz_rounded, 'Lainnya', false, () => Navigator.pushNamed(context, '/employee/quick-menu')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    final color = isActive ? AppTheme.headerGradientStart : Colors.grey[600]!;
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
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
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
                Text('Anda sedang offline', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
