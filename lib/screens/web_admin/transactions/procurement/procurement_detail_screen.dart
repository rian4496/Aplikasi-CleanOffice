import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../models/procurement.dart' as proc;
import '../../../../../services/procurement_export_service.dart';

import '../../../../../widgets/common/pdf_preview_dialog.dart';
import '../shared/receipt_form_dialog.dart';

class ProcurementDetailScreen extends ConsumerWidget {
  final String id;
  const ProcurementDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch the full list and find the item by ID.
    // In a larger app, we'd have a specific `fetchRequestById` provider.
    // We fetch both active and archived lists to ensure we can find the item.
    final activeAsync = ref.watch(procurementListProvider);
    final archiveAsync = ref.watch(procurementArchiveListProvider);

    // Merge logic: Combine both lists or handle loading states
    final combinedAsync = activeAsync.whenData((active) {
      return archiveAsync.whenData((archived) {
        return [...active, ...archived];
      });
    }).unwrapPrevious(); // Use unwrapPrevious to handle partial data if needed, or just simple logic
    
    // Actually, handling AsyncValue<AsyncValue<List>> is messy.
    // Let's simplified: If active has data, check it. If not found, check archive.
    
    // Better Approach for UI:
    // Just map both.
    
    final AsyncValue<List<ProcurementRequest>> requestsAsync = 
        (activeAsync is AsyncLoading || archiveAsync is AsyncLoading) 
            ? const AsyncLoading() 
            : (activeAsync.hasError) 
              ? AsyncError(activeAsync.error!, activeAsync.stackTrace!) 
              : AsyncData([
                  ...?activeAsync.asData?.value,
                  ...?archiveAsync.asData?.value
                ]);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pengadaan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          // Print PO Button (Visible if approved or completed)
          requestsAsync.when(
            data: (list) {
               // Logic: Retrieve request and check status/archived
               final req = list.firstWhere((r) => r.id == id, orElse: () => ProcurementRequest(id: '', code: '', requestDate: DateTime(2024)));
               
               // Archive Actions
               if (req.isArchived) {
                  return IconButton(
                    icon: const Icon(Icons.unarchive, color: Colors.orange),
                    tooltip: 'Kembalikan ke Aktif (Unarchive)',
                    onPressed: () async {
                       await ref.read(procurementRepositoryProvider).archiveRequest(req.id, false);
                       ref.invalidate(procurementListProvider);
                       ref.invalidate(procurementArchiveListProvider);
                       if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data dikembalikan ke list aktif')));
                          context.pop(); 
                       }
                    },
                  );
               } else if (['completed', 'rejected'].contains(req.status)) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.archive_outlined, color: Colors.blueGrey),
                        tooltip: 'Arsipkan Data',
                        onPressed: () async {
                           final confirm = await showDialog<bool>(
                             context: context,
                             builder: (c) => AlertDialog(
                               title: const Text('Arsipkan Pengadaan?'),
                               content: const Text('Data akan dipindahkan ke folder Arsip dan hilang dari list utama.'),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                 FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Arsipkan')),
                               ],
                             ),
                           );

                           if (confirm == true) {
                              await ref.read(procurementRepositoryProvider).archiveRequest(req.id, true);
                              ref.invalidate(procurementListProvider);
                              ref.invalidate(procurementArchiveListProvider);
                              if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diarsipkan')));
                                  context.pop();
                              }
                           }
                        },
                      ),
                      const SizedBox(width: 8),
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
                     // BA Penerimaan Button  
                     IconButton(
                       icon: Icon(Icons.assignment_turned_in, color: Colors.green.shade700),
                       tooltip: 'Cetak BA Penerimaan Barang',
                       onPressed: () {
                         _showBAPenerimaanDialog(context, req);
                       },
                     ),
                   ],
                 );
              }
              // Always allow delete for Pending or if forced (for now allow for all to fix data)
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red), 
                tooltip: 'Hapus Data (Koreksi)',
                onPressed: () async {
                   final confirm = await showDialog<bool>(
                     context: context,
                     builder: (c) => AlertDialog(
                       title: const Text('Hapus Pengajuan?'),
                       content: const Text('Data yang dihapus tidak dapat dikembalikan. Lakukan hanya jika data salah/corrupt.'),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                         TextButton(
                           onPressed: () => Navigator.pop(c, true), 
                           child: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
                         ),
                       ],
                     ),
                   );

                   if (confirm == true) {
                      try {
                        await ref.read(procurementRepositoryProvider).deleteRequest(req.id);
                        if (context.mounted) {
                          ref.invalidate(procurementListProvider);
                          context.pop(); // Back to list
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
                        }
                      }
                   }
                },
              );
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

  void _showBAPenerimaanDialog(BuildContext context, ProcurementRequest req) {
    final vendorController = TextEditingController();
    final dateController = TextEditingController(text: DateFormat('dd MMMM yyyy').format(DateTime.now()));
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cetak BA Penerimaan Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vendorController,
                decoration: const InputDecoration(
                  labelText: 'Nama Vendor/Penyedia *',
                  hintText: 'Masukkan nama vendor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengiriman',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
            onPressed: () {
              if (vendorController.text.isEmpty) {
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(content: Text('Nama vendor harus diisi'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(c);
              // Convert to ProcurementRequest model for export service
              final procurementModel = proc.ProcurementRequest(
                id: req.id,
                title: req.description ?? 'Pengadaan ${req.code}',
                description: req.description ?? '',
                departmentId: '',
                departmentName: '',
                fiscalYear: DateTime.now().year,
                status: proc.ProcurementStatus.completed,
                totalEstimatedCost: req.totalEstimatedBudget,
                createdAt: req.requestDate,
                updatedAt: req.requestDate,
                items: req.items.map((i) => proc.ProcurementItem(
                  id: i.id,
                  requestId: req.id,
                  itemName: i.itemName,
                  description: '',
                  unit: 'Unit',
                  quantity: i.quantity,
                  estimatedUnitPrice: i.unitPriceEstimate,
                )).toList(),
              );
              
              ProcurementExportService.generateBAPenerimaanBarang(
                procurement: procurementModel,
                vendorName: vendorController.text,
                deliveryDate: dateController.text,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Cetak BA'),
          ),
        ],
      ),
    );
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16, // Reduce spacing slightly
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
