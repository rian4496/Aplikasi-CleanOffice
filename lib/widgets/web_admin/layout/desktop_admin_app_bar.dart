// lib/widgets/web_admin/layout/desktop_admin_app_bar.dart
// 💻 Desktop Admin AppBar
// Wide app bar for desktop with search and notifications

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class DesktopAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final ValueChanged<String>? onSearch;

  const DesktopAdminAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spaceLg,
      ),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AdminColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title
          Text(
            title,
            style: AdminTypography.h4,
          ),

          const SizedBox(width: AdminConstants.spaceLg),

          // Search Bar
          Expanded(
            flex: 2,
            child: Container(
              height: 44,
              constraints: const BoxConstraints(maxWidth: 600),
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari laporan, permintaan, petugas...',
                  hintStyle: AdminTypography.body2.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AdminColors.textSecondary,
                    size: AdminConstants.iconMd,
                  ),
                  filled: true,
                  fillColor: AdminColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AdminConstants.spaceMd,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Quick Actions
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Show create menu
            },
            tooltip: 'Buat Baru',
            iconSize: AdminConstants.iconMd,
            color: AdminColors.textSecondary,
          ),

          const SizedBox(width: AdminConstants.spaceSm),

          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onNotificationTap,
                tooltip: 'Notifikasi',
                iconSize: AdminConstants.iconMd,
                color: AdminColors.textSecondary,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AdminColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AdminConstants.spaceSm),

          // Profile
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AdminConstants.spaceXs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AdminColors.primaryLight.withOpacity(0.2),
                    child: Text(
                      'A',
                      style: AdminTypography.body2.copyWith(
                        color: AdminColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spaceSm),
                  Text(
                    'Admin',
                    style: AdminTypography.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spaceXs),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: AdminConstants.iconSm,
                    color: AdminColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

