import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/vendor.dart';
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';

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
    final imageUrl = useState<String?>(initialData?.imageUrl);
    final isUploadingImage = useState(false);

    final categories = const [
      'Umum', 'ATK & Percetakan', 'Elektronik & IT', 'Jasa Konstruksi', 'Catering', 'Mebel & Interior', 'Lainnya'
    ];

    Future<void> _pickAndUploadImage() async {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
        
        if (pickedFile == null) return;
        
        isUploadingImage.value = true;
        
        final bytes = await pickedFile.readAsBytes();
        final fileName = 'vendor_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'vendors/$fileName';
        
        await Supabase.instance.client.storage.from('assets').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        
        final publicUrl = Supabase.instance.client.storage.from('assets').getPublicUrl(path);
        imageUrl.value = publicUrl;
        
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload foto: $e')));
        }
      } finally {
        isUploadingImage.value = false;
      }
    }

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
          imageUrl: imageUrl.value,
        );

        final isCreate = initialData == null;
        if (isCreate) {
          await ref.read(vendorControllerProvider.notifier).create(newVendor);
        } else {
          await ref.read(vendorControllerProvider.notifier).updateVendor(newVendor);
        }

        // Auto-refresh list
        ref.invalidate(vendorsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCreate 
                ? 'Vendor "${newVendor.name}" berhasil ditambahkan' 
                : 'Vendor "${newVendor.name}" berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        isLoading.value = false;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(initialData == null ? 'Tambah Penyedia (Vendor)' : 'Edit Penyedia', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 24),
                     
                     // Photo Upload Section
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.grey[50],
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey[300]!),
                       ),
                       child: Column(
                         children: [
                           if (imageUrl.value != null) ...[
                             ClipRRect(
                               borderRadius: BorderRadius.circular(8),
                               child: Image.network(
                                 imageUrl.value!,
                                 height: 120,
                                 width: double.infinity,
                                 fit: BoxFit.cover,
                                 errorBuilder: (_, __, ___) => Container(
                                   height: 120,
                                   color: Colors.grey[200],
                                   child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                 ),
                               ),
                             ),
                             const SizedBox(height: 12),
                           ],
                           OutlinedButton.icon(
                             onPressed: isUploadingImage.value ? null : _pickAndUploadImage,
                             icon: isUploadingImage.value 
                               ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                               : const Icon(Icons.add_photo_alternate_outlined),
                             label: Text(imageUrl.value == null ? 'Upload Foto Lokasi' : 'Ganti Foto'),
                             style: OutlinedButton.styleFrom(
                               foregroundColor: AppTheme.primary,
                               side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 16),
                     
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
                     
                     if (isMobile) ...[
                       TextField(
                         controller: contactController,
                         decoration: const InputDecoration(labelText: 'Kontak Person/PIC', border: OutlineInputBorder()),
                       ),
                       const SizedBox(height: 16),
                       TextField(
                         controller: phoneController,
                         decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
                       ),
                     ] else 
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
                     
                     if (isMobile) ...[
                       TextField(
                         controller: emailController,
                         decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                       ),
                       const SizedBox(height: 16),
                       TextField(
                         controller: taxController,
                         decoration: const InputDecoration(labelText: 'NPWP', border: OutlineInputBorder()),
                       ),
                     ] else
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
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}
