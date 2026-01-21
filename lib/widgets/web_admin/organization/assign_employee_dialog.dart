// lib/widgets/web_admin/organization/assign_employee_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/master/organization.dart';
import '../../../models/master/employee.dart';
import '../../../riverpod/master_crud_controllers.dart'; // For employeesProvider, employeeControllerProvider
import '../../../services/supabase_database_service.dart';

class AssignEmployeeDialog extends HookConsumerWidget {
  final Organization organization;
  final VoidCallback onSaved;

  const AssignEmployeeDialog({
    super.key,
    required this.organization,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State
    final selectedUserIds = useState<Set<String>>({});
    final searchQuery = useState('');
    final isSubmitting = useState(false);

    // Data
    final allEmployeesAsync = ref.watch(employeesProvider);

    // Filter Logic
    final usersList = allEmployeesAsync.maybeWhen(
      data: (employees) {
        return employees.where((e) {
          // Filter out employees already in this org
          if (e.organizationId == organization.id) return false;
          
          // Search query
          if (searchQuery.value.isEmpty) return true;
          final query = searchQuery.value.toLowerCase();
          return e.fullName.toLowerCase().contains(query) || 
                 (e.nip.toLowerCase().contains(query));
        }).toList();
      },
      orElse: () => <Employee>[],
    );

    Future<void> _submit() async {
      if (selectedUserIds.value.isEmpty) return;

      isSubmitting.value = true;
      try {
        // Update each selected employee
        // Using Employee Controller to update organizationId
        final allEmployees = allEmployeesAsync.asData?.value ?? [];
        
        for (var empId in selectedUserIds.value) {
           final emp = allEmployees.firstWhere((e) => e.id == empId);
           final updatedEmp = emp.copyWith(organizationId: organization.id);
           
           await ref.read(employeeControllerProvider.notifier).updateEmployee(updatedEmp);
        }
        
        if (context.mounted) {
           Navigator.of(context).pop();
           // Invalidate providers to refresh lists
           ref.invalidate(employeesProvider);
           onSaved();
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Berhasil menambahkan ${selectedUserIds.value.length} pegawai ke ${organization.name}')),
           );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assign Pegawai', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('ke unit: ${organization.name}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari Nama Pegawai...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (val) => searchQuery.value = val,
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: allEmployeesAsync.when(
                data: (_) {
                  if (usersList.isEmpty) {
                    return Center(child: Text(searchQuery.value.isNotEmpty ? 'Tidak ditemukan.' : 'Semua pegawai sudah memiliki unit lain.'));
                  }
                  
                  return ListView.builder(
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      final user = usersList[index];
                      final isSelected = selectedUserIds.value.contains(user.id);
                      
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          final newSet = Set<String>.from(selectedUserIds.value);
                          if (value == true) {
                            newSet.add(user.id);
                          } else {
                            newSet.remove(user.id);
                          }
                          selectedUserIds.value = newSet;
                        },
                        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(user.position ?? '-', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        secondary: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? Text(user.fullName.isNotEmpty ? user.fullName[0] : '?', style: const TextStyle(color: Colors.grey)) : null,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),

            const SizedBox(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: selectedUserIds.value.isEmpty || isSubmitting.value 
                      ? null 
                      : _submit,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: isSubmitting.value 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
