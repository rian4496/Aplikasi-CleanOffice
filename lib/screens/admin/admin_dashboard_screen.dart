// lib/screens/admin/admin_dashboard_screen.dart

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/core/constants/app_constants.dart';
import 'package:aplikasi_cleanoffice/models/report.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/auth_providers.dart';
import 'package:aplikasi_cleanoffice/screens/admin/verification_screen.dart';
import 'package:aplikasi_cleanoffice/widgets/shared/drawer_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const double desktopBreakpoint = 768.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = MediaQuery.of(context).size.width >= desktopBreakpoint;

    return Scaffold(
      endDrawer: !isDesktop ? _buildDrawerContent(context, ref) : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return Row(
              children: [
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(1, 0),
                      )
                    ],
                  ),
                  child: _buildDrawerContent(context, ref),
                ),
                Expanded(
                  child: Builder(
                    builder: (innerContext) => _buildMainContent(innerContext, ref, isDesktop: true),
                  ),
                ),
              ],
            );
          } else {
            return Builder(
              builder: (innerContext) => _buildMainContent(innerContext, ref, isDesktop: false),
            );
          }
        },
      ),
      floatingActionButton: !isDesktop ? _buildFloatingActionButton(context) : null,
    );
  }

  Widget _buildDrawerContent(BuildContext context, WidgetRef ref) {
    final bool isDesktop = MediaQuery.of(context).size.width >= desktopBreakpoint;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: isDesktop ? MediaQuery.of(context).padding.top + 10 : 0),
        child: DrawerMenuWidget(
          menuItems: [
            DrawerMenuItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
              },
            ),
            DrawerMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Verifikasi Akun', // ✅ DIUBAH DARI "Laporan" KE "Akun"
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                // TODO: Navigasi ke verifikasi akun
                _navigateToAccountVerification(context);
              },
            ),
            DrawerMenuItem(
              icon: Icons.assignment_outlined,
              title: 'Laporan',
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                // TODO: Navigasi ke laporan
              },
            ),
            DrawerMenuItem(
              icon: Icons.people_outline,
              title: 'Kelola Petugas',
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                // TODO: Navigasi ke kelola petugas
              },
            ),
            
            DrawerMenuItem(
              icon: Icons.person_outline,
              title: 'Profil',
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            DrawerMenuItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          onLogout: () => _handleLogout(context, ref),
          roleTitle: 'Administrator',
        ),
      ),
    );
  }

  void _navigateToAccountVerification(BuildContext context) {
    // Dummy data untuk demo
    final dummyReport = Report(
      id: 'rep_123',
      title: 'AC Tidak Dingin',
      location: 'Ruang Meeting 1',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      status: ReportStatus.completed,
      userId: 'user123',
      userName: 'Budi Santoso',
      userEmail: 'budi@example.com',
      description: 'AC tidak dingin setelah acara',
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      imageUrl: 'https://via.placeholder.com/600x400?text=Foto+Laporan',
      isUrgent: false,
      cleanerId: 'cleaner456',
      cleanerName: 'Ahmad Supriyadi',
      assignedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      departmentId: 'dept_it',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(report: dummyReport),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref, {required bool isDesktop}) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return SafeArea(
      top: !isDesktop,
      bottom: !isDesktop,
      left: !isDesktop,
      right: !isDesktop,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 1,
            titleSpacing: isDesktop ? 24 : NavigationToolbar.kMiddleSpacing,
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigasi notifikasi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifikasi belum tersedia')),
                  );
                },
                icon: const Icon(Icons.notifications_outlined, color: Colors.white), // ✅ WARNA PUTIH
                tooltip: 'Notifikasi',
              ),
              if (!isDesktop)
                Builder(
                  builder: (buttonContext) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(buttonContext).openEndDrawer();
                    },
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Header
                switch (userProfileAsync) {
                  AsyncData(:final value) => _buildWelcomeHeader(context, value?.displayName ?? 'Admin'),
                  AsyncLoading() => const Center(child: CircularProgressIndicator()),
                  AsyncError(:final error) => Text('Error: ${error.toString()}'),
                },
                const SizedBox(height: 24),
                _buildStatisticsGrid(context, isDesktop: isDesktop),
                const SizedBox(height: 32),
                _buildQuickActions(context, isDesktop: isDesktop),
                const SizedBox(height: 32),
                _buildRecentActivities(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String displayName) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $displayName!',
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat datang di dashboard admin.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, {required bool isDesktop}) {
    final crossAxisCount = isDesktop ? 4 : 2;
    final aspectRatio = isDesktop ? 1.4 : 1.1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 24, // ✅ DARI 16 → 24
      mainAxisSpacing: 24,  // ✅ DARI 16 → 24
      childAspectRatio: aspectRatio,
      children: [
        _buildStatCard(
          context: context,
          title: 'Total Laporan',
          value: '124',
          icon: Icons.assignment,
          accentColor: AppTheme.primary, // ✅ Biru
          onTap: () {
            // TODO: Navigasi ke daftar laporan
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Belum Diverifikasi',
          value: '18',
          icon: Icons.warning_amber,
          accentColor: Colors.orange, // ✅ Oranye
          onTap: () {
            _navigateToAccountVerification(context);
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Selesai',
          value: '96',
          icon: Icons.check_circle,
          accentColor: Colors.green, // ✅ Hijau
          onTap: () {
            // TODO: Navigasi ke laporan selesai
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Petugas Aktif',
          value: '12',
          icon: Icons.people,
          accentColor: Colors.purple, // ✅ Ungu
          onTap: () {
            // TODO: Navigasi ke kelola petugas
          },
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20), // ✅ DARI 16 → 20
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 24), // ✅ Ikon warna sesuai accentColor
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, {required bool isDesktop}) {
    final textTheme = Theme.of(context).textTheme;
    final List<Widget> actionButtons = [
      _buildActionButton(
        context,
        'Buat Laporan',
        Icons.add,
        AppTheme.primary, // ✅ Biru
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur segera hadir')),
          );
        },
      ),
      _buildActionButton(
        context,
        'Verifikasi', // ✅ Sesuai desain: "Verifikasi"
        Icons.verified_user_outlined,
        Colors.orange, // ✅ Oranye
        () {
          _navigateToAccountVerification(context);
        },
      ),
      _buildActionButton(
        context,
        'Lihat Semua',
        Icons.list_alt_outlined,
        Colors.grey[600]!, // ✅ Abu-abu
        () {
          // TODO: Navigasi ke daftar laporan
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: isDesktop ? actionButtons : actionButtons.take(2).toList(),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28), // ✅ Ikon warna sesuai tombol
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final recentActivities = [
      {
        'icon': Icons.assignment_turned_in,
        'title': 'Laporan Pembersihan Ruang Meeting 1',
        'time': '10 menit lalu',
        'status': 'Selesai',
        'statusColor': Colors.green,
      },
      {
        'icon': Icons.warning_amber,
        'title': 'Laporan Kerusakan AC Kantor Utama',
        'time': '2 jam lalu',
        'status': 'Diproses',
        'statusColor': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // TODO: Lihat semua aktivitas
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentActivities.isEmpty)
          Center(
            child: Text(
              'Tidak ada aktivitas terbaru.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentActivities.length > 5 ? 5 : recentActivities.length,
            itemBuilder: (ctx, index) {
              final activity = recentActivities[index];
              return _buildActivityItem(
                context: ctx,
                icon: activity['icon'] as IconData,
                title: activity['title'] as String,
                time: activity['time'] as String,
                status: activity['status'] as String,
                statusColor: activity['statusColor'] as Color,
                onTap: () {
                  // TODO: Detail aktivitas
                },
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              child: Icon(icon, color: statusColor), // ✅ Ikon warna sesuai status
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur tambah laporan segera hadir')),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Tambah'),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}