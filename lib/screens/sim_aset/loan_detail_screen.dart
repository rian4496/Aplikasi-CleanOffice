import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/loan_model.dart';
import '../../providers/transactions/loan_provider.dart';

class LoanDetailScreen extends HookConsumerWidget {
  final String id;
  const LoanDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Detail Peminjaman', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.blue),
            onPressed: () {
              // TODO: Print BAST
            },
            tooltip: 'Cetak Dokumen',
          ),
        ],
      ),
      body: loanAsync.when(
        data: (loans) {
          final loan = loans.firstWhere((l) => l.id == id, orElse: () => throw Exception('Not found'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Status
                _buildHeader(loan),
                const SizedBox(height: 24),
                
                // Content Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Borrower & Asset Info
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildInfoCard('Informasi Peminjam', [
                            _buildInfoRow('Nama Instansi', loan.borrowerName),
                            _buildInfoRow('Alamat', loan.borrowerAddress),
                            _buildInfoRow('Kontak', loan.borrowerContact),
                            _buildInfoRow('Nomor Surat', loan.requestNumber),
                          ]),
                          const SizedBox(height: 20),
                          _buildInfoCard('Detail Aset', [
                            _buildInfoRow('Nama Aset', loan.assetName),
                            _buildInfoRow('Kode Aset', loan.assetId), // Ideally fetch code
                            _buildInfoRow('Kondisi', loan.assetCondition),
                          ]),
                          const SizedBox(height: 20),
                          _buildInfoCard('Dokumen Pendukung', [
                            _buildDocRow('Surat Permohonan', loan.applicationLetterDoc),
                            _buildDocRow('Draft Perjanjian', loan.agreementDoc),
                            _buildDocRow('BAST Penyerahan', loan.bastHandoverDoc),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Right Column: Timeline & Dates
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildTimelineCard(loan),
                          const SizedBox(height: 20),
                          _buildActionCard(context, ref, loan),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(LoanRequest loan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loan.requestNumber, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(loan.borrowerName, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        _buildStatusBadge(loan.status),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }
  
  Widget _buildDocRow(String label, String? url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          if (url != null)
            TextButton(onPressed: () {}, child: const Text('Lihat', style: TextStyle(fontSize: 12)))
          else
            const Text('Belum ada', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(LoanRequest loan) {
    // Determine active step index
    int stepIndex = 0;
    switch(loan.status) {
      case 'draft': stepIndex = 0; break;
      case 'submitted': stepIndex = 1; break;
      case 'verified': stepIndex = 2; break;
      case 'approved': stepIndex = 3; break;
      case 'active': stepIndex = 4; break;
      case 'returned': stepIndex = 5; break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Peminjaman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          _buildTimelineItem('Draft', 'Permohonan dibuat', 0, stepIndex),
          _buildTimelineItem('Diajukan', 'Menunggu verifikasi', 1, stepIndex),
          _buildTimelineItem('Diverifikasi', 'Cek kelengkapan dokumen', 2, stepIndex),
          _buildTimelineItem('Disetujui', 'SK diterbitkan', 3, stepIndex),
          _buildTimelineItem('Aktif', 'Barang diserahkan', 4, stepIndex),
          _buildTimelineItem('Selesai', 'Barang dikembalikan', 5, stepIndex, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, int index, int currentIndex, {bool isLast = false}) {
    final isActive = index <= currentIndex;
    final isCurrent = index == currentIndex;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey[200],
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: Colors.blue.shade100, width: 4) : null,
              ),
            ),
            if (!isLast) Container(
              width: 2, height: 40,
              color: isActive && index < currentIndex ? Colors.blue : Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey)),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(height: 24),
          ],
        )
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, WidgetRef ref, LoanRequest loan) {
    // Actions based on status
    if (loan.status == 'active' || loan.status == 'returned') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tindakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 16),
          if (loan.status == 'draft')
             SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(context, ref, loan.id, 'submitted'), child: const Text('Ajukan Permohonan'))),
          if (loan.status == 'submitted')
             SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(context, ref, loan.id, 'verified'), child: const Text('Verifikasi Dokumen'))),
          if (loan.status == 'verified') ...[
             SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(context, ref, loan.id, 'approved'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Setujui Permohonan'))),
             const SizedBox(height: 8),
             SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _updateStatus(context, ref, loan.id, 'rejected'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Tolak'))),
          ],
          if (loan.status == 'approved')
             SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(context, ref, loan.id, 'active'), child: const Text('Serahkan Barang (BAST)'))),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String id, String status) {
     ref.read(loanListProvider.notifier).updateStatus(id, status);
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'draft': bg = Colors.grey.shade100; fg = Colors.grey.shade700; label = 'Draft'; break;
      case 'submitted': bg = Colors.blue.shade50; fg = Colors.blue.shade700; label = 'Diajukan'; break;
      case 'verified': bg = Colors.orange.shade50; fg = Colors.orange.shade800; label = 'Diverifikasi'; break;
      case 'approved': bg = Colors.green.shade50; fg = Colors.green.shade700; label = 'Disetujui'; break;
      case 'active': bg = Colors.blue.shade50; fg = Colors.blue.shade700; label = 'Aktif'; break;
      case 'returned': bg = Colors.teal.shade50; fg = Colors.teal.shade700; label = 'Selesai'; break;
      case 'rejected': bg = Colors.red.shade50; fg = Colors.red.shade700; label = 'Ditolak'; break;
      default: bg = Colors.grey.shade100; fg = Colors.black; label = status;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
      backgroundColor: bg,
      side: BorderSide.none,
    );
  }
}
