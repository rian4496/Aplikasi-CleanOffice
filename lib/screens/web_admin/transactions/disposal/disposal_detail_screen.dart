import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../riverpod/transactions/disposal_provider.dart';
import '../../../../services/disposal_export_service.dart';

class DisposalDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const DisposalDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DisposalDetailScreen> createState() => _DisposalDetailScreenState();
}

class _DisposalDetailScreenState extends ConsumerState<DisposalDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // We reuse disposalListProvider or create a detail provider. 
    // Usually lists have all the data, but let's assume valid fetching.
    // For now, finding from list provider or fetching single.
    // We'll use a simple find from list or future specific fetch if available.
    // Assuming we need a specific provider for detail or just fetch it.
    // Let's rely on `disposalDetailProvider` if it exists or create simple logic.
    // Checking previous context, `disposalListProvider` was used.
    
    // We'll watch a detail provider. If not defined, we might need to add it, but 
    // let's try to assume it exists or use list filtering for now to be safe,
    // OR just use the pattern from Mutation which has a detail provider.
    // Wait, I haven't seen `disposalDetailProvider` in `disposal_provider.dart`.
    // I will assume it's like Mutation. If not, I'll fallback to List finding.
    
    // Actually, safemode: Let's assume we can fetch it or just use the list to find it if loaded.
    // Better: Define a FutureProvider.family locally or used shared logic.
    // Let's simulate a detail fetch using the list for speed, or a direct Supabase call.
    
    final disposalAsync = ref.watch(disposalListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Detail Penghapusan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        actions: [
          // Print buttons based on status
          disposalAsync.when(
            data: (list) {
              final item = list.firstWhere(
                (e) => e.id == widget.id,
                orElse: () => const DisposalRequest(id: '', code: '', assetId: '', reason: '', status: '', estimatedValue: 0, createdAt: null),
              );
              if (item.id.isEmpty) return const SizedBox();
              
              return Row(
                children: [
                  // SK Button (show for approved/executed)
                  if (['approved', 'executed'].contains(item.status))
                    IconButton(
                      icon: const Icon(Icons.description_outlined, color: Colors.blue),
                      tooltip: 'Cetak SK Penghapusan',
                      onPressed: () => DisposalExportService.previewSK(
                        item,
                        assetName: item.assetName ?? 'Unknown Asset',
                        assetCode: item.assetCode ?? '-',
                        estimatedValue: item.estimatedValue,
                      ),
                    ),
                  // BA Button (show for executed only)
                  if (item.status == 'executed')
                    IconButton(
                      icon: const Icon(Icons.print_outlined, color: Colors.green),
                      tooltip: 'Cetak Berita Acara',
                      onPressed: () => DisposalExportService.previewBeritaAcara(
                        item,
                        assetName: item.assetName ?? 'Unknown Asset',
                        assetCode: item.assetCode ?? '-',
                        finalValue: item.finalValue ?? item.estimatedValue,
                        executionType: item.finalDisposalType ?? 'sold',
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: disposalAsync.when(
        data: (list) {
          final item = list.firstWhere((element) => element.id == widget.id, orElse: () => const DisposalRequest(id: '', code: '', assetId: '', reason: '', status: '', estimatedValue: 0, createdAt: null));
          
          if (item.id.isEmpty) return const Center(child: Text('Data tidak ditemukan'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(item),
                    const SizedBox(height: 24),
                    
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 800;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildInfoCard(item),
                              const SizedBox(height: 24),
                              _buildTimelineCard(item),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildInfoCard(item)),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: _buildTimelineCard(item)),
                          ],
                        );
                      }
                    ),

                    const SizedBox(height: 32),
                    
                    // Action buttons based on status
                    if (item.status == 'proposed')
                      _buildActionButtons(context, item, ref),
                    if (item.status == 'verified')
                      _buildApprovalButtons(context, item, ref),
                    if (item.status == 'approved')
                      _buildExecutionButtons(context, item, ref),
                    if (item.status == 'executed')
                      _buildCompletedBadge(),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderCard(DisposalRequest item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return isMobile 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Expanded(child: _buildTitleSection(item)),
                   ],
                ),
                const SizedBox(height: 16),
                _buildStatusBadge(item.status),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildTitleSection(item)),
                _buildStatusBadge(item.status),
              ],
            );
        }
      ),
    );
  }

  Widget _buildTitleSection(DisposalRequest item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.assetName ?? 'Unknown Asset',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          item.code,
          style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard(DisposalRequest item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Aset', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          
          _buildDetailRow('Kode Aset', item.assetCode ?? '-', Icons.qr_code),
          const SizedBox(height: 16),
          _buildDetailRow('Nilai Estimasi', 'Rp ${NumberFormat.decimalPattern('id').format(item.estimatedValue)}', Icons.attach_money),
          
          const SizedBox(height: 32),
          
          Text('Alasan Penghapusan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50], 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Text(
              item.reason, 
              style: TextStyle(color: Colors.red[900], height: 1.5, fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineCard(DisposalRequest item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Timeline', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
           const Divider(height: 32),
           
           _buildTimelineItem(
             'Diajukan', 
             DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt ?? DateTime.now()),
             'Admin', // Replace with creator name if available
             isFirst: true,
             isLast: item.status == 'proposed',
           ),
           
           if (['verified', 'approved', 'executed'].contains(item.status))
             _buildTimelineItem(
               'Diverifikasi', 
               DateFormat('dd MMM yyyy').format(item.approvalDate ?? DateTime.now()), 
               'Manager',
               isLast: item.status == 'verified',
               color: Colors.blue
             ),

           if (['approved', 'executed'].contains(item.status))
             _buildTimelineItem(
               'Disetujui', 
               DateFormat('dd MMM yyyy').format(item.approvalDate ?? DateTime.now()), 
               'Head of Office',
               isLast: item.status == 'approved',
               color: Colors.purple
             ),
             
           if (item.status == 'executed')
             _buildTimelineItem(
               'Dieksekusi (Selesai)', 
               DateFormat('dd MMM yyyy').format(item.executionDate ?? DateTime.now()), 
               'Asset Team',
               isLast: true,
               color: Colors.green
             ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, String user, {bool isFirst = false, bool isLast = false, Color color = Colors.orange}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            if (!isLast) Container(width: 2, height: 40, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status.toUpperCase();
    switch(status) {
      case 'proposed': color = Colors.orange; label = 'Menunggu Verifikasi'; break;
      case 'verified': color = Colors.blue; label = 'Terverifikasi'; break;
      case 'approved': color = Colors.purple; label = 'Disetujui'; break;
      case 'executed': color = Colors.green; label = 'Selesai'; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, DisposalRequest item, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _updateStatus(context, ref, item.id, 'rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Tolak'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
             height: 50,
             child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _updateStatus(context, ref, item.id, 'verified'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check, color: Colors.white),
              label: const Text('Verifikasi'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String newStatus, [DisposalRequest? item]) async {
    setState(() => _isLoading = true);
    try {
      // Update status in Supabase
      await Supabase.instance.client
          .from('transactions_disposal')
          .update({
            'status': newStatus,
            if (newStatus == 'verified' || newStatus == 'approved') 'approval_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      // Refresh list
      ref.invalidate(disposalListProvider);
      
      if (mounted) {
        final statusLabel = newStatus == 'rejected' 
            ? 'Usulan penghapusan ditolak' 
            : newStatus == 'approved' 
                ? 'SK Penghapusan berhasil diterbitkan!'
                : 'Usulan berhasil diverifikasi';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusLabel),
            backgroundColor: newStatus == 'rejected' ? Colors.red : Colors.green,
          ),
        );
        
        // If approved and item provided, offer to print SK immediately
        if (newStatus == 'approved' && item != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            final shouldPrint = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('SK Berhasil Diterbitkan! 🎉'),
                content: const Text('Apakah Anda ingin langsung mencetak Surat Keputusan Penghapusan Aset?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Nanti Saja'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(c, true),
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak SK'),
                  ),
                ],
              ),
            );
            
            if (shouldPrint == true) {
              await DisposalExportService.previewSK(
                item,
                assetName: item.assetName ?? 'Unknown Asset',
                assetCode: item.assetCode ?? '-',
                estimatedValue: item.estimatedValue,
              );
            }
          }
        } else {
          // For reject/verify -> go back to list
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Approval buttons for VERIFIED status (Kepala OPD approval)
  Widget _buildApprovalButtons(BuildContext context, DisposalRequest item, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _updateStatus(context, ref, item.id, 'rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Tolak'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
             height: 50,
             child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _updateStatus(context, ref, item.id, 'approved', item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.gavel, color: Colors.white),
              label: const Text('Setujui (Terbitkan SK)'),
            ),
          ),
        ),
      ],
    );
  }

  // Execution buttons for APPROVED status (Final execution)
  Widget _buildExecutionButtons(BuildContext context, DisposalRequest item, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _showExecutionDialog(context, ref, item),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _isLoading 
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check_circle, color: Colors.white),
        label: const Text('Eksekusi (Lelang/Musnahkan)'),
      ),
    );
  }

  void _showExecutionDialog(BuildContext context, WidgetRef ref, DisposalRequest item) {
    String executionType = 'sold';
    final valueController = TextEditingController(text: item.estimatedValue.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eksekusi Penghapusan Aset'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih metode eksekusi:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: const Text('Dijual / Lelang'),
                subtitle: const Text('Aset dilelang atau dijual ke pihak ketiga'),
                value: 'sold',
                groupValue: executionType,
                onChanged: (v) => setState(() => executionType = v!),
              ),
              RadioListTile<String>(
                title: const Text('Dimusnahkan / Dihibahkan'),
                subtitle: const Text('Aset dimusnahkan atau dihibahkan'),
                value: 'destroyed',
                groupValue: executionType,
                onChanged: (v) => setState(() => executionType = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Nilai Akhir (Rp)',
                  hintText: '0 jika dimusnahkan',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final finalValue = double.tryParse(valueController.text) ?? 0;
              await _executeDisposal(context, ref, item.id, executionType, finalValue, item.assetId);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Eksekusi'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDisposal(BuildContext context, WidgetRef ref, String id, String type, double finalValue, String assetId) async {
    setState(() => _isLoading = true);
    bool assetUpdated = false;
    
    try {
      // 1. Update disposal status
      await Supabase.instance.client
          .from('transactions_disposal')
          .update({
            'status': 'executed',
            'final_disposal_type': type,
            'final_value': finalValue,
            'execution_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      // 2. Update asset status to 'disposed' (remove from active inventory)
      if (assetId.isNotEmpty) {
        try {
          debugPrint('[Disposal] Updating asset status: assetId=$assetId');
          await Supabase.instance.client
              .from('assets')
              .update({'status': 'disposed'})
              .eq('id', assetId);
          assetUpdated = true;
          debugPrint('[Disposal] Asset status updated successfully');
        } catch (assetError) {
          debugPrint('[Disposal] ERROR updating asset status: $assetError');
          assetUpdated = false;
        }
      } else {
        debugPrint('[Disposal] WARNING: assetId is empty! Cannot update asset status.');
      }
      
      ref.invalidate(disposalListProvider);
      
      if (mounted) {
        if (assetUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Penghapusan aset berhasil dieksekusi. Aset telah dihapus dari daftar aktif.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          // Warning: Disposal executed but asset status not updated
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ Penghapusan dieksekusi, tapi status aset gagal diupdate. Silakan update manual di Master Aset.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 6),
            ),
          );
        }
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // Completed badge for EXECUTED status
  Widget _buildCompletedBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 12),
          Text(
            'Penghapusan Aset Selesai',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
