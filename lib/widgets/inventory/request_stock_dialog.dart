// lib/widgets/inventory/request_stock_dialog.dart
// Dialog for cleaner to request stock

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../riverpod/auth_providers.dart';
import '../../models/stock_request.dart';

class RequestStockDialog extends ConsumerStatefulWidget {
  final InventoryItem? item; // null = show item picker, non-null = pre-selected

  const RequestStockDialog({
    this.item,
    super.key,
  });

  @override
  ConsumerState<RequestStockDialog> createState() => _RequestStockDialogState();
}

class _RequestStockDialogState extends ConsumerState<RequestStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _inventoryService = InventoryService();

  InventoryItem? _selectedItem;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.item;
  }

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
              if (widget.item == null) ...[
                _buildItemPicker(),
                const SizedBox(height: 16),
              ],
              if (_selectedItem != null) ...[
                _buildItemInfo(_selectedItem!),
                const SizedBox(height: 16),
              ],
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
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.request_page,
            color: AppTheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Ajukan Permintaan Stok',
            style: TextStyle(
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

  // ==================== ITEM PICKER ====================
  Widget _buildItemPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pilih Item',
              style: TextStyle(
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
        StreamBuilder<List<InventoryItem>>(
          stream: _inventoryService.streamAllItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tidak ada item tersedia',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
                hintText: 'Pilih item...',
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item.id,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '(${item.currentStock} ${item.unit})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (itemId) {
                if (itemId != null) {
                  final item = items.firstWhere((i) => i.id == itemId);
                  setState(() => _selectedItem = item);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih item terlebih dahulu';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  // ==================== ITEM INFO ====================
  Widget _buildItemInfo(InventoryItem item) {
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
              const Icon(Icons.info_outline, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Info Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok Tersedia',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.currentStock} ${item.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.statusColor,
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
                      'Status',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: item.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
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

  // ==================== QUANTITY FIELD ====================
  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Jumlah yang Diminta',
              style: TextStyle(
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
            prefixIcon: const Icon(Icons.shopping_cart),
            suffixText: _selectedItem?.unit ?? '',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}), // For preview
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah harus diisi';
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Jumlah harus lebih dari 0';
            }
            return null;
          },
        ),
        if (_selectedItem != null) ...[
          const SizedBox(height: 8),
          _buildRequestPreview(),
        ],
      ],
    );
  }

  Widget _buildRequestPreview() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity == 0 || _selectedItem == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppTheme.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Anda akan mengajukan permintaan $quantity ${_selectedItem!.unit} ${_selectedItem!.name}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.info,
              ),
            ),
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
              'Catatan / Alasan',
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
            hintText: 'Jelaskan alasan permintaan stok...',
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
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 20),
            label: Text(_isSubmitting ? 'Mengirim...' : 'Ajukan Permintaan'),
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== METHODS ====================

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih item terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak terautentikasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final quantity = int.parse(_quantityController.text);
      final now = DateTime.now();

      final request = StockRequest(
        id: 'req_${now.millisecondsSinceEpoch}',
        itemId: _selectedItem!.id,
        itemName: _selectedItem!.name,
        requesterId: userProfile.uid,
        requesterName: userProfile.displayName,
        requestedQuantity: quantity,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'pending',
        createdAt: now,
      );

      await _inventoryService.createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil diajukan'),
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
        setState(() => _isSubmitting = false);
      }
    }
  }
}

