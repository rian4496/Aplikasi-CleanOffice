// lib/widgets/admin/mobile/layout/mobile_app_bar.dart
// 📱 Mobile Admin AppBar
// Gradient app bar for mobile admin screens

import 'package:flutter/material.dart';
import '../../../../core/design/admin_colors.dart';
import '../../../../core/design/admin_typography.dart';
import '../../../../core/design/admin_constants.dart';

class MobileAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showGradient;
  final VoidCallback? onNotificationTap;

  const MobileAdminAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showGradient = true,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AdminConstants.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showGradient
          ? const BoxDecoration(gradient: AdminColors.appBarGradient)
          : const BoxDecoration(color: AdminColors.primary),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        title: Text(
          title,
          style: AdminTypography.h3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        actions: actions ??
            [
              if (onNotificationTap != null)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: onNotificationTap,
                  color: Colors.white,
                ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  // Navigate to profile
                },
                color: Colors.white,
              ),
              const SizedBox(width: AdminConstants.spaceSm),
            ],
      ),
    );
  }
}
