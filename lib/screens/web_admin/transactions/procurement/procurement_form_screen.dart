import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../riverpod/budget_view_providers.dart';
import '../../../../../models/master/budget.dart';

class ProcurementFormScreen extends HookConsumerWidget {
  const ProcurementFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State
    final isLoading = useState(false);
    
    // Form Controllers
    final codeController = useTextEditingController(text: 'REQ-${DateFormat('yyyyMMdd').format(DateTime.now())}-${const Uuid().v4().substring(0, 6).toUpperCase()}');
    final descController = useTextEditingController();
    
    // Items State (Using a simplified list of maps for the form)
    final items = useState<List<Map<String, dynamic>>>([
       {'name': '', 'qty': 1, 'price': 0.0, 'budget_id': null}
    ]);
    
    final budgetsAsync = ref.watch(filteredBudgetsProvider);

    // Calculate Total
    double totalEstimated = items.value.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Pengajuan Baru', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Kode Request', border: OutlineInputBorder()),
                      readOnly: true, // Auto-generated
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Keterangan / Tujuan Pengadaan', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Daftar Barang', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 2. Dynamic Items List
            ...items.value.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          
                          if (isMobile) {
                            // Mobile Layout
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: item['name'],
                                        decoration: const InputDecoration(labelText: 'Nama Barang', isDense: true),
                                        onChanged: (val) {
                                           items.value[index]['name'] = val;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (items.value.length > 1) {
                                          final newList = List<Map<String, dynamic>>.from(items.value);
                                          newList.removeAt(index);
                                          items.value = newList;
                                        }
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Hapus Item',
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        initialValue: item['qty'].toString(),
                                        decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) {
                                           items.value[index]['qty'] = int.tryParse(val) ?? 1;
                                           items.value = List.from(items.value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        initialValue: item['price'].toString(),
                                        decoration: const InputDecoration(labelText: 'Est. Harga', prefixText: 'Rp ', isDense: true),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) {
                                           items.value[index]['price'] = double.tryParse(val) ?? 0;
                                           items.value = List.from(items.value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          
                          // Desktop Layout
                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: item['name'],
                                  decoration: const InputDecoration(labelText: 'Nama Barang', isDense: true),
                                  onChanged: (val) {
                                     items.value[index]['name'] = val;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: item['qty'].toString(),
                                  decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                     items.value[index]['qty'] = int.tryParse(val) ?? 1;
                                     items.value = List.from(items.value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: item['price'].toString(),
                                  decoration: const InputDecoration(labelText: 'Est. Harga', prefixText: 'Rp ', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                     items.value[index]['price'] = double.tryParse(val) ?? 0;
                                     items.value = List.from(items.value);
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (items.value.length > 1) {
                                    final newList = List<Map<String, dynamic>>.from(items.value);
                                    newList.removeAt(index);
                                    items.value = newList;
                                  }
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              )
                            ],
                          );
                        },
                      ),
                  
                  const SizedBox(height: 12),
                  
                  // Budget Selector
                  if (budgetsAsync.isEmpty)
                    const Text('Tidak ada anggaran aktif tahun ini', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))
                  else
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sumber Anggaran',
                        isDense: true,
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.account_balance_wallet, size: 20),
                      ),
                      value: item['budget_id'],
                      items: budgetsAsync.map((b) => DropdownMenuItem(
                        value: b.id,
                        child: Text('${b.sourceName} (Sisa: ${NumberFormat.compactSimpleCurrency(locale: 'id').format(b.remainingAmount)})', 
                          style: GoogleFonts.inter(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (val) {
                        items.value[index]['budget_id'] = val;
                        items.value = List.from(items.value); // Trigger rebuild
                      },
                      validator: (val) => val == null ? 'Wajib pilih anggaran' : null,
                    ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                items.value = [...items.value, {'name': '', 'qty': 1, 'price': 0.0, 'budget_id': null}];
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Barang'),
            ),

            const Divider(height: 32),
            
            // 3. Footer / Submit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimasi', style: TextStyle(color: Colors.grey)),
                    Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalEstimated),
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: isLoading.value ? null : () async {
                    if (descController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi keterangan')));
                      return;
                    }
                    
                    // Validate Budgets
                    if (items.value.any((i) => i['budget_id'] == null)) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon pilih Sumber Anggaran untuk semua barang')));
                       return;
                    }

                    isLoading.value = true;
                    try {
                      // Construct Models
                      final req = ProcurementRequest(
                        id: '', // DB generated or ignored
                        code: codeController.text,
                        requestDate: DateTime.now(),
                        description: descController.text,
                        totalEstimatedBudget: totalEstimated,
                      );

                      final itemList = items.value.map((i) => ProcurementItem(
                        id: '',
                        procurementId: '', // Set by Repo
                        itemName: i['name'],
                        quantity: i['qty'],
                        unitPriceEstimate: i['price'].toDouble(),
                        budgetId: i['budget_id'],
                      )).toList();

                      await ref.read(procurementRepositoryProvider).createRequest(req, itemList);
                      
                      ref.invalidate(procurementListProvider);
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan berhasil dibuat')));
                      }
                    } catch (e) {
                      isLoading.value = false;
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  icon: isLoading.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.send),
                  label: const Text('Kirim Pengajuan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: AppTheme.primary,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
