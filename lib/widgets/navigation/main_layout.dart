import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_header.dart';
import 'sidebar_navigation.dart';
import '../../core/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final List<SidebarItem> sidebarItems;
  final String currentRoute;
  final String headerTitle;
  final String headerSubtitle;
  final String? userPhotoUrl;
  final VoidCallback? onLogout;
  
  // Mobile specific callbacks
  final int? bottomNavIndex;
  final Function(int)? onBottomNavTap;

  const MainLayout({
    super.key,
    required this.child,
    required this.sidebarItems,
    required this.currentRoute,
    required this.headerTitle,
    required this.headerSubtitle,
    this.userPhotoUrl,
    this.onLogout,
    this.bottomNavIndex,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.background,
      
      // Desktop: No Drawer, Mobile: Right Side Drawer (EndDrawer)
      endDrawer: !isDesktop
          ? Drawer(
              width: 280,
              child: SidebarNavigation(
                items: sidebarItems, // Full menu in drawer
                currentRoute: currentRoute,
                onLogout: onLogout,
              ),
            )
          : null,
          
      body: Row(
        children: [
          // Sidebar (Desktop Only)
          if (isDesktop)
            SidebarNavigation(
              items: sidebarItems,
              currentRoute: currentRoute,
              onLogout: onLogout,
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                DashboardHeader(
                  title: headerTitle,
                  subtitle: headerSubtitle,
                  photoUrl: userPhotoUrl,
                  // Mobile: Hide menu button in header (we use bottom nav 'More')
                  onMenuTap: null, 
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Mobile Bottom Navigation - Modern Design
      bottomNavigationBar: !isDesktop
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isActive: (bottomNavIndex ?? 0) == 0,
                        onTap: () => onBottomNavTap?.call(0),
                      ),
                      _buildNavItem(
                        icon: Icons.assignment_rounded,
                        label: 'Laporan',
                        isActive: (bottomNavIndex ?? 0) == 1,
                        onTap: () => onBottomNavTap?.call(1),
                      ),
                      _buildNavItem(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Chat',
                        isActive: (bottomNavIndex ?? 0) == 2,
                        onTap: () => onBottomNavTap?.call(2),
                      ),
                      _buildNavItem(
                        icon: Icons.menu_rounded,
                        label: 'More',
                        isActive: (bottomNavIndex ?? 0) == 3,
                        onTap: () {
                          scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF5D5FEF); // Blue color
    final inactiveColor = Colors.grey[600]!;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

