// lib/widgets/shared/drawer_menu_widget.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

/// Drawer Menu Widget - Reusable untuk semua role
/// Bisa dipakai di Employee, Cleaner, bahkan Admin
/// 
/// Usage:
/// ```dart
/// Drawer(
///   child: DrawerMenuWidget(
///     menuItems: [
///       DrawerMenuItem(icon: Icons.home, title: 'Beranda', onTap: () {}),
///       DrawerMenuItem(icon: Icons.task, title: 'Tugas', onTap: () {}),
///     ],
///     onLogout: () => _handleLogout(),
///   ),
/// )
/// ```
class DrawerMenuWidget extends StatelessWidget {
  /// List menu items yang akan ditampilkan
  final List<DrawerMenuItem> menuItems;

  /// Callback ketika logout di-tap
  final VoidCallback onLogout;

  /// Custom user profile (optional)
  final UserProfile? userProfile;

  /// Judul role (optional, contoh: "Petugas Kebersihan", "Employee")
  final String? roleTitle;

  const DrawerMenuWidget({
    super.key,
    required this.menuItems,
    required this.onLogout,
    this.userProfile,
    this.roleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header dengan avatar, nama, email
          _buildHeader(userProfile),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Render semua menu items
                ...menuItems.map((item) => _buildMenuItem(item)),

                // Divider sebelum logout (tipis, minimalis grey)
                Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),

                // Logout button with confirmation
                _buildMenuItem(
                  DrawerMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    onTap: () => _showLogoutConfirmation(context),
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey[300],
            backgroundImage: profile?.photoURL != null
                ? NetworkImage(profile!.photoURL!)
                : null,
            child: profile?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          const SizedBox(height: 12),

          // Nama
          Text(
            profile?.displayName ?? roleTitle ?? 'User',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Email
          if (profile != null)
            Text(
              profile.email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah anda ingin logout?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          // BATAL button (Blue)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'BATAL',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // KELUAR button (Red)
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onLogout(); // Call logout callback
            },
            child: const Text(
              'KELUAR',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isDestructive ? AppTheme.error : Colors.grey[700],
        size: 24,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 16,
          color: item.isDestructive ? AppTheme.error : Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: item.badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: item.onTap, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      enabled: item.enabled,
    );
  }
}

/// Data class untuk drawer menu item
class DrawerMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap; // ✅ Nullable
  final bool isDestructive;
  final bool enabled;
  final int? badge;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    this.onTap, // ✅ Opsional
    this.isDestructive = false,
    this.enabled = true,
    this.badge,
  });
}