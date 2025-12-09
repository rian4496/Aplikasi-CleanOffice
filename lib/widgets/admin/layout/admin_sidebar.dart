// lib/widgets/admin/layout/admin_sidebar.dart
// 🗂️ Admin Sidebar
// Desktop persistent navigation sidebar

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                Column(
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
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AdminConstants.spaceMd),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.inventory_2,
                  label: 'Aset',
                  index: 1,
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.build,
                  label: 'Maintenance',
                  index: 2,
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  icon: Icons.event,
                  label: 'Booking',
                  index: 3,
                  isSelected: currentIndex == 3,
                ),
                _buildNavItem(
                  icon: Icons.inventory,
                  label: 'Inventaris',
                  index: 4,
                  isSelected: currentIndex == 4,
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AdminConstants.spaceMd,
                    vertical: AdminConstants.spaceSm,
                  ),
                  child: Divider(),
                ),

                _buildNavItem(
                  icon: Icons.assessment,
                  label: 'Reports',
                  index: 5,
                  isSelected: currentIndex == 5,
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Pengaturan',
                  index: 6,
                  isSelected: currentIndex == 6,
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
                    'A',
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
                        'Admin',
                        style: AdminTypography.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin@cleanoffice.com',
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
                    // Handle logout
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
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.error,
                      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    ),
                    child: Text(
                      badge.toString(),
                      style: AdminTypography.badge.copyWith(
                        color: Colors.white,
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
