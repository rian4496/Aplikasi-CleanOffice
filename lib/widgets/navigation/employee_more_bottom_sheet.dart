// lib/widgets/navigation/employee_more_bottom_sheet.dart
// Employee More Menu Bottom Sheet - Slide up from bottom

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/employee/all_reports_screen.dart';

class EmployeeMoreBottomSheet extends StatelessWidget {
  const EmployeeMoreBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmployeeMoreBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Menu Lengkap',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Laporan'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.assignment_outlined,
                  title: 'Semua Laporan',
                  subtitle: 'Lihat semua laporan kebersihan',
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllReportsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.history,
                  title: 'Riwayat Permintaan',
                  subtitle: 'Permintaan layanan Anda',
                  color: AppTheme.info,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to request history screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur segera hadir')),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Aksi Cepat'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  title: 'Buat Laporan Baru',
                  subtitle: 'Laporkan masalah kebersihan',
                  color: AppTheme.success,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create_report');
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.room_service_outlined,
                  title: 'Minta Layanan',
                  subtitle: 'Permintaan layanan personal',
                  color: AppTheme.warning,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create_request');
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Akun'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Profil',
                  subtitle: 'Lihat dan edit profil Anda',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  subtitle: 'Atur preferensi aplikasi',
                  color: Colors.grey[700]!,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
