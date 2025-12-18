import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../providers/transactions/disposal_provider.dart';

class DisposalFormScreen extends HookConsumerWidget {
  const DisposalFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reasonCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final valueCtrl = useTextEditingController(text: '0');
    
    // Asset Selection State
    final selectedAssetId = useState<String?>(null);
    final selectedAssetName = useState<String?>(null);
    final selectedAssetCode = useState<String?>(null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Buat Usulan Penghapusan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Aset yang diusulkan akan dibekukan sementara sampai ada keputusan SK.', style: TextStyle(color: Colors.brown))),
                ],
              ),
            ),
            
            // 1. Pilih Aset
            const Text('1. Aset Bermasalah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
             InkWell(
              onTap: () => _showAssetPicker(context, selectedAssetId, selectedAssetName, selectedAssetCode),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle), child: const Icon(Icons.inventory_2)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedAssetName.value ?? 'Pilih Aset...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selectedAssetName.value == null ? Colors.grey : Colors.black87)),
                          if(selectedAssetCode.value != null) Text('Kode: ${selectedAssetCode.value}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Detail Penghapusan
            const Text('2. Alasan Penghapusan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Kategori Alasan', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Rusak Berat', child: Text('Rusak Berat (RB)')),
                DropdownMenuItem(value: 'Hilang', child: Text('Hilang (Kecurian/Tercecer)')),
                DropdownMenuItem(value: 'Beralih Fungsi', child: Text('Beralih Fungsi / Usang')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (val) => reasonCtrl.text = val ?? '',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Kronologi / Keterangan Detail', border: OutlineInputBorder(), alignLabelWithHint: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Taksiran Nilai Sisa (Rp)', border: OutlineInputBorder(), prefixText: 'Rp '),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  // Mock Submit
                  if (selectedAssetId.value == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih aset dahulu')));
                    return;
                  }
                  
                  final req = DisposalRequest(
                    id: 'DISP-${DateTime.now().millisecondsSinceEpoch}', 
                    code: 'DRAFT/2024/${(DateTime.now().millisecondsSinceEpoch % 1000)}', 
                    assetId: selectedAssetId.value!, 
                    assetName: selectedAssetName.value,
                    assetCode: selectedAssetCode.value,
                    reason: reasonCtrl.text,
                    description: descCtrl.text,
                    estimatedValue: double.tryParse(valueCtrl.text) ?? 0,
                    status: 'proposed',
                    createdAt: DateTime.now(),
                  );
                  
                  ref.read(disposalListProvider.notifier).submitProposal(req);
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usulan penghapusan berhasil dibuat!')));
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red[700]), // Danger color
                child: const Text('Ajukan Usulan'),
              ),
            )
          ],
        ),
      ),
    );
  }
  
   void _showAssetPicker(BuildContext context, ValueNotifier<String?> id, ValueNotifier<String?> name, ValueNotifier<String?> code) {
    showModalBottomSheet(context: context, builder: (context) {
       return Container(
         padding: const EdgeInsets.all(24),
         height: 400,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text('Pilih Aset Tersedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
             const SizedBox(height: 16),
             Expanded(
               child: ListView(
                 children: [
                   ListTile(
                     leading: const Icon(Icons.directions_car),
                     title: const Text('Suzuki APV 2012'),
                     subtitle: const Text('VHC-099'),
                     onTap: () {
                       id.value = 'AST-CAR-099'; name.value = 'Suzuki APV 2012'; code.value = 'VHC-099';
                       Navigator.pop(context);
                     },
                   ),
                   ListTile(
                     leading: const Icon(Icons.computer),
                     title: const Text('PC Desktop Lenovo ThinkCentre (Rusak Motherboard)'),
                     subtitle: const Text('IT-043'),
                     onTap: () {
                       id.value = 'AST-IT-043'; name.value = 'PC Desktop Lenovo ThinkCentre'; code.value = 'IT-043';
                       Navigator.pop(context);
                     },
                   ),
                 ],
               ),
             )
           ],
         ),
       );
    });
  }
}
