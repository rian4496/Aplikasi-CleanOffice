import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../models/report_filter.dart';
import '../../../models/inventory_item.dart';
import '../../../services/pdf_report_service.dart';
import '../../../providers/riverpod/agency_providers.dart';
import '../../../providers/master_data_providers.dart';
import '../../../repositories/master_data_repositories.dart';
import '../../../providers/riverpod/supabase_service_providers.dart';
import '../../../services/supabase_database_service.dart';
import '../../../models/transactions/disposal_model.dart';
import '../../../models/transactions/loan_model.dart';

class ReportCenterScreen extends HookConsumerWidget {
  const ReportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final selectedCategory = useState('Semua');

    // Filter categories (Mock)
    final categories = ['Semua', 'Aset', 'Keuangan', 'Gudang', 'Kepegawaian'];

    // Mock Report Catalog
    final reportCatalog = [
      _ReportItem(
        id: 'inv_kib',
        title: 'Laporan Inventaris (KIB)',
        desc: 'Generate KIB A, B, C, D, E sesuai standar Permendagri.',
        icon: Icons.inventory_2,
        type: ReportType.inventory,
        category: 'Aset',
      ),
      _ReportItem(
        id: 'mutation',
        title: 'Laporan Mutasi Aset',
        desc: 'Rekap perpindahan aset antar unit kerja dalam periode tertentu.',
        icon: Icons.swap_horiz,
        type: ReportType.mutation,
        category: 'Aset',
      ),
      _ReportItem(
        id: 'disposal',
        title: 'Laporan Penghapusan',
        desc: 'Daftar aset yang diusulkan atau telah disetujui untuk dihapus.',
        icon: Icons.delete_forever,
        type: ReportType.disposal,
        category: 'Aset',
      ),
      _ReportItem(
        id: 'maintenance',
        title: 'Riwayat Pemeliharaan',
        desc: 'Ringkasan kesehatan aset dan log servis teknisi.',
        icon: Icons.build_circle,
        type: ReportType.maintenance,
        category: 'Gudang',
      ),
      _ReportItem(
        id: 'loan_recap',
        title: 'Rekap Peminjaman',
        desc: 'Monitoring status peminjaman aset dan riwayat kontrak.',
        icon: Icons.calendar_month,
        type: ReportType.summary,
        category: 'Aset',
      ),
       _ReportItem(
        id: 'stock',
        title: 'Stok Opname Gudang',
        desc: 'Posisi stok barang habis pakai terkini.',
        icon: Icons.warehouse,
        type: ReportType.summary, // Placeholder type
        category: 'Gudang',
      ),
       _ReportItem(
        id: 'budget',
        title: 'Realisasi Anggaran',
        desc: 'Laporan serapan anggaran pengadaan barang.',
        icon: Icons.pie_chart,
        type: ReportType.summary, // Placeholder type
        category: 'Keuangan',
      ),
    ];

