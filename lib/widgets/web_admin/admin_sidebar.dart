import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final String location;
  
  const AdminSidebar({
    super.key,
    String? currentRoute,
    String? location,
  }) : location = location ?? currentRoute ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppTheme.primary,
      child: Column(
        children: [
          // Logo Area
          _buildHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              child: Column(
                children: [
                  _buildSectionLabel('MENU UTAMA'),
                  _buildMenuItem(context, 'Dashboard', Icons.dashboard_rounded, '/admin/dashboard'),
                  
                  // NEW: Master Data Dropdown
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildSectionLabel('DATA'),
                  _buildExpandableMenu(
                    context, 
                    title: 'Master Data', 
                    icon: Icons.dataset_rounded,
                    children: [
                       _buildSubMenuItem(context, 'Pegawai (SDM)', '/admin/master/pegawai'),
                       _buildSubMenuItem(context, 'Organisasi', '/admin/master/organisasi'),
                       _buildSubMenuItem(context, 'Anggaran', '/admin/master/anggaran'),
                       _buildSubMenuItem(context, 'Aset', '/admin/master/aset'),
                       _buildSubMenuItem(context, 'Vendor', '/admin/master/vendor'),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingMd),
                  _buildSectionLabel('TRANSAKSI'),
                  _buildMenuItem(context, 'Inventaris (Stok)', Icons.inventory_2_rounded, '/admin/inventory'),
                  _buildMenuItem(context, 'Pengadaan', Icons.shopping_cart_checkout_rounded, '/admin/procurement'),
                  _buildMenuItem(context, 'Helpdesk', Icons.support_agent_rounded, '/admin/helpdesk'),
                  _buildMenuItem(context, 'Peminjaman', Icons.assignment_return_rounded, '/admin/loans'),
                  _buildMenuItem(context, 'Penghapusan', Icons.delete_forever_rounded, '/admin/disposal'),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
                  _buildSectionLabel('LAPORAN & SETTINGS'),
                  _buildMenuItem(context, 'Laporan / Report', Icons.bar_chart_rounded, '/admin/reports'),
                  _buildMenuItem(context, 'Manajemen User', Icons.manage_accounts_rounded, '/admin/users'),
                ],
              ),
            ),
          ),
          
          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
      ),
      child: Row(
        children: [
           // Logo
          Container(
            width: 45, // Slightly larger to compensate for lack of circle
            height: 50,
            child: Image.asset(
              'assets/images/logo-pemprov-kalsel.png',
              fit: BoxFit.contain, // Maintain aspect ratio
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 24),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIM-ASET',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'BRIDA Kalsel',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingSm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenu(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final bool isExpanded = children.any((c) => c is _SubMenuItem && location.startsWith(c.path));
    
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        collapsedIconColor: Colors.white.withOpacity(0.7),
        iconColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, size: 20, color: isExpanded ? Colors.white : Colors.white.withOpacity(0.8)),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isExpanded ? Colors.white : Colors.white.withOpacity(0.9),
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        children: children,
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, String title, String path) {
    return _SubMenuItem(title: title, path: path, location: location);
  }

  // Original MenuItem builder (unchanged logic)
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String path) {
    final bool isActive = location.startsWith(path);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 2),
      child: Material(
        color: isActive ? AppTheme.secondary : Colors.transparent,
        borderRadius: AppTheme.radiusMd,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: AppTheme.radiusMd,
          hoverColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.black : Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.black : Colors.white.withOpacity(0.9),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          Divider(color: Colors.white.withOpacity(0.1)),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            title: Text(
              'Keluar',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            onTap: () {
               showDialog(
                 context: context,
                 builder: (dialogContext) => AlertDialog(
                   title: const Text('Konfirmasi Logout'),
                   content: const Text('Apakah Anda ingin logout?'),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.pop(dialogContext),
                       child: const Text('Batal'),
                     ),
                     TextButton(
                       onPressed: () async {
                         Navigator.pop(dialogContext); // Close dialog
                         await Supabase.instance.client.auth.signOut();
                         if (context.mounted) context.go('/login');
                       },
                       child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                     ),
                   ],
                 ),
               );
            },
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  final String title;
  final String path;
  final String location;
  
  const _SubMenuItem({required this.title, required this.path, required this.location});
  
  @override
  Widget build(BuildContext context) {
    final bool isActive = location.startsWith(path);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 2),
      child: Material(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent, // Sub-menu highlight uses subtle contrast
        borderRadius: AppTheme.radiusMd,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: AppTheme.radiusMd,
          hoverColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: isActive ? AppTheme.secondary : Colors.white.withOpacity(0.4)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

