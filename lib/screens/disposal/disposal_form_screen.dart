import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../riverpod/transaction_providers.dart';
import '../../riverpod/dropdown_providers.dart';
import '../../models/transactions/disposal_model.dart';
import '../../models/master/master_data_models.dart';

class DisposalFormScreen extends HookConsumerWidget {
  const DisposalFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    
    // Form Controllers
    final selectedAsset = useState<MasterAset?>(null);
    final reasonController = useTextEditingController();
    final descController = useTextEditingController();
    final estimatedValueController = useTextEditingController(text: '0');

    // Data Loaders
    final assetsAsync = ref.watch(assetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Penghapusan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Asset Selection
            _buildSectionTitle('Pilih Aset'),
            assetsAsync.when(
              data: (assets) => DropdownButtonFormField<MasterAset>(
                value: selectedAsset.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Cari aset yang ingin dihapus...',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: assets.map((asset) {
                  return DropdownMenuItem(
                    value: asset,
                    child: Text('${asset.name} (${asset.assetCode})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => selectedAsset.value = val,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Gagal memuat aset: $err'),
            ),
            const SizedBox(height: 24),

            // 2. Details
            _buildSectionTitle('Detail Penghapusan'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Penghapusan',
                hintText: 'Contoh: Rusak Berat, Hilang, Usang',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keterangan Tambahan',
                hintText: 'Jelaskan kondisi aset secara detail...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Valuation
            _buildSectionTitle('Taksiran Nilai (Opsional)'),
             TextField(
              controller: estimatedValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimasi Nilai Jual (Rp)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                helperText: 'Isi 0 jika akan dimusnahkan tanpa nilai jual',
              ),
            ),

            const SizedBox(height: 40),

            // 4. Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isLoading.value ? null : () async {
                  if (selectedAsset.value == null || reasonController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aset dan Alasan wajib diisi')));
                    return;
                  }

                  isLoading.value = true;
                  try {
                    final req = DisposalRequest(
                      id: '', // DB Generated
                      code: 'DSP-${DateTime.now().millisecondsSinceEpoch}', // Temp Code
                      assetId: selectedAsset.value!.id,
                      reason: reasonController.text,
                      description: descController.text,
                      estimatedValue: double.tryParse(estimatedValueController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                      status: 'draft',
                    );

                    await ref.read(disposalRepositoryProvider).createRequest(req);
                    
                    ref.invalidate(disposalListProvider);
                    if (context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usulan berhasil dibuat')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } finally {
                    isLoading.value = false;
                  }
                },
                child: isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kirim Pengajuan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }
}
