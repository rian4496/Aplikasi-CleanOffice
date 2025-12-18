import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/employee.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/actions/generic_export_button.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/employee_form_dialog.dart';

class MasterPegawaiScreen extends HookConsumerWidget {
  const MasterPegawaiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real Data
    final employeeAsync = ref.watch(employeesProvider);
    final expandedRowIndex = useState<int?>(null);
    final searchQuery = useState('');
    final sortOption = useState('Nama (A-Z)');

    // Helper for expanded view
    Widget _buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140, 
              child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))
            ),
          ],
        ),
      );
    }

    Future<void> _showForm([Employee? emp]) async {
      await showDialog(
        context: context,
        builder: (context) => EmployeeFormDialog(initialData: emp),
      );
    }

    Future<void> _delete(String id, String name) async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hapus Pegawai $name?'),
          content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref.read(employeeControllerProvider.notifier).delete(id);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: AppBar(
        title: Text('Data Pegawai', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          // Export
           employeeAsync.maybeWhen(
            data: (list) {
              final exportData = list.where((e) {
                 final q = searchQuery.value.toLowerCase();
                 return e.fullName.toLowerCase().contains(q) || e.nip.contains(q);
              }).toList();
              
              return GenericExportButton(
                title: 'Data Pegawai',
                headers: const ['NIP', 'Nama', 'Jabatan', 'Email', 'No. HP'],
                data: exportData,
                rowBuilder: (item) => [
                  item.nip,
                  item.fullName,
                  item.position ?? '-',
                  item.email ?? '-',
                  item.phone ?? '-',
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Tambah Pegawai'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Card(
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: Column(
          children: [
            // Toolbar
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                   Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Cari Nama Lengkap atau NIP...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) => searchQuery.value = value,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sort Logic
                  PopupMenuButton<String>(
                    onSelected: (value) => sortOption.value = value,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Nama (A-Z)', child: Text('Nama (A-Z)')),
                      const PopupMenuItem(value: 'NIP (Terkecil)', child: Text('NIP (Terkecil)')),
                      const PopupMenuItem(value: 'Jabatan', child: Text('Jabatan')),
                    ],
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.sort),
                      label: Text('Urutkan: ${sortOption.value}'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Header Row
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               decoration: BoxDecoration(
                 color: AppTheme.primary.withOpacity(0.05),
                 border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
               ),
               child: Row(
                 children: [
                   const SizedBox(width: 40), // Expand icon space
                   SizedBox(width: 40, child: Text('', style: GoogleFonts.inter(fontWeight: FontWeight.bold))), // Avatar
                   const SizedBox(width: 16),
                   Expanded(flex: 3, child: Text('Nama Lengkap', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('NIP', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('Jabatan', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('No HP', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 1, child: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   const SizedBox(width: 80), // Actions
                 ],
               ),
            ),
            
            // Table Rows
            Expanded(
              child: employeeAsync.when(
                data: (allEmployees) {
                  // Filter
                  var employees = allEmployees.where((e) {
                    final query = searchQuery.value.toLowerCase();
                    return e.fullName.toLowerCase().contains(query) || 
                           e.nip.toLowerCase().contains(query);
                  }).toList();

                  // Sort
                  employees.sort((a, b) {
                    switch (sortOption.value) {
                      case 'Nama (A-Z)': return a.fullName.compareTo(b.fullName);
                      case 'NIP (Terkecil)': return a.nip.compareTo(b.nip);
                      case 'Jabatan': return (a.position ?? '').compareTo(b.position ?? '');
                      default: return 0;
                    }
                  });

                  if (employees.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(searchQuery.value.isNotEmpty ? 'Tidak ditemukan data pegawai.' : 'Belum ada data pegawai.', 
                            style: GoogleFonts.inter(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final e = employees[index];
                      final isExpanded = expandedRowIndex.value == index;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (isExpanded) {
                                expandedRowIndex.value = null;
                              } else {
                                expandedRowIndex.value = index;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpanded ? AppTheme.primary.withOpacity(0.02) : Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                              ),
                              child: Row(
                                children: [
                                  // Expand Icon
                                  Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more, 
                                    size: 20, 
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 20),
                                  
                                  // Avatar Placeholder
                                  SizedBox(
                                    width: 40,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                                      backgroundImage: e.photoUrl != null ? NetworkImage(e.photoUrl!) : null,
                                      child: e.photoUrl == null ? Text(e.fullName.isNotEmpty ? e.fullName[0] : '?', 
                                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Name
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (e.email != null)
                                          Text(e.email!, style:  TextStyle(fontSize: 11, color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                  // NIP
                                  Expanded(
                                    flex: 2,
                                    child: Text(e.nip, style: GoogleFonts.sourceCodePro(fontSize: 13, color: Colors.grey[800])),
                                  ),
                                  // Jabatan
                                  Expanded(
                                    flex: 2,
                                    child: Text(e.position ?? '-', style: const TextStyle(fontSize: 13)),
                                  ),
                                  // No HP
                                  Expanded(
                                    flex: 2,
                                    child: Text(e.phone ?? '-', style: const TextStyle(fontSize: 13)),
                                  ),
                                  // Status
                                  Expanded(
                                    flex: 1,
                                    child: _buildStatusPill(e.status),
                                  ),
                                  
                                  // Actions (Collapsed view only show few or none, mostly in expanded)
                                  SizedBox(
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                          onPressed: () => _showForm(e),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            onPressed: () => _delete(e.id, e.fullName),
                                            tooltip: 'Hapus',
                                        ),
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Expanded Details
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Photo Large
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                      image: e.photoUrl != null ? DecorationImage(image: NetworkImage(e.photoUrl!), fit: BoxFit.cover) : null,
                                    ),
                                    child: e.photoUrl == null ? Icon(Icons.person, size: 60, color: Colors.grey[300]) : null,
                                  ),
                                  const SizedBox(width: 32),
                                  
                                  // Middle: Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Detail Informasi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 16),
                                        _buildDetailRow('Unit Kerja', e.departmentName ?? e.organizationId ?? '-'),
                                        _buildDetailRow('Email', e.email ?? '-'),
                                        _buildDetailRow('No. HP', e.phone ?? '-'), 
                                      ],
                                    ),
                                  ),
                                  
                                  // Right: Badges / More Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Status Kepegawaian', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: e.status == 'active' ? Colors.green[50] : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: e.status == 'active' ? Colors.green[200]! : Colors.grey[300]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(e.status == 'active' ? Icons.check_circle : Icons.cancel, 
                                                size: 16, color: e.status == 'active' ? Colors.green : Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(e.status.toUpperCase(), 
                                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: e.status == 'active' ? Colors.green[700] : Colors.grey[700])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    bool isActive = status == 'active';
    Color color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
