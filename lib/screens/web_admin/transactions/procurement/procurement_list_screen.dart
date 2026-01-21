import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../widgets/web_admin/actions/generic_export_button.dart';
import '../../../../../widgets/shared/responsive_stats_grid.dart'; // Responsive Grid

class ProcurementListScreen extends HookConsumerWidget {
  const ProcurementListScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch Data
    final requestsAsync = ref.watch(procurementListProvider);
    
    // 2. Local State
// 2. Local State
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final filterStatus = useState('all'); // Filter State
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isMobile = MediaQuery.of(context).size.width < 600; // Define Check

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: isMobile ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () => context.go('/admin/procurement/new'),
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
                  const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Buat Pengajuan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
         ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
             final matchSearch = r.code.toLowerCase().contains(q) || 
                    (r.description ?? '').toLowerCase().contains(q);
             
             bool matchFilter = true;
             final s = r.status.toLowerCase();
             if (filterStatus.value == 'pending') {
               matchFilter = s.contains('pending') || s.contains('review') || s.contains('draft');
             } else if (filterStatus.value == 'active') {
               matchFilter = s.contains('approved') || s.contains('issued');
             } else if (filterStatus.value == 'completed') {
               matchFilter = s.contains('completed') || s.contains('received');
             } else if (filterStatus.value == 'rejected') {
               matchFilter = s.contains('rejected');
             }
             
             return matchSearch && matchFilter;
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Header & Toolbar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                // Back button for mobile
                leading: isMobile ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
                ) : null,
                automaticallyImplyLeading: false,
                bottom: PreferredSize(
                   preferredSize: const Size.fromHeight(1.0),
                   child: Container(color: Colors.grey[200], height: 1),
                ),
                title: LayoutBuilder(
                   builder: (context, constraints) {
                     return Text(
                       constraints.maxWidth < 600 ? 'Procurement' : 'Procurement Command Center', 
                       style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)
                     );
                   }
                ),
                actions: [
                   // Web/Tablet Actions
                   if (!isMobile) ...[
                     IconButton(
                       icon: const Icon(Icons.folder_special_outlined, color: Colors.grey),
                       tooltip: 'Arsip Pengadaan',
                       onPressed: () => context.go('/admin/procurement/archive'),
                     ),
                     const SizedBox(width: 8),
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
                   ] else ...[
                     // Mobile Actions (Compact - Archive only, Create moved to FAB)
                     IconButton(
                       icon: const Icon(Icons.folder_special_outlined, color: Colors.grey),
                       onPressed: () => context.go('/admin/procurement/archive'),
                     ),
                     const SizedBox(width: 8),
                   ]
                ],
              ),

              // 2. Dashboard KPIs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 800;
                      // Stats List
                      final statsChildren = [
                        _buildKpiCard('Menunggu Persetujuan', pendingCount.toString(), 'Request', Colors.orange, Icons.hourglass_top, isMobile),
                        _buildKpiCard('Active PO', approvedCount.toString(), 'Active PO', Colors.blue, Icons.shopping_bag_outlined, isMobile),
                        _buildKpiCard('Total Belanja', currencyFormat.format(totalSpend), 'Budget Used', Colors.purple, Icons.monetization_on_outlined, isMobile),
                        _buildKpiCard('Selesai', completedCount.toString(), 'Items Received', Colors.green, Icons.check_circle_outline, isMobile),
                      ];

                      if (isMobile) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: statsChildren.map((w) => Padding(padding: const EdgeInsets.only(right: 12), child: SizedBox(width: 180, child: w))).toList(),
                          ),
                        );
                      }
                      
                      return ResponsiveStatsGrid(children: statsChildren);
                    }
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
                            hintText: 'Cari Request...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (val) => searchQuery.value = val,
                        ),
                      ),
                       const SizedBox(width: 12),
                       PopupMenuButton<String>(
                         icon: Icon(Icons.filter_list, color: filterStatus.value != 'all' ? AppTheme.primary : null),
                         tooltip: 'Filter Status',
                         onSelected: (val) => filterStatus.value = val,
                         itemBuilder: (context) => [
                            const PopupMenuItem(value: 'all', child: Text('Semua Status')),
                            const PopupMenuItem(value: 'pending', child: Text('Draft / Menunggu')),
                            const PopupMenuItem(value: 'active', child: Text('Active PO / Approved')),
                            const PopupMenuItem(value: 'completed', child: Text('Selesai / Diterima')),
                            const PopupMenuItem(value: 'rejected', child: Text('Ditolak')),
                         ],
                       ),
                    ],
                  ),
                ),
              ),

              // 4. Smart List Content
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                sliver: filtered.isEmpty 
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48), 
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('Tidak ada data ditemukan', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
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

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppTheme.primary.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isActive ? AppTheme.primary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, Color color, IconData icon, [bool isMobile = false]) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
              Icon(icon, color: color.withValues(alpha: 0.8), size: isMobile ? 16 : 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/admin/procurement/detail/${item.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row (Code & Date)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        item.code,
                        style: GoogleFonts.sourceCodePro(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(item.requestDate),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 2. Main Content Row (Title & Budget)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.description ?? 'Pengadaan Barang', 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      fmt.format(item.totalEstimatedBudget), 
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 3. Status Stepper
                _buildStatusStepper(item.status),
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
