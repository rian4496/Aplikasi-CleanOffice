import 'package:flutter/material.dart';
import '../notification_screen.dart';
import '../create_report_screen.dart';

// Refactored Admin Dashboard Screen
// - Minimalist & Professional UI/UX
// - Strategic Color Accents
// - Clean, Data-Focused Layout
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // --- NEW COLOR PALETTE ---
  static const Color _primaryColor = Color(0xFF2C3E50);
  static const Color _backgroundColor = Color(0xFFF7F9FA);
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _primaryTextColor = Colors.black87;
  static const Color _secondaryTextColor = Color(
    0xFF757575,
  ); // Colors.grey[600]
  static const Color _accentColor = Color(0xFF3498DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- 1. Refactored Header ---
            // Solid primary color, no gradient, white text/icons.
            SliverAppBar(
              pinned: true,
              backgroundColor: _primaryColor,
              elevation: 2,
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: _accentColor,
                    child: Icon(
                      Icons.person_outline,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // --- Main Content ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),

                    // --- 2. Refactored Statistics Cards ---
                    _buildStatisticsGrid(),
                    const SizedBox(height: 32),

                    // Quick Actions (Optional: Can be refactored similarly if needed)
                    _buildQuickActions(),
                    const SizedBox(height: 32),

                    // Recent Activities
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- 3. Refactored Floating Action Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportScreen()),
          );
        },
        backgroundColor: _accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Laporan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang Kembali! 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola kebersihan kantor dengan mudah.',
          style: TextStyle(fontSize: 16, color: _secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
    // --- Card data remains the same, only presentation changes ---
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0, // Adjusted for a more square look
      children: [
        _buildStatCard(
          title: 'Menunggu',
          value: '8',
          icon: Icons.pending_actions_outlined, // Outline icon
          accentColor: const Color(0xFFFF9800), // Orange accent
        ),
        _buildStatCard(
          title: 'Verifikasi',
          value: '5',
          icon: Icons.verified_user_outlined, // Outline icon
          accentColor: const Color(0xFF2196F3), // Blue accent
        ),
        _buildStatCard(
          title: 'Selesai',
          value: '23',
          icon: Icons.check_circle_outline, // Outline icon
          accentColor: const Color(0xFF4CAF50), // Green accent
        ),
        _buildStatCard(
          title: 'Total Aktif',
          value: '36',
          icon: Icons.trending_up,
          accentColor: const Color(0xFF673AB7), // Purple accent
        ),
      ],
    );
  }

  // --- REFACTORED STAT CARD WIDGET ---
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackgroundColor, // White background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ), // Subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: accentColor, size: 32),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32, // Large, bold number
                  fontWeight: FontWeight.bold,
                  color: accentColor, // Accent color for the number
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: _secondaryTextColor, // Secondary text color
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Verifikasi',
                Icons.verified_outlined,
                const Color(0xFF2196F3),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Laporan',
                Icons.assessment_outlined,
                const Color(0xFF4CAF50),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Petugas',
                Icons.people_outline,
                const Color(0xFFFF9800),
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    // This widget is slightly restyled for consistency
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: _primaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    // This widget already follows the new design principles, so it remains largely unchanged.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: _accentColor),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.cleaning_services_outlined,
          title: 'Toilet Lt. 2',
          time: '10 menit lalu',
          status: 'Selesai',
          statusColor: const Color(0xFF4CAF50),
        ),
        _buildActivityItem(
          icon: Icons.hourglass_top_rounded,
          title: 'Ruang Rapat A',
          time: '25 menit lalu',
          status: 'Dikerjakan',
          statusColor: const Color(0xFF2196F3),
        ),
        _buildActivityItem(
          icon: Icons.notifications_active_outlined,
          title: 'Area Pantry',
          time: '1 jam lalu',
          status: 'Menunggu',
          statusColor: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: _secondaryTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
