import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../riverpod/transaction_providers.dart';
import '../../riverpod/auth_providers.dart';
import '../../models/transactions/disposal_model.dart';
import '../../widgets/common/pdf_preview_dialog.dart';

class DisposalDetailScreen extends ConsumerWidget {
  final String id;
  const DisposalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(disposalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        actions: [
          // Print Button (Visible if approved/completed)
          requestsAsync.when(
            data: (list) {
              final req = list.firstWhere((e) => e.id == id, orElse: () => const DisposalRequest(id: '', code: '', assetId: '', reason: '', estimatedValue: 0));
              if (req.status == 'approved' || req.status == 'completed') {
                return IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Cetak Berita Acara',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => PdfPreviewDialog(
                        title: 'Berita Acara Penghapusan',
                        docNumber: req.code,
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          )
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (list) {
          final request = list.firstWhere((e) => e.id == id, orElse: () => throw Exception('Not Found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(request),
                const SizedBox(height: 24),
                _buildInfoCard(request),
                const SizedBox(height: 24),
                // Role-based verification: Only Admin and Kasubbag UMPEG can verify
                Builder(
                  builder: (context) {
                    final userRole = ref.watch(currentUserRoleProvider);
                    final canVerify = userRole == 'admin' || userRole == 'kasubbag_umpeg';
                    
                    if (request.status == 'draft' || request.status == 'submitted') {
                      if (canVerify) {
                        return _buildActionButtons(context, ref, request);
                      } else {
                        return _buildPendingVerificationInfo();
                      }
                    } else {
                      return _buildExecutionInfo(context, ref, request);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... (Header and InfoCard remain same) -> I will invoke original methods here via replace if needed, or assume they are there.
  // Actually I need to replace the whole file or be handled by the replace tool smartness.
  // Since I am replacing the top part, I need to make sure I don't delete helper methods.
  // I will target specific chunks.

  Widget _buildHeader(DisposalRequest req) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.delete_outline, color: Colors.blue, size: 32),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(req.code, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(DateFormat('dd MMM yyyy').format(req.createdAt ?? DateTime.now()), style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Chip(
          label: Text(req.status.toUpperCase()),
          backgroundColor: _getStatusColor(req.status).withValues(alpha: 0.1),
          labelStyle: TextStyle(color: _getStatusColor(req.status), fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildInfoCard(DisposalRequest req) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRow('Aset', req.assetName ?? '-'),
            const Divider(),
            _buildRow('Alasan', req.reason),
            const Divider(),
            _buildRow('Deskripsi', req.description ?? '-'),
            const Divider(),
            _buildRow('Taksiran Nilai', NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(req.estimatedValue)),
            if (req.status == 'completed') ...[
               const Divider(),
               _buildRow('Tipe Eksekusi', req.finalDisposalType == 'sold' ? 'Lelang / Jual' : 'Pemusnahan'),
               _buildRow('Nilai Akhir', NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(req.finalValue ?? 0)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, DisposalRequest req) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateStatus(context, ref, req.id, 'rejected'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
             onPressed: () => _updateStatus(context, ref, req.id, 'approved'),
             style: FilledButton.styleFrom(backgroundColor: Colors.green),
             child: const Text('Setujui'),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingVerificationInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Menunggu Verifikasi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pengajuan ini sedang menunggu verifikasi dari Admin atau Kasubbag UMPEG.',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionInfo(BuildContext context, WidgetRef ref, DisposalRequest req) {
    if (req.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red[50],
        child: const Text('Pengajuan ini telah ditolak.', style: TextStyle(color: Colors.red)),
      );
    }
    
    final isCompleted = req.status == 'completed';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isCompleted ? Colors.blue[50] : Colors.green[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: ${isCompleted ? 'SELESAI' : 'DISETUJUI'}', style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.blue : Colors.green)),
          const SizedBox(height: 8),
          if (!isCompleted)
             const Text('Menunggu proses eksekusi (Lelang/Pemusnahan). Setelah proses selesai, klik tombol di bawah untuk menyelesaikan tiket.', style: TextStyle(fontSize: 12)),
          
          if (!isCompleted)
             Padding(
               padding: const EdgeInsets.only(top: 16.0),
               child: FilledButton.icon(
                 onPressed: () => _showExecutionDialog(context, ref, req),
                 icon: const Icon(Icons.check_circle_outline),
                 label: const Text('Eksekusi (Jual/Musnahkan)'),
               ),
             )
        ],
      ),
    );
  }

  void _showExecutionDialog(BuildContext context, WidgetRef ref, DisposalRequest req) {
    final valueController = TextEditingController(text: req.estimatedValue.toStringAsFixed(0));
    String type = 'sold'; // sold, destroyed

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eksekusi Aset'),
        content: StatefulBuilder(
           builder: (context, setState) => Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               RadioListTile(
                 title: const Text('Lelang / Dijual'),
                 value: 'sold', 
                 groupValue: type, 
                 onChanged: (v) => setState(() => type = v.toString())
               ),
               RadioListTile(
                 title: const Text('Dimusnahkan / Hibah'),
                 value: 'destroyed', 
                 groupValue: type, 
                 onChanged: (v) => setState(() => type = v.toString())
               ),
               const SizedBox(height: 16),
               TextField(
                 controller: valueController,
                 decoration: const InputDecoration(labelText: 'Nilai Akhir (Rp)', border: OutlineInputBorder()),
                 keyboardType: TextInputType.number,
               )
             ],
           ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
               final val = double.tryParse(valueController.text) ?? 0;
               _updateStatus(context, ref, req.id, 'completed', type: type, finalValue: val);
            },
            child: const Text('Selesaikan'),
          )
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String status, {String? type, double? finalValue}) async {
    try {
      await ref.read(disposalRepositoryProvider).updateStatus(id, status, disposalType: type, finalValue: finalValue);
      ref.invalidate(disposalListProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah ke: ${status.toUpperCase()}'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Close dialog or screen
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
     switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.blueGrey;
      default: return Colors.orange;
    }
  }
}
