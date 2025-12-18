// lib/widgets/web_admin/cards/pastel_stat_card.dart
// 📊 Pastel Stat Card
// Colorful stat card with pastel background for mobile

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class PastelStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool trendUp;
  final double progress; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  const PastelStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp = true,
    this.progress = 0.0,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AdminColors.cardBlueBg;
    final fgColor = foregroundColor ?? AdminColors.cardBlueDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AdminConstants.borderRadiusCard,
        child: Container(
          padding: AdminConstants.cardPaddingAll,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AdminConstants.borderRadiusCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon & Label row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AdminConstants.spaceSm),
                    decoration: BoxDecoration(
                      color: fgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: AdminConstants.iconSm,
                      color: fgColor,
                    ),
                  ),
                  const Spacer(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminConstants.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: trendUp
                            ? AdminColors.success.withOpacity(0.15)
                            : AdminColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp ? Icons.trending_up : Icons.trending_down,
                            size: 12,
                            color: trendUp ? AdminColors.success : AdminColors.error,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend!,
                            style: AdminTypography.badge.copyWith(
                              color: trendUp ? AdminColors.success : AdminColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AdminConstants.spaceMd),
              
              // Value
              Text(
                value,
                style: AdminTypography.statNumberMobile.copyWith(color: fgColor),
              ),
              const SizedBox(height: AdminConstants.spaceXs),
              
              // Label
              Text(
                label,
                style: AdminTypography.statLabel.copyWith(color: fgColor.withOpacity(0.8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AdminConstants.spaceSm),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AdminConstants.radiusXs),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: fgColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

