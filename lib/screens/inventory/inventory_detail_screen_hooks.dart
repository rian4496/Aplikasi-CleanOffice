// lib/screens/inventory/inventory_detail_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Detailed view of inventory item with actions and history

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../models/user_role.dart';
import '../../services/inventory_service.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/inventory/stock_adjustment_dialog.dart';
import '../../widgets/inventory/request_stock_dialog.dart';
import './inventory_add_edit_screen.dart';
import './stock_history_screen.dart';

/// Inventory Detail Screen - View item details with actions (admin/cleaner specific)
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class InventoryDetailScreen extends HookConsumerWidget {
  final String itemId;

  const InventoryDetailScreen({
    required this.itemId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Service memoization
    final inventoryService = useMemoized(() => InventoryService());

    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(context, isAdmin, itemId, inventoryService),
      body: StreamBuilder<List<InventoryItem>>(
        stream: inventoryService.streamAllItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final items = snapshot.data ?? [];
          final item = items.where((i) => i.id == itemId).firstOrNull;

          if (item == null) {
            return _buildNotFound(context);
          }

          return _buildContent(context, item, isAdmin, inventoryService);
        },
      ),
      floatingActionButton:
          isAdmin ? _buildFAB(context, itemId, inventoryService) : null,
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build app bar
  static AppBar _buildAppBar(
    BuildContext context,
    bool isAdmin,
    String itemId,
    InventoryService inventoryService,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Detail Item',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: isAdmin
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _confirmDelete(context, itemId, inventoryService),
                tooltip: 'Hapus Item',
              ),
            ]
          : null,
    );
  }

  /// Build content
  static Widget _buildContent(
    BuildContext context,
    InventoryItem item,
    bool isAdmin,
    InventoryService inventoryService,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItemCard(item),
          const SizedBox(height: 16),
          _buildStockCard(item),
          const SizedBox(height: 16),
          _buildActionsCard(context, item, isAdmin),
          const SizedBox(height: 16),
          _buildDescriptionCard(item),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build item card with image and metadata
  static Widget _buildItemCard(InventoryItem item) {
    final category = ItemCategory.values.firstWhere(
      (c) => c.name == item.category,
      orElse: () => ItemCategory.alat,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          if (item.imageUrl != null) const SizedBox(height: 20),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: category.color),
                const SizedBox(width: 6),
                Text(
                  category.label,
                  style: TextStyle(
                    color: category.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Item Name
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Unit
          Row(
            children: [
              Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Satuan: ${item.unit}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timestamps
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dibuat',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy', 'id_ID').format(item.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terakhir Diupdate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy', 'id_ID').format(item.updatedAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stock card with progress indicator
  static Widget _buildStockCard(InventoryItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.inventory_2, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Stok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.status == StockStatus.inStock
                      ? Icons.check_circle
                      : item.status == StockStatus.outOfStock
                          ? Icons.cancel
                          : Icons.warning,
                  color: item.statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  item.statusLabel,
                  style: TextStyle(
                    color: item.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stock Progress
          Row(
            children: [
              Text(
                '${item.currentStock} / ${item.maxStock} ${item.unit}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${item.stockPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: item.statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: item.stockPercentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(item.statusColor),
            ),
          ),
          const SizedBox(height: 20),

          // Min/Max Stock Info
          Row(
            children: [
              Expanded(
                child: _buildStockInfo(
                  'Minimum',
                  '${item.minStock} ${item.unit}',
                  Icons.warning_amber,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockInfo(
                  'Maximum',
                  '${item.maxStock} ${item.unit}',
                  Icons.vertical_align_top,
                  AppTheme.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stock info badge
  static Widget _buildStockInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build actions card (role-specific actions)
  static Widget _buildActionsCard(
    BuildContext context,
    InventoryItem item,
    bool isAdmin,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.touch_app, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isAdmin) ...[
            // Admin Actions
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Tambah Stok',
              color: AppTheme.success,
              onPressed: () => _showStockAdjustmentDialog(context, item, isAdd: true),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.remove_circle_outline,
              label: 'Kurangi Stok',
              color: AppTheme.warning,
              onPressed: () => _showStockAdjustmentDialog(context, item, isAdd: false),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.edit,
              label: 'Edit Item',
              color: AppTheme.info,
              onPressed: () => _editItem(context, item),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.history,
              label: 'Lihat Riwayat Stok',
              color: Colors.deepPurple,
              onPressed: () => _viewHistory(context, item),
            ),
          ] else ...[
            // Cleaner Actions
            _buildActionButton(
              icon: Icons.request_page,
              label: 'Ajukan Permintaan Stok',
              color: AppTheme.primary,
              onPressed: () => _showRequestDialog(context, item),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.history,
              label: 'Lihat Riwayat Stok',
              color: Colors.deepPurple,
              onPressed: () => _viewHistory(context, item),
            ),
          ],
        ],
      ),
    );
  }

  /// Build action button
  static Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// Build description card
  static Widget _buildDescriptionCard(InventoryItem item) {
    if (item.description == null || item.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  static Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  /// Build not found state
  static Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Item tidak ditemukan'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  /// Build floating action button (admin only)
  static Widget _buildFAB(
    BuildContext context,
    String itemId,
    InventoryService inventoryService,
  ) {
    return FloatingActionButton(
      onPressed: () async {
        // Get current item
        final snapshot = await inventoryService.streamAllItems().first;
        final item = snapshot.where((i) => i.id == itemId).firstOrNull;
        if (item != null) {
          _editItem(context, item);
        }
      },
      backgroundColor: AppTheme.primary,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  // ==================== ACTION HANDLERS ====================

  /// Navigate to edit item screen
  static Future<void> _editItem(BuildContext context, InventoryItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryAddEditScreen(item: item),
      ),
    );

    if (result == true) {
      // Refresh handled by stream
    }
  }

  /// Confirm delete dialog
  static Future<void> _confirmDelete(
    BuildContext context,
    String itemId,
    InventoryService inventoryService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem(context, itemId, inventoryService);
    }
  }

  /// Delete item
  static Future<void> _deleteItem(
    BuildContext context,
    String itemId,
    InventoryService inventoryService,
  ) async {
    try {
      await inventoryService.deleteItem(itemId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item berhasil dihapus'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show stock adjustment dialog
  static Future<void> _showStockAdjustmentDialog(
    BuildContext context,
    InventoryItem item, {
    required bool isAdd,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => StockAdjustmentDialog(
        item: item,
        isAdd: isAdd,
      ),
    );
  }

  /// Show request stock dialog (cleaner)
  static Future<void> _showRequestDialog(BuildContext context, InventoryItem item) async {
    await showDialog(
      context: context,
      builder: (context) => RequestStockDialog(item: item),
    );
  }

  /// Navigate to stock history screen
  static void _viewHistory(BuildContext context, InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockHistoryScreen(item: item),
      ),
    );
  }
}

