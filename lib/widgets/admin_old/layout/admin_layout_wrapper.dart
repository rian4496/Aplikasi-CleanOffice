// lib/widgets/admin/layout/admin_layout_wrapper.dart
// 🎭 Admin Layout Wrapper
// Automatically switches between mobile and desktop layouts

import 'package:flutter/material.dart';
import '../../../core/design/admin_constants.dart';
import 'admin_sidebar.dart';
import 'desktop_admin_app_bar.dart';
import 'mobile_admin_app_bar.dart';
import 'admin_bottom_nav.dart';

class AdminLayoutWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final int currentNavIndex;
  final ValueChanged<int>? onNavigationChanged;
  final VoidCallback? onNotificationTap;
  final ValueChanged<String>? onSearch;
  final Widget? floatingActionButton;

  const AdminLayoutWrapper({
    super.key,
    required this.title,
    required this.child,
    this.currentNavIndex = 0,
    this.onNavigationChanged,
    this.onNotificationTap,
    this.onSearch,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AdminConstants.tabletBreakpoint;

        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // Desktop Layout: Sidebar + AppBar + Content
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          AdminSidebar(
            currentIndex: currentNavIndex,
            onNavigationChanged: onNavigationChanged,
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Desktop AppBar
                DesktopAdminAppBar(
                  title: title,
                  onNotificationTap: onNotificationTap,
                  onSearch: onSearch,
                ),

                // Scrollable Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  // Mobile Layout: AppBar + Content + BottomNav
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: MobileAdminAppBar(
        title: title,
        onNotificationTap: onNotificationTap,
      ),
      body: child,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: currentNavIndex,
        onTap: onNavigationChanged,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
