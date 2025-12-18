import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:aplikasi_cleanoffice/models/master/budget.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/master_providers.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/actions/generic_export_button.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_detail_drawer.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_list_card.dart';
import 'package:aplikasi_cleanoffice/widgets/web_admin/budget/budget_stats_widget.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/budget_view_providers.dart';
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
      }
    }

    // Filter Logic
    final filteredList = budgets.where((b) {
      return b.sourceName.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    // Sort by Remaining Amount (Ascending - Warning first)
    filteredList.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Anggaran (DPA/APBD)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Stats
                  const BudgetStatsWidget(),
                  const SizedBox(height: 24),

                  // Search & Filter Bar
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari Sumber Anggaran...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) => searchQuery.value = val,
                  ),
                  const SizedBox(height: 20),

                  // List
                  if (filteredList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          budgets.isEmpty 
                              ? 'Belum ada data anggaran tahun $selectedYear' 
                              : 'Tidak ditemukan anggaran dengan kata kunci tersebut.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ...filteredList.map((budget) => BudgetListCard(
                      budget: budget,
                      isSelected: selectedBudget.value?.id == budget.id,
                      onTap: () {
                         // Toggle logic
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
      ),
    );
  }
}
