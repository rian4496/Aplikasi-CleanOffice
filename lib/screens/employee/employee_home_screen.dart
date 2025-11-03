// lib/screens/employee/employee_home_screen.dart
// 🏠 Employee Home Screen - UPDATED: Clean dashboard only
// Search, sort, filter moved to All Reports Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../widgets/shared/request_overview_widget.dart';
import '../../widgets/shared/recent_requests_widget.dart';
import '../../widgets/shared/custom_speed_dial.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

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
      backgroundColor: Colors.grey[50],
      
      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,      
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          // Hamburger Menu (Right Side)
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),  
        ],
      ),

      // ==================== DRAWER ====================
      endDrawer: Drawer(
        child: DrawerMenuWidget(
          menuItems: [
            DrawerMenuItem(
              icon: Icons.home,
              title: 'Beranda',
              onTap: () => Navigator.pop(context),
            ),
            DrawerMenuItem(
              icon: Icons.history,
              title: 'Riwayat Laporan',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/all_reports');
              },
            ),
            DrawerMenuItem(
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            DrawerMenuItem(
              icon: Icons.settings,
              title: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          onLogout: () => _handleLogout(),
        ),
      ),

      // ==================== BODY ====================
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh by invalidating the provider
          ref.invalidate(employeeReportsProvider);
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: reportsAsync.when(
          // Loading State
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          
          // Error State
          error: (error, stack) => ErrorEmptyState(
            title: 'Terjadi kesalahan',
            subtitle: error.toString(),
            onRetry: () => ref.invalidate(employeeReportsProvider),
          ),
          
          // Success State
          data: (reports) {
            return CustomScrollView(
              slivers: [
                // ==================== HEADER WITH GREETING ====================
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // ==================== STATS CARDS ====================
                SliverToBoxAdapter(
                  child: _buildStatsCards(summary),
                ),

                // ==================== REQUEST OVERVIEW ====================
                SliverToBoxAdapter(
                  child: RequestOverviewWidget(reports: reports),
                ),

                // ==================== RECENT REQUESTS ====================
                SliverToBoxAdapter(
                  child: RecentRequestsWidget(
                    reports: reports,
                    onViewAll: () => Navigator.pushNamed(context, '/all_reports'),
                  ),
                ),

                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        ),
      ),

      // ==================== SPEED DIAL FAB ====================
      floatingActionButton: _buildSpeedDial(),
    );
  }

  // ==================== HEADER WITH GREETING ====================
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
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
          Text(
            user?.displayName ?? 'Budi',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
  Widget _buildStatsCards(EmployeeReportsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Terkirim (Pending)
          Expanded(
            child: _buildStatCard(
              icon: Icons.send,
              label: 'Terkirim',
              value: summary.pending,
              color: Colors.orange,
              iconColor: Colors.orange[700]!,
            ),
          ),
          const SizedBox(width: 12),

          // Dikerjakan (In Progress)
          Expanded(
            child: _buildStatCard(
              icon: Icons.autorenew,
              label: 'Dikerjakan',
              value: summary.inProgress,
              color: Colors.blue,
              iconColor: Colors.blue[700]!,
            ),
          ),
          const SizedBox(width: 12),

          // Selesai (Completed)
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle,
              label: 'Selesai',
              value: summary.completed,
              color: Colors.green,
              iconColor: Colors.green[700]!,
            ),
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
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with circle background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== SPEED DIAL ====================
  Widget _buildSpeedDial() {
    final pendingReports = ref.watch(employeeReportsByStatusProvider(ReportStatus.pending));
    
    return CustomSpeedDial(
      mainButtonColor: AppTheme.primary,
      actions: [
        // Semua Laporan (Ungu/Purple)
        SpeedDialAction(
          icon: Icons.view_list,
          label: 'Semua Laporan',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.pushNamed(context, '/all_reports'),
        ),
        
        // Pending (Orange)
        SpeedDialAction(
          icon: Icons.schedule,
          label: 'Pending${pendingReports.isNotEmpty ? ' (${pendingReports.length})' : ''}',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.pushNamed(
            context,
            '/all_reports',
            arguments: {'filterStatus': ReportStatus.pending},
          ),
        ),
        
        // Minta Layanan (Hijau/Green)
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Minta Layanan',
          backgroundColor: SpeedDialColors.green,
          onTap: () {
            Navigator.pushNamed(context, '/create_request');
          },
        ),
        
        // Buat Laporan (Biru/Blue)
        SpeedDialAction(
          icon: Icons.add,
          label: 'Buat Laporan',
          backgroundColor: SpeedDialColors.blue,
          onTap: () => Navigator.pushNamed(context, '/create_report'),
        ),
      ],
    );
  }

  // ==================== LOGOUT ====================
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
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
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal keluar: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}