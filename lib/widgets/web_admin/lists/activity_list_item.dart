// lib/widgets/web_admin/lists/activity_list_item.dart
// 📌 Activity List Item
// Compact list item for recent activities

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class ActivityListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const ActivityListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Setup Indonesian locale for timeago
    timeago.setLocaleMessages('id', timeago.IdMessages());
    final timeAgo = timeago.format(timestamp, locale: 'id');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AdminConstants.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spaceMd,
            vertical: AdminConstants.spaceSm,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AdminConstants.spaceSm),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: AdminConstants.iconSm,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AdminConstants.spaceMd),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AdminTypography.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AdminConstants.spaceSm),
              
              // Timestamp
              Text(
                timeAgo,
                style: AdminTypography.caption.copyWith(
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

