// lib/screens/web_admin/dashboard/admin_dashboard.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../widgets/web_admin/cards/compact_stat_card.dart';
import '../../../widgets/web_admin/lists/activities_section.dart';
import '../../../riverpod/admin_dashboard_provider.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../widgets/web_admin/charts/ticket_trend_chart.dart';
import '../../../widgets/web_admin/charts/dashboard_charts.dart'; // Keep if used for other charts, or remove if replacing
import '../../../models/ticket.dart'; // For TicketType popup

import '../../../riverpod/admin_dashboard_provider.dart'; // Ensure this is here
import '../../../platforms/mobile/admin/admin_dashboard_mobile_screen.dart'; // Import Mobile Screen
import '../transactions/helpdesk/ticket_detail_dialog.dart';

class AdminDashboardScreen extends HookConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mobile Check - Force Recompile
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    if (isMobile) {
      return const AdminDashboardMobileScreen();
    }
    
    final userAsync = ref.watch(currentUserProvider);
    final dashboardAsync = ref.watch(adminDashboardDataProvider);
    final recentActivitiesAsync = ref.watch(recentActivitiesProvider);
    final currentNavIndex = useState(0);

    return AdminLayoutWrapper(
      title: 'Dashboard', 
      // Title is handled by Layout, but we want custom branding in the header
      // The wrapper might need adjustment or we insert the branding here
      
      currentNavIndex: currentNavIndex.value,
      onNavigationChanged: (index) {
        currentNavIndex.value = index;
        // Navigation logic here
      },
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardDataProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Branding
              _buildBrandingHeader(context, userAsync),
              
              const SizedBox(height: 24),

              // 2. Compact Stat Cards (Grid of 4)
              dashboardAsync.when(
                data: (data) => _buildStatCards(context, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),

              const SizedBox(height: 24),

              // 3. Analytics & Activity Section (Split View on Desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  // If wide enough, show side-by-side
                  if (constraints.maxWidth > 900) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Same height
                        children: [
                          // Left: Charts (2/3 width)
                          Expanded(
                            flex: 2,
                            child: dashboardAsync.when(
                              data: (data) => _buildChartsSection(context, data),
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const SizedBox(),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right: Recent Activity (1/3 width)
                          Expanded(
                            flex: 1,
                            child: recentActivitiesAsync.when(
                              data: (activities) => _buildRecentActivity(context, activities),
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Mobile: Vertical Stack
                    return Column(
                      children: [
                        dashboardAsync.when(
                          data: (data) => _buildChartsSection(context, data),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                        const SizedBox(height: 24),
                        recentActivitiesAsync.when(
                          data: (activities) => _buildRecentActivity(context, activities),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context, AsyncValue userAsync) {
    // Determine greeting
    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    if (hour >= 11) greeting = 'Selamat Siang';
    if (hour >= 15) greeting = 'Selamat Sore';
    if (hour >= 19) greeting = 'Selamat Malam';

    return Container(
      clipBehavior: Clip.antiAlias, // Clip for background shapes
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Modern Wave Pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: HeaderWavePainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                 // Greeting Vector Image
                 Image.asset(
                   'assets/images/vector_greeting.png',
                   height: 120, // Adjust height as needed
                   fit: BoxFit.contain,
                 ),
                 const SizedBox(width: 24),
                 
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       userAsync.when(
                         data: (user) => Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               greeting,
                               style: TextStyle(
                                 color: Colors.white.withOpacity(0.9),
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               user?.displayName ?? "Admin",
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 28, // Prominent
                                 fontWeight: FontWeight.bold,
                                 letterSpacing: 0.5,
                               ),
                             ),
                           ],
                         ),
                         loading: () => const Text('Loading...', style: TextStyle(color: Colors.white70)),
                         error: (_, __) => const SizedBox(),
                       ),
                     ],
                   ),
                 ),
                  const SizedBox(width: 16),

                 // Date Display (Top Right)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.15),
                     borderRadius: BorderRadius.circular(30),
                     border: Border.all(color: Colors.white.withOpacity(0.2)),
                   ),
                   child: Text(
                     _formatIndonesianDate(DateTime.now()),
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, Map<String, dynamic> data) {
    // Responsive Grid
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (width > 600) crossAxisCount = 2; // Tablet
    if (width > 1200) crossAxisCount = 4; // Desktop

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6, // Rectangular aspect ratio for cards
      children: [
        CompactStatCard(
          title: 'Tiket Hari Ini',
          value: data['ticketsToday']?.toString() ?? '0',
          icon: Icons.today_rounded,
          iconColor: Colors.blue.shade600,
          progress: 0.0, 
        ),
         CompactStatCard(
          title: 'Tiket Minggu Ini',
          value: data['ticketsThisWeek']?.toString() ?? '0',
          icon: Icons.date_range_rounded,
          iconColor: Colors.indigo.shade600,
          progress: 0.0,
        ),
         CompactStatCard(
          title: 'Tiket Bulan Ini',
          value: data['ticketsThisMonth']?.toString() ?? '0',
          icon: Icons.calendar_month_rounded,
          iconColor: Colors.purple.shade600,
          progress: 0.0,
        ),
        CompactStatCard(
          title: 'Tiket Open',
          value: data['ticketsOpen']?.toString() ?? '0',
          icon: Icons.assignment_late_rounded,
          iconColor: Colors.red.shade600,
          progress: 0.0,
          trendValue: 'Perlu Ditindak', 
          trendUp: false,
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, Map<String, dynamic> data) {
      if (data['trendKerusakan'] == null) return const DashboardCharts();

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider.withOpacity(0.8), width: 1.2),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 2,
               offset: const Offset(0, 1)
             ),
             BoxShadow(
               color: Colors.black.withOpacity(0.08),
               blurRadius: 16, 
               offset: const Offset(0, 4)
             ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Tiket Masuk',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '7 hari terakhir',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => context.go('/admin/analytics/tickets'),
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
                  tooltip: 'Lihat Detail',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Nested Chart Card (The "Double Card" Effect)
            TicketTrendChart(
              trendKerusakan: (data['trendKerusakan'] as List).cast<double>(),
              trendKebersihan: (data['trendKebersihan'] as List).cast<double>(),
              trendStok: (data['trendStok'] as List).cast<double>(),
              // Default isMobile=false, useWrapper=true
            ),
          ],
        ),
      );
  }

  Widget _buildRecentActivity(BuildContext context, List<Map<String, dynamic>> activitiesRaw) {
    // Filter out generic 'Notifikasi' or 'General' items as requested by user
    final activities = activitiesRaw.where((activity) {
      final type = (activity['type'] as String? ?? '').toLowerCase();
      final category = (activity['category'] as String? ?? '').toLowerCase();
      return type != 'general' && !category.contains('notifikasi') && !category.contains('general');
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withOpacity(0.8), width: 1.2),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 2,
             offset: const Offset(0, 1)
           ),
           BoxShadow(
             color: Colors.black.withOpacity(0.08),
             blurRadius: 16, 
             offset: const Offset(0, 4)
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
                 children: [
                   Icon(Icons.receipt_long_rounded, size: 20, color: AppTheme.primary),
                   const SizedBox(width: 8),
                   const Text(
                     'Aktivitas Terbaru',
                     style: TextStyle(
                       fontSize: 16, 
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textPrimary
                     ),
                   ),
                 ],
               ),
               IconButton(
                 onPressed: () => context.go('/admin/activities'),
                 icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 18),
                 tooltip: 'Lihat Semua',
                 padding: EdgeInsets.zero,
                 constraints: const BoxConstraints(),
               ),
             ],
           ),
           const SizedBox(height: 12),
           
           const SizedBox(height: 12),
           
           // List items directly (natural height)
           // List items with scroll support
           if (activities.isEmpty)
              const Expanded(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada aktivitas"))))
           else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: activities.take(3).map((activity) {
                      return _buildActivityCard(context, activity);
                    }).toList(),
                  ),
                ),
              ),
         ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> activity) {
    final type = activity['type'] ?? 'other';
    final status = activity['status'] ?? 'open';
    final title = activity['title'] ?? '-';
    final subtitle = activity['subtitle'] ?? '-';
    final timestamp = activity['timestamp'] as DateTime? ?? DateTime.now();
    final isUrgent = activity['isUrgent'] == true;
    
    // Type display
    String typeLabel = 'Aktivitas';
    IconData typeIcon = Icons.assignment;
    Color typeColor = Colors.grey;
    
    if (type == 'kerusakan') {
      typeLabel = 'Kerusakan';
      typeIcon = Icons.build_circle;
      typeColor = Colors.red;
    } else if (type == 'kebersihan') {
      typeLabel = 'Kebersihan';
      typeIcon = Icons.cleaning_services;
      typeColor = Colors.green;
    } else if (type == 'stok') {
      typeLabel = 'Request Stok';
      typeIcon = Icons.inventory_2;
      typeColor = Colors.orange;
    } else if (type == 'procurement') {
      typeLabel = 'Pengadaan';
      typeIcon = Icons.shopping_cart;
      typeColor = Colors.blue;
    } else if (type == 'maintenance') {
      typeLabel = 'Maintenance';
      typeIcon = Icons.handyman;
      typeColor = Colors.amber;
    }
    
    // Status badge
    Color statusBgColor = Colors.grey.shade100;
    Color statusTextColor = Colors.grey.shade700;
    String statusLabel = 'Open';
    
    if (status == 'open' || status == 'pending' || status == 'submitted') {
      statusBgColor = Colors.amber.shade50;
      statusTextColor = Colors.amber.shade800;
      statusLabel = 'Pending';
    } else if (status == 'inProgress' || status == 'claimed' || status == 'in_progress') {
      statusBgColor = Colors.blue.shade50;
      statusTextColor = Colors.blue.shade700;
      statusLabel = 'In Progress';
    } else if (status == 'completed' || status == 'approved' || status == 'done') {
      statusBgColor = Colors.green.shade50;
      statusTextColor = Colors.green.shade700;
      statusLabel = 'Completed';
    } else if (status == 'rejected') {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade700;
      statusLabel = 'Rejected';
    }

    return InkWell(
      onTap: () {
        final id = activity['id'];
        if (id == null) return;
        
        if (type == 'maintenance' || ['kerusakan', 'kebersihan', 'stok'].contains(type)) {
          showDialog(
            context: context,
            builder: (context) => TicketDetailDialog(ticketId: id),
          );
        } else if (type == 'procurement') {
          context.go('/admin/procurement/detail/$id');
        } else {
          context.go('/admin/helpdesk');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title + Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Row 2: Type + Subtitle
            Row(
              children: [
                Icon(typeIcon, size: 14, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 3: Location (Separate Line)
            if (activity['location'] != null && 
                activity['location'] != 'Unknown' &&
                ['kerusakan', 'kebersihan', 'stok'].contains(activity['type']))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity['location'] ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Row 4: Creator (Separate Line)
            if (activity['userName'] != null && 
                activity['userName'] != 'User' &&
                ['kerusakan', 'kebersihan', 'stok'].contains(activity['type']))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      activity['userName'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            
            // Row 4: Date + Urgent Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatActivityDate(timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, size: 12, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Urgent',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    if (dateOnly == today) {
      return 'Hari ini, $timeStr';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, $timeStr';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  String _formatTimeArea(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatIndonesianDate(DateTime date) {
    const List<String> days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const List<String> months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = days[date.weekday % 7];
    final day = date.day;
    final monthName = months[date.month];
    final year = date.year;
    
    return '$dayName, $day $monthName $year';
  }
}

class HeaderWavePainter extends CustomPainter {
  final Color color;

  HeaderWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();

    // Start from bottom right
    path.moveTo(size.width, size.height);
    // Line to bottom left-ish
    path.lineTo(size.width * 0.6, size.height);
    
    // Smooth curve to top right-ish
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.5, // Control point
      size.width * 0.5, 0, // End point
    );
    
    // Close path via top right corner
    path.lineTo(size.width, 0); 
    path.close();

    canvas.drawPath(path, paint);
    
    // Second Wave Layer (Lighter)
    var paint2 = Paint()
      ..color = color.withOpacity(0.3) // Faint
      ..style = PaintingStyle.fill;
      
    var path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width * 0.8, size.height);
    path2.quadraticBezierTo(
      size.width * 0.85, size.height * 0.6,
      size.width * 0.7, 0,
    );
    path2.lineTo(size.width, 0);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

