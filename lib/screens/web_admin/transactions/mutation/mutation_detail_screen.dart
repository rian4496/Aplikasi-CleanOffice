// lib/screens/web_admin/transactions/mutation/mutation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/asset_mutation.dart';
import '../../../../riverpod/mutation_providers.dart';
import '../../../../services/mutation_export_service.dart';

class MutationDetailScreen extends ConsumerStatefulWidget {
  final String mutationId;

  const MutationDetailScreen({super.key, required this.mutationId});

  @override
  ConsumerState<MutationDetailScreen> createState() => _MutationDetailScreenState();
}

class _MutationDetailScreenState extends ConsumerState<MutationDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mutationAsync = ref.watch(mutationDetailProvider(widget.mutationId));

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Mutasi', 
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)
        ),
        actions: [
          // Print Menu Button (only if approved)
          mutationAsync.whenOrNull(
            data: (mutation) {
              if (mutation == null || mutation.status != MutationStatus.approved) return null;
              return PopupMenuButton<String>(
                icon: Icon(Icons.print_outlined, color: Colors.blue.shade700),
                tooltip: 'Cetak Dokumen',
                onSelected: (value) {
                  switch (value) {
                    case 'sk':
                      MutationExportService.previewSKMutasi(mutation);
                      break;
                    case 'ba':
                      MutationExportService.previewBAMutasi(mutation);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sk',
                    child: ListTile(
                      leading: Icon(Icons.article_outlined, color: Colors.indigo),
                      title: Text('SK Mutasi'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'ba',
                    child: ListTile(
                      leading: Icon(Icons.description_outlined, color: Colors.teal),
                      title: Text('BA Mutasi'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: mutationAsync.when(
        data: (mutation) {
          if (mutation == null) return const Center(child: Text('Data tidak ditemukan'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: MaxWidthContainer(
              maxWidth: 900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Status
                  _buildHeaderCard(mutation),
                  const SizedBox(height: 24),
                  
                  // Main Info Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 800;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildAssetLocationCard(mutation),
                            const SizedBox(height: 24),
                            _buildTimelineCard(mutation),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildAssetLocationCard(mutation)),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildTimelineCard(mutation)),
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Actions (Only if Pending)
                  if (mutation.status == MutationStatus.pending)
                    _buildActionButtons(context, mutation),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderCard(AssetMutation mutation) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          return isSmall 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                              mutation.mutationCode,
                              style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Request ID', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                         ],
                       ),
                     ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailStatusBadge(mutation.status),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mutation.mutationCode,
                        style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('Request ID', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildDetailStatusBadge(mutation.status),
              ],
            );
        }
      ),
    );
  }

  Widget _buildAssetLocationCard(AssetMutation mutation) {
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
          Text('Informasi Perpindahan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          
          // Asset
          _buildInfoRow('Aset', mutation.assetName ?? '-', icon: Icons.inventory_2_outlined),
          const SizedBox(height: 24),
          
          // Origin -> Destination
          Row(
            children: [
              Expanded(child: _buildLocationBox(mutation.originLocationName ?? '-', 'Lokasi Asal', Colors.orange)),
              const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16),
                 child: Icon(Icons.arrow_forward_rounded, color: Colors.grey),
              ),
              Expanded(child: _buildLocationBox(mutation.destinationLocationName ?? '-', 'Lokasi Tujuan', Colors.blue)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text('Keterangan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50], 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              mutation.reason ?? '-', 
              style: TextStyle(color: Colors.grey[800], height: 1.5)
            ),
          ),

          if (mutation.status == MutationStatus.rejected) ...[
             const SizedBox(height: 24),
             Text('Alasan Penolakan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
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
                  mutation.rejectionReason ?? '-', 
                  style: TextStyle(color: Colors.red[900], height: 1.5)
                ),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildLocationBox(String name, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(AssetMutation mutation) {
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
             DateFormat('dd MMM yyyy, HH:mm').format(mutation.createdAt),
             mutation.requesterName ?? 'User',
             isFirst: true,
             isLast: mutation.status == MutationStatus.pending,
           ),
           
           if (mutation.status == MutationStatus.approved)
             _buildTimelineItem(
               'Disetujui', 
               DateFormat('dd MMM yyyy').format(mutation.createdAt), // Ideally should be updated_at
               'Admin',
               isLast: true,
               color: Colors.green
             ),
             
           if (mutation.status == MutationStatus.rejected)
             _buildTimelineItem(
               'Ditolak', 
               DateFormat('dd MMM yyyy').format(mutation.createdAt), 
               'Admin',
               isLast: true,
               color: Colors.red
             ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, String user, {bool isFirst = false, bool isLast = false, Color color = Colors.blue}) {
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
            Text('by $user', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: Colors.grey[400]), const SizedBox(width: 12)],
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

  Widget _buildDetailStatusBadge(MutationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
             status == MutationStatus.approved ? Icons.check_circle : 
             status == MutationStatus.rejected ? Icons.cancel : Icons.hourglass_top,
             size: 16, color: status.color
          ),
          const SizedBox(width: 8),
          Text(
            status.displayName,
            style: TextStyle(color: status.color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AssetMutation mutation) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _showRejectDialog(context, mutation.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Tolak Permintaan'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
             height: 50,
             child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () async {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;
                
                setState(() => _isLoading = true);
  
                try {
                  await ref.read(mutationActionsProvider).approveMutation(mutation.id, userId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mutasi disetujui & Lokasi Aset diperbarui'), backgroundColor: Colors.green),
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Keep Green for Approval
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Setujui & Proses'),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, String mutationId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Mutasi'),
        content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Text('Apakah Anda yakin ingin menolak permintaan mutasi ini?'),
             const SizedBox(height: 16),
             TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan (wajib)...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
           ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan wajib diisi')));
                 return;
              }
               final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) return;

              Navigator.pop(context); // close dialog
              
              setState(() => _isLoading = true);

              try {
                await ref.read(mutationActionsProvider).rejectMutation(mutationId, userId, reasonController.text);
                
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mutasi ditolak'), backgroundColor: Colors.red),
                  );
                  context.pop(); // close detail screen
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Tolak Permintaan'),
          ),
        ],
      ),
    );
  }
}

// Simple Helper for Max Width Constraint
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthContainer({super.key, required this.child, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
