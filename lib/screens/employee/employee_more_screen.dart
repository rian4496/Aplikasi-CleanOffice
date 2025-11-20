// lib/screens/employee/employee_more_screen.dart
// Employee More Menu Screen - Additional navigation options

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/navigation/employee_bottom_nav.dart';
import '../shared/all_reports_screen.dart';
import './request_history_screen_hooks.dart';

/// Employee More Screen - Grid menu for additional features
class EmployeeMoreScreen extends HookConsumerWidget {
  const EmployeeMoreScreen({super.key});

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
                'Akses semua fitur aplikasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Reports Section
              _buildSection(
                title: 'Laporan',
                items: [
                  _MenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Semua Laporan',
                    subtitle: 'Lihat semua laporan kebersihan',
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllReportsScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Permintaan',
                    subtitle: 'Permintaan layanan Anda',
                    color: AppTheme.info,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestHistoryScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions Section
              _buildSection(
                title: 'Aksi Cepat',
                items: [
                  _MenuItem(
                    icon: Icons.add_circle_outline,
                    title: 'Buat Laporan Baru',
                    subtitle: 'Laporkan masalah kebersihan',
                    color: AppTheme.success,
                    onTap: () => Navigator.pushNamed(context, '/create_report'),
                  ),
                  _MenuItem(
                    icon: Icons.room_service_outlined,
                    title: 'Minta Layanan',
                    subtitle: 'Permintaan layanan personal',
                    color: AppTheme.warning,
                    onTap: () => Navigator.pushNamed(context, '/create_request'),
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
                    color: Colors.purple,
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
      bottomNavigationBar: EmployeeBottomNav(
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
          '/employee_home',
          (route) => false,
        );
        break;
      case 1: // Laporan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllReportsScreen(),
          ),
        );
        break;
      case 2: // Layanan
        Navigator.pushNamed(context, '/create_request');
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
