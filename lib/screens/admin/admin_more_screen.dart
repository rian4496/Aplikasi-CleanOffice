// lib/screens/admin/admin_more_screen.dart
// Admin More Menu Screen - Additional navigation options

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/navigation/admin_bottom_nav.dart';
import './analytics_screen_hooks.dart';
import './all_reports_management_screen.dart';
import './all_requests_management_screen.dart';
import './cleaner_management_screen.dart';
import './bulk_receipt_screen_hooks.dart';
import '../inventory/inventory_list_screen.dart';
import '../dev/seed_data_screen.dart';

/// Admin More Screen - Grid menu for additional features
class AdminMoreScreen extends HookConsumerWidget {
  const AdminMoreScreen({super.key});

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
                'Akses semua fitur admin',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Analytics & Reports Section
              _buildSection(
                title: 'Analitik & Laporan',
                items: [
                  _MenuItem(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    subtitle: 'Statistik dan grafik lengkap',
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Kelola Laporan',
                    subtitle: 'Verifikasi dan kelola semua laporan',
                    color: AppTheme.info,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllReportsManagementScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.room_service_outlined,
                    title: 'Kelola Permintaan',
                    subtitle: 'Kelola permintaan layanan',
                    color: AppTheme.success,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllRequestsManagementScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Management Section
              _buildSection(
                title: 'Manajemen',
                items: [
                  _MenuItem(
                    icon: Icons.people_outline,
                    title: 'Kelola Petugas',
                    subtitle: 'Manajemen data petugas cleaning',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CleanerManagementScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventaris',
                    subtitle: 'Kelola inventaris alat cleaning',
                    color: Colors.orange,
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

              // Tools Section
              _buildSection(
                title: 'Tools',
                items: [
                  _MenuItem(
                    icon: Icons.upload_file_outlined,
                    title: 'Upload Bukti Receipt',
                    subtitle: 'Upload bulk receipt dari Excel',
                    color: AppTheme.warning,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BulkReceiptScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.data_object_outlined,
                    title: 'Generate Data',
                    subtitle: 'Buat sample data untuk testing',
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SeedDataScreen(),
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
      bottomNavigationBar: AdminBottomNav(
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
          '/admin_dashboard',
          (route) => false,
        );
        break;
      case 1: // Laporan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllReportsManagementScreen(),
          ),
        );
        break;
      case 2: // Chat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur chat segera hadir')),
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
