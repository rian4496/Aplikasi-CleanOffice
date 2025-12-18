import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../models/stock_request.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
// import '../../widgets/shared/custom_text_field.dart';

class InventoryRequestFormScreen extends ConsumerStatefulWidget {
  const InventoryRequestFormScreen({super.key});

  @override
  ConsumerState<InventoryRequestFormScreen> createState() => _InventoryRequestFormScreenState();
}

class _InventoryRequestFormScreenState extends ConsumerState<InventoryRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _notesController = TextEditingController();
  
  InventoryItem? _selectedItem;
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch items for dropdown
    final itemsAsync = ref.watch(allInventoryItemsProvider);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: AppBar(
        title: const Text('Buat Permintaan Barang'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Illustration/Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_rounded, size: 64, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 32),

              // Item Selection
              const Text(
                'Pilih Barang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              itemsAsync.when(
                data: (items) {
                   // Filter only items with stock? Or allow requesting anyways?
                   // Usually requesting assumes we need it. 
                   return DropdownButtonFormField<InventoryItem>(
                     value: _selectedItem,
                     decoration: InputDecoration(
                       filled: true,
                       fillColor: Colors.white,
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(color: Colors.grey.shade300),
                       ),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(color: Colors.grey.shade300),
                       ),
                       hintText: 'Pilih barang yang dibutuhkan',
                     ),
                     items: items.map((item) {
                       return DropdownMenuItem(
                         value: item,
                         child: Row(
                           children: [
                             Text(item.name),
                             if (item.currentStock <= item.minStock)
                               Text(' (Stok Menipis)', style: TextStyle(color: Colors.red, fontSize: 12)),
                           ],
                         ),
                       );
                     }).toList(),
                     onChanged: (val) {
                       setState(() {
                         _selectedItem = val;
                       });
                     },
                     validator: (val) => val == null ? 'Wajib dipilih' : null,
                   );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Gagal memuat barang: $err'),
              ),

              const SizedBox(height: 24),

              // Quantity
              const Text(
                'Jumlah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Masukkan jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  suffixText: _selectedItem?.unit ?? 'Pcs',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) return 'Jumlah tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Notes
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Untuk keperluan apa?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Kirim Permintaan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('User not logged in');

      // Create request object
      // Note: itemId and name are handled by model
      final request = StockRequest(
        id: '', // DB generates
        itemId: _selectedItem!.id,
        itemName: _selectedItem!.name,
        requesterId: user.uid,
        requesterName: user.displayName ?? 'Karyawan',
        requestedQuantity: int.parse(_qtyController.text),
        status: 'pending',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(), // Will be ignored by DB defaults usually, but good for local
      );

      await ref.read(inventoryServiceProvider).createRequest(request);

      if (mounted) {
        context.pop(); // Return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil dikirim! Menunggu persetujuan admin.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim permintaan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
