// lib/widgets/admin/admin_sidebar.dart
// Persistent sidebar navigation for Admin dashboard (Desktop/Tablet)
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/admin_providers.dart' hide currentUserProfileProvider;
import '../../providers/riverpod/auth_providers.dart';

import '../../screens/admin/all_reports_management_screen.dart';
import '../../screens/admin/all_requests_management_screen.dart';
import '../../screens/admin/cleaner_management_screen.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../screens/inventory/inventory_dashboard_screen.dart';
import '../../services/inventory_service.dart';
import '../../models/inventory_item.dart';

class AdminSidebar extends ConsumerWidget {
  final String currentRoute;

  const AdminSidebar({
    this.currentRoute = 'dashboard',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final verificationCount = ref.watch(needsVerificationCountProvider);

    return StreamBuilder<List<InventoryItem>>(
      stream: InventoryService().streamLowStockItems(),
      builder: (context, lowStockSnapshot) {
        final lowStockCount = lowStockSnapshot.data?.length ?? 0;

        return _buildSidebarContent(
          context,
          userProfileAsync,
          verificationCount,
          lowStockCount,
        );
      },
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    AsyncValue userProfileAsync,
    int verificationCount,
    int lowStockCount,
  ) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          right: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // ==================== HEADER ====================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // User Name
                userProfileAsync.when(
                  data: (profile) => Text(
                    profile?.displayName ?? 'ADMIN',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Text(
                    'Loading...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  error: (e, _) => const Text(
                    'ADMIN',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ==================== MENU ITEMS ====================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  isActive: currentRoute == 'dashboard',
                  onTap: () {
                    if (currentRoute != 'dashboard') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home_admin',
                        (route) => false,
                      );
                    }
                  },
                ),

                const SizedBox(height: 4),

                _buildMenuItem(
                  context: context,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  title: 'Kelola Laporan',
                  badge: verificationCount,
                  isActive: currentRoute == 'reports_management',
                  onTap: () {
                    if (currentRoute != 'reports_management') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllReportsManagementScreen(),
                        ),
                      );
                    }
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.room_service_outlined,
                  activeIcon: Icons.room_service,
                  title: 'Kelola Permintaan',
                  isActive: currentRoute == 'requests_management',
                  onTap: () {
                    if (currentRoute != 'requests_management') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllRequestsManagementScreen(),
                        ),
                      );
                    }
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Kelola Petugas',
                  isActive: currentRoute == 'cleaner_management',
                  onTap: () {
                    if (currentRoute != 'cleaner_management') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CleanerManagementScreen(),
                        ),
                      );
                    }
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  title: 'Inventaris',
                  badge: lowStockCount,
                  isActive: currentRoute == 'inventory',
                  onTap: () {
                    if (currentRoute != 'inventory') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryDashboardScreen(),
                        ),
                      );
                    }
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  title: 'Analitik',
                  isActive: currentRoute == 'analytics',
                  onTap: () {
                    if (currentRoute != 'analytics') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      );
                    }
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.grey[300], height: 1),
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  title: 'Pengaturan',
                  isActive: currentRoute == 'settings',
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profil',
                  isActive: currentRoute == 'profile',
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.grey[300], height: 1),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.logout,
                      color: AppTheme.error,
                      size: 22,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _handleLogout(context),
                    hoverColor: AppTheme.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================== FOOTER ====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'CleanOffice v1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    int? badge,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(
                color: AppTheme.primary,
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? AppTheme.primary : Colors.grey[700],
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primary : AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: badge != null && badge > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        onTap: onTap,
        hoverColor: AppTheme.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Navigate to login screen - logout handled by login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
