// lib/screens/admin/analytics/analytics_screen.dart
// 📊 Analytics Screen
// View analytics and reports with time range selection

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/admin/layout/mobile_admin_app_bar.dart';
import '../../../widgets/admin/layout/admin_bottom_nav.dart';
import '../../../widgets/admin/cards/pastel_stat_card.dart';

enum TimeRange { week, month, quarter, year }

class AnalyticsScreen extends HookConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeRange = useState(TimeRange.week);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const MobileAdminAppBar(
        title: 'Analytics',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Selector
            _buildTimeRangeSelector(selectedTimeRange),

            const SizedBox(height: AdminConstants.spaceMd),

            // Key Metrics
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminConstants.screenPaddingHorizontal,
              ),
              child: Text(
                'Metrik Utama',
                style: AdminTypography.h5,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),

            _buildKeyMetricsGrid(),

            const SizedBox(height: AdminConstants.spaceLg),

            // Charts Section (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminConstants.screenPaddingHorizontal,
              ),
              child: Text(
                'Grafik',
                style: AdminTypography.h5,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),

            _buildChartsPlaceholder(),

            const SizedBox(height: AdminConstants.spaceLg),

            // Export Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminConstants.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: AdminTypography.h5,
                  ),
                  const SizedBox(height: AdminConstants.spaceSm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_download),
                          label: const Text('CSV'),
                        ),
                      ),
                      const SizedBox(width: AdminConstants.spaceSm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_download),
                          label: const Text('Excel'),
                        ),
                      ),
                      const SizedBox(width: AdminConstants.spaceSm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(ValueNotifier<TimeRange> selectedTimeRange) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
        vertical: AdminConstants.spaceSm,
      ),
      child: Row(
        children: [
          _buildTimeRangeChip('7D', TimeRange.week, selectedTimeRange),
          const SizedBox(width: AdminConstants.spaceSm),
          _buildTimeRangeChip('30D', TimeRange.month, selectedTimeRange),
          const SizedBox(width: AdminConstants.spaceSm),
          _buildTimeRangeChip('90D', TimeRange.quarter, selectedTimeRange),
          const SizedBox(width: AdminConstants.spaceSm),
          _buildTimeRangeChip('1Y', TimeRange.year, selectedTimeRange),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(
    String label,
    TimeRange range,
    ValueNotifier<TimeRange> selectedTimeRange,
  ) {
    final isSelected = selectedTimeRange.value == range;
    return Expanded(
      child: GestureDetector(
        onTap: () => selectedTimeRange.value = range,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AdminColors.primary
                : AdminColors.surface,
            borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AdminColors.primary
                  : AdminColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AdminTypography.button.copyWith(
              color: isSelected
                  ? Colors.white
                  : AdminColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AdminConstants.gridGap,
        mainAxisSpacing: AdminConstants.gridGap,
        childAspectRatio: 1.2,
        children: [
          PastelStatCard(
            icon: Icons.trending_up,
            label: 'Total Reports',
            value: '1,234',
            trend: '+12%',
            trendUp: true,
            progress: 0.75,
            backgroundColor: AdminColors.cardBlueBg,
            foregroundColor: AdminColors.cardBlueDark,
          ),
          PastelStatCard(
            icon: Icons.speed,
            label: 'Avg Response',
            value: '2.5h',
            trend: '-8%',
            trendUp: true,
            progress: 0.85,
            backgroundColor: AdminColors.cardGreenBg,
            foregroundColor: AdminColors.cardGreenDark,
          ),
          PastelStatCard(
            icon: Icons.check_circle,
            label: 'Completion Rate',
            value: '94%',
            trend: '+3%',
            trendUp: true,
            progress: 0.94,
            backgroundColor: AdminColors.cardPurpleBg,
            foregroundColor: AdminColors.cardPurpleDark,
          ),
          PastelStatCard(
            icon: Icons.star,
            label: 'Avg Rating',
            value: '4.7',
            trend: '+0.2',
            trendUp: true,
            progress: 0.94,
            backgroundColor: AdminColors.cardYellowBg,
            foregroundColor: AdminColors.cardYellowDark,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
      ),
      padding: const EdgeInsets.all(AdminConstants.spaceLg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: AdminConstants.borderRadiusCard,
        boxShadow: AdminConstants.shadowCard,
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: AdminColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: AdminConstants.spaceMd),
          Text(
            'Grafik Akan Ditampilkan di Sini',
            style: AdminTypography.body2.copyWith(
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: AdminConstants.spaceSm),
          Text(
            'Chart widgets (fl_chart) akan diimplementasikan',
            style: AdminTypography.caption.copyWith(
              color: AdminColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
