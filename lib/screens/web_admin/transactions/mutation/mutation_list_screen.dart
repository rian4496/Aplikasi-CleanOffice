// lib/screens/web_admin/transactions/mutation/mutation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/asset_mutation.dart';
import '../../../../riverpod/mutation_providers.dart';
import '../../../../widgets/shared/responsive_stats_grid.dart';

class MutationListScreen extends HookConsumerWidget {
  const MutationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch Data
    // We watch the provider with 'null' initially to get all, then filter locally for UI responsiveness 
    // or we could rely on the provider filter. Let's filter locally for smoother UX like Procurement
    final mutationListAsync = ref.watch(mutationListProvider(null));

    // 2. Local State
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final filterStatus = useState('All'); // 'All', 'Pending', 'Approved', 'Rejected'
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: isMobile ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () => context.go('/admin/transactions/mutation/create'),
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
                  const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text('Buat Mutasi', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
         ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: mutationListAsync.when(
        data: (allMutations) {
          // --- KPI Calculation ---
          final pendingCount = allMutations.where((m) => m.status == MutationStatus.pending).length;
          final approvedCount = allMutations.where((m) => m.status == MutationStatus.approved).length;
          final rejectedCount = allMutations.where((m) => m.status == MutationStatus.rejected).length;
          final totalCount = allMutations.length;

          // --- Filtering ---
          final filtered = allMutations.where((m) {
            final q = searchQuery.value.toLowerCase();
            final matchSearch = m.mutationCode.toLowerCase().contains(q) || 
                                (m.assetName ?? '').toLowerCase().contains(q) ||
                                (m.requesterName ?? '').toLowerCase().contains(q);
            
            bool matchFilter = true;
            if (filterStatus.value == 'Pending') matchFilter = m.status == MutationStatus.pending;
            if (filterStatus.value == 'Approved') matchFilter = m.status == MutationStatus.approved;
            if (filterStatus.value == 'Rejected') matchFilter = m.status == MutationStatus.rejected;

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
                       'Mutasi Aset', 
                       style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)
                     );
                   }
                ),
                actions: [
                   if (!isMobile) ...[
                     FilledButton.icon(
                      onPressed: () => context.go('/admin/transactions/mutation/create'),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Buat Mutasi'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 16),
                   ]
                ],
              ),

              // 2. Dashboard KPIs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Stats List
                      final statsChildren = [
                        _buildKpiCard('Total Mutasi', totalCount.toString(), 'All requests', Colors.blue, Icons.list_alt),
                        _buildKpiCard('Menunggu', pendingCount.toString(), 'Need approval', Colors.orange, Icons.hourglass_top),
                        _buildKpiCard('Disetujui', approvedCount.toString(), 'Completed', Colors.green, Icons.check_circle_outline),
                        _buildKpiCard('Ditolak', rejectedCount.toString(), 'Rejected', Colors.red, Icons.cancel_outlined),
                      ];

                      if (isMobile) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                             children: statsChildren.map((w) => Padding(padding: const EdgeInsets.only(right: 12), child: SizedBox(width: 160, child: w))).toList(),
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
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            hintText: 'Cari Kode, Aset, atau Pengaju...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (val) => searchQuery.value = val,
                        ),
                      ),
                       const SizedBox(width: 12),
                       _buildFilterDropdown(filterStatus),
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
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('Tidak ada data mutasi ditemukan', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          return _buildMutationCard(context, item);
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

  Widget _buildFilterDropdown(ValueNotifier<String> filterStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Filter Status',
        icon: Icon(
          Icons.sort, 
          color: filterStatus.value == 'All' ? Colors.grey : AppTheme.primary
        ),
        onSelected: (val) => filterStatus.value = val,
        itemBuilder: (context) => ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
          final isSelected = filterStatus.value == status;
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status == 'All' ? 'Semua Status' : status,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primary : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, size: 16, color: AppTheme.primary),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMutationCard(BuildContext context, AssetMutation item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/admin/transactions/mutation/${item.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.swap_horiz_rounded, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.mutationCode,
                            style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.assetName ?? 'Unknown Asset',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.originLocationName ?? '-'}  ➜  ${item.destinationLocationName ?? '-'}',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Request by: ${item.requesterName ?? '-'}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(item.createdAt),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 12),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MutationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
