import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
import 'admin_sidebar.dart'; // Updated import path
import 'desktop_admin_header.dart';
import '../../shared/notification_bell.dart';
import '../../shared/realtime_notification_listener.dart';

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
    if (currentPath.contains('profile')) currentRoute = '/admin/profile'; // Added Profile
    if (currentPath.contains('dashboard')) currentRoute = '/admin/dashboard';
    if (currentPath.contains('cleaner')) currentRoute = '/console/cleaner/dashboard'; // Added for Cleaner

    // DESKTOP LAYOUT (Sidebar + Content)
    if (isDesktop) {
      return RealtimeNotificationListener(
        child: Scaffold(
          backgroundColor: AppTheme.modernBg,
          body: Row(
            children: [
              // Persistent Sidebar
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
        ),
      );
    }

    // MOBILE/TABLET WEB LAYOUT
    // Special Case: Cleaner Dashboard handles its own layout (Custom Header + EndDrawer)
    if (currentRoute == '/console/cleaner/dashboard') {
      return child; 
    }

    // Check if on dashboard
    final bool isDashboard = currentPath == '/admin/dashboard' || currentPath == '/admin';

    // Non-dashboard pages: Let individual screens handle their own AppBar
    // This prevents duplicate headers
    if (!isDashboard) {
      return RealtimeNotificationListener(child: child);
    }

    // Dashboard only: Show AppBar with notification + hamburger menu
    return RealtimeNotificationListener(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            // Notification Bell
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: NotificationBell(
                iconColor: Colors.black87,
                onTap: () => context.push('/admin/notifications'),
              ),
            ),
            // Hamburger Menu (Triggers EndDrawer)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        endDrawer: AdminSidebar(currentRoute: currentRoute, isDrawer: true),
        body: child,
      ),
    );
  }
}

