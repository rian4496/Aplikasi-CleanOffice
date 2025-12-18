import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/vendor.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/actions/generic_export_button.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/vendor_form_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MasterVendorScreen extends HookConsumerWidget {
  const MasterVendorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real Data
    final vendorsAsync = ref.watch(vendorsProvider);
    final expandedRowIndex = useState<int?>(null);
    final searchQuery = useState('');
    final selectedCategory = useState<String?>(null);

    // Actions
    Future<void> _showForm([Vendor? vendor]) async {
      await showDialog(
        context: context,
        builder: (context) => VendorFormDialog(initialData: vendor),
      );
    }

    Future<void> _delete(String id, String name) async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hapus Vendor $name?'),
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
        await ref.read(vendorControllerProvider.notifier).delete(id);
      }
    }

    // Helpers
    Future<void> _blacklist(Vendor vendor) async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Blacklist Vendor ${vendor.name}?'),
          content: const Text('Vendor yang di-blacklist akan ditandai merah dan tidak direkomendasikan untuk dipilih.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.black87),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Blacklist'),
            ),
          ],
        ),
      );

      if (confirm == true) {
         final updated = vendor.copyWith(status: 'blacklisted');
         await ref.read(vendorControllerProvider.notifier).updateVendor(updated);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern BG
      appBar: AppBar(
        title: Text('Data Penyedia (Vendor)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Export
          vendorsAsync.maybeWhen(
            data: (list) {
               return GenericExportButton(
                title: 'Data Penyedia',
                headers: const ['Kategori', 'Nama Perusahaan', 'Kontak', 'Telp', 'NPWP', 'Status'],
                data: list,
                rowBuilder: (item) => [
                  item.category,
                  item.name,
                  item.contactPerson ?? '-',
                  item.phone ?? '-',
                  item.taxId ?? '-',
                  item.status
                ],
              );
            }, 
            orElse: () => const SizedBox.shrink()
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add_business_rounded, size: 18),
            label: const Text('Tambah Vendor'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Card(
        margin: const EdgeInsets.all(24),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: Column(
          children: [
             // Toolbar
             Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                   Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Cari Nama Perusahaan atau Kontak...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (val) => searchQuery.value = val,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Filter Category
                  DropdownButton<String?>(
                    value: selectedCategory.value,
                    hint: const Text('Semua Kategori'),
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                      ...['Umum', 'ATK & Percetakan', 'Elektronik & IT', 'Jasa Konstruksi', 'Catering'].map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (val) => selectedCategory.value = val,
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
                   const SizedBox(width: 40), // Expand Icon
                   Expanded(flex: 3, child: Text('Nama Perusahaan', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('Kontak Person', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 2, child: Text('No. Telepon', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   Expanded(flex: 1, child: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                   const SizedBox(width: 120), // Actions (Wider for 3 buttons)
                 ],
               ),
            ),

            // List
            Expanded(
              child: vendorsAsync.when(
                data: (vendors) {
                  final filtered = vendors.where((v) {
                     final q = searchQuery.value.toLowerCase();
                     final matchSearch = v.name.toLowerCase().contains(q) || (v.contactPerson?.toLowerCase().contains(q) ?? false);
                     final matchCat = selectedCategory.value == null || v.category == selectedCategory.value;
                     return matchSearch && matchCat;
                  }).toList();

                  if (filtered.isEmpty) return const Center(child: Text('Tidak ada data vendor'));

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isExpanded = expandedRowIndex.value == index;
                      final isBlacklisted = item.status == 'blacklisted';

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              expandedRowIndex.value = isExpanded ? null : index;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpanded ? AppTheme.primary.withOpacity(0.02) : (isBlacklisted ? Colors.red[50] : Colors.white),
                                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                              ),
                              child: Row(
                                children: [
                                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.grey),
                                  const SizedBox(width: 20),
                                  
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: isBlacklisted ? Colors.red[100] : Colors.blue[50],
                                          child: Text(item.name[0], style: TextStyle(color: isBlacklisted ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, color: isBlacklisted ? Colors.red[900] : Colors.black87))),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.grey[300]!)
                                        ),
                                        child: Text(item.category, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Text(item.contactPerson ?? '-', style: const TextStyle(fontSize: 13))),
                                  Expanded(flex: 2, child: Text(item.phone ?? '-', style: const TextStyle(fontSize: 13))),
                                  Expanded(
                                    flex: 1, 
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildStatusChip(item.status),
                                    ),
                                  ),
                                  
                                  SizedBox(
                                    width: 120,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Edit Button
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                          onPressed: () => _showForm(item),
                                          tooltip: 'Edit',
                                        ),
                                        
                                        // Delete Button
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          onPressed: () => _delete(item.id, item.name),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),

                          // Detail Panel
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              color: Colors.grey[50],
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section 1: Detail Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Informasi Detail', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        _buildDetailRow('Email', item.email ?? '-'),
                                        _buildDetailRow('NPWP', item.taxId ?? '-'),
                                        _buildDetailRow('Alamat', item.address ?? '-'),
                                      ],
                                    ),
                                  ),
                                  // Section 2: History (Placeholder)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Riwayat Transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: const Center(
                                            child: Text('Belum ada transaksi tercatat.', style: TextStyle(color: Colors.grey)),
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
                error: (e,s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status;
    
    if (status == 'active') {
       color = Colors.green;
       label = 'Verified';
    } else if (status == 'blacklisted') {
       color = Colors.red;
       label = 'Blacklist';
    } else {
       color = Colors.orange;
       label = 'Unverified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
