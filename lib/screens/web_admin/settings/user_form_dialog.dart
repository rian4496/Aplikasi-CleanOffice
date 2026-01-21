import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../models/user_profile.dart';
import '../../../models/user_role.dart';
import '../../../models/master/employee.dart';
import '../../../riverpod/master_crud_controllers.dart';
import '../../../riverpod/supabase_service_providers.dart';
import '../../../riverpod/user_providers.dart';
import '../../../utils/password_generator.dart';

class UserFormDialog extends HookConsumerWidget {
  final UserProfile? user;

  const UserFormDialog({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = user != null;
    
    // Form Controllers (for Edit mode)
    final nameCtrl = useTextEditingController(text: user?.displayName ?? '');
    final emailCtrl = useTextEditingController(text: user?.email ?? '');
    final phoneCtrl = useTextEditingController(text: user?.phoneNumber ?? '');
    final deptCtrl = useTextEditingController(text: user?.departmentId ?? '');
    
    // State for Add mode (create from employee)
    final selectedEmployee = useState<Employee?>(null);
    final generatedPassword = useState<String>('');
    final passwordCopied = useState(false);
    
    // Common State
    final selectedRole = useState<String>(user?.role ?? 'employee');
    final selectedStatus = useState<String>(user?.status ?? 'active');
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Fetch employees for dropdown (only those without email conflict)
    final employeesAsync = ref.watch(employeesProvider);
    // Fetch existing users to prevent duplicates
    final usersAsync = ref.watch(userListProvider);

    // Roles map
    final roles = {
      for (var r in UserRole.allRoles) r: UserRole.getRoleDisplayName(r)
    };

    // Generate password when employee is selected
    void _onEmployeeSelected(Employee? emp) {
      selectedEmployee.value = emp;
      if (emp != null) {
        generatedPassword.value = PasswordGenerator.fromName(emp.fullName);
        passwordCopied.value = false;
      }
    }

    // Copy password to clipboard
    void _copyPassword() {
      Clipboard.setData(ClipboardData(text: generatedPassword.value));
      passwordCopied.value = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password disalin ke clipboard'), duration: Duration(seconds: 2)),
      );
    }

    // Submit for Add mode
    Future<void> _createUser() async {
      if (selectedEmployee.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih pegawai terlebih dahulu')),
        );
        return;
      }

      final emp = selectedEmployee.value!;
      if (emp.email == null || emp.email!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pegawai belum memiliki email. Harap tambahkan email di Master Pegawai.')),
        );
        return;
      }

      isLoading.value = true;
      try {
        final authService = ref.read(supabaseAuthServiceProvider);
        
        // 1. Create auth user & profile
        final newUser = await authService.signUpWithEmailAndPassword(
          email: emp.email!,
          password: generatedPassword.value,
          name: emp.fullName,
          role: selectedRole.value,
        );
        
        // 2. Auto-approve since Admin created this user (skip approval flow)
        await authService.updateUserVerificationStatus(
          userId: newUser.uid,
          status: 'approved',
        );
        
        if (context.mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${emp.fullName} berhasil dibuat dan diaktifkan!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    // Submit for Edit mode
    Future<void> _updateUser() async {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        try {
          final authService = ref.read(supabaseAuthServiceProvider);
          await authService.adminUpdateUser(
            userId: user!.uid,
            displayName: nameCtrl.text,
            role: selectedRole.value,
            status: selectedStatus.value,
            departmentId: deptCtrl.text.isEmpty ? null : deptCtrl.text,
            phoneNumber: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
          );
          if (context.mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil update user')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          isLoading.value = false;
        }
      }
    }

    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Buat User dari Pegawai'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: isEditing 
          ? _buildEditForm(formKey, emailCtrl, nameCtrl, selectedRole, selectedStatus, roles, deptCtrl, phoneCtrl)
          : _buildAddForm(employeesAsync, usersAsync, selectedEmployee, _onEmployeeSelected, generatedPassword, passwordCopied, _copyPassword, selectedRole, roles),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading.value ? null : (isEditing ? _updateUser : _createUser),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary, 
            foregroundColor: Colors.white,
          ),
          child: Text(isLoading.value ? 'Memproses...' : (isEditing ? 'Simpan' : 'Buat User')),
        ),
      ],
    );
  }

  Widget _buildEditForm(
    GlobalKey<FormState> formKey,
    TextEditingController emailCtrl,
    TextEditingController nameCtrl,
    ValueNotifier<String> selectedRole,
    ValueNotifier<String> selectedStatus,
    Map<String, String> roles,
    TextEditingController deptCtrl,
    TextEditingController phoneCtrl,
  ) {
    final statuses = {
      'active': 'Aktif',
      'inactive': 'Nonaktif',
    };

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.black12),
              readOnly: true,
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
            DropdownButtonFormField<String>(
              value: selectedStatus.value,
              decoration: const InputDecoration(labelText: 'Status Akun'),
              items: statuses.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) {
                if (v != null) selectedStatus.value = v;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: deptCtrl,
              decoration: const InputDecoration(labelText: 'Unit Kerja / Dept ID'),
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
    );
  }

  Widget _buildAddForm(
    AsyncValue<List<Employee>> employeesAsync,
    AsyncValue<List<UserProfile>> usersAsync,
    ValueNotifier<Employee?> selectedEmployee,
    Function(Employee?) onEmployeeSelected,
    ValueNotifier<String> generatedPassword,
    ValueNotifier<bool> passwordCopied,
    VoidCallback onCopyPassword,
    ValueNotifier<String> selectedRole,
    Map<String, String> roles,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Select Employee
          const Text('1. Pilih Pegawai', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // Employee dropdown with filtering
          employeesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error loading employees: $e'),
            data: (employees) {
              return usersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading users: $e'),
                data: (users) {
                  // Create set of registered emails (normalized)
                  final registeredEmails = users.map((u) => u.email.toLowerCase()).toSet();

                  // Filter employees: Must have email AND not be already registered
                  final validEmps = employees.where((e) {
                    final hasEmail = e.email != null && e.email!.isNotEmpty;
                    if (!hasEmail) return false;
                    return !registeredEmails.contains(e.email!.toLowerCase());
                  }).toList();

                  if (validEmps.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Semua pegawai dengan email sudah terdaftar sebagai user.', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return DropdownButtonFormField<Employee>(
                    value: selectedEmployee.value,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Pegawai',
                      border: OutlineInputBorder(),
                      hintText: 'Pilih pegawai...',
                    ),
                    items: validEmps.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text('${e.fullName} (${e.email})', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (emp) => onEmployeeSelected(emp),
                  );
                },
              );
            },
          ),
          
          if (selectedEmployee.value != null) ...[
            const SizedBox(height: 24),
            
            // Step 2: Select Role
            const Text('2. Pilih Peran (Role)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedRole.value,
              decoration: const InputDecoration(
                labelText: 'Peran',
                border: OutlineInputBorder(),
              ),
              items: roles.entries.map((e) => DropdownMenuItem(
                value: e.key, 
                child: Text(e.value),
              )).toList(),
              onChanged: (v) {
                if (v != null) selectedRole.value = v;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Step 3: Generated Password
            const Text('3. Password (Auto-Generated)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          generatedPassword.value,
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          passwordCopied.value ? Icons.check : Icons.copy,
                          color: passwordCopied.value ? Colors.green : AdminColors.primary,
                        ),
                        tooltip: 'Salin Password',
                        onPressed: onCopyPassword,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ Catat password ini! Hanya ditampilkan sekali.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

