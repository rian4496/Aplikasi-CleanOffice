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
import '../../../providers/riverpod/admin_dashboard_provider.dart';
import '../../../providers/riverpod/auth_providers.dart';
import '../../../widgets/web_admin/charts/budget_trend_chart.dart';
import '../../../widgets/web_admin/charts/dashboard_charts.dart'; // Keep if used for other charts, or remove if replacing
import '../../../models/ticket.dart'; // For TicketType popup

import '../../../providers/riverpod/admin_dashboard_provider.dart'; // Ensure this is here
import 'admin_dashboard_mobile_screen.dart'; // Import Mobile Screen

class AdminDashboardScreen extends HookConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mobile Check
    final isMobile = !kIsWeb && (MediaQuery.of(context).size.width < 900);
    
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
                    return IntrinsicHeight( // Ensure both columns obey stretch
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Align bottom
                        children: [
                          // Left: Charts (2/3 width)
                          Expanded(
                            flex: 2,
                            child: dashboardAsync.when(
                              data: (data) => _buildChartsSection(data),
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
                          data: (data) => _buildChartsSection(data),
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
          title: 'Laporan Pending',
          value: data['pendingReports']?.toString() ?? '0',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.amber.shade700, // Warning
          progress: 0.5, 
        ),
         CompactStatCard(
          title: 'Permintaan Baru',
          value: data['pendingRequests']?.toString() ?? '0',
          icon: Icons.shopping_cart_checkout_rounded,
          iconColor: Colors.blue.shade600, // Info
          progress: 0.5,
        ),
         CompactStatCard(
          title: 'Aset Rusak/Maint.',
          value: data['assetsUnderMaintenance']?.toString() ?? '0',
          icon: Icons.build_circle_rounded,
          iconColor: Colors.red.shade600, // Health
          progress: 0.2, // Arbitrary
        ),
         CompactStatCard(
          title: 'Serapan Anggaran',
          value: '${data['budgetPercent'] ?? "0"}%',
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFFE53935), // Vivid Red
          progress: (double.tryParse(data['budgetPercent'] ?? '0') ?? 0) / 100,
          trendValue: 'Tahun Ini', 
          trendUp: true,
        ),
      ],
    );
  }

  Widget _buildChartsSection(Map<String, dynamic> data) {
      if (data['monthlyBudget'] != null && data['monthlyActual'] != null) {
          return BudgetTrendChart(
            monthlyBudget: (data['monthlyBudget'] as List).cast<double>(),
            monthlyActual: (data['monthlyActual'] as List).cast<double>(),
          );
      }
      return const DashboardCharts();
  }

  Widget _buildRecentActivity(BuildContext context, List<Map<String, dynamic>> activities) {
    // Activity Card fills heigth
    return Container(
      padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withOpacity(0.8), width: 1.2), // Stronger border
        boxShadow: [
           // Tighter shadow
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 2,
             offset: const Offset(0, 1)
           ),
           // Softer shadow
           BoxShadow(
             color: Colors.black.withOpacity(0.08), // Stronger opacity
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
               const Text(
                 'Aktivitas Terbaru',
                 style: TextStyle(
                   fontSize: 18, 
                   fontWeight: FontWeight.bold,
                   color: AppTheme.textPrimary
                 ),
               ),
               IconButton(
                 onPressed: () {
                   context.go('/admin/activities');
                 },
                 icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 20),
                 tooltip: 'Lihat Semua',
               ),
             ],
           ),
           const SizedBox(height: 20),
           
           if (activities.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada aktivitas"))),

           ...activities.take(5).map((activity) {
              Color dotColor = Colors.grey;
              if (activity['type'] == 'maintenance') dotColor = Colors.orange;
              if (activity['type'] == 'procurement') dotColor = Colors.blue;
              if (activity['status'] == 'completed' || activity['status'] == 'approved') dotColor = Colors.green;

              return _buildActivityItem(
                context,
                activity['title'] ?? '-',
                activity['subtitle'] ?? '-',
                activity['timestamp'] as DateTime? ?? DateTime.now(),
                dotColor,
                () {
                   if (activity['type'] == 'maintenance') {
                      final id = activity['id'];
                      if (id != null) context.go('/admin/helpdesk/detail/$id');
                    } else if (activity['type'] == 'procurement') {
                      final id = activity['id'];
                      if (id != null) context.go('/admin/procurement/detail/$id');
                    }
                }
              );
           }).toList(),
         ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String user, DateTime time, Color dotColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 4, left: 4, right: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('$user • ${_formatTimeArea(time)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
             const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
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

