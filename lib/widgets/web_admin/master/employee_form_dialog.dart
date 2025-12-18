import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/employee.dart';
import 'package:aplikasi_cleanoffice/models/master/organization.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';

class EmployeeFormDialog extends HookConsumerWidget {
  final Employee? initialData;

  const EmployeeFormDialog({super.key, this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nipController = useTextEditingController(text: initialData?.nip);
    final nameController = useTextEditingController(text: initialData?.fullName);
    final emailController = useTextEditingController(text: initialData?.email);
    final phoneController = useTextEditingController(text: initialData?.phone);
    final positionController = useTextEditingController(text: initialData?.position);
    
    // Organization Selection
    final organizationIdState = useState<String?>(initialData?.organizationId);
    
    final isLoading = useState(false);

    // Fetch organizations for dropdown
    final orgsAsync = ref.watch(organizationsProvider);

    // Status State
    final statusState = useState(initialData?.status ?? 'active');

    Future<void> _submit() async {
      if (nameController.text.isEmpty || nipController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan NIP wajib diisi')));
        return;
      }

      isLoading.value = true;
      try {
        final newEmployee = Employee(
          id: initialData?.id ?? '', // Empty for new
          nip: nipController.text,
          fullName: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          position: positionController.text,
          organizationId: organizationIdState.value,
          status: statusState.value,
        );

        if (initialData == null) {
          await ref.read(employeeControllerProvider.notifier).create(newEmployee);
        } else {
          await ref.read(employeeControllerProvider.notifier).updateEmployee(newEmployee);
        }

        if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        isLoading.value = false;
      }
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                initialData == null ? 'Tambah Pegawai' : 'Edit Pegawai',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nipController,
                      decoration: const InputDecoration(labelText: 'NIP', border: OutlineInputBorder(), isDense: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), isDense: true),
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
                      decoration: const InputDecoration(labelText: 'Email (Opsional)', border: OutlineInputBorder(), isDense: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'No. HP (Opsional)', border: OutlineInputBorder(), isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Jabatan (Cth: Analis Kepegawaian)', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 16),
          
              // Organization Dropdown
              orgsAsync.when(
                data: (orgs) {
                  return DropdownButtonFormField<String>(
                    value: organizationIdState.value,
                    decoration: const InputDecoration(labelText: 'Unit Kerja / Organisasi', border: OutlineInputBorder(), isDense: true),
                    items: orgs.map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.code} - ${e.name}', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => organizationIdState.value = val,
                    isExpanded: true,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text('Gagal memuat unit kerja'),
              ),
              
              // Helper for status switch
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Pegawai', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          statusState.value == 'active' ? 'Pegawai Aktif' : 'Pegawai Non-Aktif / Resign',
                          style: TextStyle(
                            fontSize: 12, 
                            color: statusState.value == 'active' ? Colors.green : Colors.grey
                          )
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: statusState.value == 'active',
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                      onChanged: (val) {
                         statusState.value = val ? 'active' : 'inactive';
                      },
                    ),
                  ],
                ),
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
