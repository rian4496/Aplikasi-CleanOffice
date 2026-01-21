// lib/screens/employee/employee_home_screen_enhanced.dart
// 🏠 Employee Dashboard - CLONED from platforms/mobile/admin/admin_dashboard_mobile_screen.dart
// Confirmed to be the "True" Admin Mobile View (Solid Blue Header, Quick Actions, 2x2 Stats)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

// Employee Providers
import '../../riverpod/employee_providers.dart'; // For real data
import '../../riverpod/auth_providers.dart';
import '../../riverpod/notification_providers.dart';

// Shared
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/dashboard_stat_card.dart';
import '../../widgets/web_admin/charts/ticket_trend_chart.dart';

// Screens for Quick Actions (Adapted for Employee)
import '../inventory/inventory_request_form_screen.dart'; // For Request Stok

class EmployeeHomeScreenEnhanced extends ConsumerStatefulWidget {
  const EmployeeHomeScreenEnhanced({super.key});

  @override
  ConsumerState<EmployeeHomeScreenEnhanced> createState() =>
      _EmployeeHomeScreenEnhancedState();
}

class _EmployeeHomeScreenEnhancedState extends ConsumerState<EmployeeHomeScreenEnhanced> {
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
      resizeToAvoidBottomInset: false, 
      backgroundColor: Colors.white,
      
