// lib/widgets/web_admin/layout/admin_sidebar.dart
// 🗂️ Admin Sidebar
// Desktop persistent navigation sidebar with RBAC

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/riverpod/mock_auth_providers.dart';
import '../../../models/user_role.dart';

class AdminSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔍 Watch Mock User for RBAC
    final user = ref.watch(currentUserProvider);
    final userRole = user.role;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border(
          right: BorderSide(
            color: AdminColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Title
          Container(
            padding: const EdgeInsets.all(AdminConstants.spaceLg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AdminColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AdminColors.primary,
                        AdminColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AdminConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIM-ASET',
                        style: AdminTypography.h5.copyWith(
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Manajemen Aset',
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items (RBAC Filtered)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AdminConstants.spaceMd),
              children: [
                // 1. DASHBOARD
                // Semua Role punya Dashboard, tapi isinya beda (handled by page)
                 _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  isSelected: currentIndex == 0,
                ),

                // 2. MASTER ASET
                // Admin: Full Access
                // Kasubag, Teknisi, Employee: Read Only (Menu tetap ada)
                // Cleaner: Hidden ? Or Read Only? Spec says Read Only for Teknisi.
                // Let's show for everyone except Cleaner.
                if (userRole != UserRole.cleaner)
                  _buildNavItem(
                    icon: Icons.inventory_2,
                    label: user.isEmployee ? 'Aset Saya' : 'Master Aset', // Ganti nama untuk Employee
                    index: 1,
                    isSelected: currentIndex == 1,
                  ),

                // 3. MAINTENANCE (TIKET)
                // Semua Role bisa akses
                _buildNavItem(
                  icon: Icons.build,
                  label: 'Maintenance',
                  index: 2,
                  isSelected: currentIndex == 2,
                ),

                // 4. PEMINJAMAN (BOOKING/LOAN)
                // Admin, Kasubag, Employee. 
                // Cleaner & Teknisi biasanya tidak pinjam aset operasional kantor (kecuali alat kerja).
                if (userRole != UserRole.cleaner)
                  _buildNavItem(
                    icon: Icons.event,
                    label: 'Peminjaman',
                    index: 3,
                    isSelected: currentIndex == 3,
                  ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AdminConstants.spaceMd,
                    vertical: AdminConstants.spaceSm,
                  ),
                  child: Divider(),
                ),

                // 5. REPORTS
                // Admin, Kasubag
                if (UserRole.isManagement(userRole))
                  _buildNavItem(
                    icon: Icons.assessment,
                    label: 'Laporan',
                    index: 4,
                    isSelected: currentIndex == 4,
                  ),

                // 6. SETTINGS (User Management)
                // Only Admin
                if (user.isAdmin)
                  _buildNavItem(
                    icon: Icons.settings,
                    label: 'Pengaturan',
                    index: 5,
                    isSelected: currentIndex == 5,
                  ),
              ],
            ),
          ),

          // 🛠️ DEBUG ROLE SWITCHER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.yellow[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DEBUG: Ganti Role', style: TextStyle(fontSize: 10, color: Colors.grey)),
                DropdownButton<String>(
                  value: userRole,
                  isDense: true,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  underline: Container(),
                  items: UserRole.allRoles.map((r) => DropdownMenuItem(
                    value: r, 
                    child: Text(UserRole.getRoleDisplayName(r), style: const TextStyle(fontWeight: FontWeight.w600)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(mockUserRoleProvider.notifier).setRole(val);
                    }
                  },
                ),
              ],
            ),
          ),

          // User Profile
          Container(
            padding: const EdgeInsets.all(AdminConstants.spaceMd),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AdminColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AdminColors.primaryLight.withOpacity(0.2),
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                    style: AdminTypography.h5.copyWith(
                      color: AdminColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AdminConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: AdminTypography.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        UserRole.getRoleDisplayName(user.role),
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () {
                     // Logout Logic
                  },
                  color: AdminColors.textSecondary,
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    int? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spaceMd,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigationChanged?.call(index),
          borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminConstants.spaceMd,
              vertical: AdminConstants.spaceSm + 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminColors.primaryLight.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: AdminConstants.iconMd,
                  color: isSelected
                      ? AdminColors.primary
                      : AdminColors.textSecondary,
                ),
                const SizedBox(width: AdminConstants.spaceMd),
                Expanded(
                  child: Text(
                    label,
                    style: AdminTypography.body2.copyWith(
                      color: isSelected
                          ? AdminColors.primary
                          : AdminColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
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

