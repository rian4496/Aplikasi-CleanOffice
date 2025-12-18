// lib/screens/inventory/inventory_detail_screen.dart
// Detailed view of inventory item with actions and history

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../models/user_role.dart';
import '../../services/inventory_service.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../models/stock_history.dart';
import '../../widgets/inventory/stock_adjustment_dialog.dart';
import '../../widgets/inventory/stock_history_dialog.dart';
import '../../widgets/inventory/request_stock_dialog.dart';
import '../../widgets/inventory/inventory_form_dialog.dart';


class InventoryDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const InventoryDetailScreen({
    required this.itemId,
    super.key,
  });

  @override
  ConsumerState<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  final _inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(isAdmin),
      body: StreamBuilder<List<InventoryItem>>(
        stream: _inventoryService.streamAllItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final items = snapshot.data ?? [];
          final item = items.where((i) => i.id == widget.itemId).firstOrNull;

          if (item == null) {
            return _buildNotFound();
          }

          return _buildContent(item, isAdmin);
        },
      ),
      // floatingActionButton: isAdmin ? _buildFAB() : null, // Hide FAB in detail/history for cleaner look
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(bool isAdmin) {
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
                onPressed: _confirmDelete,
                tooltip: 'Hapus Item',
              ),
            ]
          : null,
    );
  }

  // ==================== CONTENT ====================
  Widget _buildContent(InventoryItem item, bool isAdmin) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItemCard(item),
          const SizedBox(height: 16),
          _buildStockCard(item),
          const SizedBox(height: 16),

          _buildDescriptionCard(item),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== ITEM CARD ====================
  Widget _buildItemCard(InventoryItem item) {
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

  // ==================== STOCK CARD ====================
  Widget _buildStockCard(InventoryItem item) {
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
          Row(
            children: [
              const Icon(Icons.inventory_2, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Informasi Stok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              // Quick Actions Dropdown
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'add':
                      _showStockAdjustmentDialog(item, isAdd: true);
                      break;
                    case 'remove':
                      _showStockAdjustmentDialog(item, isAdd: false);
                      break;
                    case 'edit':
                      _editItem(item);
                      break;
                    case 'history':
                      _viewHistory(item);
                      break;
                    case 'request':
                      _showRequestDialog(item);
                      break;
                  }
                },
                itemBuilder: (context) {
                  final userProfile = ref.read(currentUserProfileProvider).value;
                  final isAdmin = userProfile?.role == UserRole.admin;

                  if (isAdmin) {
                    return [
                      const PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: AppTheme.success, size: 20),
                            SizedBox(width: 12),
                            Text('Tambah Stok'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline, color: AppTheme.warning, size: 20),
                            SizedBox(width: 12),
                            Text('Kurangi Stok'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.info, size: 20),
                            SizedBox(width: 12),
                            Text('Edit Item'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                         value: 'history',
                         child: Row(
                           children: [
                             Icon(Icons.history, color: Colors.deepPurple, size: 20),
                             SizedBox(width: 12),
                             Text('Riwayat'),
                           ],
                         ),
                       ),
                    ];
                  } else {
                    return [
                       const PopupMenuItem(
                        value: 'request',
                        child: Row(
                          children: [
                            Icon(Icons.request_page, color: AppTheme.primary, size: 20),
                            SizedBox(width: 12),
                            Text('Ajukan Permintaan'),
                          ],
                        ),
                      ),
                       const PopupMenuItem(
                         value: 'history',
                         child: Row(
                           children: [
                             Icon(Icons.history, color: Colors.deepPurple, size: 20),
                             SizedBox(width: 12),
                             Text('Riwayat'),
                           ],
                         ),
                       ),
                    ];
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                       Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[700]),
                    ],
                  ),
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${item.currentStock} / ${item.maxStock}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.unit,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
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
                  '${item.minStock}',
                  item.unit,
                  Icons.warning_amber,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockInfo(
                  'Maximum',
                  '${item.maxStock}',
                  item.unit,
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

  Widget _buildStockInfo(String label, String value, String unit, IconData icon, Color color) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS CARD ====================


  // ==================== DESCRIPTION CARD ====================
  Widget _buildDescriptionCard(InventoryItem item) {
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

  // ==================== ERROR & NOT FOUND ====================
  Widget _buildError(String error) {
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

  Widget _buildNotFound() {
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

  // ==================== FAB ====================
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () async {
        // Get current item
        final snapshot = await _inventoryService.streamAllItems().first;
        final item = snapshot.where((i) => i.id == widget.itemId).firstOrNull;
        if (item != null) {
          _editItem(item);
        }
      },
      backgroundColor: AppTheme.primary,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  // ==================== METHODS ====================

  Future<void> _editItem(InventoryItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => InventoryFormDialog(item: item),
    );

    if (result == true) {
      // Refresh handled by stream
    }
  }

  Future<void> _confirmDelete() async {
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
      await _deleteItem();
    }
  }

  Future<void> _deleteItem() async {
    try {
      await _inventoryService.deleteItem(widget.itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil dihapus'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStockAdjustmentDialog(InventoryItem item, {required bool isAdd}) async {
    await showDialog(
      context: context,
      builder: (context) => StockAdjustmentDialog(
        item: item,
        isAdd: isAdd,
      ),
    );
  }

  Future<void> _showRequestDialog(InventoryItem item) async {
    await showDialog(
      context: context,
      builder: (context) => RequestStockDialog(item: item),
    );
  }

  void _viewHistory(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => StockHistoryDialog(item: item),
    );
  }
}

