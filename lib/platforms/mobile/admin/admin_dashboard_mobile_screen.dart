// lib/platforms/mobile/admin/admin_dashboard_mobile_screen.dart
// 🏠 Admin Dashboard Mobile - True Admin Mobile View
// (Solid Blue Header, Quick Actions, 2x2 Stats)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

// Admin Providers
import '../../../riverpod/admin_providers.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/transaction_providers.dart';
import '../../../riverpod/notification_providers.dart';

// Shared
import '../../../widgets/shared/drawer_menu_widget.dart';
import '../../../widgets/shared/dashboard_stat_card.dart';
import '../../../widgets/web_admin/charts/ticket_trend_chart.dart';
import '../../../screens/web_admin/transactions/helpdesk/ticket_detail_dialog.dart';

class AdminDashboardMobileScreen extends ConsumerStatefulWidget {
  const AdminDashboardMobileScreen({super.key});

  @override
  ConsumerState<AdminDashboardMobileScreen> createState() =>
      _AdminDashboardMobileScreenState();
}

class _AdminDashboardMobileScreenState extends ConsumerState<AdminDashboardMobileScreen> {
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
    // Data Providers - Admin specific
    final dashboardAsync = ref.watch(adminDashboardDataProvider);
    // Warm up users map
    ref.watch(usersMapProvider);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false, 
      backgroundColor: Colors.white,
      
      endDrawer: Drawer(child: _buildDrawer()),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminDashboardDataProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Search Box
              SliverToBoxAdapter(
                child: _buildSearchBox(),
              ),

              // Stats Cards (Grid 2x2)
              SliverToBoxAdapter(
                child: _buildStatsGrid(dashboardAsync),
              ),

