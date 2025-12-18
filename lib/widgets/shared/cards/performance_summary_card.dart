import 'package:flutter/material.dart';
import '../../../core/design/shared_design_constants.dart';

/// Performance Summary Card (Ringkasan Kinerja)
/// Displays completion rate, task stats, and performance metrics
/// Used in Employee and Cleaner home screens
class PerformanceSummaryCard extends StatelessWidget {
  final String title;
  final double completionRate; // 0-100
  final List<MetricItem> metrics;
  final Color primaryColor;
  final String? badge; // e.g. "Maluk", "Baik"
  final Color? badgeColor;

  const PerformanceSummaryCard({
    super.key,
    this.title = 'Ringkasan Kinerja',
    required this.completionRate,
    required this.metrics,
    required this.primaryColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SharedDesignConstants.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SharedDesignConstants.borderRadiusMd,
        boxShadow: SharedDesignConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: Color(0xFF1F2937),
              ),
              const SizedBox(width: SharedDesignConstants.spaceXs),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: SharedDesignConstants.spaceMd),

          // Completion Rate Progress Bar
          _buildProgressSection(
            label: 'Tingkat Penyelesaian',
            value: completionRate,
            badge: badge,
            badgeColor: badgeColor,
          ),

          const SizedBox(height: SharedDesignConstants.spaceMd),

          // Metrics Grid
          _buildMetricsGrid(),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String label,
    required double value,
    String? badge,
    Color? badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            Row(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor?.withValues(alpha: 0.1) ??
                          primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeColor ?? primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar with animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: animValue / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Wrap(
      spacing: SharedDesignConstants.spaceMd,
      runSpacing: SharedDesignConstants.spaceSm,
      children: metrics.map((metric) => _buildMetricItem(metric)).toList(),
    );
  }

  Widget _buildMetricItem(MetricItem metric) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: metric.color ?? primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${metric.label}: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          metric.value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

/// Metric item for performance summary
class MetricItem {
  final String label;
  final String value;
  final Color? color;

  const MetricItem({
    required this.label,
    required this.value,
    this.color,
  });
}

