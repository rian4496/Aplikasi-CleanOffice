// lib/widgets/admin/dashboard/dashboard_stats_grid.dart

import 'package:flutter/material.dart';
import '../../../models/stat_card_data.dart';
import '../cards/modern_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  final List<StatCardData> stats;
  final bool isDesktop;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      // 2x2 Grid for desktop
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return ModernStatCard(data: stats[index]);
        },
      );
    } else {
      // 1 column for mobile
      return Column(
        children: stats
            .map((stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ModernStatCard(data: stat),
                ))
            .toList(),
      );
    }
  }
}
