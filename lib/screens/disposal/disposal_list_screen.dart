import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../providers/transaction_providers.dart';
import '../../../../models/transactions/disposal_model.dart';

class DisposalListScreen extends HookConsumerWidget {
  const DisposalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data
    final requestsAsync = ref.watch(disposalListProvider);
    
    // 2. State
    final selectedIds = useState<Set<String>>({});
    final isSelectionMode = useState(false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Penghapusan Aset (Disposal)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (isSelectionMode.value) ...[
             Center(child: Text('${selectedIds.value.length} terpilih', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
             const SizedBox(width: 16),
             TextButton.icon(
               onPressed: () {
                 isSelectionMode.value = false;
                 selectedIds.value = {};
               },
               icon: const Icon(Icons.close),
               label: const Text('Batal'),
             ),
          ] else ...[
             IconButton(onPressed: () => ref.refresh(disposalListProvider), icon: const Icon(Icons.refresh)),
             const SizedBox(width: 8),
             FilledButton.icon(
               onPressed: () => context.go('/admin/disposal/new'),
               icon: const Icon(Icons.add),
               label: const Text('Buat Usulan'),
               style: FilledButton.styleFrom(
                 backgroundColor: AppTheme.primary,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
             ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) return _buildEmptyState();

          return Column(
            children: [
              // Toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 12),
                color: Colors.white,
                child: Row(
                   children: [
                     const Icon(Icons.grid_view, size: 20, color: Colors.grey),
                     const SizedBox(width: 8),
                     Text('Gallery Mode', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                     const Spacer(),
                     if (!isSelectionMode.value)
                       OutlinedButton.icon(
                         onPressed: () => isSelectionMode.value = true,
                         icon: const Icon(Icons.checklist_rtl, size: 18),
                         label: const Text('Pilih Banyak'),
                       ),
                   ],
                ),
              ),
              const Divider(height: 1),
              
              // Gallery Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final item = requests[index];
                    final isSelected = selectedIds.value.contains(item.id);
                    
                    return InkWell(
                      onTap: () {
                        if (isSelectionMode.value) {
                           final newSet = Set<String>.from(selectedIds.value);
                           if (isSelected) {
                             newSet.remove(item.id);
                           } else {
                             newSet.add(item.id);
                           }
                           selectedIds.value = newSet;
                        } else {
                           context.go('/admin/disposal/detail/${item.id}');
                        }
                      },
                      child: Stack(
                        children: [
                          _buildAssetCard(item, isSelected),
                          if (isSelectionMode.value)
                             Positioned(
                               top: 8, right: 8,
                               child: Container(
                                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                 child: Icon(
                                   isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                   color: isSelected ? AppTheme.primary : Colors.grey,
                                   size: 28,
                                 ),
                               ),
                             ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: (isSelectionMode.value && selectedIds.value.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () {
                 // Action: Generate SK
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating Berita Acara for selected assets...')));
              },
              icon: const Icon(Icons.description),
              label: Text('Buat Berita Acara (${selectedIds.value.length})'),
              backgroundColor: AppTheme.primary,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
     return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_sweep_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada usulan penghapusan aset.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
  }

  Widget _buildAssetCard(DisposalRequest item, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Placeholder
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              width: double.infinity,
              child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey[400]),
            ),
          ),
          
          // Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.assetName ?? 'Asset #${item.assetId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      item.reason,
                      style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                         NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.estimatedValue),
                         style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey[700]),
                       ),
                       _buildStatusDot(item.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String status) {
     Color color;
     switch(status) {
       case 'approved': color = Colors.green; break;
       case 'pending': color = Colors.orange; break;
       default: color = Colors.grey;
     }
     
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: color.withOpacity(0.3)),
       ),
       child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
     );
  }
}
