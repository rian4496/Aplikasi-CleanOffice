// lib/widgets/inventory/batch_action_bar.dart
// Bottom action bar for batch operations on selected inventory items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../riverpod/inventory_selection_provider.dart';
import '../../services/inventory_service.dart';
import './inventory_export_dialog.dart';

class BatchActionBar extends ConsumerWidget {
  final List<InventoryItem> allItems;
  final VoidCallback onActionComplete;

  const BatchActionBar({
    required this.allItems,
    required this.onActionComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(inventorySelectionProvider);
    final selectedCount = selectedIds.length;

    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    final selectedItems = allItems
        .where((item) => selectedIds.contains(item.id))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Selection count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$selectedCount dipilih',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Action buttons
            _buildActionButton(
              context: context,
              icon: Icons.download,
              label: 'Export',
              onPressed: () => _handleExport(context, selectedItems),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              icon: Icons.category,
              label: 'Kategori',
              onPressed: () => _handleBulkCategoryUpdate(context, ref, selectedIds.toList()),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              icon: Icons.delete,
              label: 'Hapus',
              color: AppTheme.error,
              onPressed: () => _handleBulkDelete(context, ref, selectedIds.toList()),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ref.read(selectionModeProvider.notifier).disable();
              },
              tooltip: 'Batalkan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.white,
        foregroundColor: color != null ? Colors.white : AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  void _handleExport(BuildContext context, List<InventoryItem> items) {
    showDialog(
      context: context,
      builder: (context) => InventoryExportDialog(items: items),
    );
  }

  Future<void> _handleBulkCategoryUpdate(
    BuildContext context,
    WidgetRef ref,
    List<String> itemIds,
  ) async {
    final category = await showDialog<String>(
      context: context,
      builder: (context) => _CategorySelectDialog(),
    );

    if (category == null) return;

    try {
      final inventoryService = InventoryService();
      await inventoryService.bulkUpdateCategory(itemIds, category);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${itemIds.length} item berhasil diupdate'),
            backgroundColor: AppTheme.success,
          ),
        );
        ref.read(selectionModeProvider.notifier).disable();
        onActionComplete();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleBulkDelete(
    BuildContext context,
    WidgetRef ref,
    List<String> itemIds,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Yakin ingin menghapus ${itemIds.length} item?\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final inventoryService = InventoryService();
      await inventoryService.bulkDelete(itemIds);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${itemIds.length} item berhasil dihapus'),
            backgroundColor: AppTheme.success,
          ),
        );
        ref.read(selectionModeProvider.notifier).disable();
        onActionComplete();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

class _CategorySelectDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryOption(context, 'Alat', 'alat'),
          const SizedBox(height: 8),
          _buildCategoryOption(context, 'Consumable', 'consumable'),
          const SizedBox(height: 8),
          _buildCategoryOption(context, 'PPE', 'ppe'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  Widget _buildCategoryOption(BuildContext context, String label, String value) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(value),
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alat':
        return Icons.build;
      case 'consumable':
        return Icons.shopping_bag;
      case 'ppe':
        return Icons.shield;
      default:
        return Icons.category;
    }
  }
}

