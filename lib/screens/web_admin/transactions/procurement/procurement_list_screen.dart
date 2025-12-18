import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../widgets/web_admin/actions/generic_export_button.dart';

class ProcurementListScreen extends HookConsumerWidget {
  const ProcurementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch Data
    final requestsAsync = ref.watch(procurementListProvider);
    
    // 2. Local State
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: requestsAsync.when(
        data: (allRequests) {
          // --- KPI Calculation ---
          final pendingCount = allRequests.where((r) => r.status.contains('pending')).length;
          final approvedCount = allRequests.where((r) => r.status.contains('approved')).length;
          final completedCount = allRequests.where((r) => r.status == 'completed').length;
          final totalSpend = allRequests.fold(0.0, (sum, r) => sum + r.totalEstimatedBudget);
          
          // Filtered List for Table
          final filtered = allRequests.where((r) {
             final q = searchQuery.value.toLowerCase();
             return r.code.toLowerCase().contains(q) || 
                    (r.description ?? '').toLowerCase().contains(q);
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Header & Toolbar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                bottom: PreferredSize(
                   preferredSize: const Size.fromHeight(1.0),
                   child: Container(color: Colors.grey[200], height: 1),
                ),
                title: Text('Procurement Command Center', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
                actions: [
                   GenericExportButton(
                    title: 'Laporan Pengadaan',
                    headers: const ['Kode Request', 'Tanggal', 'Pengaju', 'Deskripsi', 'Total Estimasi', 'Status'],
                    data: filtered,
                    rowBuilder: (item) => [
                      item.code,
                      DateFormat('yyyy-MM-dd').format(item.requestDate),
                      item.requesterName ?? '-',
                      item.description ?? '-',
                      currencyFormat.format(item.totalEstimatedBudget),
                      item.status,
                    ],
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => context.go('/admin/procurement/new'),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Buat Pengajuan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // 2. Dashboard KPIs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Row(
                    children: [
                      Expanded(child: _buildKpiCard('Menunggu Persetujuan', pendingCount.toString(), 'Request', Colors.orange, Icons.hourglass_top)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Purchase Orders (Aktif)', approvedCount.toString(), 'Active PO', Colors.blue, Icons.shopping_bag_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Total Belanja (YTD)', currencyFormat.format(totalSpend), 'Budget Used', Colors.purple, Icons.monetization_on_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Selesai / Diterima', completedCount.toString(), 'Items Received', Colors.green, Icons.check_circle_outline)),
                    ],
                  ),
                ),
              ),

              // 3. Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 8),
                  child: Row(
                    children: [
                       Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Cari Kode Request atau Barang...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (val) => searchQuery.value = val,
                        ),
                      ),
                       const SizedBox(width: 12),
                       IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list), tooltip: 'Advanced Filters'),
                    ],
                  ),
                ),
              ),

              // 4. Smart List Content
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      return _buildSmartRow(context, item, currencyFormat);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(icon, color: color.withOpacity(0.8), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
           const SizedBox(height: 4),
           Row(
             children: [
               Icon(Icons.trending_up, size: 14, color: Colors.green[600]), // Mock trend
               const SizedBox(width: 4),
               Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildSmartRow(BuildContext context, ProcurementRequest item, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/admin/procurement/detail/${item.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 1. ID & basic info
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          item.code,
                          style: GoogleFonts.sourceCodePro(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(DateFormat('dd MMM').format(item.requestDate), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                
                // 2. Main Content & Stepper
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description ?? 'Pengadaan Barang', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildStatusStepper(item.status),
                    ],
                  ),
                ),
                
                // 3. Amount & Actions
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.format(item.totalEstimatedBudget), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           if (item.status == 'pending') ...[
                             OutlinedButton(
                               onPressed: () {}, // Mock Quick Action
                               style: OutlinedButton.styleFrom(
                                 visualDensity: VisualDensity.compact,
                                 side: BorderSide(color: Colors.green.shade200),
                                 padding: const EdgeInsets.symmetric(horizontal: 12),
                               ),
                               child: Text('Approve', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                             ),
                           ],
                           if (item.status == 'approved_head' || item.status == 'approved_admin')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text('PO Ready', style: TextStyle(color: Colors.purple.shade700, fontSize: 11)),
                              ),
                         ],
                       ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStepper(String currentStatus) {
    // Pipeline: pending -> approved -> completed
    // (Simplification for UI)
    int currentStep = 0;
    if (currentStatus.contains('pending')) currentStep = 1;
    else if (currentStatus.contains('approved')) currentStep = 2; // PO Issued
    else if (currentStatus == 'completed') currentStep = 3;
    else if (currentStatus == 'rejected') currentStep = -1;

    if (currentStep == -1) {
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
         decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
         child: Text('❌ Ditolak / Rejected', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
       );
    }

    return Row(
      children: [
        _buildStepDot('Draft', 1, currentStep >= 0),
        _buildConnector(currentStep >= 1),
        _buildStepDot('Review', 2, currentStep >= 1),
        _buildConnector(currentStep >= 2),
        _buildStepDot('PO Issued', 3, currentStep >= 2),
         _buildConnector(currentStep >= 3),
        _buildStepDot('Received', 4, currentStep >= 3),
      ],
    );
  }

  Widget _buildStepDot(String label, int index, bool isActive) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primary : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          fontSize: 11, 
          color: isActive ? Colors.black87 : Colors.grey.shade400,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
       margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? AppTheme.primary : Colors.grey.shade200,
    );
  }
}
