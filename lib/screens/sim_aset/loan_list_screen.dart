import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/loan_model.dart';
import '../../providers/transactions/loan_provider.dart';

class LoanListScreen extends HookConsumerWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanListProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final activeTab = useState(0); // 0: Semua, 1: Permohonan, 2: Berjalan, 3: Selesai

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Peminjaman (Pinjam Pakai)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
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
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_list_rounded),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'all', child: Text('Semua Status')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        _buildTabItem('Semua', 0, activeTab),
                        _buildTabItem('Permohonan', 1, activeTab),
                        _buildTabItem('Sedang Berjalan', 2, activeTab),
                        _buildTabItem('Selesai / Ditolak', 3, activeTab),
                      ],
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
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
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
            Row(
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
                          Text(item.borrowerAddress, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
                      Text(item.assetId, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
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
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
