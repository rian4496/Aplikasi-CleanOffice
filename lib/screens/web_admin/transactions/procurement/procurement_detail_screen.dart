import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';

import '../../../../../widgets/common/pdf_preview_dialog.dart';
import '../shared/receipt_form_dialog.dart';

class ProcurementDetailScreen extends ConsumerWidget {
  final String id;
  const ProcurementDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch the full list and find the item by ID.
    // In a larger app, we'd have a specific `fetchRequestById` provider.
    final requestsAsync = ref.watch(procurementListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pengadaan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          // Print PO Button (Visible if approved or completed)
          requestsAsync.when(
            data: (list) {
              final req = list.firstWhere((r) => r.id == id, orElse: () => ProcurementRequest(id: '', code: '', requestDate: DateTime(2024)));
              if (['approved_admin', 'approved_head', 'completed'].contains(req.status)) {
                 return Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     // Receipt Button
                     IconButton(
                       icon: const Icon(Icons.receipt_long),
                       tooltip: 'Cetak Kuitansi (SPJ)',
                       onPressed: () {
                         showDialog(
                           context: context,
                           builder: (c) => ReceiptFormDialog(
                             initialData: {
                               'receivedFrom': 'Bendahara Pengeluaran Pembantu Balai', // Default from screenshot insight
                               'amount': req.totalEstimatedBudget,
                               'description': 'Pembayaran Pengadaan ${req.description ?? ''} (${req.code})',
                               'recipientName': req.requesterName, // Applicant is usually the one receiving the cash advance or reimbursement? Or Vendor?
                               // Let's rely on user editing the form for specifics.
                             },
                           ),
                         );
                       },
                     ),
                     // PO Button
                     IconButton(
                       icon: const Icon(Icons.print),
                       tooltip: 'Cetak Purchase Order',
                       onPressed: () {
                         showDialog(
                           context: context,
                           builder: (c) => PdfPreviewDialog(
                             title: 'Purchase Order (PO)',
                             docNumber: req.code,
                           ),
                         );
                       },
                     ),
                   ],
                 );
              }
              return const SizedBox();
            },
            loading: () => const SizedBox(),
            error: (_,__) => const SizedBox(),
          )
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (requests) {
          final request = requests.firstWhere(
            (r) => r.id == id,
            orElse: () => throw Exception('Request not found'),
          );
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card
                _buildHeaderCard(context, request, ref),

                const SizedBox(height: 24),

                // 2. Items Table
                Text('Daftar Barang', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildItemsTable(request.items),

                // 3. Approval Actions
                if (request.status == 'pending') ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Tindakan Approval', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                             // Reject Logic
                             _updateStatus(context, ref, request.id, 'rejected');
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Tolak Pengajuan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                             // Approve Logic
                             _updateStatus(context, ref, request.id, 'approved_admin');
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Setujui Pengajuan'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
                // 4. Completion Action (For Approved Requests)
                if (request.status == 'approved_admin' || request.status == 'approved_head') ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Tindakan Penyelesaian', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                         // Complete Logic -> Triggers Asset Registration
                         _updateStatus(context, ref, request.id, 'completed');
                      },
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Barang Diterima & Selesaikan (Masuk Aset)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String status) async {
      try {
        await ref.read(procurementRepositoryProvider).updateStatus(id, status);
        // Invalidate list to refresh UI
        ref.invalidate(procurementListProvider);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diperbarui')));
           context.pop();
        }
      } catch (e) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
         }
      }
  }

  Widget _buildHeaderCard(BuildContext context, ProcurementRequest request, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.code,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(request.requestDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.person, 'Diajukan Oleh', request.requesterName ?? '-'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.description, 'Keterangan', request.description ?? '-'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.monetization_on, 'Total Estimasi', 
               NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(request.totalEstimatedBudget)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsTable(List<ProcurementItem> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(label: Text('Nama Barang')),
          DataColumn(label: Text('Jumlah')),
          DataColumn(label: Text('Harga Satuan')),
          DataColumn(label: Text('Total')),
        ],
        rows: items.map((item) {
          final total = item.quantity * item.unitPriceEstimate;
          return DataRow(cells: [
             DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
             DataCell(Text('${item.quantity} Unit')),
             DataCell(Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.unitPriceEstimate))),
             DataCell(Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // Reuse logic from List Screen or move to shared util
     Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Menunggu';
        break;
      case 'approved_admin':
      case 'approved_head':
        color = Colors.blue;
        label = 'Disetujui';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
