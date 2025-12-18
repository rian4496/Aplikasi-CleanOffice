import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../models/user_profile.dart';
import '../../../models/user_role.dart';
import '../../../providers/riverpod/supabase_service_providers.dart';

class UserFormDialog extends HookConsumerWidget {
  final UserProfile? user;

  const UserFormDialog({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = user != null;
    
    // Form Controllers
    final nameCtrl = useTextEditingController(text: user?.displayName ?? '');
    final emailCtrl = useTextEditingController(text: user?.email ?? '');
    final phoneCtrl = useTextEditingController(text: user?.phoneNumber ?? '');
    final deptCtrl = useTextEditingController(text: user?.departmentId ?? ''); // Should be department name ideally
    
    // State
    final selectedRole = useState<String>(user?.role ?? 'employee');
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Roles map
    final roles = {
      for (var r in UserRole.allRoles) r: UserRole.getRoleDisplayName(r)
    };

    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Tambah User'),
      content: SizedBox(
        width: 400,
        child: isEditing 
          ? Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     TextFormField(
                       controller: emailCtrl,
                       decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.black12),
                       readOnly: true, // Cannot change email easily in Supabase without verification
                     ),
                     const SizedBox(height: 16),
                     TextFormField(
                       controller: nameCtrl,
                       decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                       validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                     ),
                     const SizedBox(height: 16),
                     DropdownButtonFormField<String>(
                       value: selectedRole.value,
                       decoration: const InputDecoration(labelText: 'Peran'),
                       items: roles.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                       onChanged: (v) {
                         if (v != null) selectedRole.value = v;
                       },
                     ),
                     const SizedBox(height: 16),
                     TextFormField(
                       controller: deptCtrl,
                       decoration: const InputDecoration(labelText: 'Unit Kerja / Dept ID'),
                       // Simple text for now, should be dropdown in full ERP
                     ),
                     const SizedBox(height: 16),
                     TextFormField(
                       controller: phoneCtrl,
                       decoration: const InputDecoration(labelText: 'No. Telepon'),
                       keyboardType: TextInputType.phone,
                     ),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Fitur pembuatan akun manual saat ini belum tersedia secara langsung.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan minta pengguna untuk melakukan Registrasi (Sign Up) melalui Aplikasi Mobile atau Web dengan email dinas mereka. Setelah itu, akun akan muncul di daftar ini untuk disetujui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (isEditing)
          ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              if (formKey.currentState!.validate()) {
                isLoading.value = true;
                try {
                  final authService = ref.read(supabaseAuthServiceProvider);
                  await authService.adminUpdateUser(
                    userId: user!.uid,
                    displayName: nameCtrl.text,
                    role: selectedRole.value,
                    departmentId: deptCtrl.text.isEmpty ? null : deptCtrl.text,
                    phoneNumber: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true); // Return true to refresh
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil update user')));
                  }
                } catch (e) {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                   }
                } finally {
                  isLoading.value = false;
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
            child: Text(isLoading.value ? 'Menyimpan...' : 'Simpan'),
          ),
      ],
    );
  }
}
