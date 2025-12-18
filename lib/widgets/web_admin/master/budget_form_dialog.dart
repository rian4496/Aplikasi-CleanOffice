import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/budget.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';

class BudgetFormDialog extends HookConsumerWidget {
  final Budget? initialData;

  const BudgetFormDialog({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearController = useTextEditingController(text: (initialData?.fiscalYear ?? DateTime.now().year).toString());
    final sourceController = useTextEditingController(text: initialData?.sourceName);
    final totalController = useTextEditingController(text: initialData?.totalAmount.toString() ?? '0');
    final descController = useTextEditingController(text: initialData?.description);
    
    final statusState = useState(initialData?.status ?? 'active');
    final isLoading = useState(false);

    Future<void> _submit() async {
      final year = int.tryParse(yearController.text);
      final total = double.tryParse(totalController.text);

      if (year == null || total == null || sourceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data tidak valid')));
        return;
      }

      isLoading.value = true;
      try {
        final newBudget = Budget(
          id: initialData?.id ?? '',
          fiscalYear: year,
          sourceName: sourceController.text,
          totalAmount: total,
          remainingAmount: initialData?.remainingAmount ?? total, // New budget reset or keep calculated? Usually new starts equals. Edit shouldn't easy edit total unless re-calc. Simplified here.
          status: statusState.value,
          description: descController.text,
        );

        if (initialData == null) {
           await ref.read(budgetControllerProvider.notifier).create(newBudget);
        } else {
           // For edit, carefully handle amounts if logic required, but simplified CRUD:
           await ref.read(budgetControllerProvider.notifier).updateBudget(newBudget);
        }

        if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        isLoading.value = false;
      }
    }

    return Dialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Container(
         width: 500,
         padding: const EdgeInsets.all(24),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text(initialData == null ? 'Tambah Anggaran' : 'Edit Anggaran', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 24),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: TextField(
                     controller: yearController,
                     decoration: const InputDecoration(labelText: 'Tahun', border: OutlineInputBorder()),
                     keyboardType: TextInputType.number,
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   flex: 2,
                   child: TextField(
                     controller: sourceController,
                     decoration: const InputDecoration(labelText: 'Nama Sumber (APBD etc)', border: OutlineInputBorder()),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             TextField(
               controller: totalController,
               decoration: const InputDecoration(labelText: 'Total Anggaran (Rp)', border: OutlineInputBorder(), hintText: '0'),
               keyboardType: TextInputType.number,
             ),
             const SizedBox(height: 16),
             TextField(
               controller: descController,
               decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             DropdownButtonFormField<String>(
               value: statusState.value,
               items: const [
                 DropdownMenuItem(value: 'active', child: Text('Aktif')),
                 DropdownMenuItem(value: 'closed', child: Text('Tutup')),
               ],
               onChanged: (val) => statusState.value = val!,
               decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 24),
             Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: isLoading.value ? null : _submit,
                    child: isLoading.value 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Simpan'),
                  ),
                ],
              )
           ],
         ),
       ),
    );
  }
}
