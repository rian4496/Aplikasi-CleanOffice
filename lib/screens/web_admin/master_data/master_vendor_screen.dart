import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printing/printing.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/vendor.dart';
import 'package:aplikasi_cleanoffice/models/agency_profile.dart';
import 'package:aplikasi_cleanoffice/models/report_filter.dart';
import 'package:aplikasi_cleanoffice/models/export_config.dart' hide ReportType;
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';
import 'package:aplikasi_cleanoffice/riverpod/agency_providers.dart';
import 'package:aplikasi_cleanoffice/services/pdf_report_service.dart';
import 'package:aplikasi_cleanoffice/services/export_service.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/vendor_form_dialog.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/mobile_vendor_card.dart';



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
        ref.invalidate(vendorsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vendor "$name" berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
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

    // Responsive Check
    final isMobile = MediaQuery.of(context).size.width < 900; 

    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern BG
      floatingActionButton: isMobile ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () => _showForm(),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.9)]),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.add_business_rounded, color: Colors.white, size: 20),
                   const SizedBox(width: 8),
                   Text('Tambah Vendor', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
         ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        leading: isMobile ? IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ) : null,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Data Penyedia (Vendor)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Export Menu
          if (!isMobile)
          vendorsAsync.maybeWhen(
            data: (list) {
               return PopupMenuButton<String>(
                 icon: const Icon(Icons.file_download_outlined),
                 tooltip: 'Export Data',
                 onSelected: (value) async {
                   if (value == 'pdf') {
                     // PDF Export
                     final agencyAsync = ref.read(agencyProfileProvider);
                     final profile = agencyAsync.value ?? AgencyProfile.empty();
                     final filter = ReportFilter(
                       type: ReportType.inventory,
                       startDate: DateTime.now(),
                       endDate: DateTime.now(),
                     );
                     
                     // Convert Vendor list to Map format
                     final items = list.map((v) => {
                       'name': v.name,
                       'category': v.category,
                       'contact_person': v.contactPerson ?? '-',
                       'phone': v.phone ?? '-',
                       'address': v.address ?? '-',
                       'status': v.status,
                     }).toList();
                     
                     // Generate and print PDF directly
                     final pdfBytes = await PdfReportService().generateVendorReport(
                       profile: profile,
                       items: items,
                       filter: filter,
                     );
                     
                     await Printing.layoutPdf(
                       onLayout: (format) async => pdfBytes,
                       name: 'Daftar_Vendor_BRIDA.pdf',
                     );
                   } else if (value == 'excel') {
                     // Excel Export using ExportService
                     final excelData = list.map((v) => [
                       v.category,
                       v.name,
                       v.contactPerson ?? '-',
                       v.phone ?? '-',
                       v.taxId ?? '-',
                       v.status
                     ]).toList();
                     
                     await ExportService().exportGenericData(
                       title: 'Data Penyedia',
                       headers: ['Kategori', 'Nama Perusahaan', 'Kontak', 'Telp', 'NPWP', 'Status'],
                       data: excelData,
                       format: ExportFormat.excel,
                     );
                   }
                 },
                 itemBuilder: (context) => [
                   const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 18, color: Colors.red), SizedBox(width: 8), Text('Export PDF')])),
                   const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_chart, size: 18, color: Colors.green), SizedBox(width: 8), Text('Export Excel')])),
                 ],
               );
            }, 
            orElse: () => const SizedBox.shrink()
          ),
          const SizedBox(width: 8),
          if (!isMobile)
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
      body: vendorsAsync.when(
        data: (vendors) {
           final filtered = vendors.where((v) {
              final q = searchQuery.value.toLowerCase();
              final matchSearch = v.name.toLowerCase().contains(q) || (v.contactPerson?.toLowerCase().contains(q) ?? false);
              final matchCat = selectedCategory.value == null || v.category == selectedCategory.value;
              return matchSearch && matchCat;
           }).toList();

          if (isMobile) {
            // ================= MOBILE LAYOUT =================
            return Column(
              children: [
                // Mobile Toolbar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Cari vendor...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (val) => searchQuery.value = val,
                      ),
                      const SizedBox(height: 12),
                      
                      // Category Dropdown
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: selectedCategory.value,
                            hint: const Text('Semua Kategori', style: TextStyle(color: Colors.black87)),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                              ...['Umum', 'ATK & Percetakan', 'Elektronik & IT', 'Jasa Konstruksi', 'Catering'].map((c) => DropdownMenuItem(value: c, child: Text(c))),
                            ],
                            onChanged: (val) => selectedCategory.value = val,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mobile List
                Expanded(
                  child: filtered.isEmpty 
                      ? const Center(child: Text('Tidak ada data vendor'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return MobileVendorCard(
                              vendor: item,
                              onEdit: () => _showForm(item),
                              onDelete: () => _delete(item.id, item.name),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          // ================= DESKTOP LAYOUT =================
          return Card(
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
                      IgnorePointer(
                        ignoring: expandedRowIndex.value != null, // Block clicks
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: expandedRowIndex.value != null ? Colors.grey[200] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!), // Match TextField border roughly
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: selectedCategory.value,
                              hint: const Text('Semua Kategori', style: TextStyle(color: Colors.black87)),
                              icon: Icon(
                                Icons.arrow_drop_down, 
                                color: expandedRowIndex.value != null ? Colors.transparent : Colors.grey[700],
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                                ...['Umum', 'ATK & Percetakan', 'Elektronik & IT', 'Jasa Konstruksi', 'Catering'].map((c) => DropdownMenuItem(value: c, child: Text(c))),
                              ],
                              onChanged: (val) => selectedCategory.value = val,
                            ),
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
                     color: AppTheme.primary.withValues(alpha: 0.05),
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
                  child: filtered.isEmpty 
                      ? const Center(child: Text('Tidak ada data vendor'))
                      : ListView.builder(
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
                                    color: isExpanded ? AppTheme.primary.withValues(alpha: 0.02) : (isBlacklisted ? Colors.red[50] : Colors.white),
                                    border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.grey),
                                      const SizedBox(width: 20),
                                      
                                      Expanded(
                                        flex: 3,
                                        child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, color: isBlacklisted ? Colors.red[900] : Colors.black87)),
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
                      ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Error: $e')),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
