// lib/screens/inventory/inventory_analytics_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Inventory analytics with charts

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../riverpod/inventory_providers.dart';

/// Inventory Analytics Screen - Charts and visualizations for inventory data
/// ✅ MIGRATED: ConsumerWidget → HookConsumerWidget
class InventoryAnalyticsScreen extends HookConsumerWidget {
  const InventoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isInDialog = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Analitik Inventaris',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Visualisasi data dan laporan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Sembunyikan back button jika di web/dialog
        automaticallyImplyLeading: !isInDialog,
        actions: isInDialog
            ? [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ]
            : null,
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Tidak ada data untuk ditampilkan'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allInventoryItemsProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(items),
                  const SizedBox(height: 24),
                  _buildStockStatusPieChart(items),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdownChart(items),
                  const SizedBox(height: 24),
                  _buildStockLevelsBarChart(items),
                  const SizedBox(height: 24),
                  _buildLowStockItemsList(items),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build summary cards
  static Widget _buildSummaryCards(List<InventoryItem> items) {
    final totalItems = items.length;
    final inStock = items.where((i) => i.status == StockStatus.inStock).length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Item',
            totalItems.toString(),
            Icons.inventory_2,
            AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Stok Cukup',
            inStock.toString(),
            Icons.check_circle,
            AppTheme.success,
          ),
        ),
      ],
    );
  }

  /// Build summary card
  static Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stock status pie chart
  static Widget _buildStockStatusPieChart(List<InventoryItem> items) {
    final inStock = items.where((i) => i.status == StockStatus.inStock).length;
    final mediumStock = items.where((i) => i.status == StockStatus.mediumStock).length;
    final lowStock = items.where((i) => i.status == StockStatus.lowStock).length;
    final outOfStock = items.where((i) => i.status == StockStatus.outOfStock).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Stok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (inStock > 0)
                    PieChartSectionData(
                      value: inStock.toDouble(),
                      title: '$inStock',
                      color: AppTheme.success,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (mediumStock > 0)
                    PieChartSectionData(
                      value: mediumStock.toDouble(),
                      title: '$mediumStock',
                      color: Colors.blue,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (lowStock > 0)
                    PieChartSectionData(
                      value: lowStock.toDouble(),
                      title: '$lowStock',
                      color: AppTheme.warning,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (outOfStock > 0)
                    PieChartSectionData(
                      value: outOfStock.toDouble(),
                      title: '$outOfStock',
                      color: AppTheme.error,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (inStock > 0) _buildLegendItem('Stok Cukup', AppTheme.success),
              if (mediumStock > 0) _buildLegendItem('Stok Sedang', Colors.blue),
              if (lowStock > 0) _buildLegendItem('Stok Rendah', AppTheme.warning),
              if (outOfStock > 0) _buildLegendItem('Habis', AppTheme.error),
            ],
          ),
        ],
      ),
    );
  }

  /// Build category breakdown chart
  static Widget _buildCategoryBreakdownChart(List<InventoryItem> items) {
    final categories = <String, int>{};

    for (final item in items) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi per Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...categories.entries.map((entry) {
            final percentage =
                (entry.value / items.length * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCategoryLabel(entry.key),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${entry.value} item ($percentage%)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value / items.length,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _getCategoryColor(entry.key),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build stock levels bar chart
  static Widget _buildStockLevelsBarChart(List<InventoryItem> items) {
    // Top 10 items sorted by stock percentage
    final sortedItems = List<InventoryItem>.from(items)
      ..sort((a, b) => a.stockPercentage.compareTo(b.stockPercentage));

    final topItems = sortedItems.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '10 Item dengan Stok Terendah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barGroups: topItems
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.stockPercentage,
                              color: entry.value.statusColor,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= topItems.length) {
                          return const SizedBox();
                        }
                        final item = topItems[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            item.name.length > 8
                                ? '${item.name.substring(0, 8)}...'
                                : item.name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build low stock items list
  static Widget _buildLowStockItemsList(List<InventoryItem> items) {
    final lowStockItems = items
        .where((item) =>
            item.status == StockStatus.lowStock ||
            item.status == StockStatus.outOfStock)
        .toList()
      ..sort((a, b) => a.currentStock.compareTo(b.currentStock));

    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppTheme.warning),
              const SizedBox(width: 8),
              const Text(
                'Item Perlu Restok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...lowStockItems.take(5).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${item.currentStock}/${item.maxStock} ${item.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        color: item.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Build legend item for pie chart
  static Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get category label in Indonesian
  static String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'alat':
        return 'Alat Kebersihan';
      case 'consumable':
        return 'Bahan Habis Pakai';
      case 'ppe':
        return 'Alat Pelindung Diri';
      default:
        return category;
    }
  }

  /// Get category color for visualization
  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alat':
        return Colors.blue;
      case 'consumable':
        return Colors.orange;
      case 'ppe':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

