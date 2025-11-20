// lib/screens/cleaner/cleaner_more_screen.dart
// Cleaner More Menu Screen - Additional navigation options

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/navigation/cleaner_bottom_nav.dart';
import './my_tasks_screen.dart';
import './available_requests_list_screen_hooks.dart';
import './create_cleaning_report_screen_hooks.dart';
import './pending_reports_list_screen.dart';
import '../inventory/inventory_list_screen.dart';

/// Cleaner More Screen - Grid menu for additional features
class CleanerMoreScreen extends HookConsumerWidget {
  const CleanerMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Menu Lengkap',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Akses semua fitur petugas',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Tasks Section
              _buildSection(
                title: 'Tugas & Permintaan',
                items: [
                  _MenuItem(
                    icon: Icons.task_alt_outlined,
                    title: 'Tugas Saya',
                    subtitle: 'Lihat semua tugas yang ditugaskan',
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyTasksScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.playlist_add_check_outlined,
                    title: 'Permintaan Tersedia',
                    subtitle: 'Ambil permintaan layanan baru',
                    color: AppTheme.success,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvailableRequestsListScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.inbox_outlined,
                    title: 'Laporan Masuk',
                    subtitle: 'Laporan yang perlu ditindaklanjuti',
                    color: AppTheme.warning,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingReportsListScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Reports & Inventory Section
              _buildSection(
                title: 'Laporan & Inventaris',
                items: [
                  _MenuItem(
                    icon: Icons.add_circle_outline,
                    title: 'Buat Laporan',
                    subtitle: 'Buat laporan pembersihan baru',
                    color: AppTheme.info,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCleaningReportScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventaris Alat',
                    subtitle: 'Kelola alat pembersihan',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryListScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account Section
              _buildSection(
                title: 'Akun',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Profil',
                    subtitle: 'Lihat dan edit profil Anda',
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    subtitle: 'Atur preferensi aplikasi',
                    color: Colors.grey[700]!,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: CleanerBottomNav(
        currentIndex: 3, // More screen
        onTap: (index) => _handleBottomNavTap(context, index),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/cleaner_home',
          (route) => false,
        );
        break;
      case 1: // Laporan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateCleaningReportScreen(),
          ),
        );
        break;
      case 2: // Inbox
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingReportsListScreen(),
          ),
        );
        break;
      case 3: // More - already here
        break;
    }
  }
}

// Menu item data class
class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
