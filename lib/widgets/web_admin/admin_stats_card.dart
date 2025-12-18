// lib/widgets/web_admin/admin_stats_card.dart
// Reusable stats card widget for Admin dashboard

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class AdminStatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;
  
  const AdminStatsCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.cardBorderRadius(context),
      ),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context) * 0.75),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.cardBorderRadius(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isDesktop ? 28 : 24,
              ),
            ),
            const SizedBox(height: 12),
            
            // Value
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.bodyFontSize(context) * 0.85,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

