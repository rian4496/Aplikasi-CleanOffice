// lib/screens/admin/admin_dashboard_screen.dart - RESPONSIVE LAYOUT

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:firebase_auth/firebase_auth.dart';
import '../notification_screen.dart';
import '../employee/create_report_screen.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../core/constants/app_constants.dart';

// Ubah menjadi ConsumerWidget agar bisa pakai ref nantinya
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  // Definisikan breakpoint untuk layout
  static const double desktopBreakpoint = 768.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Tambahkan WidgetRef ref
    return Scaffold(
      // Drawer hanya untuk layar kecil, dikontrol oleh AppBar
      endDrawer: MediaQuery.of(context).size.width < desktopBreakpoint
          ? _buildDrawerContent(context, ref) // Gunakan method konten drawer
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Cek lebar layar
          if (constraints.maxWidth >= desktopBreakpoint) {
            // --- DESKTOP LAYOUT ---
            return Row(
              children: [
                // Sidebar Permanen
                Container(
                  width: 250, // Lebar sidebar
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna background sidebar
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ]
                  ),
                  child: _buildDrawerContent(context, ref), // Isi dengan menu drawer
                ),
                // Konten Utama
                Expanded(
                  child: _buildMainContent(context, ref, isDesktop: true), // Kirim flag isDesktop
                ),
              ],
            );
          } else {
            // --- MOBILE/TABLET LAYOUT ---
            return _buildMainContent(context, ref, isDesktop: false); // Kirim flag isDesktop
          }
        },
      ),
      // FAB hanya muncul di layar kecil? Atau tetap?
      floatingActionButton: MediaQuery.of(context).size.width < desktopBreakpoint
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  // Method untuk membuat konten drawer/sidebar (reusable)
  Widget _buildDrawerContent(BuildContext context, WidgetRef ref) {
     return DrawerMenuWidget(
        menuItems: [
          DrawerMenuItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context), // Tutup drawer jika di mobile
          ),
          DrawerMenuItem(
            icon: Icons.verified_user_outlined,
            title: 'Verifikasi Laporan',
            onTap: () {
              Navigator.pop(context); // Tutup drawer jika di mobile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi: Verifikasi Laporan (Segera)')),
              );
            },
          ),
          DrawerMenuItem(
            icon: Icons.assessment_outlined,
            title: 'Laporan',
            onTap: () {
              Navigator.pop(context); // Tutup drawer jika di mobile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi: Laporan (Segera)')),
              );
            },
          ),
          DrawerMenuItem(
            icon: Icons.people_outline,
            title: 'Kelola Petugas',
            onTap: () {
              Navigator.pop(context); // Tutup drawer jika di mobile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi: Kelola Petugas (Segera)')),
              );
            },
          ),
          DrawerMenuItem(
            icon: Icons.person_outline,
            title: 'Profil',
            onTap: () {
              Navigator.pop(context); // Tutup drawer jika di mobile
              Navigator.pushNamed(context, '/profile');
            },
          ),
          DrawerMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {
              Navigator.pop(context); // Tutup drawer jika di mobile
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        onLogout: () => _handleLogout(context, ref), // Kirim ref ke logout
        roleTitle: 'Administrator',
      );
  }

  // Method untuk membangun konten utama (AppBar + Body)
  Widget _buildMainContent(BuildContext context, WidgetRef ref, {required bool isDesktop}) {
    return SafeArea( // SafeArea mungkin tidak perlu jika AppBar sudah handle
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false, // Tidak perlu back button
            title: const Text('Dashboard'),
            backgroundColor: isDesktop ? AppTheme.background : AppTheme.primary, // Warna beda?
            foregroundColor: isDesktop ? AppTheme.textPrimary : Colors.white,
            elevation: isDesktop ? 0 : 1, // Beri shadow di mobile
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
                icon: Icon(Icons.notifications_outlined, color: isDesktop ? AppTheme.textPrimary : Colors.white),
              ),
              // Hanya tampilkan tombol menu jika BUKAN desktop
              if (!isDesktop)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                     tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),

          // Konten Sliver
          SliverPadding( // Gunakan SliverPadding
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList( // Gunakan SliverList untuk children
              delegate: SliverChildListDelegate([
                 _buildWelcomeHeader(context),
                 const SizedBox(height: 24),
                 // Gunakan _buildStatisticsGrid dengan context yang benar
                 LayoutBuilder(builder: (ctx, constraints) => _buildStatisticsGrid(ctx)),
                 const SizedBox(height: 32),
                 _buildQuickActions(context),
                 const SizedBox(height: 32),
                 _buildRecentActivities(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button (dipisah agar bisa dikontrol tampilannya)
  Widget _buildFloatingActionButton(BuildContext context) {
      return FloatingActionButton.extended(
        onPressed: () {
          // Pertimbangkan navigasi yang lebih relevan untuk Admin?
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      );
  }


  // ==================== LOGOUT ====================
  // (Fungsi logout perlu WidgetRef ref)
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          // Gunakan TextButton agar konsisten
          TextButton(
            onPressed: () => Navigator.pop(context, true),
             style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await FirebaseAuth.instance.signOut(); // Atau gunakan provider jika ada: ref.read(authActionsProvider.notifier).logout();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  // ==================== WIDGET BUILDERS LAINNYA (TETAP SAMA) ====================
  // (_buildWelcomeHeader, _buildStatisticsGrid, _buildStatCard,
  //  _buildQuickActions, _buildActionButton, _buildRecentActivities,
  //  _buildActivityItem)
  // Anda bisa salin dari kode admin_dashboard_screen.dart sebelumnya.
  // Pastikan _buildStatisticsGrid menggunakan context yang tepat.

  Widget _buildWelcomeHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Ambil nama user dari provider jika sudah diimplementasikan
    // final userProfile = ref.watch(currentUserProfileProvider);
    // final displayName = userProfile.whenData((profile) => profile?.displayName ?? 'Admin').value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang Kembali! 👋', // Ganti dengan nama jika ada: 'Selamat Datang, $displayName! 👋'
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola kebersihan kantor dengan mudah.',
          style: textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    // TODO: Ganti value dengan data dari provider (misal: ref.watch(dashboardSummaryProvider))
    final summaryData = { // Data dummy sementara
        'pending': 8,
        'needsVerification': 5,
        'completedToday': 23, // Asumsi 'Selesai' di sini adalah selesai hari ini
        'totalActive': 36
    };

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width >= desktopBreakpoint ? 4 : 2, // 4 kolom di desktop, 2 di mobile
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width >= desktopBreakpoint ? 1.2 : 1.0, // Sesuaikan rasio aspek
      children: [
        _buildStatCard(
          context: context,
          title: 'Menunggu',
          value: summaryData['pending'].toString(), // Ambil data asli
          icon: Icons.pending_actions_outlined,
          accentColor: AppTheme.warning,
          onTap: () { /* Navigasi ke list laporan pending */ }
        ),
        _buildStatCard(
          context: context,
          title: 'Verifikasi',
          value: summaryData['needsVerification'].toString(), // Ambil data asli
          icon: Icons.verified_user_outlined,
          accentColor: AppTheme.info,
          onTap: () { /* Navigasi ke list laporan perlu verifikasi */ }
        ),
        _buildStatCard(
          context: context,
          title: 'Selesai Hari Ini', // Ubah label agar lebih jelas
          value: summaryData['completedToday'].toString(), // Ambil data asli
          icon: Icons.check_circle_outline,
          accentColor: AppTheme.success,
          onTap: () { /* Navigasi ke list laporan selesai */ }
        ),
        _buildStatCard(
          context: context,
          title: 'Total Aktif',
          value: summaryData['totalActive'].toString(), // Ambil data asli
          icon: Icons.task_alt, // Ganti icon jika perlu
          accentColor: AppTheme.primary,
          onTap: () { /* Navigasi ke list semua laporan aktif */ }
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTap, // Tambah onTap
  }) {
    final cardTheme = Theme.of(context).cardTheme;
    return InkWell( // Bungkus dengan InkWell
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardTheme.color ?? Colors.white,
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
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: accentColor, size: 32),
            const Spacer(), // Dorong konten ke bawah
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32, // Ukuran bisa disesuaikan
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1, // Batasi 1 baris
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Verifikasi',
                Icons.verified_outlined,
                AppTheme.info,
                () { /* Navigasi ke layar verifikasi */ },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Semua Laporan', // Ganti label?
                Icons.assessment_outlined,
                AppTheme.success,
                () { /* Navigasi ke layar semua laporan */ },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Petugas',
                Icons.people_outline,
                AppTheme.warning,
                () { /* Navigasi ke layar kelola petugas */ },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final cardTheme = Theme.of(context).cardTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center, // Center text
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildRecentActivities(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // TODO: Ganti dengan data dari provider (misal: ref.watch(recentReportsProvider))
    final recentActivities = [ // Data dummy
        {'icon': Icons.cleaning_services_outlined, 'title': 'Toilet Lt. 2', 'time': '10 menit lalu', 'status': 'Selesai', 'statusColor': AppTheme.success},
        {'icon': Icons.hourglass_top_rounded, 'title': 'Ruang Rapat A', 'time': '25 menit lalu', 'status': 'Dikerjakan', 'statusColor': AppTheme.info},
        {'icon': Icons.notifications_active_outlined, 'title': 'Area Pantry', 'time': '1 jam lalu', 'status': 'Menunggu', 'statusColor': AppTheme.warning},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () { /* Navigasi ke list semua aktivitas/laporan */ },
              style: TextButton.styleFrom(foregroundColor: AppTheme.info),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentActivities.isEmpty)
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 32.0),
             child: Center(
                child: Text('Belum ada aktivitas terbaru', style: TextStyle(color: AppTheme.textSecondary))
             ),
           )
        else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Karena sudah di dalam CustomScrollView
              itemCount: recentActivities.length > 5 ? 5 : recentActivities.length, // Batasi item
              itemBuilder: (context, index){
                final activity = recentActivities[index];
                return _buildActivityItem(
                  context: context,
                  icon: activity['icon'] as IconData,
                  title: activity['title'] as String,
                  time: activity['time'] as String,
                  status: activity['status'] as String,
                  statusColor: activity['statusColor'] as Color,
                  onTap: () { /* Navigasi ke detail aktivitas/laporan */ },
                );
              },
            ),
      ],
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    VoidCallback? onTap, // Tambah onTap
  }) {
    final cardTheme = Theme.of(context).cardTheme;
    return InkWell( // Bungkus dengan InkWell
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider, width: 1),
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
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
      ),
    );
  }

}