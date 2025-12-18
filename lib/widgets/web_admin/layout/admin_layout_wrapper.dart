// lib/widgets/web_admin/layout/admin_layout_wrapper.dart
// 🎭 Admin Layout Wrapper
// Automatically switches between mobile and desktop layouts

import 'package:flutter/foundation.dart' show kIsWeb;
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
    // On Web, ALWAYS use desktop layout (sidebar is provided by AdminShellLayout)
    // This prevents BottomNav from appearing even on narrow browser windows
    if (kIsWeb) {
      return _buildDesktopLayout();
    }

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
    // Update: Since we use ShellRoute (AdminShellLayout) which already provides
    // Sidebar and Header, we don't need to render them again here.
    // We just return the content.
    return child;
  }

  // Mobile Layout: Content + BottomNav (no AppBar - handled by parent if needed)
  Widget _buildMobileLayout() {
    return Scaffold(
      // NOTE: Removed MobileAdminAppBar to prevent duplicate header
      // When inside AdminShellLayout, header is already provided
      body: child,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: currentNavIndex,
        onTap: onNavigationChanged,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

