import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/asset.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../riverpod/asset_providers.dart';
import '../../../../riverpod/transactions/disposal_provider.dart';

class DisposalFormScreen extends HookConsumerWidget {
  const DisposalFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descCtrl = useTextEditingController();
    final valueCtrl = useTextEditingController(text: '0');
    
    // State
    final selectedAsset = useState<Asset?>(null);
    final selectedReason = useState<String?>(null);
    final isLoading = useState(false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Buat Usulan Penghapusan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50, 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Perhatian', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                            const SizedBox(height: 4),
                            Text(
                              'Aset yang diusulkan akan dibekukan sementara sampai ada keputusan SK.',
                              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Card Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Pilih Aset
                      _buildSectionTitle('1', 'Aset Bermasalah'),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showAssetPickerDialog(context, ref, selectedAsset),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedAsset.value != null ? AppTheme.primary : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: selectedAsset.value != null ? AppTheme.primary.withValues(alpha: 0.05) : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12), 
                                decoration: BoxDecoration(
                                  color: selectedAsset.value != null ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey[200], 
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined, 
                                  color: selectedAsset.value != null ? AppTheme.primary : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: selectedAsset.value != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedAsset.value!.name, 
                                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(selectedAsset.value!.qrCode ?? '-', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              selectedAsset.value!.category ?? 'Tidak ada kategori',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Pilih Aset...', 
                                      style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                                    ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 2. Alasan Penghapusan
                      _buildSectionTitle('2', 'Alasan Penghapusan'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedReason.value,
                        decoration: InputDecoration(
                          labelText: 'Kategori Alasan',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Rusak Berat', child: Text('Rusak Berat (RB)')),
                          DropdownMenuItem(value: 'Hilang', child: Text('Hilang (Kecurian/Tercecer)')),
                          DropdownMenuItem(value: 'Beralih Fungsi', child: Text('Beralih Fungsi / Usang')),
                          DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                        ],
                        onChanged: (val) => selectedReason.value = val,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Kronologi / Keterangan Detail',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Jelaskan kondisi aset dan alasan mengapa perlu dihapus...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: valueCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Taksiran Nilai Sisa (Rp)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixText: 'Rp ',
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: isLoading.value ? null : () async {
                            // Validate
                            if (selectedAsset.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih aset terlebih dahulu'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (selectedReason.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih alasan penghapusan'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            
                            isLoading.value = true;
                            
                            final req = DisposalRequest(
                              id: '', // Let DB generate
                              code: 'DSP/${DateTime.now().year}/${(DateTime.now().millisecondsSinceEpoch % 10000)}', 
                              assetId: selectedAsset.value!.id, 
                              assetName: selectedAsset.value!.name,
                              assetCode: selectedAsset.value!.qrCode,
                              reason: selectedReason.value!,
                              description: descCtrl.text,
                              estimatedValue: double.tryParse(valueCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0,
                              status: 'proposed',
                              createdAt: DateTime.now(),
                            );
                            
                            try {
                              await ref.read(disposalListProvider.notifier).submitProposal(req);
                              if (context.mounted) {
                                context.pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Usulan penghapusan berhasil dibuat!'),
                                  backgroundColor: Colors.green,
                                ));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Gagal membuat usulan: $e'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: isLoading.value 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.delete_forever),
                          label: Text(isLoading.value ? 'Mengajukan...' : 'Ajukan Usulan Penghapusan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String number, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
  
  void _showAssetPickerDialog(BuildContext context, WidgetRef ref, ValueNotifier<Asset?> selectedAsset) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => HookBuilder(
        builder: (context) {
          final searchQuery = useState('');
          final assetsAsync = ref.watch(allAssetsProvider);
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 500,
              height: 550,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text('Pilih Aset', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari aset...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => searchQuery.value = val.toLowerCase(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Asset List
                  Expanded(
                    child: assetsAsync.when(
                      data: (assets) {
                        // Filter by search and only show active/available assets
                        final filtered = assets.where((a) {
                          final matchSearch = searchQuery.value.isEmpty ||
                              a.name.toLowerCase().contains(searchQuery.value) ||
                              (a.qrCode?.toLowerCase().contains(searchQuery.value) ?? false) ||
                              (a.category?.toLowerCase().contains(searchQuery.value) ?? false);
                          final isAvailable = a.status == AssetStatus.active;
                          return matchSearch && isAvailable;
                        }).toList();
                        
                        if (filtered.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('Tidak ada aset ditemukan', style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final asset = filtered[index];
                            final isSelected = selectedAsset.value?.id == asset.id;
                            
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: asset.imageUrl != null && asset.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: asset.imageUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[200],
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(asset.category).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(_getCategoryIcon(asset.category), color: _getCategoryColor(asset.category)),
                                      ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(asset.category).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(_getCategoryIcon(asset.category), color: _getCategoryColor(asset.category)),
                                    ),
                              ),
                              title: Text(asset.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(asset.qrCode ?? '-', style: const TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(asset.category ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                              trailing: isSelected 
                                ? const Icon(Icons.check_circle, color: AppTheme.primary)
                                : null,
                              selected: isSelected,
                              selectedTileColor: AppTheme.primary.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onTap: () {
                                selectedAsset.value = asset;
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'kendaraan':
      case 'vehicle':
        return Colors.blue;
      case 'elektronik':
      case 'it':
      case 'komputer':
        return Colors.purple;
      case 'furniture':
      case 'mebel':
        return Colors.brown;
      case 'peralatan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'kendaraan':
      case 'vehicle':
        return Icons.directions_car;
      case 'elektronik':
      case 'it':
      case 'komputer':
        return Icons.computer;
      case 'furniture':
      case 'mebel':
        return Icons.chair;
      case 'peralatan':
        return Icons.build;
      default:
        return Icons.inventory_2;
    }
  }
}
