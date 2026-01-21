import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/loan_model.dart';
import '../../riverpod/transactions/loan_provider.dart';

class LoanListScreen extends HookConsumerWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanListProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final activeTab = useState(0); // 0: Semua, 1: Permohonan, 2: Berjalan, 3: Selesai

    // Responsive Check
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: isMobile ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () => context.push('/admin/loans/new'),
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
                   Text('Buat Permohonan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
        title: Text('Peminjaman (Pinjam Pakai)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (!isMobile)
            FilledButton.icon(
              onPressed: () {
                 // Navigate to Form
                 context.push('/admin/loans/new');
              }, 
              icon: const Icon(Icons.add), 
              label: const Text('Buat Permohonan'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: loanAsync.when(
        data: (loans) {
          // Filtering Logic
          final filtered = loans.where((l) {
            final q = searchQuery.value.toLowerCase();
            final matchSearch = l.borrowerName.toLowerCase().contains(q) || 
                                l.assetName.toLowerCase().contains(q) ||
                                l.requestNumber.toLowerCase().contains(q);
            
            bool matchTab = true;
            if (activeTab.value == 1) { // Permohonan (Draft, Submitted, Verified, Approved)
              matchTab = ['draft', 'submitted', 'verified', 'approved'].contains(l.status);
            } else if (activeTab.value == 2) { // Berjalan (Active)
              matchTab = l.status == 'active';
            } else if (activeTab.value == 3) { // Selesai (Returned / Rejected)
              matchTab = ['returned', 'rejected'].contains(l.status);
            }
            
            return matchSearch && matchTab;
          }).toList();

          return Column(
            children: [
              // Search & Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Column(
                  children: [
// Search & Filter
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                            // Helper for labels
                            String getFilterLabel(int index) {
                              switch (index) {
                                case 1: return 'Permohonan';
                                case 2: return 'Sedang Berjalan';
                                case 3: return 'Selesai / Ditolak';
                                default: return 'Semua Status';
                              }
                            }

                            if (constraints.maxWidth < 600) {
                                return TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Cari No. Surat, Peminjam, atau Aset...',
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    suffixIcon: PopupMenuButton<int>(
                                      icon: Icon(Icons.filter_list_rounded, color: activeTab.value != 0 ? AppTheme.primary : null),
                                      tooltip: 'Filter Status',
                                      onSelected: (val) => activeTab.value = val,
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 0, child: Text('Semua Status')),
                                        const PopupMenuItem(value: 1, child: Text('Permohonan')),
                                        const PopupMenuItem(value: 2, child: Text('Sedang Berjalan')),
                                        const PopupMenuItem(value: 3, child: Text('Selesai / Ditolak')),
                                      ],
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                  ),
                                  onChanged: (val) => searchQuery.value = val,
                                );
                            }
                          
                          // Desktop View
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Cari No. Surat, Peminjam, atau Aset...',
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                  ),
                                  onChanged: (val) => searchQuery.value = val,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Enhanced Filter Button
                              PopupMenuButton<int>(
                                initialValue: activeTab.value,
                                tooltip: 'Filter Status',
                                onSelected: (val) => activeTab.value = val,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 0, child: Text('Semua Status')),
                                  const PopupMenuItem(value: 1, child: Text('Permohonan')),
                                  const PopupMenuItem(value: 2, child: Text('Sedang Berjalan')),
                                  const PopupMenuItem(value: 3, child: Text('Selesai / Ditolak')),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.filter_list_rounded, 
                                        size: 20, 
                                        color: activeTab.value != 0 ? AppTheme.primary : Colors.grey[600]
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        getFilterLabel(activeTab.value),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: activeTab.value != 0 ? AppTheme.primary : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
              
              // List Content
              Expanded(
                child: filtered.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Tidak ada data peminjaman', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildLoanCard(context, filtered[index]);
                      },
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

  Widget _buildTabItem(String label, int index, ValueNotifier<int> activeTab) {
    final isActive = activeTab.value == index;
    return InkWell(
      onTap: () => activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? AppTheme.primary : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanRequest item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(item.requestNumber, style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                _buildStatusChip(item.status),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 450) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.borrowerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.business, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(item.borrowerAddress, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.assetName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(item.assetId, style: TextStyle(color: Colors.grey[500], fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.borrowerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.business, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(child: Text(item.borrowerAddress, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(item.assetName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 120, 
                            child: Text(item.assetId, style: TextStyle(color: Colors.grey[500], fontSize: 12), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }
            ),
            const Divider(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(item.startDate)} - ${DateFormat('dd MMM yyyy').format(item.endDate)}',
                              style: TextStyle(color: Colors.grey[800], fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text('${item.durationYears} Thn', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push('/admin/loans/detail/${item.id}');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Lihat Detail'),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${DateFormat('dd MMM yyyy').format(item.startDate)} - ${DateFormat('dd MMM yyyy').format(item.endDate)}',
                          style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                          child: Text('${item.durationYears} Tahun', style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/admin/loans/detail/${item.id}');
                      },
                      child: const Text('Lihat Detail'),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'draft':
        bg = Colors.grey.shade100; fg = Colors.grey.shade700; label = 'Draft'; break;
      case 'submitted':
        bg = Colors.blue.shade50; fg = Colors.blue.shade700; label = 'Diajukan'; break;
      case 'verified':
        bg = Colors.orange.shade50; fg = Colors.orange.shade800; label = 'Diverifikasi'; break;
      case 'approved':
        bg = Colors.purple.shade50; fg = Colors.purple.shade700; label = 'Disetujui'; break;
      case 'active':
        bg = Colors.green.shade50; fg = Colors.green.shade700; label = 'Sedang Dipinjam'; break;
      case 'returned':
        bg = Colors.teal.shade50; fg = Colors.teal.shade700; label = 'Dikembalikan'; break;
      case 'rejected':
        bg = Colors.red.shade50; fg = Colors.red.shade700; label = 'Ditolak'; break;
      default:
        bg = Colors.grey.shade100; fg = Colors.black; label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
