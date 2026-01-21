import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../web_admin/advanced_filter_dialog.dart';

/// Dashboard header widget with search, notifications and profile
class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? photoUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap; // For mobile sidebar toggle

  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.photoUrl,
    this.onNotificationTap,
    this.onProfileTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparent background to show scaffold bg
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (isMobile && onMenuTap != null)
                IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.textSecondary),
                  onPressed: onMenuTap,
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),

              // Search Bar (Hidden on small mobile)
              if (!isMobile)
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              border: InputBorder.none,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AdvancedFilterDialog(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 10),

              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 10),
              _buildIconButton(
                icon: Icons.info_outline_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 10),

              // Profile
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primary,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

