import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isHeader;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isHeader = false,
  });

  static SidebarItem header(String title) =>
      SidebarItem(title: title, icon: Icons.abc, route: '', isHeader: true);
}

class SidebarNavigation extends StatelessWidget {
  final List<SidebarItem> items;
  final String currentRoute;
  final VoidCallback? onLogout;

  const SidebarNavigation({
    super.key,
    required this.items,
    required this.currentRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Area
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.cleaning_services_rounded, color: AppTheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'CleanOffice',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 20),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                
                if (item.isHeader) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                    child: Text(
                      item.title.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }

                final isActive = currentRoute == item.route;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => context.go(item.route),
                    leading: Icon(
                      item.icon,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    dense: true,
                  ),
                );
              },
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: onLogout,
                leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