      endDrawer: Drawer(child: _buildDrawer()),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeeReportsProvider);
            ref.invalidate(employeeReportsSummaryProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Search Box (Admin has it, so we keep it)
              SliverToBoxAdapter(
                child: _buildSearchBox(),
              ),

              // Stats Cards (Grid 2x2)
              SliverToBoxAdapter(
                child: _buildStatsGrid(summaryAsync),
              ),

              // Quick Actions Row (Adapted)
              SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: _buildQuickActions(context),
                 ),
              ),

              // Ticket Trend Chart
              SliverToBoxAdapter(
                child: _buildChartsSection(reportsAsync),
              ),

              // Recent Activities Section
              SliverToBoxAdapter(
                child: _buildRecentActivities(reportsAsync),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER (BLUE CARD & ICONS) ====================
  Widget _buildHeader() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();
    final today = DateFormatter.fullDate(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Row 1: Top Icons (Notification & Menu) - Outside Blue Card
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildNotificationIcon(isDark: true), // Dark icon for white bg
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 24),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Row 2: Blue Greeting Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF155BBC), // Solid Blue
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF155BBC).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting + ',',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      userProfileAsync.when(
                        data: (user) => Text(
                          user?.displayName ?? 'Karyawan',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => const Text('Loading...', style: TextStyle(color: Colors.white)),
                        error: (e, _) => const Text('Karyawan', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2), 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              today,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Vector Image
                SizedBox(
                  height: 100,
                  width: 90, 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       Image.asset(
                        'assets/images/vector_greeting.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_,__,___) => const Icon(Icons.person, size: 60, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon({bool isDark = false}) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final iconColor = isDark ? AppTheme.textPrimary : Colors.white;

    return InkWell(
      onTap: () => context.push('/admin/notifications'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
             Icon(Icons.notifications_outlined, color: iconColor, size: 24),
            unreadCountAsync.when(
              data: (count) {
                if (count > 0) {
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
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
        ),
      ),
    );
  }

  // ==================== SEARCH BOX ====================
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari laporan...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATS GRID (2x2) ====================
  Widget _buildStatsGrid(EmployeeReportsSummary summary) {
    // Mapping Employee Data to Admin Grid Layout
    final todayCount = summary.pending; // Placeholder: "Pending Today"
    final weekCount = summary.total; // Placeholder: Total
    final monthCount = summary.completed; // Placeholder: Completed
    final urgentCount = summary.urgent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: DashboardStatCard(
                icon: Icons.assignment_rounded,
                label: 'Total Laporan',
                value: summary.total.toString(),
                bgColor: StatCardColors.blueBg,
                iconColor: StatCardColors.blueIcon,
              )),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Menunggu',
                value: summary.pending.toString(),
                bgColor: StatCardColors.yellowBg,
                iconColor: StatCardColors.yellowIcon,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: DashboardStatCard(
                icon: Icons.check_circle_rounded,
                label: 'Selesai',
                value: summary.completed.toString(),
                bgColor: StatCardColors.greenBg,
                iconColor: StatCardColors.greenIcon,
              )),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Urgent',
                value: summary.urgent.toString(),
                bgColor: StatCardColors.redBg,
                iconColor: StatCardColors.redIcon,
                showBadge: summary.urgent > 0,
                badgeText: 'Priority',
              )),
            ],
          ),
        ],
      ),
    );
  }

  // _buildStatCard removed - now using DashboardStatCard widget

  // ==================== QUICK ACTIONS (ADAPTED) ====================
  Widget _buildQuickActions(BuildContext context) {
    // Map to Employee-relevant actions
    final actions = [
      _QuickActionData(
        title: 'Kerusakan',
        icon: Icons.build_circle_outlined, 
        color: Colors.black, 
        onTap: () => context.go('/admin/helpdesk/kerusakan'), // Reuse routes if valid or push new
      ),
      _QuickActionData(
        title: 'Kebersihan',
        icon: Icons.cleaning_services_outlined, 
        color: Colors.black,
        onTap: () => context.go('/admin/helpdesk/kebersihan'), 
      ),
      _QuickActionData(
        title: 'Req Stok',
        icon: Icons.inventory_2_outlined, 
        color: Colors.black,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventoryRequestFormScreen()),
        ),
      ),
      _QuickActionData(
        title: 'Riwayat',
        icon: Icons.history_rounded, 
        color: Colors.black,
        onTap: () => context.push('/request_history'),
      ),
      _QuickActionData(
        title: 'Lainnya',
        icon: Icons.grid_view_rounded,
        color: Colors.black,
        onTap: () => context.push('/admin/quick-menu'),
      ),
    ];

    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions.map((action) => _buildQuickActionItem(action)).toList(),
      ),
    );
  }

  // _showQuickMenu removed as it is replaced by EmployeeQuickMenuScreen

  Widget _buildQuickActionItem(_QuickActionData action) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(50), 
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey.shade300), 
            ),
            child: Icon(action.icon, color: action.color, size: 26), 
          ),
        ),
        const SizedBox(height: 8),
        Text(
          action.title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ==================== CHARTS SECTION ====================
  // ==================== CHARTS SECTION ====================
  Widget _buildChartsSection(AsyncValue reportsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      clipBehavior: Clip.hardEdge, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tren Laporan Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '7 hari terakhir',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              // Arrow similar to Admin
              IconButton(
                onPressed: () {
                   // Optional: Navigate to full history or analytics
                },
                icon: const Icon(Icons.show_chart_rounded, color: AppTheme.primary),
                tooltip: 'Lihat Detail',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          reportsAsync.when(
            data: (reports) {
              // Calculate trends for the last 7 days
              final trends = _calculateTrendData(reports as List);
              
              if (reports.isEmpty) {
                 // Empty state that keeps the chart space but empty
                 return const SizedBox(
                    height: 200, 
                    child: Center(child: Text("Belum ada data grafik", style: TextStyle(color: Colors.grey)))
                 );
              }

              return TicketTrendChart(
                trendKerusakan: trends['kerusakan']!,
                trendKebersihan: trends['kebersihan']!,
                trendStok: trends['stok']!,
                isMobile: true,
                useWrapper: false, // Wrapper handled by this container
              );
            },
            loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            error: (_,__) => const SizedBox(height: 200, child: Center(child: Text("Gagal memuat grafik"))),
          ),
        ],
      ),
    );
  }

  Map<String, List<double>> _calculateTrendData(List reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Initialize lists for 7 days (6 days ago to today)
    List<double> kerusakan = List.filled(7, 0.0);
    List<double> kebersihan = List.filled(7, 0.0);
    List<double> stok = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: 6 - i));
        
        // Filter reports for this date
        final dailyReports = reports.where((r) {
            // Need to cast if dynamic, but List<Report> is expected
            // date getter is DateTime
            final rDate = r.date; 
            return rDate.year == date.year && 
                   rDate.month == date.month && 
                   rDate.day == date.day;
        }).toList();

        // Count by category
        double countKerusakan = 0;
        double countKebersihan = 0;
        double countStok = 0;

        for (var r in dailyReports) {
            final titleLower = r.title.toString().toLowerCase();
            final descLower = (r.description ?? '').toLowerCase();
            
            // Check known category Logic
            if (titleLower.contains('kerusakan') || titleLower.contains('rusak') || descLower.contains('kerusakan')) {
                countKerusakan++;
            } else if (titleLower.contains('kebersihan') || titleLower.contains('sapu') || titleLower.contains('bersih')) {
                countKebersihan++;
            } else {
                // Determine 'stok' or others
                if (titleLower.contains('stok') || titleLower.contains('permintaan')) {
                   countStok++;
                } else {
                   // Fallback: put in kerusakan or separate? For now put in Kerusakan as default or ignore
                   countKerusakan++; 
                }
            }
        }
        
        kerusakan[i] = countKerusakan;
        kebersihan[i] = countKebersihan;
        stok[i] = countStok;
    }

    return {
        'kerusakan': kerusakan,
        'kebersihan': kebersihan,
        'stok': stok,
    };
  }

  // ==================== RECENT ACTIVITIES ====================
  Widget _buildRecentActivities(AsyncValue reportsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                 return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada laporan")));
              }
              final list = (reports as List).take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildActivityCard(list[i]),
              );
            },
            loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
            error: (e,__) => Text("Error: $e"),
          )
        ],
      ),
    );
  }

  Widget _buildActivityCard(dynamic report) {
    // Map Report model to UI
    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade700;
    
    // Status Logic
    final statusStr = report.status.label;
    if (statusStr == 'Selesai' || statusStr == 'Terverifikasi') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade700;
    } else if (statusStr == 'Ditolak') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade700;
    } else {
      statusBg = Colors.orange.shade50;
      statusText = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(color: statusText, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormatter.shortDate(report.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
             context.push('/admin/profile');
          },
        ),
      ],
      onLogout: () async {
        await ref.read(authActionsProvider.notifier).logout();
        if (mounted) context.go('/login');
      },
    );
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
