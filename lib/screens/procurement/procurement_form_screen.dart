import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/procurement.dart';

class ProcurementFormScreen extends ConsumerStatefulWidget {
  const ProcurementFormScreen({super.key});

  @override
  ConsumerState<ProcurementFormScreen> createState() => _ProcurementFormScreenState();
}

class _ProcurementFormScreenState extends ConsumerState<ProcurementFormScreen> {
  final _items = <ProcurementItem>[];
  
  // Basic info controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _fiscalYear = 2024;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addItem(ProcurementItem item) {
    setState(() {
      _items.add(item);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalEstimatedCost => _items.fold(0, (sum, item) => sum + item.estimatedTotalPrice);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Buat Usulan Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Card
                  _buildSectionTitle('Informasi Dasar'),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Judul Usulan',
                              hintText: 'Contoh: Pengadaan Laptop Staff IT 2024',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _fiscalYear,
                                  decoration: const InputDecoration(
                                    labelText: 'Tahun Anggaran',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 2024, child: Text("2024")),
                                    DropdownMenuItem(value: 2025, child: Text("2025")),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _fiscalYear = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Bidang / Bagian',
                                    hintText: 'Bidang IT (Auto)',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi / Latar Belakang',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Items List (RKBMD)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Daftar Barang (RKBMD)'),
                      ElevatedButton.icon(
                        onPressed: _showAddItemDialog,
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Tambah Barang'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Satuan', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Harga Satuan', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                              SizedBox(width: 48), // Actions
                            ],
                          ),
                        ),
                        
                        // Empty State or List
                        if (_items.isEmpty)
                          Padding(
                             padding: const EdgeInsets.all(32),
                             child: Center(
                               child: Column(
                                 children: [
                                    Icon(Icons.playlist_add, size: 48, color: Colors.grey[300]),
                                    const SizedBox(height: 8),
                                    Text("Belum ada barang", style: TextStyle(color: Colors.grey[500])),
                                 ],
                               ),
                             ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _items.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(flex: 3, child: Text(item.itemName)),
                                    Expanded(flex: 1, child: Text(item.quantity.toString())),
                                    Expanded(flex: 2, child: Text(item.unit)),
                                    Expanded(flex: 2, child: Text('Rp ${item.estimatedUnitPrice.toStringAsFixed(0)}')), // Format later
                                    Expanded(flex: 2, child: Text('Rp ${item.estimatedTotalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    SizedBox(
                                      width: 48,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _removeItem(index),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        
                        // Footer Total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Total Estimasi:', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 16),
                              Text(
                                'Rp ${_totalEstimatedCost.toStringAsFixed(0)}', // Format later
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _items.isEmpty ? null : () {
                         // Submit Logic
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usulan berhasil diajukan!')),
                         );
                         context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan & Ajukan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'Unit');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Jumlah (Qty)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitCtrl,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Harga Satuan (Rp)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                 final newItem = ProcurementItem(
                   id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
                   requestId: '',
                   itemName: nameCtrl.text,
                   description: '',
                   quantity: int.tryParse(qtyCtrl.text) ?? 1,
                   estimatedUnitPrice: double.tryParse(priceCtrl.text) ?? 0,
                   unit: unitCtrl.text,
                 );
                 _addItem(newItem);
                 Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

