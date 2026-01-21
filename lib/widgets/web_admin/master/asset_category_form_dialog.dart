import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/asset_category.dart';
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';

class AssetCategoryFormDialog extends HookConsumerWidget {
  final AssetCategory? initialData;

  const AssetCategoryFormDialog({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useTextEditingController(text: initialData?.code);
    final nameController = useTextEditingController(text: initialData?.name);
    final descController = useTextEditingController(text: initialData?.description);

    final isLoading = useState(false);

    Future<void> _submit() async {
      
      if (nameController.text.isEmpty || codeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Kode wajib diisi')));
        return;
      }

      isLoading.value = true;
      try {
        final newCat = AssetCategory(
          id: initialData?.id ?? '',
          code: codeController.text,
          name: nameController.text,
          description: descController.text,
        );

        if (initialData == null) {
          await ref.read(assetCategoryControllerProvider.notifier).create(newCat);
        } else {
          await ref.read(assetCategoryControllerProvider.notifier).updateCategory(newCat);
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
             Text(initialData == null ? 'Tambah Kategori Aset' : 'Edit Kategori', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 24),
             TextField(
               controller: codeController,
               decoration: const InputDecoration(labelText: 'Kode Kategori (Cth: 02.04)', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             TextField(
               controller: nameController,
               decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             TextField(
               controller: descController,
               decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
               maxLines: 2,
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
