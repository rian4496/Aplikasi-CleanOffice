import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import '../admin_sidebar.dart'; // Uses original ../admin_sidebar.dart (not layout/)
import 'desktop_admin_header.dart';

class AdminShellLayout extends ConsumerWidget {
  final Widget child;

  const AdminShellLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Get current route path to highlight sidebar
    final String currentPath = GoRouterState.of(context).uri.path;
    String currentRoute = 'dashboard';
    
    // Logic mapping path to sidebar keys
    if (currentPath.contains('assets') || currentPath.contains('master')) currentRoute = '/admin/master/aset'; // Default highlight for master
    if (currentPath.contains('pegawai')) currentRoute = '/admin/master/pegawai';
    if (currentPath.contains('organisasi')) currentRoute = '/admin/master/organisasi';
    if (currentPath.contains('anggaran')) currentRoute = '/admin/master/anggaran';
    if (currentPath.contains('vendor')) currentRoute = '/admin/master/vendor';
    
    if (currentPath.contains('loans')) currentRoute = '/admin/loans';
    if (currentPath.contains('maintenance')) currentRoute = '/admin/maintenance';
    if (currentPath.contains('inventory')) currentRoute = '/admin/inventory';
    if (currentPath.contains('procurement')) currentRoute = '/admin/procurement';
    if (currentPath.contains('disposal')) currentRoute = '/admin/disposal';
    if (currentPath.contains('reports')) currentRoute = '/admin/reports';
    if (currentPath.contains('users')) currentRoute = '/admin/users';
    if (currentPath.contains('settings')) currentRoute = '/admin/settings';
    if (currentPath.contains('dashboard')) currentRoute = '/admin/dashboard';


    if (!isDesktop) {
      return child;
    }

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: Row(
        children: [
          // Persistent Sidebar (Original Full Menu)
          AdminSidebar(currentRoute: currentRoute),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                const DesktopAdminHeader(), 
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

