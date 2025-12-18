import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../models/inventory_item.dart';
import '../../models/stock_history.dart';

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

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Item',
                    value: totalItems.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    trend: '+2 item baru',
                    trendUp: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Stok Menipis',
                    value: lowStockItems.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                    isAlert: lowStockItems > 0,
                    subtitle: lowStockItems > 0 ? 'Perlu Restock Segera' : 'Stok Aman',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Stok Habis',
                    value: outOfStockItems.toString(),
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    isAlert: outOfStockItems > 0,
                    subtitle: 'Kritis',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
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
                      subtitle: 'Menunggu Approval',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Text('Error loading dashboard: $err', style: const TextStyle(color: Colors.red)),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAlert ? Border.all(color: color.withOpacity(0.5)) : null,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isAlert ? color : Colors.grey.shade500,
                      fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
