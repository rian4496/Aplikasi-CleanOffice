import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/organization.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/actions/generic_export_button.dart';
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
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: Text('Struktur Organisasi (BRIDA)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Export Button
          organizationAsync.maybeWhen(
            data: (orgs) {
              return GenericExportButton(
                title: 'Data Organisasi',
                headers: const ['Kode Unit', 'Nama Unit', 'Tipe'],
                data: orgs,
                rowBuilder: (item) => [item.code, item.name, item.type],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
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
      body: Row(
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
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Cari Unit Organisasi...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) => searchQuery.value = value,
                            ),
                          ),
                          // Add visual toggle or other tools here if needed
                        ],
                      ),
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
                           // If filtered, we might lose hierarchy context if we strictly use tree builder only on filtered items.
                           // Ideally, we filter keys and keep parents.
                           // For now, if searching, just show flat list or filtered tree?
                           // Let's assume user wants to see matches.
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
                        // If searching, hierarchy might be broken so we might want to fallback to flat list or keep tree but only matching paths.
                        // Simple approach: Always try to build tree, but if flat search is active, maybe show list?
                        // Let's try building tree from whatever list we have (might result in multiple roots if parents missing)
                        // OrganizationTreeBuilder handles partial lists by creating roots for orphans.
                        final treeNodes = OrganizationTreeBuilder.buildTree(displayList);

                        return ListView.builder( // Removed separate and padding to avoid double padding
                          padding: const EdgeInsets.only(bottom: 80), // Fab space
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
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(-4, 0)),
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
