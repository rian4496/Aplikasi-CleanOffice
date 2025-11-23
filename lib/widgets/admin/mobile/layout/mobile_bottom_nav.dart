// lib/widgets/admin/mobile/layout/mobile_bottom_nav.dart
// 📱 Mobile Bottom Navigation
// Bottom navigation bar for mobile admin screens

import 'package:flutter/material.dart';
import '../../../../core/design/admin_colors.dart';
import '../../../../core/design/admin_constants.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AdminConstants.radiusLg),
          topRight: Radius.circular(AdminConstants.radiusLg),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AdminConstants.radiusLg),
          topRight: Radius.circular(AdminConstants.radiusLg),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AdminColors.surface,
          selectedItemColor: AdminColors.primary,
          unselectedItemColor: AdminColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Lainnya',
            ),
          ],
        ),
      ),
    );
  }
}
