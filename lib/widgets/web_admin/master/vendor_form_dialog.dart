import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/vendor.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';

class VendorFormDialog extends HookConsumerWidget {
  final Vendor? initialData;

  const VendorFormDialog({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: initialData?.name);
    final contactController = useTextEditingController(text: initialData?.contactPerson);
    final phoneController = useTextEditingController(text: initialData?.phone);
    final emailController = useTextEditingController(text: initialData?.email);
    final addressController = useTextEditingController(text: initialData?.address);
    final taxController = useTextEditingController(text: initialData?.taxId);

    final categoryState = useState(initialData?.category ?? 'Umum');
    final statusState = useState(initialData?.status ?? 'active'); 
    final isLoading = useState(false);

    final categories = const [
      'Umum', 'ATK & Percetakan', 'Elektronik & IT', 'Jasa Konstruksi', 'Catering', 'Mebel & Interior', 'Lainnya'
    ];

    Future<void> _submit() async {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Perusahaan wajib diisi')));
        return;
      }

      isLoading.value = true;
      try {
        final newVendor = Vendor(
          id: initialData?.id ?? '',
          name: nameController.text,
          category: categoryState.value,
          contactPerson: contactController.text,
          phone: phoneController.text,
          email: emailController.text,
          address: addressController.text,
          taxId: taxController.text,
          status: statusState.value,
        );

        if (initialData == null) {
          await ref.read(vendorControllerProvider.notifier).create(newVendor);
        } else {
          await ref.read(vendorControllerProvider.notifier).updateVendor(newVendor);
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
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(initialData == null ? 'Tambah Penyedia (Vendor)' : 'Edit Penyedia', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               const SizedBox(height: 24),
               
               TextField(
                 controller: nameController,
                 decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder()),
               ),
               const SizedBox(height: 16),
               
               DropdownButtonFormField<String>(
                 value: categories.contains(categoryState.value) ? categoryState.value : 'Umum',
                 items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                 onChanged: (val) => categoryState.value = val!,
                 decoration: const InputDecoration(labelText: 'Kategori Usaha', border: OutlineInputBorder()),
               ),
               const SizedBox(height: 16),
               
               Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: contactController,
                       decoration: const InputDecoration(labelText: 'Kontak Person/PIC', border: OutlineInputBorder()),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: TextField(
                       controller: phoneController,
                       decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: emailController,
                       decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: TextField(
                       controller: taxController,
                       decoration: const InputDecoration(labelText: 'NPWP', border: OutlineInputBorder()),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               TextField(
                 controller: addressController,
                 decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                 maxLines: 2,
               ),
               const SizedBox(height: 16),
               
               DropdownButtonFormField<String>(
                 value: statusState.value, // Make sure default matches one of items
                 items: const [
                   DropdownMenuItem(value: 'active', child: Text('Active (Verifikasi)')), 
                   DropdownMenuItem(value: 'unverified', child: Text('Unverified')),
                   DropdownMenuItem(value: 'blacklisted', child: Text('Blacklisted (Daftar Hitam)')),
                 ],
                 onChanged: (val) => statusState.value = val!,
                 decoration: const InputDecoration(labelText: 'Status Keaktifan', border: OutlineInputBorder()),
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
      ),
    );
  }
}
