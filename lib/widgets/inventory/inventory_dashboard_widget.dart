import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../riverpod/inventory_providers.dart';
import '../../models/inventory_item.dart';
import '../../models/stock_history.dart';
import '../../widgets/shared/responsive_stats_grid.dart';

class InventoryDashboardWidget extends ConsumerWidget {
  const InventoryDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    // TODO: Add provider for pending requests count
    // final pendingRequestsAsync = ref.watch(pendingStockRequestsProvider); 

    return itemsAsync.when(
      data: (items) {
        // Calculate Stats
        final totalItems = items.length;
        final lowStockItems = items.where((i) => i.status == StockStatus.lowStock).length;
        final outOfStockItems = items.where((i) => i.status == StockStatus.outOfStock).length;
        
        // Mock value (In real app, multiply stock * cost)
        // final totalValue = 15000000; 

        // Check Mobile
        final isMobile = MediaQuery.of(context).size.width < 600;

        // Stats List
        final statsList = [
          _buildStatCard(
            context,
            title: 'Total Item',
            value: totalItems.toString(),
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            isMobile: isMobile,
          ),
          _buildStatCard(
            context,
            title: 'Stok Menipis',
            value: lowStockItems.toString(),
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            isAlert: lowStockItems > 0,
            subtitle: lowStockItems > 0 ? 'Restock' : 'Aman',
            isMobile: isMobile,
          ),
          _buildStatCard(
            context,
            title: 'Stok Habis',
            value: outOfStockItems.toString(),
            icon: Icons.cancel_outlined,
            color: Colors.red,
            isAlert: outOfStockItems > 0,
            subtitle: 'Kritis',
            isMobile: isMobile,
          ),
          InkWell(
            onTap: () => context.push('/admin/inventory/requests'),
            child: _buildStatCard(
              context,
              title: 'Permintaan',
              value: ref.watch(pendingStockRequestsProvider).maybeWhen(
                data: (reqs) => reqs.length.toString(),
                orElse: () => '0',
              ),
              icon: Icons.assignment_late_outlined,
              color: Colors.purple,
              subtitle: 'Wait Approval',
              isMobile: isMobile,
            ),
          ),
        ];

        if (isMobile) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statsList.map((w) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(width: 140, child: w), // Fixed slim width
              )).toList(),
            ),
          );
        }

        return Column(
          children: [
            ResponsiveStatsGrid(
              children: statsList,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool trendUp = true,
    bool isAlert = false,
    String? subtitle,
    bool isMobile = false,
  }) {
    // Preferred User Style: Icon Top Right, Text Left
    // Compact Stat Card Style
    return Container(
      // Remove fixed height or make it much smaller
      height: isMobile ? 85 : 120, 
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAlert ? color.withValues(alpha: 0.5) : Colors.grey.shade200),
        boxShadow: isMobile ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Title & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: isMobile ? 16 : 20),
              ),
            ],
          ),
          
          // Bottom Row: Value & Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24, 
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  height: 1.0, 
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isAlert ? color : Colors.grey.shade500,
                      fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
