import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/organization.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';

class OrganizationFormDialog extends HookConsumerWidget {
  final Organization? initialData;

  const OrganizationFormDialog({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useTextEditingController(text: initialData?.code);
    final nameController = useTextEditingController(text: initialData?.name);
    final typeState = useState(initialData?.type ?? 'seksi'); // Default to seksi

    final isLoading = useState(false);

    // Fetch potential parents for dropdown
    final organizationsAsync = ref.watch(organizationsProvider);

    Future<void> _submit() async {
      if (nameController.text.isEmpty || codeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Kode wajib diisi')));
        return;
      }

      isLoading.value = true;
      try {
        final newOrg = Organization(
          id: initialData?.id ?? '', // Empty ID for new
          code: codeController.text,
          name: nameController.text,
          type: typeState.value,
          parentId: null, // Simplified: Not handled in this basic form yet, or add Dropdown
        );

        if (initialData == null) {
          await ref.read(organizationControllerProvider.notifier).create(newOrg);
        } else {
          await ref.read(organizationControllerProvider.notifier).updateOrganization(newOrg);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              initialData == null ? 'Tambah Organisasi' : 'Edit Organisasi',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Code
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Unit (Cth: 01.02)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Unit Kerja',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Type Dropdown
             DropdownButtonFormField<String>(
              value: typeState.value,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'dinas', child: Text('Dinas')),
                DropdownMenuItem(value: 'bidang', child: Text('Bidang')),
                DropdownMenuItem(value: 'seksi', child: Text('Seksi')),
                DropdownMenuItem(value: 'upt', child: Text('UPT')),
              ],
              onChanged: (val) => typeState.value = val!,
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
