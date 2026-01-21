import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';

class ProcurementArchiveScreen extends HookConsumerWidget {
  const ProcurementArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch Archived Data
    final archivedAsync = ref.watch(procurementArchiveListProvider);
    
    // State
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedYear = useState<int>(DateTime.now().year);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Arsip Pengadaan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.blueGrey[900])),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.blueGrey[900]),
        actions: const [], // Refresh moved to toolbar
      ),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allArchived) {
          // Filter Logic
          final filtered = allArchived.where((r) {
            // 1. Year Filter (Mandatory)
            if (r.requestDate.year != selectedYear.value) return false;
            
            // 2. Search Text
            final q = searchQuery.value.toLowerCase();
            return r.code.toLowerCase().contains(q) || 
                   (r.description ?? '').toLowerCase().contains(q);
          }).toList();

          // Calculate Summary
          final totalValue = filtered.fold<double>(0, (sum, item) => sum + item.totalEstimatedBudget);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Stats & Filters Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row (Non-expanded, left aligned)
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                         _buildStatCard('Total Arsip', '${filtered.length} Dokumen', Icons.folder_open, Colors.blue),
                         _buildStatCard('Total Nilai', currencyFormat.format(totalValue), Icons.monetization_on, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Filter Row
                    Row(
                      children: [
                         // Search (Expanded, First)
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: GoogleFonts.outfit(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Cari berdasarkan kode atau deskripsi...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                            ),
                            onChanged: (val) => searchQuery.value = val,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year Dropdown (Right)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedYear.value,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                              items: [2023, 2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("Tahun $y"))).toList(),
                              onChanged: (val) => selectedYear.value = val!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Refresh Button (Rightest)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh, color: AppTheme.primary),
                            onPressed: () => ref.refresh(procurementArchiveListProvider),
                            tooltip: 'Refresh Data',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 2. List Content
              Expanded(
                child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                            child: Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                          ),
                          const SizedBox(height: 16),
                          Text('Tidak ada arsip ditemukan', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          Text('Pilih tahun lain atau ubah pencarian', style: GoogleFonts.outfit(color: Colors.grey[400])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: filtered.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildArchiveCard(context, item, currencyFormat);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    // Removed Expanded: content sized.
    return Container(
      width: 200, // Fixed reasonable width or remove for content-sized
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Outline style
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300), // Grey border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveCard(BuildContext context, ProcurementRequest item, NumberFormat fmt) {
    Color statusColor = Colors.grey;
    if (item.status == 'completed') statusColor = Colors.green;
    else if (item.status == 'rejected') statusColor = Colors.red;

    return InkWell(
      onTap: () => context.go('/admin/procurement/detail/${item.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status Strip
              Container(width: 6, color: statusColor),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                       // Code & Date
                       Expanded(
                         flex: 4,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 Text(item.code, style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                 const SizedBox(width: 8),
                                 Container(width: 1, height: 12, color: Colors.grey[300]),
                                 const SizedBox(width: 8),
                                 Text(DateFormat('dd MMMM yyyy', 'id_ID').format(item.requestDate), style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
                               ],
                             ),
                             const SizedBox(height: 6),
                             Text(item.description ?? 'Tidak ada deskripsi', 
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                             ),
                             const SizedBox(height: 4),
                             Text(item.requesterName ?? 'Unknown Requester', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500])),
                           ],
                         ),
                       ),

                       // Value
                       Expanded(
                         flex: 2,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text('Total Estimasi', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500])),
                             Text(fmt.format(item.totalEstimatedBudget), style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                           ],
                         ),
                       ),

                       // Status Badge
                       const SizedBox(width: 16),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: statusColor.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(
                               item.status == 'completed' ? Icons.check_circle : Icons.cancel, 
                               size: 14, color: statusColor
                             ),
                             const SizedBox(width: 6),
                             Text(
                               item.status == 'completed' ? 'Selesai' : 'Ditolak', 
                               style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(width: 8),
                       const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
