import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/employee.dart';
import 'package:aplikasi_cleanoffice/models/master/organization.dart';
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';

import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_cleanoffice/riverpod/supabase_service_providers.dart';

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
    
    // New fields for employee classification
    final employeeTypeState = useState<String>(initialData?.employeeType ?? EmployeeType.pns);
    final golonganPangkatState = useState<String?>(initialData?.golonganPangkat);
    final eselonState = useState<String?>(initialData?.eselon);
    
    // Organization Selection
    final organizationIdState = useState<String?>(initialData?.organizationId);
    
    final isLoading = useState(false);

    // Fetch organizations for dropdown
    final orgsAsync = ref.watch(organizationsProvider);

    // Status State
    final statusState = useState(initialData?.status ?? 'active');

    // Photo State
    final newImageFile = useState<XFile?>(null);
    final photoUrlState = useState<String?>(initialData?.photoUrl);

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600); // Optimize size
      if (picked != null) {
        newImageFile.value = picked;
      }
    }

    Future<void> _submit() async {
      if (nameController.text.isEmpty || nipController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan NIP wajib diisi')));
        return;
      }

      isLoading.value = true;
      try {
        // 1. Upload Photo if New Image Selected
        String? photoUrl = photoUrlState.value;
        if (newImageFile.value != null) {
           final storage = ref.read(supabaseStorageServiceProvider);
           // Use NIP as unique identifier for the file
           photoUrl = await storage.uploadProfileImage(newImageFile.value!, nipController.text);
        }

        final newEmployee = Employee(
          id: initialData?.id ?? '', // Empty for new
          nip: nipController.text,
          fullName: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          position: positionController.text,
          employeeType: employeeTypeState.value,
          golonganPangkat: employeeTypeState.value == EmployeeType.pns ? golonganPangkatState.value : null,
          eselon: employeeTypeState.value == EmployeeType.pns ? eselonState.value : null,
          organizationId: organizationIdState.value,
          status: statusState.value,
          photoUrl: photoUrl,
        );

        if (initialData == null) {
          await ref.read(employeeControllerProvider.notifier).create(newEmployee);
        } else {
          await ref.read(employeeControllerProvider.notifier).updateEmployee(newEmployee);
        }

        // Auto-refresh list
        ref.invalidate(employeesProvider);

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      initialData == null ? 'Tambah Pegawai' : 'Edit Pegawai',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
      
                    // Photo Input (3x4 Ratio)
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120, // 3 parts
                              height: 160, // 4 parts (3x4 ratio)
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                image: newImageFile.value != null
                                    ? DecorationImage(
                                        image: NetworkImage(newImageFile.value!.path), // Works on Web for XFile
                                        fit: BoxFit.cover,
                                      )
                                    : photoUrlState.value != null
                                        ? DecorationImage(
                                            image: NetworkImage(photoUrlState.value!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (newImageFile.value == null && photoUrlState.value == null)
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Foto 3x4',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          if (newImageFile.value != null || photoUrlState.value != null)
                            TextButton(
                              onPressed: () {
                                newImageFile.value = null;
                                photoUrlState.value = null;
                              },
                              child: const Text('Hapus Foto', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (isMobile) ...[
                      TextField(
                        controller: nipController,
                        decoration: const InputDecoration(labelText: 'NIP / NIK', border: OutlineInputBorder(), isDense: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(), isDense: true),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nipController,
                              decoration: const InputDecoration(labelText: 'NIP / NIK', border: OutlineInputBorder(), isDense: true),
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
                    
                    if (isMobile) ...[
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email (Opsional)', border: OutlineInputBorder(), isDense: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'No. HP (Opsional)', border: OutlineInputBorder(), isDense: true),
                      ),
                    ] else
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
                    
                    // Tipe Pegawai Dropdown
                    DropdownButtonFormField<String>(
                      value: employeeTypeState.value,
                      decoration: const InputDecoration(labelText: 'Tipe Pegawai', border: OutlineInputBorder(), isDense: true),
                      items: EmployeeType.all.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(EmployeeType.getDisplayName(type)),
                      )).toList(),
                      onChanged: (val) {
                        employeeTypeState.value = val ?? EmployeeType.pns;
                        // Clear PNS-specific fields if not PNS
                        if (val != EmployeeType.pns) {
                          golonganPangkatState.value = null;
                          eselonState.value = null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Golongan & Eselon - Only for PNS
                    if (employeeTypeState.value == EmployeeType.pns) ...[
                      if (isMobile) ...[
                        DropdownButtonFormField<String>(
                          value: golonganPangkatState.value,
                          isExpanded: true, 
                          decoration: const InputDecoration(labelText: 'Golongan Pangkat', border: OutlineInputBorder(), isDense: true),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('-- Pilih Golongan --')),
                            ...GolonganPangkat.all.map((g) => DropdownMenuItem(
                              value: g, 
                              child: Text(g, overflow: TextOverflow.ellipsis), 
                            )),
                          ],
                          onChanged: (val) => golonganPangkatState.value = val,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: eselonState.value,
                          decoration: const InputDecoration(labelText: 'Eselon (Opsional)', border: OutlineInputBorder(), isDense: true),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('-- Non-Struktural --')),
                            ...Eselon.all.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                          ],
                          onChanged: (val) => eselonState.value = val,
                        ),
                      ] else 
                        Row(
                          children: [
                            Expanded(
                              flex: 3, 
                              child: DropdownButtonFormField<String>(
                                value: golonganPangkatState.value,
                                isExpanded: true, 
                                decoration: const InputDecoration(labelText: 'Golongan Pangkat', border: OutlineInputBorder(), isDense: true),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('-- Pilih Golongan --')),
                                  ...GolonganPangkat.all.map((g) => DropdownMenuItem(
                                    value: g, 
                                    child: Text(g, overflow: TextOverflow.ellipsis), 
                                  )),
                                ],
                                onChanged: (val) => golonganPangkatState.value = val,
                                selectedItemBuilder: (context) {
                                  return [
                                    const Text('-- Pilih Golongan --'),
                                    ...GolonganPangkat.all.map((g) => Text(g, overflow: TextOverflow.ellipsis))
                                  ];
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2, 
                              child: DropdownButtonFormField<String>(
                                value: eselonState.value,
                                decoration: const InputDecoration(labelText: 'Eselon (Opsional)', border: OutlineInputBorder(), isDense: true),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('-- Non-Struktural --')),
                                  ...Eselon.all.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                                ],
                                onChanged: (val) => eselonState.value = val,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                
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
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}