    final filteredReports = reportCatalog.where((r) {
      final matchesSearch = r.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          r.desc.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'Semua' || r.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();

    return AdminLayoutWrapper(
      title: 'Pusat Laporan & Arsip',
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          children: [
            // Sticky Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Row(
                    children: [
                      // Search
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: (v) => searchQuery.value = v,
                          decoration: const InputDecoration(
                            hintText: 'Cari template laporan...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Mock Date/Period Filter (Global)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Periode: ${DateFormat('MMM yyyy').format(DateTime.now())}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Categories
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat == selectedCategory.value;
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => selectedCategory.value = cat,
                          checkmarkColor: Colors.white,
                          selectedColor: _getCategoryColor(cat),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid Content
            Expanded(
              child: filteredReports.isEmpty
                ? const Center(child: Text('Laporan tidak ditemukan'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      return _ReportCard(
                        item: filteredReports[index], 
                        onGenerate: () => _showGenerateDialog(context, ref, filteredReports[index]),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateDialog(BuildContext context, WidgetRef ref, _ReportItem item) {
    showDialog(
      context: context,
      builder: (context) => _GenerateReportDialog(item: item),
    );
  }
}

class _ReportItem {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final ReportType type;
  final String category;

  _ReportItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.type,
    required this.category,
  });
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'Aset': return const Color(0xFF2196F3); // Blue
    case 'Keuangan': return const Color(0xFF4CAF50); // Green
    case 'Gudang': return const Color(0xFFFF9800); // Orange
    case 'Kepegawaian': return const Color(0xFF9C27B0); // Purple
    default: return AdminColors.primary;
  }
}

class _ReportCard extends StatefulWidget {
  final _ReportItem item;
  final VoidCallback onGenerate;

  const _ReportCard({required this.item, required this.onGenerate});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = _getCategoryColor(widget.item.category);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onGenerate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? themeColor.withOpacity(0.5) : Colors.grey[200]!,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? themeColor.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Color-coded Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.item.icon, color: themeColor, size: 28),
                  ),
                  const Spacer(),
                  // Premium PDF Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'PDF', 
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.red[700]
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.item.title, 
                style: AdminTypography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[900]
                ), 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  widget.item.desc, 
                  style: AdminTypography.body2.copyWith(
                    fontSize: 13, 
                    color: Colors.grey[600],
                    height: 1.4
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              // Lighter / Cleaner Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onGenerate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isHovered ? Colors.white : themeColor,
                    backgroundColor: _isHovered ? themeColor : Colors.transparent,
                    side: BorderSide(color: themeColor.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(_isHovered ? Icons.print_rounded : Icons.print_outlined, size: 18),
                       const SizedBox(width: 8),
                       const Text('Generate', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerateReportDialog extends HookConsumerWidget {
  final _ReportItem item;

  const _GenerateReportDialog({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyProfile = ref.watch(agencyProfileProvider);
    final startDate = useState(DateTime.now().subtract(const Duration(days: 30)));
    final endDate = useState(DateTime.now());
    final isGenerating = useState(false);

    return AlertDialog(
      title: Text('Generate: ${item.title}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Periode Data:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _datePicker(context, 'Dari', startDate),
                ),
                const SizedBox(width: 16),
                Expanded(
                   child: _datePicker(context, 'Sampai', endDate),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Example of specialized filter for KIB
            if (item.type == ReportType.inventory)
               DropdownButtonFormField<String>(
                 decoration: const InputDecoration(labelText: 'Jenis Aset', border: OutlineInputBorder()),
                 items: const [
                   DropdownMenuItem(value: 'all', child: Text('Semua (Gabungan)')),
                   DropdownMenuItem(value: 'A', child: Text('KIB A (Tanah)')),
                   DropdownMenuItem(value: 'B', child: Text('KIB B (Peralatan)')),
                 ],
                 onChanged: (_) {},
                 value: 'all',
               ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton.icon(
          onPressed: isGenerating.value ? null : () async {
            isGenerating.value = true;
            try {
               final filter = ReportFilter(
                 type: item.type,
                 startDate: startDate.value,
                 endDate: endDate.value,
               );

               final pdfService = PdfReportService();
               final profile = agencyProfile.asData?.value;
               if (profile == null) throw Exception('Profil instansi belum dimuat');
               
               Uint8List? pdfBytes;
               
               // === LOGIC SWITCH ===
               switch(item.type) {
                 case ReportType.inventory:
                   final assetRepo = ref.read(assetRepositoryProvider);
                   final assets = await assetRepo.getAssetsForReport(startDate: startDate.value, endDate: endDate.value, category: 'all');
                   final reportItems = assets.map((a) => InventoryItem(
                     id: a.id, name: a.name, category: a.assetCode, currentStock: 1, maxStock: 1, minStock: 0, unit: 'unit', createdAt: DateTime.now(), updatedAt: DateTime.now(), description: a.conditionId,
                   )).toList();
                   pdfBytes = await pdfService.generateInventoryReport(profile: profile, items: reportItems, filter: filter);
                   break;
                   
                 default:
                   // Other reports temporarily disabled - show message
                   throw Exception('Laporan ${item.title} sedang dalam pengembangan.');
               }

               if (pdfBytes != null) {
                  if (context.mounted) Navigator.pop(context); // Close dialog
                  await Printing.layoutPdf(
                     onLayout: (format) async => pdfBytes!,
                     name: '${item.title}_${DateFormat('yyyyMMdd').format(DateTime.now())}',
                  );
               }
            } catch (e) {
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            } finally {
              isGenerating.value = false;
            }
          },
          icon: isGenerating.value 
             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
             : const Icon(Icons.print),
          label: Text(isGenerating.value ? 'Memproses...' : 'Cetak PDF'),
          style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _datePicker(BuildContext context, String label, ValueNotifier<DateTime> dateNotifier) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dateNotifier.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) dateNotifier.value = picked;
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(dateNotifier.value)),
      ),
    );
  }
}
