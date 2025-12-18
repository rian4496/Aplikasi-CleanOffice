// lib/widgets/web_admin/cards/greeting_card.dart
// 👋 Greeting Card
// Displays greeting message with user name and date

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class GreetingCard extends StatelessWidget {
  final String userName;
  final bool compact;
  final Widget? avatar;

  const GreetingCard({
    super.key,
    required this.userName,
    this.compact = true,
    this.avatar,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Container(
      margin: EdgeInsets.all(compact ? AdminConstants.spaceMd : AdminConstants.spaceLg),
      padding: EdgeInsets.all(compact ? AdminConstants.spaceMd : AdminConstants.spaceLg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: AdminConstants.borderRadiusCard,
        boxShadow: AdminConstants.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: (compact ? AdminTypography.body2 : AdminTypography.body1).copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AdminConstants.spaceXs),
                Text(
                  userName,
                  style: compact ? AdminTypography.h4 : AdminTypography.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AdminConstants.spaceXs),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: compact ? AdminConstants.iconXs : AdminConstants.iconSm,
                      color: AdminColors.textSecondary,
                    ),
                    const SizedBox(width: AdminConstants.spaceXs),
                    Flexible(
                      child: Text(
                        dateStr,
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (avatar != null) ...[
            const SizedBox(width: AdminConstants.spaceMd),
            avatar!,
          ] else ...[
            const SizedBox(width: AdminConstants.spaceMd),
            CircleAvatar(
              radius: compact ? 24 : 32,
              backgroundColor: AdminColors.primaryLight.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: AdminColors.primary,
                size: compact ? AdminConstants.iconMd : AdminConstants.iconLg,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

