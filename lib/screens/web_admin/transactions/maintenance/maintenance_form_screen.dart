import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../riverpod/dropdown_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../models/master/master_data_models.dart';

class MaintenanceRequestForm extends HookConsumerWidget {
  final String? id; // Null = New, Not Null = Edit
  const MaintenanceRequestForm({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final selectedAsset = useState<MasterAset?>(null);
    final issueTitleController = useTextEditingController();
    final issueDescController = useTextEditingController();
    final isUrgent = useState(false);

    // Fetch Assets for selection
    final assetsAsync = ref.watch(assetListProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard blank space issue
      appBar: AppBar(
        title: Text(id == null ? 'Buat Laporan Kerusakan' : 'Edit Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Asset Selection
            Text('Aset Bermasalah', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 8),
            assetsAsync.when(
              data: (assets) {
                return DropdownButtonFormField<MasterAset>(
                  value: selectedAsset.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Pilih Aset',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  items: assets.map((asset) {
                    return DropdownMenuItem(
                      value: asset,
                      child: Text('${asset.name} (${asset.assetCode})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => selectedAsset.value = val,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Gagal memuat aset: $err', style: const TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 24),

            // 2. Issue Details
            Text('Detail Masalah', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 8),
            TextField(
              controller: issueTitleController,
              decoration: const InputDecoration(
                labelText: 'Judul Masalah',
                hintText: 'Contoh: AC Bocor, Laptop Mati Total',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: issueDescController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Detail',
                hintText: 'Jelaskan kronologi atau gejala kerusakan...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // 3. Urgency Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUrgent.value ? Colors.red[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isUrgent.value ? Colors.red[200]! : Colors.grey[300]!),
              ),
              child: SwitchListTile(
                title: Text(
                  'Mendesak / Urgent?', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isUrgent.value ? Colors.red : Colors.grey[800]
                  )
                ),
                subtitle: const Text('Aktifkan jika kerusakan menghambat operasional utama.'),
                activeColor: Colors.red,
                value: isUrgent.value,
                onChanged: (val) => isUrgent.value = val,
              ),
            ),

            const SizedBox(height: 32),

            // 4. Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: isLoading.value ? null : () async {
                   if (selectedAsset.value == null || issueTitleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi aset dan judul masalah')));
                      return;
                   }

                   isLoading.value = true;
                   try {
                     final req = MaintenanceRequest(
                       id: '', // Generated by Repo/DB
                       assetId: selectedAsset.value!.id,
                       issueTitle: issueTitleController.text,
                       issueDescription: issueDescController.text,
                       priority: isUrgent.value ? 'urgent' : 'normal',
                       status: 'reported',
                       // Other fields default/null
                     );

                     await ref.read(maintenanceRepositoryProvider).createRequest(req);
                     
                     ref.invalidate(maintenanceListProvider);
                     if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim')));
                     }
                   } catch (e) {
                      isLoading.value = false;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                      }
                   }
                },
                icon: isLoading.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send),
                label: const Text('Kirim Laporan'),
                style: FilledButton.styleFrom(
                  backgroundColor: isUrgent.value ? Colors.red : AppTheme.primary,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
