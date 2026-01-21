// lib/platforms/mobile/admin/quick_menu_screen.dart
// 📱 Quick Menu Screen - Unified Role-Aware Quick Actions Menu
// Shows all available features in a structured section layout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../riverpod/auth_providers.dart';

class QuickMenuScreen extends ConsumerWidget {
  const QuickMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Menu Cepat',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 18, // Slightly larger than 16 to match standard but compact
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== DATA SECTION ====================
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionHeader('Data'),
              ),
              const SizedBox(height: 24),
              _buildGridMenu(context, [
                _MenuItem(
                  icon: Icons.people_outline,
                  label: 'Pegawai',
                  onTap: () => context.push('/admin/master/pegawai'),
                ),
                _MenuItem(
                  icon: Icons.domain_outlined,
                  label: 'Organisasi',
                  onTap: () => context.push('/admin/master/organisasi'),
                ),
                _MenuItem(
                  icon: Icons.monetization_on_outlined,
                  label: 'Anggaran',
                  onTap: () => context.push('/admin/master/anggaran'),
                ),
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Aset',
                  onTap: () => context.push('/admin/assets'),
                ),
                _MenuItem(
                  icon: Icons.storefront_outlined,
                  label: 'Vendor',
                  onTap: () => context.push('/admin/master/vendor'),
                ),
              ]),

              const SizedBox(height: 24),
              Divider(thickness: 1, height: 1, color: Colors.grey.shade200), // Darker divider
              const SizedBox(height: 24),

              // ==================== AKTIVITAS SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionHeader('Aktivitas'),
              ),
              const SizedBox(height: 24),
              _buildGridMenu(context, [
                _MenuItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Inventaris',
                  onTap: () => context.push('/admin/inventory'),
                ),
                _MenuItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Pengadaan',
                  onTap: () => context.push('/admin/procurement'),
                ),
                _MenuItem(
                  icon: Icons.support_agent,
                  label: 'Helpdesk',
                  onTap: () => context.push('/admin/helpdesk'),
                ),
                _MenuItem(
                  icon: Icons.transfer_within_a_station_outlined, // Matching sidebar icon (rounded->outlined for mobile consistency)
                  label: 'Mutasi Aset',
                  onTap: () => context.push('/admin/transactions/mutation'),
                ),
                _MenuItem(
                  icon: Icons.assignment_return_outlined,
                  label: 'Peminjaman',
                  onTap: () => context.push('/admin/loans'),
                ),
                _MenuItem(
                  icon: Icons.delete_outline,
                  label: 'Penghapusan',
                  onTap: () => context.push('/admin/disposal'),
                ),
              ]),

              const SizedBox(height: 24),
              Divider(thickness: 1, height: 1, color: Colors.grey.shade200), // Darker divider
              const SizedBox(height: 24),

              // ==================== LAPORAN & SETTINGS SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionHeader('Laporan & Settings'),
              ),
              const SizedBox(height: 24),
              _buildGridMenu(context, [
                _MenuItem(
                  icon: Icons.analytics_outlined,
                  label: 'Laporan',
                  onTap: () => context.push('/admin/reports'),
                ),
                if (ref.watch(currentUserRoleProvider) != 'employee')
                  _MenuItem(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Manajemen\nUser',
                    onTap: () => context.push('/admin/users'),
                  ),
              ]),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16, // Back to 16
        fontWeight: FontWeight.bold, // Bold to match "Data" in screenshot
        color: Colors.black, // Stark black
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, List<_MenuItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.75, // Adjust as needed for label wrapping
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(items[index]);
      },
    );
  }


  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      hoverColor: Colors.transparent, // Disable hover effect as requested
      splashColor: Colors.transparent, // Optional: cleaner look
      highlightColor: Colors.transparent, // Optional: cleaner look
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(item.icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11, // Match Dashboard (11)
              fontWeight: FontWeight.w600, // Match Dashboard (w600)
              color: Colors.grey.shade700, // Match Dashboard (Grey 700)
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
