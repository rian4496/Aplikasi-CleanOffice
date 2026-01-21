import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/budget.dart';
import 'package:aplikasi_cleanoffice/models/agency_profile.dart';
import 'package:aplikasi_cleanoffice/models/report_filter.dart';
import 'package:aplikasi_cleanoffice/models/export_config.dart' hide ReportType;
import 'package:aplikasi_cleanoffice/riverpod/master_crud_controllers.dart';
import 'package:aplikasi_cleanoffice/riverpod/agency_providers.dart';
import 'package:aplikasi_cleanoffice/services/pdf_report_service.dart';
import 'package:aplikasi_cleanoffice/services/export_service.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_detail_drawer.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_list_card.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_stats_widget.dart';
import 'package:aplikasi_cleanoffice/riverpod/budget_view_providers.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/master/budget_form_dialog.dart';


class MasterAnggaranScreen extends HookConsumerWidget {
  const MasterAnggaranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data
    final budgets = ref.watch(filteredBudgetsProvider);
    final selectedYear = ref.watch(budgetFilterYearProvider);
    final searchQuery = useState('');
    final selectedBudget = useState<Budget?>(null);

    // Form
    Future<void> _showForm([Budget? budget]) async {
       await showDialog(
        context: context,
        builder: (context) => BudgetFormDialog(initialData: budget),
      );
    }

    // Delete
     Future<void> _delete(String id) async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Anggaran?'),
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
        if (selectedBudget.value?.id == id) selectedBudget.value = null; // Deselect if deleting
        await ref.read(budgetControllerProvider.notifier).delete(id);
        ref.invalidate(budgetsProvider);
      }
    }

    // Filter Logic
    final filteredList = budgets.where((b) {
      return b.sourceName.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    // Sort by Remaining Amount (Ascending - Warning first)
    filteredList.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));

    final isMobile = MediaQuery.of(context).size.width < 900; // Consistent with layout builder check

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: (isMobile && selectedBudget.value == null) ? Container(
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
                   const Icon(Icons.add, color: Colors.white, size: 20),
                   const SizedBox(width: 8),
                   Text('Tambah Anggaran', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
          child: Text('Anggaran (DPA/APBD)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
            // Year Filter Dropdown
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear,
                  items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(budgetFilterYearProvider.notifier).setYear(val);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Export Button
            if (!isMobile)
              PopupMenuButton<String>(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Export Data',
                onSelected: (value) async {
                  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                  if (value == 'pdf') {
                    // PDF Export
                    final agencyAsync = ref.read(agencyProfileProvider);
                    final profile = agencyAsync.value ?? AgencyProfile.empty();
                    final filter = ReportFilter(
                      type: ReportType.inventory,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                    );
                    
                    // Convert Budget list to Map format
                    final items = filteredList.map((b) => {
                      'year': b.fiscalYear.toString(),
                      'source': b.sourceName,
                      'total': currencyFormat.format(b.totalAmount),
                      'realized': currencyFormat.format(b.totalAmount - b.remainingAmount),
                      'remaining': currencyFormat.format(b.remainingAmount),
                      'percentage': '${((b.totalAmount - b.remainingAmount) / b.totalAmount * 100).toStringAsFixed(1)}%',
                    }).toList();
                    
                    // Generate and print PDF directly
                    final pdfBytes = await PdfReportService().generateBudgetReport(
                      profile: profile,
                      items: items,
                      filter: filter,
                    );
                    
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                      name: 'Daftar_Anggaran_BRIDA.pdf',
                    );
                  } else if (value == 'excel') {
                    // Excel Export
                    final excelData = filteredList.map((b) => [
                      b.fiscalYear.toString(),
                      b.sourceName,
                      currencyFormat.format(b.totalAmount),
                      currencyFormat.format(b.totalAmount - b.remainingAmount),
                      currencyFormat.format(b.remainingAmount),
                      '${((b.totalAmount - b.remainingAmount) / b.totalAmount * 100).toStringAsFixed(1)}%',
                    ]).toList();
                    
                    await ExportService().exportGenericData(
                      title: 'Data Anggaran',
                      headers: ['Tahun', 'Sumber Dana', 'Pagu', 'Realisasi', 'Sisa', '%'],
                      data: excelData,
                      format: ExportFormat.excel,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 18, color: Colors.red), SizedBox(width: 8), Text('Export PDF')])),
                  const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_chart, size: 18, color: Colors.green), SizedBox(width: 8), Text('Export Excel')])),
                ],
              ),
            const SizedBox(width: 8),
            if (!isMobile)
              FilledButton.icon(
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Anggaran'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return Stack(
              fit: StackFit.expand, // Force stack to fill screen so overlay is full height
              children: [
                // List View
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const BudgetStatsWidget(),
                       const SizedBox(height: 24),
                       TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Cari Sumber Anggaran...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) => searchQuery.value = val,
                      ),
                      const SizedBox(height: 20),
                      if (filteredList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              budgets.isEmpty 
                                  ? 'Belum ada data anggaran tahun $selectedYear' 
                                  : 'Tidak ditemukan anggaran.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      else
                        ...filteredList.map((budget) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BudgetListCard(
                            budget: budget,
                            isSelected: selectedBudget.value?.id == budget.id,
                            onTap: () => selectedBudget.value = budget,
                            onEdit: _showForm,
                            onDelete: (b) => _delete(b.id),
                          ),
                        )),
                    ],
                  ),
                ),

                // Mobile Drawer (Full Screen Overlay)
                if (selectedBudget.value != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white,
                      child: SafeArea( // Ensure content doesn't overlap status bar
                        child: BudgetDetailDrawer(
                          budget: selectedBudget.value!,
                          onClose: () => selectedBudget.value = null,
                          onEdit: _showForm,
                          onDelete: (b) => _delete(b.id),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          // Desktop Layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BudgetStatsWidget(),
                      const SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Cari Sumber Anggaran...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) => searchQuery.value = val,
                      ),
                      const SizedBox(height: 20),
                      if (filteredList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              budgets.isEmpty 
                                  ? 'Belum ada data anggaran tahun $selectedYear' 
                                  : 'Tidak ditemukan anggaran.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      else
                        ...filteredList.map((budget) => BudgetListCard(
                          budget: budget,
                          isSelected: selectedBudget.value?.id == budget.id,
                          onTap: () {
                             if (selectedBudget.value?.id == budget.id) {
                               selectedBudget.value = null;
                             } else {
                               selectedBudget.value = budget;
                             }
                          },
                          onEdit: _showForm,
                          onDelete: (b) => _delete(b.id),
                        )),
                    ],
                  ),
                ),
              ),

              // Detail Drawer
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: Container(
                  width: selectedBudget.value != null ? 400 : 0,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: selectedBudget.value != null 
                    ? BudgetDetailDrawer(
                        budget: selectedBudget.value!,
                        onClose: () => selectedBudget.value = null,
                        onEdit: _showForm,
                        onDelete: (b) => _delete(b.id),
                      )
                    : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
