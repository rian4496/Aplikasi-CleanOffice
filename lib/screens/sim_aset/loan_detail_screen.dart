import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/loan_model.dart';
import '../../riverpod/transactions/loan_provider.dart';
import '../../services/loan_export_service.dart';

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
          // Print Menu Button
          loanAsync.whenOrNull(
            data: (loans) {
              final loan = loans.firstWhere((l) => l.id == id, orElse: () => throw Exception('Not found'));
              return PopupMenuButton<String>(
                icon: const Icon(Icons.print_outlined, color: Colors.blue),
                tooltip: 'Cetak Dokumen',
                onSelected: (value) {
                  switch (value) {
                    case 'surat':
                      LoanExportService.previewSuratPeminjaman(loan);
                      break;
                    case 'sk':
                      LoanExportService.previewSKPeminjaman(loan);
                      break;
                    case 'bast_handover':
                      LoanExportService.previewBASerahTerimaPenyerahan(loan);
                      break;
                    case 'bast_return':
                      _showReturnDialog(context, loan);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'surat',
                    child: ListTile(
                      leading: Icon(Icons.mail_outlined, color: Colors.blue),
                      title: Text('Surat Peminjaman'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (loan.status == 'approved' || loan.status == 'active' || loan.status == 'returned')
                    const PopupMenuItem(
                      value: 'sk',
                      child: ListTile(
                        leading: Icon(Icons.article_outlined, color: Colors.indigo),
                        title: Text('SK Peminjaman'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (loan.status == 'approved' || loan.status == 'active' || loan.status == 'returned')
                    const PopupMenuItem(
                      value: 'bast_handover',
                      child: ListTile(
                        leading: Icon(Icons.description_outlined, color: Colors.teal),
                        title: Text('BA Serah Terima (Penyerahan)'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (loan.status == 'returned')
                    const PopupMenuItem(
                      value: 'bast_return',
                      child: ListTile(
                        leading: Icon(Icons.description_outlined, color: Colors.orange),
                        title: Text('BA Serah Terima (Pengembalian)'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              );
            },
          ) ?? const SizedBox(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Hapus Peminjaman',
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
                
                // Content - Responsive Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Mobile: Stack vertically
                      return Column(
                        children: [
                          _buildInfoCard('Informasi Peminjam', [
                            _buildInfoRow('Nama Instansi', loan.borrowerName),
                            _buildInfoRow('Alamat', loan.borrowerAddress),
                            _buildInfoRow('Kontak', loan.borrowerContact),
                            _buildInfoRow('Nomor Surat', loan.requestNumber),
                          ]),
                          const SizedBox(height: 16),
                          _buildTimelineCard(loan),
                          const SizedBox(height: 16),
                          _buildInfoCard('Detail Aset', [
                            _buildInfoRow('Nama Aset', loan.assetName),
                            _buildInfoRow('Kode Aset', _truncateId(loan.assetId)),
                            _buildInfoRow('Kondisi', loan.assetCondition),
                          ]),
                          const SizedBox(height: 16),
                          _buildActionCard(context, ref, loan),
                          const SizedBox(height: 16),
                          _buildInfoCard('Dokumen Pendukung', [
                            _buildDocRow('Surat Permohonan', loan.applicationLetterDoc),
                            _buildDocRow('Draft Perjanjian', loan.agreementDoc),
                            _buildDocRow('BAST Penyerahan', loan.bastHandoverDoc),
                          ]),
                        ],
                      );
                    }
                    
                    // Desktop: 2-column layout
                    return Row(
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
                                _buildInfoRow('Kode Aset', loan.assetId),
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
                        
                        // Right Column: Timeline & Actions
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
                    );
                  },
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loan.requestNumber, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                loan.borrowerName, 
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
    // No actions for returned status
    if (loan.status == 'returned') return const SizedBox.shrink();

    // Check if loan is overdue (only for active status)
    final isOverdue = loan.status == 'active' && DateTime.now().isAfter(loan.endDate);
    final daysOverdue = isOverdue ? DateTime.now().difference(loan.endDate).inDays : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isOverdue ? Colors.red.shade200 : Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overdue Warning Banner
          if (isOverdue) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ PEMINJAMAN MELEWATI JATUH TEMPO!',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Terlambat $daysOverdue hari. Segera lakukan konfirmasi pengembalian.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          Text(
            'Tindakan', 
            style: TextStyle(fontWeight: FontWeight.bold, color: isOverdue ? Colors.red.shade700 : Colors.blue),
          ),
          const SizedBox(height: 16),
          
          // Status-based actions
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
          
          // Return Confirmation for Active Loans
          if (loan.status == 'active')
             SizedBox(
               width: double.infinity, 
               child: ElevatedButton.icon(
                 onPressed: () => _showReturnConfirmationDialog(context, ref, loan),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: isOverdue ? Colors.red : Colors.teal,
                   padding: const EdgeInsets.symmetric(vertical: 14),
                 ),
                 icon: const Icon(Icons.assignment_return, color: Colors.white),
                 label: const Text('Konfirmasi Pengembalian Barang', style: TextStyle(color: Colors.white)),
               ),
             ),
        ],
      ),
    );
  }

  void _showReturnConfirmationDialog(BuildContext context, WidgetRef ref, LoanRequest loan) {
    final kondisiController = TextEditingController(text: 'Baik');
    final catatanController = TextEditingController();
    String selectedKondisi = 'Baik';
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.assignment_return, color: Colors.teal),
              SizedBox(width: 8),
              Text('Konfirmasi Pengembalian'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Aset
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aset: ${loan.assetName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Peminjam: ${loan.borrowerName}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Kondisi Dropdown
                DropdownButtonFormField<String>(
                  value: selectedKondisi,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Aset Saat Dikembalikan',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Baik', child: Text('✅ Baik')),
                    DropdownMenuItem(value: 'Rusak Ringan', child: Text('⚠️ Rusak Ringan')),
                    DropdownMenuItem(value: 'Rusak Berat', child: Text('❌ Rusak Berat')),
                  ],
                  onChanged: (v) {
                    setState(() => selectedKondisi = v ?? 'Baik');
                    kondisiController.text = v ?? 'Baik';
                  },
                ),
                const SizedBox(height: 12),
                
                // Catatan
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Pengembalian (Opsional)',
                    hintText: 'Masukkan catatan jika ada kerusakan atau kekurangan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(c);
                // Update status to returned
                _updateStatus(context, ref, loan.id, 'returned');
                
                // Show success and offer to print BA
                if (context.mounted) {
                  final shouldPrint = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('✅ Pengembalian Dikonfirmasi'),
                      content: const Text('Barang telah dikembalikan. Apakah ingin mencetak BA Serah Terima Pengembalian?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Nanti Saja'),
                        ),
                        FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, true),
                          icon: const Icon(Icons.print),
                          label: const Text('Cetak BA'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldPrint == true) {
                    LoanExportService.previewBASerahTerimaPengembalian(
                      loan,
                      kondisi: kondisiController.text,
                      catatan: catatanController.text.isNotEmpty ? catatanController.text : null,
                    );
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Konfirmasi Pengembalian'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String status) async {
    try {
      await ref.read(loanListProvider.notifier).updateStatus(id, status);
      if (context.mounted) {
        final statusLabel = _getStatusLabel(status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diubah menjadi "$statusLabel"'),
            backgroundColor: status == 'rejected' ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft': return 'Draft';
      case 'submitted': return 'Diajukan';
      case 'verified': return 'Diverifikasi';
      case 'approved': return 'Disetujui';
      case 'active': return 'Aktif (Dipinjam)';
      case 'returned': return 'Dikembalikan';
      case 'rejected': return 'Ditolak';
      default: return status;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Peminjaman?'),
        content: const Text('Data peminjaman yang dihapus tidak dapat dikembalikan. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(loanListProvider.notifier).deleteLoan(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

  String _truncateId(String id) {
    if (id.length > 12) {
      return '${id.substring(0, 8)}...';
    }
    return id;
  }

  void _showReturnDialog(BuildContext context, LoanRequest loan) {
    final kondisiController = TextEditingController(text: 'Baik');
    final catatanController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cetak BA Pengembalian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: 'Baik',
              decoration: const InputDecoration(
                labelText: 'Kondisi Aset Saat Dikembalikan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Baik', child: Text('Baik')),
                DropdownMenuItem(value: 'Rusak Ringan', child: Text('Rusak Ringan')),
                DropdownMenuItem(value: 'Rusak Berat', child: Text('Rusak Berat')),
              ],
              onChanged: (v) => kondisiController.text = v ?? 'Baik',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(c);
              LoanExportService.previewBASerahTerimaPengembalian(
                loan,
                kondisi: kondisiController.text,
                catatan: catatanController.text.isNotEmpty ? catatanController.text : null,
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Cetak BA'),
          ),
        ],
      ),
    );
  }
}
