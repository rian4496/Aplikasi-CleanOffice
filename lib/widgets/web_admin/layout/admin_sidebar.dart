// lib/widgets/web_admin/layout/admin_sidebar.dart
// 🗂️ Admin Sidebar (Consolidated)
// Logic: RBAC + Content from active sidebar

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../models/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSidebar extends HookConsumerWidget {
  final String location;
  
  const AdminSidebar({
    super.key,
    String? currentRoute,
    String? location,
    this.isDrawer = false,
  }) : location = location ?? currentRoute ?? '';

  final bool isDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isMobile = !ResponsiveHelper.isDesktop(context); // Check for mobile view

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
                  // 1. DASHBOARD SECTION
                  _buildSectionLabel('MENU UTAMA'),
                  
                  // Dashboard redirect based on role
                  _buildMenuItem(
                    context, 
                    'Dashboard', 
                    Icons.dashboard_rounded, 
                    _getDashboardRoute(userRole),
                  ),

                  // Profile (Explicit access)
                  _buildMenuItem(
                    context, 
                    'Profile', 
                    Icons.person_rounded, 
                    '/admin/profile',
                  ),
                  
                  // 2. DATA SECTION (Admin, Kasubbag)
                  // Hidden for Cleaner, Teknisi, Employee
                  // Hidden on Mobile as per request
                  // Hidden on Mobile as per request
                  if ((userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) && !isMobile && !isDrawer) ...[
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
                  ],

                   // 3. AKTIVITAS SECTION
                  // Hide for Cleaner as per request
                  // Hide on Mobile
                  if (userRole != UserRole.cleaner && !isMobile && !isDrawer) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildSectionLabel('AKTIVITAS'),
                  ],

                  // Inventaris (Stok) - Admin, Kasubbag only? 
                  if ((userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Inventaris (Stok)', Icons.inventory_2_rounded, '/admin/inventory'),
                  
                  // Pengadaan - Admin, Kasubbag
                  if ((userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Pengadaan', Icons.shopping_cart_checkout_rounded, '/admin/procurement'),

                  // Mutasi Aset - Admin, Kasubbag, Employee
                  if ((userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Mutasi Aset', Icons.transfer_within_a_station_rounded, '/admin/transactions/mutation'),
                  
                  // Helpdesk - All Roles (access logic handled by screen/router, menu visibility here)
                  // Helpdesk - Hidden for Cleaner
                  if (userRole != UserRole.cleaner && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Helpdesk', Icons.support_agent_rounded, '/admin/helpdesk'),
                  
                  // Peminjaman (Loans)
                  // Admin, Kasubbag, Employee (My Loans)
                  // Cleaner/Teknisi usually don't borrow assets directly via system? Or can?
                  // Providing access to "Peminjaman" for everyone, user role logic inside screen handles "My Loans" vs "All".
                  if (userRole != UserRole.cleaner && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Peminjaman', Icons.assignment_return_rounded, '/admin/loans'),
                  
                  // Penghapusan (Disposal)
                  // Admin & Kasubbag Only
                  if ((userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) && !isMobile && !isDrawer)
                    _buildMenuItem(context, 'Penghapusan', Icons.delete_forever_rounded, '/admin/disposal'),
                  
                  const SizedBox(height: AppTheme.spacingLg),
                  
  // 4. REPORTS & SETTINGS
                  // Admin, Kasubbag & Employee
                  if (userRole == UserRole.admin || userRole == UserRole.kasubbag || userRole == UserRole.employee) ...[
                    if (!isMobile && !isDrawer) _buildSectionLabel('LAPORAN & SETTINGS'),
                    
                    // Laporan - Visible to all except cleaner/teknisi
                    if (!isMobile && !isDrawer) _buildMenuItem(context, 'Laporan / Report', Icons.bar_chart_rounded, '/admin/reports'),
                    
                    // User Management - Admin & Kasubbag Only
                    if ((userRole == UserRole.admin || userRole == UserRole.kasubbag) && !isMobile && !isDrawer)
                      _buildMenuItem(context, 'Manajemen User', Icons.manage_accounts_rounded, '/admin/users'),

                    // Pengaturan - For Everyone
                    _buildMenuItem(context, 'Pengaturan', Icons.settings_rounded, '/admin/settings'),
                  ],

                  // CLEANER/TEKNISI SPECIFIC MENUS
                   if (userRole == UserRole.cleaner) ...[
                     const SizedBox(height: AppTheme.spacingMd),
                     // Profil accessible via Bottom Nav
                     _buildMenuItem(context, 'Pengaturan', Icons.settings_rounded, '/console/cleaner/settings'),
                   ],
                   
                   if (userRole == UserRole.teknisi) ...[
                     const SizedBox(height: AppTheme.spacingMd),
                     _buildSectionLabel('TUGAS TEKNISI'),
                     _buildMenuItem(context, 'Tiket Saya', Icons.handyman_rounded, '/console/teknisi/tickets'),
                   ],
                ],
              ),
            ),
          ),
          
          // Footer
          _buildFooter(context, ref, userProfile?.displayName),
        ],
      ),
    );
  }

  String _getDashboardRoute(String? role) {
    if (role == UserRole.cleaner) return '/console/cleaner/dashboard';
    if (role == UserRole.employee) return '/admin/dashboard'; // Unified view
    if (role == UserRole.teknisi) return '/admin/helpdesk'; // Teknisi main dash
    return '/admin/dashboard';
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
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
                  color: Colors.white.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: 4), // Reduced from spacingSm (8)
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
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
        collapsedIconColor: Colors.white.withValues(alpha: 0.7),
        iconColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, size: 20, color: isExpanded ? Colors.white : Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isExpanded ? Colors.white : Colors.white.withValues(alpha: 0.9),
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
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 1), // Reduced vertical margin
      child: Material(
        color: isActive ? AppTheme.secondary : Colors.transparent,
        borderRadius: AppTheme.radiusMd,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: AppTheme.radiusMd,
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 8), // Reduced vertical padding
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.black : Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.black : Colors.white.withValues(alpha: 0.9),
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
  
  Widget _buildFooter(BuildContext context, WidgetRef ref, String? displayName) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            title: Text(
              'Keluar',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
             subtitle: displayName != null ? Text(
              displayName, 
              style: GoogleFonts.inter(color: Colors.white30, fontSize: 10)
            ) : null,
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
                         try {
                           await ref.read(authActionsProvider.notifier).logout();
                         } catch (e) {
                           // Fallback: direct signout if provider fails
                           await Supabase.instance.client.auth.signOut();
                         }
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
        color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent, // Sub-menu highlight uses subtle contrast
        borderRadius: AppTheme.radiusMd,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: AppTheme.radiusMd,
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 8), // Reduced from 10
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: isActive ? AppTheme.secondary : Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
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
