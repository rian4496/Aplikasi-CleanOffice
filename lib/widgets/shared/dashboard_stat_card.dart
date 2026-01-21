// lib/widgets/shared/dashboard_stat_card.dart
// 📊 Reusable Dashboard Stat Card Widget
// Used by both Admin and Employee dashboards for consistency

import 'package:flutter/material.dart';

/// A reusable stat card widget for mobile dashboards.
/// 
/// Displays a statistic with:
/// - Circular icon background
/// - Large value text
/// - Label below
/// - Optional badge (e.g., "Perlu Tindakan", "Priority")
/// 
/// Usage:
/// ```dart
/// DashboardStatCard(
///   icon: Icons.calendar_today_rounded,
///   label: 'Tiket Hari Ini',
///   value: '5',
///   bgColor: Color(0xFFEFF8FF),
///   iconColor: Color(0xFF2E90FA),
/// )
/// ```
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bgColor;
  final Color iconColor;
  final bool showBadge;
  final String badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;
  final Color? badgeBorderColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.iconColor,
    this.showBadge = false,
    this.badgeText = 'Perlu Tindakan',
    this.badgeBgColor,
    this.badgeTextColor,
    this.badgeBorderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  
                  const SizedBox(height: 12),

                  // Bottom: Value and Label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          height: 1.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Badge (optional)
            if (showBadge)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor ?? const Color(0xFFFEF3F2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeBorderColor ?? const Color(0xFFFECDCA)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      color: badgeTextColor ?? const Color(0xFFB42318),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Preset color schemes for common stat card types
class StatCardColors {
  // Blue - Today/Current
  static const Color blueBg = Color(0xFFEFF8FF);
  static const Color blueIcon = Color(0xFF2E90FA);
  
  // Purple/Indigo - This Week
  static const Color purpleBg = Color(0xFFF9F5FF);
  static const Color purpleIcon = Color(0xFF6941C6);
  
  // Pink - This Month
  static const Color pinkBg = Color(0xFFFDF2FA);
  static const Color pinkIcon = Color(0xFFC11574);
  
  // Red - Open/Urgent
  static const Color redBg = Color(0xFFFEF3F2);
  static const Color redIcon = Color(0xFFB42318);
  
  // Green - Completed/Success
  static const Color greenBg = Color(0xFFF0FDF4);
  static const Color greenIcon = Color(0xFF15803D);
  
  // Yellow - Pending/Warning
  static const Color yellowBg = Color(0xFFFEFCE8);
  static const Color yellowIcon = Color(0xFFA16207);
  
  // Orange - In Progress
  static const Color orangeBg = Color(0xFFFFF7ED);
  static const Color orangeIcon = Color(0xFFC2410C);
}
