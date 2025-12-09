// lib/widgets/navigation/admin_more_bottom_sheet.dart
// Admin More Menu Bottom Sheet - Slide up from bottom

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../screens/admin/all_reports_management_screen.dart';
import '../../screens/admin/all_requests_management_screen.dart';
import '../../screens/admin/cleaner_management_screen.dart';
import '../../screens/admin/account_verification_screen.dart';
import '../../screens/inventory/inventory_list_screen.dart';

class AdminMoreBottomSheet extends StatelessWidget {
  const AdminMoreBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminMoreBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                _buildSectionTitle('Analitik & Laporan'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  subtitle: 'Statistik dan grafik lengkap',
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.assignment_outlined,
                  title: 'Kelola Laporan',
                  subtitle: 'Verifikasi dan kelola semua laporan',
                  color: AppTheme.info,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllReportsManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.room_service_outlined,
                  title: 'Permintaan Layanan',
                  subtitle: 'Kelola semua permintaan layanan',
                  color: AppTheme.success,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllRequestsManagementScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Manajemen'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.verified_user_outlined,
                  title: 'Verifikasi Akun',
                  subtitle: 'Verifikasi akun petugas & employee baru',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountVerificationScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: 'Kelola Petugas',
                  subtitle: 'Manajemen data petugas cleaning',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CleanerManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventaris',
                  subtitle: 'Kelola inventaris alat cleaning',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Tools'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.upload_file_outlined,
                  title: 'Upload Bukti Receipt',
                  subtitle: 'Upload bulk receipt dari Excel',
                  color: AppTheme.warning,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement bulk receipt with Appwrite
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur segera hadir')),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.data_object_outlined,
                  title: 'Generate Data',
                  subtitle: 'Buat sample data untuk testing',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ini dinonaktifkan sementara')),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Akun'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Profil',
                  subtitle: 'Lihat dan edit profil Anda',
                  color: Colors.teal,
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
