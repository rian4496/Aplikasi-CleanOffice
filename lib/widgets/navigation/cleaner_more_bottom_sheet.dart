// lib/widgets/navigation/cleaner_more_bottom_sheet.dart
// Cleaner More Menu Bottom Sheet - Slide up from bottom

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/cleaner/my_tasks_screen.dart';
import '../../screens/cleaner/available_requests_list_screen.dart';
import '../../screens/cleaner/create_cleaning_report_screen.dart';
import '../../screens/cleaner/pending_reports_list_screen.dart';
import '../../screens/inventory/inventory_list_screen.dart';

class CleanerMoreBottomSheet extends StatelessWidget {
  const CleanerMoreBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CleanerMoreBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
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
                _buildSectionTitle('Tugas & Permintaan'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.task_alt_outlined,
                  title: 'Tugas Saya',
                  subtitle: 'Lihat semua tugas yang ditugaskan',
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyTasksScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.playlist_add_check_outlined,
                  title: 'Permintaan Tersedia',
                  subtitle: 'Ambil permintaan layanan baru',
                  color: AppTheme.success,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvailableRequestsListScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inbox_outlined,
                  title: 'Laporan Masuk',
                  subtitle: 'Laporan yang perlu ditindaklanjuti',
                  color: AppTheme.warning,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingReportsListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Laporan & Inventaris'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  title: 'Buat Laporan',
                  subtitle: 'Buat laporan pembersihan baru',
                  color: AppTheme.info,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCleaningReportScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventaris Alat',
                  subtitle: 'Kelola alat pembersihan',
                  color: Colors.purple,
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
