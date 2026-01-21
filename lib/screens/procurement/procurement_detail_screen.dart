import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/procurement.dart';

// Dummy provider for details (in real app, use family provider or fetch by ID)
final procurementDetailProvider = FutureProvider.family<ProcurementRequest?, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 500));
  // Mock data matching list screen + items
  return ProcurementRequest(
    id: id,
    title: 'Pengadaan Laptop Staff',
    description: 'Kebutuhan laptop untuk 3 staff baru bidang IT',
    departmentId: 'dept-1',
    departmentName: 'Bidang IT',
    fiscalYear: 2024,
    status: ProcurementStatus.submitted,
    totalEstimatedCost: 45000000,
    createdBy: 'user-1',
    createdByName: 'Budi Santoso',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
    items: [
      ProcurementItem(id: '1', requestId: id, itemName: 'Laptop Dell XPS 15', description: '', quantity: 2, estimatedUnitPrice: 20000000, unit: 'Unit'),
      ProcurementItem(id: '2', requestId: id, itemName: 'Mouse Wireless', description: '', quantity: 2, estimatedUnitPrice: 500000, unit: 'Pcs'),
       ProcurementItem(id: '3', requestId: id, itemName: 'Tas Laptop', description: '', quantity: 2, estimatedUnitPrice: 2000000, unit: 'Pcs'),
    ],
  );
});

class ProcurementDetailScreen extends ConsumerWidget {
  final String id;
  const ProcurementDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(procurementDetailProvider(id));

    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detail Usulan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: requestAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, trace) => Center(child: Text('Error: $e')),
              data: (request) {
                if (request == null) return const Center(child: Text("Data not found"));
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: request.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: request.status.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: request.status.color),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${request.status.displayName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: request.status.color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Terakhir diupdate: ${request.updatedAt.day}/${request.updatedAt.month}/${request.updatedAt.year}',
                                  style: TextStyle(color: request.status.color),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Informasi Usulan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const Divider(height: 24),
                                    _InfoRow('Judul', request.title),
                                    _InfoRow('Bidang', request.departmentName),
                                    _InfoRow('Tahun Anggaran', request.fiscalYear.toString()),
                                    _InfoRow('Diajukan Oleh', request.createdByName ?? '-'),
                                    const SizedBox(height: 16),
                                    const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(request.description),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                           child: _buildActionCard(context, request),
                         ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Items Table
                      const Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                             // Table Header
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.grey[100],
                                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                               ),
                               child: const Row(
                                 children: [
                                   Expanded(flex: 3, child: Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                                   Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                                   Expanded(flex: 2, child: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
                                   Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                 ],
                               ),
                             ),
                             // Items
                             if (request.items != null)
                               ...request.items!.map((item) => Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                                 child: Row(
                                   children: [
                                     Expanded(flex: 3, child: Text(item.itemName)),
                                     Expanded(flex: 1, child: Text('${item.quantity} ${item.unit}')),
                                     Expanded(flex: 2, child: Text('Rp ${item.estimatedUnitPrice.toStringAsFixed(0)}')),
                                     Expanded(flex: 2, child: Text('Rp ${item.estimatedTotalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                   ],
                                 ),
                               )),
                             
                             // Footer
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                   const Text('Total Estimasi: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                   Text(
                                     'Rp ${request.totalEstimatedCost.toStringAsFixed(0)}',
                                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                   ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ProcurementRequest request) {
    // Actions based on status
    final isSubmitted = request.status == ProcurementStatus.submitted;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tindakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),
            
            if (isSubmitted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disetujui Admin')));
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Verifikasi & Teruskan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditolak')));
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Tolak Usulan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Tidak ada tindakan yang tersedia saat ini.',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

