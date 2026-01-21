import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printing/printing.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/organization.dart';
import 'package:aplikasi_cleanoffice/models/agency_profile.dart';
import 'package:aplikasi_cleanoffice/models/report_filter.dart';
import 'package:aplikasi_cleanoffice/models/export_config.dart' hide ReportType;
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';
import 'package:aplikasi_cleanoffice/riverpod/agency_providers.dart';
import 'package:aplikasi_cleanoffice/services/pdf_report_service.dart';
import 'package:aplikasi_cleanoffice/services/export_service.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/organization_form_dialog.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/organization/organization_node_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/organization/organization_tree_builder.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/organization/organization_detail_drawer.dart';


class MasterOrganisasiScreen extends HookConsumerWidget {
  const MasterOrganisasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real Data Stream
    final organizationAsync = ref.watch(organizationsProvider);
    final searchQuery = useState('');
    final selectedOrg = useState<Organization?>(null);

    // Actions
    Future<void> _showForm([Organization? org]) async {
      await showDialog(
        context: context,
        builder: (context) => OrganizationFormDialog(initialData: org),
      );
    }

    Future<void> _delete(Organization org) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Unit Organisasi?'),
          content: Text('Anda yakin ingin menghapus "${org.name}"? Data yang dihapus tidak dapat dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref.read(organizationControllerProvider.notifier).delete(org.id);
        if (selectedOrg.value?.id == org.id) {
          selectedOrg.value = null; // Deselect if deleted
        }
        ref.invalidate(organizationsProvider);
      }
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                   Text('Tambah Unit', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
        title: Text('Struktur Organisasi (BRIDA)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Export Button
          organizationAsync.maybeWhen(
            data: (orgs) {
              // Helper to get parent name
              String getParentName(String? parentId) {
                if (parentId == null) return '-';
                final parent = orgs.where((o) => o.id == parentId).firstOrNull;
                return parent?.name ?? '-';
              }
              
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
                    
                    // Convert Organization list to Map format
                    final items = orgs.map((o) => {
                      'code': o.code,
                      'name': o.name,
                      'type': o.type,
                      'parent_name': getParentName(o.parentId),
                    }).toList();
                    
                    // Generate and print PDF directly
                    final pdfBytes = await PdfReportService().generateOrganizationReport(
                      profile: profile,
                      items: items,
                      filter: filter,
                    );
                    
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name: 'Daftar_Organisasi_BRIDA.pdf',
                    );
                  } else if (value == 'excel') {
                    // Excel Export
                    final excelData = orgs.map((o) => [
                      o.code,
                      o.name,
                      o.type,
                    ]).toList();
                    
                    await ExportService().exportGenericData(
                      title: 'Data Organisasi',
                      headers: ['Kode Unit', 'Nama Unit', 'Tipe'],
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
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          if (!isMobile)
            FilledButton.icon(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add_business_rounded, size: 18),
              label: const Text('Tambah Unit'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: isMobile
        ? Stack(
            children: [
              // 1. Main List (Full Width)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Toggle Search / Toolbar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                             BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                             )
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari Unit Organisasi...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            isDense: true,
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          onChanged: (value) => searchQuery.value = value,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tree
                      Expanded(
                        child: organizationAsync.when(
                          data: (organizations) {
                             var displayList = organizations;
                             if (searchQuery.value.isNotEmpty) {
                                final q = searchQuery.value.toLowerCase();
                                displayList = organizations.where((e) => 
                                  e.name.toLowerCase().contains(q) || 
                                  e.code.toLowerCase().contains(q)
                                ).toList();
                             }

                             if (displayList.isEmpty) {
                               return const Center(child: Text('Tidak ada data'));
                             }

                             final treeNodes = OrganizationTreeBuilder.buildTree(displayList);

                             return ListView.builder(
                               padding: const EdgeInsets.only(bottom: 80),
                               itemCount: treeNodes.length,
                               itemBuilder: (context, index) {
                                 return OrganizationNodeWidget(
                                   node: treeNodes[index],
                                   onEdit: _showForm,
                                   onDelete: _delete,
                                   onTap: (org) {
                                      // On mobile, tapping opens overlay immediately
                                      selectedOrg.value = org; 
                                   },
                                   isSelected: selectedOrg.value?.id == treeNodes[index].data.id,
                                 );
                               },
                             );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, s) => Text('Error: $err'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Mobile Detail Overlay
              if (selectedOrg.value != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54, // Barrier
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: double.infinity, // Full width on mobile constrained by maxWidth if needed, or simple fractional
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          children: [
                            // Mobile Header for Drawer
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => selectedOrg.value = null,
                                  ),
                                  const Expanded(child: Text('Detail Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: OrganizationDetailDrawer(
                                organization: selectedOrg.value!,
                                onClose: () => selectedOrg.value = null,
                                onEdit: _showForm,
                                onDelete: _delete,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN CONTENT (Tree)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                         BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                         )
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Unit Organisasi...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        isDense: true,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      onChanged: (value) => searchQuery.value = value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tree View
                  Expanded(
                    child: organizationAsync.when(
                      data: (organizations) {
                        // Filter Logic
                        var displayList = organizations;
                        if (searchQuery.value.isNotEmpty) {
                           final q = searchQuery.value.toLowerCase();
                           displayList = organizations.where((e) => 
                             e.name.toLowerCase().contains(q) || 
                             e.code.toLowerCase().contains(q)
                           ).toList();
                        }

                        if (displayList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('Tidak ada unit organisasi ditemukan.', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          );
                        }

                        // Build Tree
                        final treeNodes = OrganizationTreeBuilder.buildTree(displayList);

                        return ListView.builder( 
                          padding: const EdgeInsets.only(bottom: 80), 
                          itemCount: treeNodes.length,
                          itemBuilder: (context, index) {
                            return OrganizationNodeWidget(
                              node: treeNodes[index],
                              onEdit: _showForm,
                              onDelete: _delete,
                              onTap: (org) {
                                if (selectedOrg.value?.id == org.id) {
                                  selectedOrg.value = null; // Toggle off
                                } else {
                                  selectedOrg.value = org; // Select new
                                }
                              },
                              isSelected: selectedOrg.value?.id == treeNodes[index].data.id,
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
          ),

          // SIDE PANEL (Detail Drawer)
          // AnimatedSwitcher for smooth transition
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              width: selectedOrg.value == null ? 0 : 400,
              child: selectedOrg.value != null 
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey[200]!)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(-4, 0)),
                      ],
                    ),
                    child: OrganizationDetailDrawer(
                      organization: selectedOrg.value!,
                      onClose: () => selectedOrg.value = null,
                      onEdit: _showForm,
                      onDelete: _delete,
                    ),
                  )
                : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
