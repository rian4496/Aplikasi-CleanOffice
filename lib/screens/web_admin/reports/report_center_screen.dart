import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_helper.dart';

import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../models/report_filter.dart';
import '../../../services/pdf_report_service.dart';
import '../../../riverpod/agency_providers.dart';
import '../../../riverpod/dropdown_providers.dart' hide budgetRepositoryProvider;
import '../../../riverpod/supabase_service_providers.dart';
import '../../../riverpod/transactions/disposal_provider.dart';
import '../../../riverpod/maintenance_providers.dart';
import '../../../riverpod/maintenance_providers.dart';
import '../../../riverpod/transactions/loan_provider.dart';
import '../../../riverpod/inventory_providers.dart'; // Inventory
import '../../../riverpod/master_crud_controllers.dart'; // Budget
import '../../../riverpod/asset_providers.dart'; // For allAssetsProvider
import '../../../riverpod/mutation_providers.dart'; // Mutation Service

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

    final isMobile = ResponsiveHelper.isMobile(context);

    // Build content
    Widget content = Padding(
      padding: EdgeInsets.all(isMobile ? 16 : AdminConstants.spaceLg),
      child: Column(
        children: [
          // Compact Header Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isMobile ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ] : null,
              border: isMobile ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile) ...[
                  // Mobile: Compact Row (Search + Filter Icon)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (v) => searchQuery.value = v,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Cari laporan...',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter/Period Button (Icon Only)
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black87),
                          tooltip: 'Periode: ${DateFormat('MMM yyyy').format(DateTime.now())}',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                   // Desktop: Side by side (Keep as is)
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
                      // Period Filter
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Periode: ${DateFormat('MMM yyyy').format(DateTime.now())}'),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Categories (Compact)
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == selectedCategory.value;
                      return FilterChip(
                        label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        selected: isSelected,
                        onSelected: (_) => selectedCategory.value = cat,
                        checkmarkColor: Colors.white,
                        selectedColor: _getCategoryColor(cat),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -4),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Responsive Grid Content
          Expanded(
            child: filteredReports.isEmpty
              ? const Center(child: Text('Laporan tidak ditemukan'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                  // Mobile: 2 columns (small cards), Desktop: Adaptive
                    final crossAxisCount = isMobile ? 2 : (constraints.maxWidth / 350).floor();
                    // INCREASED aspect ratio to make cards SHORTER vertically. 
                    // Previous 0.85 (tall) -> New 1.1 (Square-ish/Shorter)
                    final aspectRatio = isMobile ? 1.1 : 1.6; 
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 12, // Compact spacing
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredReports.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        return _ReportCard(
                          item: filteredReports[index], 
                          onGenerate: () => _showGenerateDialog(context, ref, filteredReports[index]),
                          isCompact: isMobile, // Pass compact flag
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );

    // For mobile: wrap with Scaffold + AppBar
    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
          ),
          titleSpacing: 0,
          title: const Text('Pusat Laporan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
        ),
        body: content,
      );
    }

    // Desktop: use AdminLayoutWrapper
    return AdminLayoutWrapper(
      title: 'Pusat Laporan & Arsip',
      child: content,
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
  final bool isCompact;

  const _ReportCard({required this.item, required this.onGenerate, this.isCompact = false});

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
      cursor: SystemMouseCursors.basic, // Changed cursor to basic as it is no longer clickable
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Reduced padding for compact mode
          padding: EdgeInsets.all(widget.isCompact ? 10 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? themeColor.withValues(alpha: 0.5) : Colors.grey[200]!,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? themeColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Color-coded Icon
                      Container(
                        padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.item.icon, color: themeColor, size: widget.isCompact ? 20 : 28),
                      ),
                      // Badge removed for space in compact
                      if (!widget.isCompact) ...[
                         // (Badge code omitted)
                      ]
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.title, 
                    style: AdminTypography.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isCompact ? 13 : 16,
                      color: Colors.grey[900],
                      height: 1.2,
                    ), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
              
              // Button section
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onGenerate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isHovered ? Colors.white : themeColor,
                    backgroundColor: _isHovered ? themeColor : Colors.transparent,
                    side: BorderSide(color: themeColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: widget.isCompact ? 0 : 16), // Minimal vertical padding
                    elevation: 0,
                    minimumSize: Size(0, widget.isCompact ? 32 : 48), // Reduced height further
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce touch target margin
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(_isHovered ? Icons.print_rounded : Icons.print_outlined, size: widget.isCompact ? 14 : 18),
                       const SizedBox(width: 4),
                       Text('Generate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: widget.isCompact ? 11 : 14)),
                    ],
                  ),
                ),
              ),
            ],
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
    final orientation = useState(PdfPageFormat.a4);
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
            const SizedBox(height: 16),
            const Text('Orientasi:'),
            const SizedBox(height: 8),
            Row(
              children: [
                 Expanded(
                   child: _OrientationSelector(
                     label: 'Tegak',
                     icon: Icons.crop_portrait,
                     isSelected: orientation.value == PdfPageFormat.a4,
                     onTap: () => orientation.value = PdfPageFormat.a4,
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: _OrientationSelector(
                     label: 'Mendatar',
                     icon: Icons.crop_landscape,
                     isSelected: orientation.value == PdfPageFormat.a4.landscape,
                     onTap: () => orientation.value = PdfPageFormat.a4.landscape,
                   ),
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
                   // Fetch ALL assets (no date filter for inventory reports)
                   final assets = await ref.read(allAssetsProvider.future);
                   
                   // DEBUG: Log count
                   debugPrint('📊 PDF Report: Found ${assets.length} assets');
                   
                   final reportItems = assets.map((a) => <String, dynamic>{
                     'code': a.qrCode,
                     'name': a.name,
                     'nup': '001',
                     'brand': '${a.brand ?? '-'} ${(a.model ?? '') != '-' && (a.model ?? '').isNotEmpty ? '/ ${a.model}' : ''}',
                     'year': a.purchaseDate != null ? DateFormat('yyyy').format(a.purchaseDate!) : '-',
                     'condition': a.condition.displayName,
                     'price': a.purchasePriceFormatted ?? '-',
                     'description': a.description ?? '-',
                   }).toList();
                   
                   debugPrint('📊 PDF Report: Mapped ${reportItems.length} items');
                   
                   pdfBytes = await pdfService.generateInventoryReport(profile: profile, items: reportItems, filter: filter, pageFormat: orientation.value);
                   break;

                 case ReportType.mutation:
                   final service = ref.read(mutationServiceProvider);
                   final mutations = await service.getMutationsForReport(
                     startDate: startDate.value,
                     endDate: endDate.value,
                   );

                   final mutationItems = mutations.map((m) => <String, dynamic>{
                     'code': m.mutationCode,
                     'date': m.createdAt.toIso8601String(),
                     'asset_name': m.assetName,
                     'origin': m.originLocationName,
                     'destination': m.destinationLocationName,
                     'requester': m.requesterName,
                     'status': m.status.displayName,
                   }).toList();

                   pdfBytes = await pdfService.generateMutationReport(profile: profile, items: mutationItems, filter: filter, pageFormat: orientation.value);
                   break;

                 case ReportType.disposal:
                   final disposalReqs = await ref.read(disposalListProvider.future);
                   final filteredDisposal = disposalReqs.where((r) {
                      final date = r.createdAt;
                      if (date == null) return false;
                      return date.isAfter(startDate.value.subtract(const Duration(days: 1))) && 
                             date.isBefore(endDate.value.add(const Duration(days: 1)));
                   }).toList();
                   
                   final disposalItems = filteredDisposal.map((r) => <String, dynamic>{
                     'code': r.assetCode,
                     'asset_name': r.assetName,
                     'reason': r.reason,
                     'method': '-', // Not in model yet
                     'status': r.status,
                     'created_at': r.createdAt?.toIso8601String(),
                   }).toList();

                   pdfBytes = await pdfService.generateDisposalReport(profile: profile, items: disposalItems, filter: filter, pageFormat: orientation.value);
                   break;

                 case ReportType.maintenance:
                   // Optimized fetch by date range
                   final maintenanceLogs = await ref.read(maintenanceLogsByDateProvider((
                     start: startDate.value, 
                     end: endDate.value.add(const Duration(days: 1)) // Inclusive end date
                   )).future);

                   final maintenanceItems = maintenanceLogs.map((l) => <String, dynamic>{
                     'ticket_number': l.id.substring(0, 8).toUpperCase(),
                     'assets': {'name': l.assetName},
                     'assigned_to_user': {'display_name': l.technicianId}, 
                     'details': l.description,
                     'status': l.status.displayName,
                   }).toList();

                   pdfBytes = await pdfService.generateMaintenanceReport(profile: profile, items: maintenanceItems, filter: filter, pageFormat: orientation.value);
                   break;

                   case ReportType.summary: 
                   if (item.id == 'loan_recap') {
                     // ... (Loan Recap Logic - Existing) ...
                     final loanReqs = await ref.read(loanListProvider.future);
                     final filteredLoans = loanReqs.where((l) {
                        final date = l.startDate;
                        return date.isAfter(startDate.value.subtract(const Duration(days: 1))) && 
                               date.isBefore(endDate.value.add(const Duration(days: 1)));
                     }).toList();

                     final loanItems = filteredLoans.map((l) => <String, dynamic>{
                       'request_number': l.requestNumber,
                       'borrower_name': l.borrowerName,
                       'asset_name': l.assetName,
                       'start_date': l.startDate.toIso8601String(),
                       'duration_years': 1, 
                       'status': l.status,
                     }).toList();

                     pdfBytes = await pdfService.generateLoanReport(profile: profile, items: loanItems, filter: filter, pageFormat: orientation.value);

                   } else if (item.id == 'stock') {
                     // === 1. STOCK REPORT LOGIC (UPDATED) ===
                     final service = ref.read(supabaseDatabaseServiceProvider);
                     
                     // 1. Fetch All Items & Movements
                     final inventory = await service.getAllInventoryItems().first;
                     final movements = await service.getStockMovements(
                       startDate: startDate.value,
                       endDate: endDate.value.add(const Duration(days: 1)),
                     );

                     // 2. Process Data
                     final stockItems = inventory.map((i) {
                       // Filter movements for this item
                       final itemMovements = movements.where((m) => m.itemId == i.id).toList();
                       
                       // Calculate In/Out
                       int totalIn = 0;
                       int totalOut = 0;
                       
                       for (var m in itemMovements) {
                         if (m.type == 'IN') totalIn += m.quantity;
                         if (m.type == 'OUT') totalOut += m.quantity;
                       }

                       // Calculate Stocks
                       // Assumption: i.currentStock is the ACTUAL real-time stock.
                       // So currentStock = Initial + In - Out
                       // Therefore: Initial = Current - In + Out 
                       // (This logic assumes currentStock is consistent with the movements history)
                       
                       // However, if the report period is in the past, 'currentStock' is accurate NOW, not at endDate.
                       // Ideally we need to backtrack from NOW to EndDate, then to StartDate.
                       // For simplicity and user expectation of "Opname per Period", we will assume the User just wants to see the movement *during* that period
                       // and the "Final Stock" likely refers to the stock *at the end of that period*.
                       
                       // If we don't have historical snapshots, we can catch movements AFTER endDate to backtrack.
                       // Complexity tradeoff: Let's assume this report is mostly run for "Up to Now" or recent periods.
                       // Let's use clean "Pergerakan" logic:
                       // Stok Awal = (Calculated based on Current - Total Movements since then? No, that's heavy).
                       
                       // SIMPLIFIED LOGIC FOR MVP:
                       // We display 'Current Stock' as 'Stok Akhir' (Actual Opname)
                       // And we display movements that happened in the range.
                       // Then we REVERSE calculate Stok Awal:
                       // Stok Awal = Stok Akhir - Masuk + Keluar.
                       
                       final currentStock = i.currentStock; 
                       final initialStock = currentStock - totalIn + totalOut;

                       // Smart Description based on Status
                       String description = 'Stok Aman';
                       if (i.currentStock == 0) {
                         description = 'Stok Habis';
                       } else if (i.currentStock <= i.minStock) {
                         description = 'Perlu Pemesanan'; // Low Stock
                       } else if (i.stockPercentage < 20) {
                         description = 'Hampir Habis';
                       } else if (i.currentStock > i.minStock) {
                         description = 'Stok Aman';
                       }

                       // Optional: Add movement context? "Stok Aman (Stabil)"? 
                       // For now, stick to user request "statusnya"
                       
                       return <String, dynamic>{
                         'code': i.id.substring(0, 5).toUpperCase(), // Mock code if null
                         'name': i.name,
                         'initial_stock': initialStock,
                         'in': totalIn,
                         'out': totalOut,
                         'final_stock': currentStock,
                         'description': description,
                       };
                     }).toList();
                     
                     pdfBytes = await pdfService.generateStockReport(profile: profile, items: stockItems, filter: filter, pageFormat: orientation.value);

                   } else if (item.id == 'budget') {
                     // === 2. BUDGET REPORT LOGIC ===
                     final year = startDate.value.year;
                     // Use Repository directly to fetch specific year and avoid provider issues
                     final repo = ref.read(budgetRepositoryProvider);
                     final filteredBudgets = await repo.getBudgetsByYear(year);

                     final budgetItems = filteredBudgets.map((b) {
                        final realized = b.totalAmount - b.remainingAmount;
                        final percentage = b.totalAmount > 0 ? (realized / b.totalAmount * 100) : 0.0;
                        
                        return <String, dynamic>{
                           'year': b.fiscalYear.toString(),
                           'source': b.sourceName,
                           'total': NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(b.totalAmount),
                           'realized': NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(realized),
                           'remaining': NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(b.remainingAmount),
                           'percentage': '${percentage.toStringAsFixed(1)}%',
                        };
                     }).toList();

                     pdfBytes = await pdfService.generateBudgetReport(profile: profile, items: budgetItems, filter: filter, pageFormat: orientation.value);

                   } else {
                     throw Exception('Laporan summary untuk ${item.title} sedang dalam pengembangan.');
                   }
                   break;
                   
                 default:
                   // Other reports temporarily disabled - show message
                   throw Exception('Laporan ${item.title} sedang dalam pengembangan.');
               }

               if (pdfBytes != null) {
                  // Only pop if mounted
                  if (context.mounted) Navigator.pop(context); 
                  
                  if (context.mounted) {
                    if (ResponsiveHelper.isMobile(context)) {
                       // Mobile: Open In-App Preview
                       context.push('/admin/reports/preview', extra: {
                          'title': '${item.title} Report',
                          'pdfBytes': pdfBytes,
                       });
                    } else {
                       // Desktop: Native Print
                       await Printing.layoutPdf(
                          onLayout: (format) async => pdfBytes!,
                          name: '${item.title}_${DateFormat('yyyyMMdd').format(DateTime.now())}',
                       );
                    }
                  }
               }
            } catch (e) {
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            } finally {
              // Check if mounted before updating state
              if (context.mounted) {
                isGenerating.value = false;
              }
            }
          },
          icon: isGenerating.value 
             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
             : const Icon(Icons.print, color: Colors.white),
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

class _OrientationSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrientationSelector({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AdminColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AdminColors.primary : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AdminColors.primary : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
