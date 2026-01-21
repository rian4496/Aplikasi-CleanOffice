import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printing/printing.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/employee.dart';
import 'package:aplikasi_cleanoffice/models/agency_profile.dart';
import 'package:aplikasi_cleanoffice/models/report_filter.dart';
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';
import 'package:aplikasi_cleanoffice/riverpod/agency_providers.dart';
import 'package:aplikasi_cleanoffice/models/export_config.dart' hide ReportType;
import 'package:aplikasi_cleanoffice/services/export_service.dart';
import 'package:aplikasi_cleanoffice/services/pdf_report_service.dart';
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

    String? _getOrgName(String? id, WidgetRef ref) {
      if (id == null) return null;
      final orgs = ref.watch(organizationsProvider).asData?.value;
      if (orgs == null) return id; // Fallback to ID if list not loaded
      final org = orgs.where((o) => o.id == id).firstOrNull;
      return org?.name ?? id; // Fallback to ID if not found
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
        ref.invalidate(employeesProvider);
      }
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
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
                   const Icon(Icons.person_add, color: Colors.white, size: 20),
                   const SizedBox(width: 8),
                   Text('Tambah Pegawai', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
          child: Text('Data Pegawai', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
        actions: [
          // Export
           employeeAsync.maybeWhen(
            data: (list) {
              final exportData = list.where((e) {
                 final q = searchQuery.value.toLowerCase();
                 return e.fullName.toLowerCase().contains(q) || e.nip.contains(q);
              }).toList();
              
              return PopupMenuButton<String>(
                icon: const Icon(Icons.download, color: Colors.grey),
                tooltip: 'Export Data',
                enabled: exportData.isNotEmpty,
                onSelected: (value) async {
                  if (value == 'pdf') {
                    // Get agency profile for Kop Surat
                    final agencyAsync = ref.read(agencyProfileProvider);
                    final profile = agencyAsync.value ?? AgencyProfile.empty();
                    final filter = ReportFilter(
                      type: ReportType.inventory,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                    );
                    
                    // Convert Employee list to Map format
                    final items = exportData.map((e) => {
                      'nip': e.nip,
                      'full_name': e.fullName,
                      'position': e.position ?? '-',
                      'employee_type': EmployeeType.getDisplayName(e.employeeType),
                      'status': e.status,
                    }).toList();
                    
                    // Generate and print PDF directly (no preview)
                    final pdfBytes = await PdfReportService().generateEmployeeReport(
                      profile: profile,
                      items: items,
                      filter: filter,
                    );
                    
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name: 'Daftar_Pegawai_BRIDA.pdf',
                    );
                  } else if (value == 'excel') {
                    // Export to Excel using existing service
                    final exportService = ref.read(exportServiceProvider);
                    final headers = ['NIP', 'Nama Lengkap', 'Jabatan', 'Tipe Pegawai', 'Email', 'No HP', 'Status'];
                    final data = exportData.map((e) => [
                      e.nip,
                      e.fullName,
                      e.position ?? '-',
                      EmployeeType.getDisplayName(e.employeeType),
                      e.email ?? '-',
                      e.phone ?? '-',
                      e.status,
                    ]).toList();
                    await exportService.exportGenericData(
                      title: 'Data Pegawai',
                      headers: headers,
                      data: data,
                      format: ExportFormat.excel,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Export PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Export Excel'),
                      ],
                    ),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          if (!isMobile)
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
        elevation: 5, // Increased Shadow
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!, width: 0.5), // Thinner Border
        ),
        child: Column(
          children: [
            // Toolbar
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: MediaQuery.of(context).size.width < 600
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pegawai: ${employeeAsync.asData?.value.length ?? 0}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Urutkan: ${sortOption.value}',
                              icon: const Icon(Icons.sort),
                              onSelected: (value) => sortOption.value = value,
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'Nama (A-Z)', child: Text('Nama (A-Z)')),
                                const PopupMenuItem(value: 'Nama (Z-A)', child: Text('Nama (Z-A)')),
                                const PopupMenuItem(value: 'NIP (Terkecil)', child: Text('NIP (Terkecil)')),
                                const PopupMenuItem(value: 'Jabatan', child: Text('Jabatan')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
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
                        const SizedBox(width: 16),
                        Text(
                          'Total Pegawai: ${employeeAsync.asData?.value.length ?? 0}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 16),
                        PopupMenuButton<String>(
                          tooltip: 'Urutkan: ${sortOption.value}',
                          icon: const Icon(Icons.sort),
                          onSelected: (value) => sortOption.value = value,
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'Nama (A-Z)', child: Text('Nama (A-Z)')),
                            const PopupMenuItem(value: 'Nama (Z-A)', child: Text('Nama (Z-A)')),
                            const PopupMenuItem(value: 'NIP (Terkecil)', child: Text('NIP (Terkecil)')),
                            const PopupMenuItem(value: 'Jabatan', child: Text('Jabatan')),
                          ],
                        ),
                      ],
                    ),
            ),
            
                            // Header Row
            if (MediaQuery.of(context).size.width >= 800)
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 decoration: BoxDecoration(
                   color: AppTheme.primary.withValues(alpha: 0.05),
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
                      case 'Nama (A-Z)': return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
                      case 'Nama (Z-A)': return b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase());
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
                  
                  return ListView.separated(
                    padding: MediaQuery.of(context).size.width < 800 ? const EdgeInsets.all(16) : EdgeInsets.zero,
                    itemCount: employees.length,
                    separatorBuilder: (ctx, i) => MediaQuery.of(context).size.width < 800 ? const SizedBox(height: 16) : const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      final e = employees[index];
                      final isExpanded = expandedRowIndex.value == index;
                      final isMobile = MediaQuery.of(context).size.width < 800;

                      if (isMobile) {
                        return _buildMobileEmployeeCard(context, e, _showForm, _delete);
                      }

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
                                color: isExpanded ? AppTheme.primary.withValues(alpha: 0.02) : Colors.white,
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
                                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
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
                                  
                                  // Actions
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
                                        _buildDetailRow('Unit Kerja', _getOrgName(e.organizationId, ref) ?? '-'),
                                        _buildDetailRow('Tipe Pegawai', EmployeeType.getDisplayName(e.employeeType)),
                                        
                                        // Conditional ASN Fields
                                        if (e.employeeType == EmployeeType.pns) ...[
                                          if (e.golonganPangkat != null) _buildDetailRow('Golongan', e.golonganPangkat!),
                                          if (e.eselon != null) _buildDetailRow('Eselon', e.eselon!),
                                        ],

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
                                              Text(e.status == 'active' ? 'AKTIF' : 'NON-AKTIF', 
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'AKTIF' : 'NON-AKTIF',
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMobileEmployeeCard(BuildContext context, Employee e, Function(Employee) onEdit, Function(String, String) onDelete) {
    return Container(
       padding: const EdgeInsets.all(12), // Reduced from 16
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey[200]!),
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withValues(alpha: 0.05),
             blurRadius: 5,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Avatar
               CircleAvatar(
                  radius: 20, // Reduced from 24
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  backgroundImage: e.photoUrl != null ? NetworkImage(e.photoUrl!) : null,
                  child: e.photoUrl == null ? Text(e.fullName.isNotEmpty ? e.fullName[0] : '?', 
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Reduced from 16
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusPill(e.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(e.nip, style: GoogleFonts.sourceCodePro(color: Colors.grey[600], fontSize: 12)), // Reduced
                      const SizedBox(height: 2),
                      Text(e.position ?? '-', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                ),
             ],
           ),
           if (e.phone != null || e.email != null) ...[
             const SizedBox(height: 12),
             const Divider(height: 1),
             const SizedBox(height: 8),
             Row(
               children: [
                 if (e.email != null) Expanded(child: _buildIconText(Icons.email_outlined, e.email!)),
                 if (e.phone != null) Expanded(child: _buildIconText(Icons.phone_outlined, e.phone!)),
               ],
             ),
           ],
           const SizedBox(height: 8),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               // Compact Text Buttons for Actions
               InkWell(
                 onTap: () => onEdit(e),
                 child: const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   child: Row(
                     children: [
                       Icon(Icons.edit, size: 14, color: Colors.blue),
                       SizedBox(width: 4),
                       Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                     ],
                   ),
                 ),
               ),
               const SizedBox(width: 8),
               InkWell(
                 onTap: () => onDelete(e.id, e.fullName),
                 child: const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   child: Row(
                     children: [
                       Icon(Icons.delete, size: 14, color: Colors.red),
                       SizedBox(width: 4),
                       Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                     ],
                   ),
                 ),
               ),
             ],
           ),
         ],
       ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]), // Reduced
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 11), overflow: TextOverflow.ellipsis), // Reduced
        ),
      ],
    );
  }
}
