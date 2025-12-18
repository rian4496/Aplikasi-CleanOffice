// lib/widgets/web_admin/lists/activities_section.dart
// 📋 Activities Section
// Recent activities list with header

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import 'activity_list_item.dart';

class ActivitiesSection extends StatelessWidget {
  final String title;
  final List<ActivityData> activities;
  final VoidCallback? onViewAll;
  final int maxItems;

  const ActivitiesSection({
    super.key,
    this.title = 'Aktivitas Terkini',
    required this.activities,
    this.onViewAll,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayedActivities = activities.take(maxItems).toList();

    if (displayedActivities.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
        vertical: AdminConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: AdminConstants.borderRadiusCard,
        boxShadow: AdminConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AdminConstants.spaceMd),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AdminConstants.iconSm,
                  color: AdminColors.primary,
                ),
                const SizedBox(width: AdminConstants.spaceSm),
                Text(
                  title,
                  style: AdminTypography.cardTitle.copyWith(
                    color: AdminColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminConstants.spaceSm,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: AdminTypography.caption.copyWith(
                            color: AdminColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AdminColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Activity list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedActivities.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 56,
            ),
            itemBuilder: (context, index) {
              final activity = displayedActivities[index];
              return ActivityListItem(
                icon: activity.icon,
                iconColor: activity.iconColor,
                title: activity.title,
                subtitle: activity.subtitle,
                timestamp: activity.timestamp,
                onTap: activity.onTap,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
        vertical: AdminConstants.spaceSm,
      ),
      padding: const EdgeInsets.all(AdminConstants.spaceLg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: AdminConstants.borderRadiusCard,
        boxShadow: AdminConstants.shadowCard,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AdminColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            Text(
              'Belum ada aktivitas',
              style: AdminTypography.body2.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity data class
class ActivityData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const ActivityData({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.onTap,
  });
}

