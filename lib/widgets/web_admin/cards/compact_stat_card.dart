// lib/widgets/web_admin/cards/compact_stat_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final double progress; // 0.0 to 1.0
  final bool trendUp;
  final String? trendValue;

  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.progress = 0.0,
    this.trendUp = true,
    this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16), // Softer radius
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.8), width: 1.2), // STRONGER BORDER
        boxShadow: [
          // Tighter shadow for depth
          BoxShadow(
            color: (iconColor ?? Colors.black).withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          // Softer shadow for lift
          BoxShadow(
            color: (iconColor ?? Colors.black).withValues(alpha: 0.08), // STRONGER GLOW
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with light background
              Container(
                padding: const EdgeInsets.all(12), // Larger icon area
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24, // Larger icon
                  color: iconColor ?? AppTheme.primary,
                ),
              ),
              // Trend indicator
              if (trendValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trendUp ? AppTheme.success : AppTheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendValue!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: trendUp ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor ?? AppTheme.primary),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

