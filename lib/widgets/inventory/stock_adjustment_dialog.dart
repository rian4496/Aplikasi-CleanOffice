// lib/widgets/inventory/stock_adjustment_dialog.dart
// Dialog for adjusting stock (add/reduce)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../riverpod/auth_providers.dart';

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final InventoryItem item;
  final bool isAdd; // true = add stock, false = reduce stock

  const StockAdjustmentDialog({
    required this.item,
    required this.isAdd,
    super.key,
  });

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _inventoryService = InventoryService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildItemInfo(),
              const SizedBox(height: 20),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isAdd
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.isAdd ? Icons.add_circle : Icons.remove_circle,
            color: widget.isAdd ? AppTheme.success : AppTheme.warning,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.isAdd ? 'Tambah Stok' : 'Kurangi Stok',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==================== ITEM INFO ====================
  Widget _buildItemInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  label: 'Stok Saat Ini',
                  value: '${widget.item.currentStock} ${widget.item.unit}',
                  color: widget.item.statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  label: 'Status',
                  value: widget.item.statusLabel,
                  color: widget.item.statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==================== QUANTITY FIELD ====================
  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.isAdd ? 'Jumlah yang Ditambahkan' : 'Jumlah yang Dikurangi',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah...',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(
              widget.isAdd ? Icons.add : Icons.remove,
              color: widget.isAdd ? AppTheme.success : AppTheme.warning,
            ),
            suffixText: widget.item.unit,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah harus diisi';
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Jumlah harus lebih dari 0';
            }
            if (!widget.isAdd && quantity > widget.item.currentStock) {
              return 'Jumlah melebihi stok saat ini';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildStockPreview(),
      ],
    );
  }

  Widget _buildStockPreview() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final newStock = widget.isAdd
        ? widget.item.currentStock + quantity
        : widget.item.currentStock - quantity;

    if (quantity == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isAdd
            ? AppTheme.success.withValues(alpha: 0.05)
            : AppTheme.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isAdd
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Stok Baru:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: [
              Text(
                '${widget.item.currentStock} ${widget.item.unit}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '$newStock ${widget.item.unit}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.isAdd ? AppTheme.success : AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== NOTES FIELD ====================
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Opsional',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Alasan penyesuaian stok (opsional)...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note_outlined),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  // ==================== ACTIONS ====================
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleAdjustment,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isAdd ? AppTheme.success : AppTheme.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.isAdd ? 'Tambah Stok' : 'Kurangi Stok'),
          ),
        ),
      ],
    );
  }

  // ==================== METHODS ====================

  Future<void> _handleAdjustment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Get current user
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw Exception('User not authenticated');
      }

      final quantity = int.parse(_quantityController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      // Use new methods with history logging
      if (widget.isAdd) {
        await _inventoryService.addStock(
          itemId: widget.item.id,
          quantity: quantity,
          performedBy: userProfile.uid,
          performedByName: userProfile.displayName,
          notes: notes,
        );
      } else {
        await _inventoryService.reduceStock(
          itemId: widget.item.id,
          quantity: quantity,
          performedBy: userProfile.uid,
          performedByName: userProfile.displayName,
          notes: notes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isAdd
                  ? 'Stok berhasil ditambahkan'
                  : 'Stok berhasil dikurangi',
            ),
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
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