              // Quick Actions Row
              SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: _buildQuickActions(context),
                 ),
              ),

              // Ticket Trend Chart
              SliverToBoxAdapter(
                child: _buildChartsSection(dashboardAsync),
              ),

              // Recent Activities Section
              SliverToBoxAdapter(
                child: _buildRecentActivities(dashboardAsync),
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


          // Row 2: Blue Greeting Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF155BBC), // Solid Blue
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF155BBC).withOpacity(0.3),
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
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      userProfileAsync.when(
                        data: (user) => Text(
                          user?.displayName ?? 'Admin',
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
                        error: (e, _) => const Text('Admin', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), 
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
              color: Colors.black.withOpacity(0.05),
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
                  hintText: 'Cari aset, anggaran, pegawai...',
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
  Widget _buildStatsGrid(AsyncValue<Map<String, dynamic>> dashboardAsync) {
    return dashboardAsync.when(
      data: (data) {
        final todayTickets = data['ticketsToday'] ?? 0;
        final weekTickets = data['ticketsThisWeek'] ?? 0;
        final monthTickets = data['ticketsThisMonth'] ?? 0;
        final openTickets = data['ticketsOpen'] ?? 0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: DashboardStatCard(
                  icon: Icons.today_rounded,
                  label: 'Tiket Hari Ini',
                  value: todayTickets.toString(),
                  bgColor: StatCardColors.blueBg,
                  iconColor: StatCardColors.blueIcon,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: DashboardStatCard(
                  icon: Icons.date_range_rounded,
                  label: 'Minggu Ini',
                  value: weekTickets.toString(),
                  bgColor: StatCardColors.purpleBg,
                  iconColor: StatCardColors.purpleIcon,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: DashboardStatCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Bulan Ini',
                  value: monthTickets.toString(),
                  bgColor: StatCardColors.greenBg,
                  iconColor: StatCardColors.greenIcon,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: DashboardStatCard(
                  icon: Icons.assignment_late_rounded,
                  label: 'Tiket Open',
                  value: openTickets.toString(),
                  bgColor: StatCardColors.redBg,
                  iconColor: StatCardColors.redIcon,
                  showBadge: openTickets > 0,
                  badgeText: 'Perlu Tindakan',
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: 'Pengadaan',
        icon: Icons.shopping_cart_outlined, 
        color: Colors.black, 
        onTap: () => context.go('/admin/procurement'),
      ),
      _QuickActionData(
        title: 'Anggaran',
        icon: Icons.monetization_on_outlined, 
        color: Colors.black,
        onTap: () => context.go('/admin/master/anggaran'), 
      ),
      _QuickActionData(
        title: 'Peminjaman',
        icon: Icons.assignment_return_outlined, 
        color: Colors.black,
        onTap: () => context.go('/admin/loans'),
      ),
      _QuickActionData(
        title: 'Helpdesk',
        icon: Icons.support_agent, 
        color: Colors.black,
        onTap: () => context.go('/admin/helpdesk'),
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
  Widget _buildChartsSection(AsyncValue<Map<String, dynamic>> dashboardAsync) {
    return dashboardAsync.when(
      data: (data) {
        // Extract trend data from provider (or use fallback empty)
        final trendKerusakan = (data['trendKerusakan'] as List?)?.cast<double>() ?? <double>[];
        final trendKebersihan = (data['trendKebersihan'] as List?)?.cast<double>() ?? <double>[];
        final trendStok = (data['trendStok'] as List?)?.cast<double>() ?? <double>[];
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
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
                        'Tren Tiket Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '7 hari terakhir',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push('/admin/analytics/tickets'),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
                    tooltip: 'Lihat Detail',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Chart using REAL DATA from provider
              TicketTrendChart(
                trendKerusakan: trendKerusakan,
                trendKebersihan: trendKebersihan,
                trendStok: trendStok,
                isMobile: true,
                useWrapper: true,
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  // ==================== RECENT ACTIVITIES ====================
  Widget _buildRecentActivities(AsyncValue<Map<String, dynamic>> dashboardAsync) {
    return dashboardAsync.when(
      data: (data) {
        final activitiesRaw = data['recentActivities'] as List<dynamic>? ?? [];
        
        // Filter out generic 'Notifikasi' or 'General' items as requested by user
        final activities = activitiesRaw.where((activity) {
          final type = (activity['type'] as String? ?? '').toLowerCase();
          final category = (activity['category'] as String? ?? '').toLowerCase();
          return type != 'general' && !category.contains('notifikasi') && !category.contains('general');
        }).toList();
        
        // Use REAL data only - no dummy fallback

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push('/admin/activities'),
                    icon: Icon(Icons.arrow_forward_rounded, color: Colors.grey[400], size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Lihat Semua',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityCard(ref, activity);
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildActivityCard(WidgetRef ref, dynamic activity) {
    final id = activity['id'] as String?;
    final ticketId = activity['ticketId'] as String?;
    final type = activity['type'] as String? ?? 'general';
    final isRead = activity['isRead'] as bool? ?? true; 
    
    // Correct Data Mapping from Provider
    final formalTitle = activity['title'] as String? ?? 'Aktivitas Baru';
    final issueTitle = activity['subtitle'] as String? ?? '';
    final locationName = activity['location'] as String? ?? '-';
    final userName = activity['user'] as String? ?? 'User';
    final dateStr = activity['date']?.toString() ?? '';
    
    final category = activity['category'] as String? ?? type;

    // Determine colors and icon
    Color typeColor;
    IconData typeIcon;
    
    final lowerCat = category.toLowerCase();
    
    if (lowerCat.contains('kerusakan') || lowerCat.contains('repair')) {
      typeColor = Colors.red.shade600; 
      typeIcon = Icons.build_circle_outlined;
    } else if (lowerCat.contains('kebersihan') || lowerCat.contains('cleaning')) {
      typeColor = Colors.green.shade600; 
      typeIcon = Icons.cleaning_services_outlined;
    } else if (lowerCat.contains('stok') || lowerCat.contains('inventory')) {
      typeColor = Colors.amber.shade700; 
      typeIcon = Icons.inventory_2_outlined;
    } else if (lowerCat.contains('pengadaan') || type == 'procurement') {
      typeColor = Colors.blue.shade600; 
      typeIcon = Icons.shopping_cart_outlined;
    } else {
      typeColor = Colors.blue.shade600;
      typeIcon = Icons.notifications_none_rounded;
    }

    final isValidUuid = id != null && 
        RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id);

    // Extract Status
    final status = activity['status'] as String? ?? 'open';
    

    // Parse Title to separate Ticket Code
    String displayTitle = formalTitle;
    String ticketCode = '';
    if (formalTitle.contains('#')) {
      final parts = formalTitle.split('#');
      displayTitle = parts[0].trim();
      if (parts.length > 1) {
        ticketCode = '#${parts[1].trim()}';
      }
    }

    // Determine Status Colors
    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade700;
    String statusLabel = 'Pending'; // Default

    switch (status.toLowerCase()) {
      case 'open':
      case 'pending':
      case 'submitted':
        statusBg = Colors.amber.shade50;
        statusText = Colors.amber.shade700;
        statusLabel = 'Pending';
        break;
      case 'inprogress':
      case 'in_progress':
      case 'claimed':
        statusBg = Colors.blue.shade50;
        statusText = Colors.blue.shade700;
        statusLabel = 'In Progress';
        break;
      case 'completed':
      case 'done':
      case 'approved':
        statusBg = Colors.green.shade50;
        statusText = Colors.green.shade700;
        statusLabel = 'Completed';
        break;
      case 'rejected':
      case 'cancelled':
        statusBg = Colors.red.shade50;
        statusText = Colors.red.shade700;
        statusLabel = 'Rejected';
        break;
    }

    return InkWell(
      onTap: () {
        if (!isValidUuid) return;
        if (!isRead && id != null) {
          ref.read(markNotificationAsReadProvider(id));
        }

        if (ticketId != null) {
           showDialog(
            context: context,
            builder: (_) => TicketDetailDialog(ticketId: ticketId),
          );
        } else if (type == 'procurement') {
           context.go('/admin/procurement');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), 
              blurRadius: 12, 
              offset: const Offset(0, 4), 
            ),
            BoxShadow( 
              color: Colors.black.withOpacity(0.02), 
              blurRadius: 2, 
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Header (Title + Code + Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                    children: [
                       if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8, top: 6), // Align with text
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101828),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (ticketCode.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                ticketCode,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475467), // Cool Grey 600
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusBg.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Row 2: Category & Issue Title
            Row(
              children: [
                Icon(typeIcon, size: 14, color: typeColor),
                const SizedBox(width: 6),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text('•', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    issueTitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade900, fontWeight: FontWeight.w500),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12), // Spacer before footer

            // Row 3: Location | User
            Row(
              children: [
                 // Location
                 if (locationName != '-' && locationName.isNotEmpty) ...[
                    Icon(Icons.place_outlined, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 140), // Increased max width since date is gone
                      child: Text(
                        locationName,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                 ],

                 // User
                 Expanded(
                   child: Row(
                     children: [
                       Icon(Icons.person_outline, size: 12, color: Colors.grey.shade500),
                       const SizedBox(width: 4),
                       Expanded(
                         child: Text(
                           userName,
                           style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ),
            
            const SizedBox(height: 8),

            // Row 4: Date (Bottom Line, Below Location)
            Text(
               dateStr,
               style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return DrawerMenuWidget(
      roleTitle: 'Administrator',
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.inventory_2_outlined,
          title: 'Inventaris',
          onTap: () {
             Navigator.pop(context);
             context.go('/admin/inventory');
          },
        ),
        DrawerMenuItem(
          icon: Icons.category_outlined,
          title: 'Aset',
          onTap: () {
             Navigator.pop(context);
             context.go('/admin/assets');
          },
        ),
        DrawerMenuItem(
          icon: Icons.people_outlined,
          title: 'Pegawai',
          onTap: () {
             Navigator.pop(context);
             context.go('/admin/master/pegawai');
          },
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
