// lib/screens/employee/employee_home_screen.dart
// 🏠 Employee Dashboard - Admin-style design
// Sliced from admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../providers/riverpod/connectivity_provider.dart';

import '../../widgets/shared/notification_bell.dart';
import '../../widgets/shared/drawer_menu_widget.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR ====================
      appBar: _buildAppBar(),

      // ==================== END DRAWER ====================
      endDrawer: Drawer(child: _buildDrawer()),

      // ==================== BODY ====================
      body: _OfflineBannerBody(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeeReportsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Greeting Header
              SliverToBoxAdapter(child: _buildGreetingHeader()),

              // Stats Cards 2x2
              SliverToBoxAdapter(child: _buildStatsCards(summary)),

              // Quick Actions
              SliverToBoxAdapter(child: _buildQuickActions()),

              // Recent Reports
              SliverToBoxAdapter(child: _buildRecentReports(reportsAsync)),

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
  AppBar _buildAppBar() {
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
        const NotificationBell(iconColor: Colors.white),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer() {
    return DrawerMenuWidget(
      roleTitle: 'Karyawan',
      menuItems: [
        DrawerMenuItem(
          icon: Icons.home_outlined,
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

  // ==================== GREETING HEADER ====================
  Widget _buildGreetingHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Selamat Pagi' : hour < 15 ? 'Selamat Siang' : hour < 18 ? 'Selamat Sore' : 'Selamat Malam';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                userProfileAsync.when(
                  data: (profile) => Text(
                    profile?.displayName ?? 'Karyawan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  loading: () => const Text('Memuat...', style: TextStyle(color: Colors.white)),
                  error: (_, __) => const Text('Karyawan', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.fullDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATS CARDS 2x2 ====================
  Widget _buildStatsCards(EmployeeReportsSummary summary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(
                icon: Icons.send,
                label: 'Terkirim',
                value: summary.pending,
                color: Colors.orange,
                bgColor: Colors.orange[50]!,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                icon: Icons.autorenew,
                label: 'Dikerjakan',
                value: summary.inProgress,
                color: Colors.blue,
                bgColor: Colors.blue[50]!,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Selesai',
                value: summary.completed,
                color: Colors.green,
                bgColor: Colors.green[50]!,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                icon: Icons.room_service,
                label: 'Permintaan',
                value: 0, // TODO: Add request count
                color: Colors.purple,
                bgColor: Colors.purple[50]!,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard(
                icon: Icons.add_circle,
                label: 'Buat\nLaporan',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/create_report'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                icon: Icons.room_service,
                label: 'Minta\nLayanan',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/create_request'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                icon: Icons.article,
                label: 'Semua\nLaporan',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/all_reports'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                icon: Icons.history,
                label: 'Riwayat\nPermintaan',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/request_history'),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT REPORTS ====================
  Widget _buildRecentReports(AsyncValue<List<Report>> reportsAsync) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Laporan Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/all_reports'),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada laporan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: reports.take(3).map((report) => _buildReportItem(report)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(Report report) {
    Color statusColor = report.status == ReportStatus.inProgress ? Colors.orange :
                        report.status == ReportStatus.completed ? Colors.green : Colors.blue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.location ?? 'Lokasi tidak diketahui', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  report.description ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              report.status.name,
              style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV ====================
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
              _buildNavItem(Icons.home_rounded, 'Beranda', true, () {}),
              _buildNavItem(Icons.article_rounded, 'Laporan', false, () => Navigator.pushNamed(context, '/all_reports')),
              _buildNavItem(Icons.chat_bubble_rounded, 'Chat', false, () => Navigator.pushNamed(context, '/chat')),
              _buildNavItem(Icons.more_horiz_rounded, 'Lainnya', false, () => _scaffoldKey.currentState?.openEndDrawer()),
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
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  // ==================== LOGOUT ====================
  Future<void> _handleLogout() async {
    // Confirmation handled by DrawerMenuWidget
    await ref.read(authActionsProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
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
                Text('Anda sedang offline', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
