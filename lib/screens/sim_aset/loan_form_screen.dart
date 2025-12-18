import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/loan_model.dart';
import '../../models/asset.dart';
import '../../providers/transactions/loan_provider.dart';
import '../../providers/riverpod/asset_providers.dart';

class LoanFormScreen extends HookConsumerWidget {
  final String? id; // If editing
  const LoanFormScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller
    final borrowerNameCtrl = useTextEditingController();
    final borrowerAddressCtrl = useTextEditingController();
    final borrowerContactCtrl = useTextEditingController();
    final proposalNumberCtrl = useTextEditingController();
    
    // State
    final selectedAssetId = useState<String?>(null);
    final selectedAssetName = useState<String?>(null);
    final loanDuration = useState(1); // Years
    final startDate = useState(DateTime.now());
    
    // File Upload State (Placeholder)
    final applicationLetterInfo = useState<String?>('Belum ada file dipilih');
    final agreementDocInfo = useState<String?>('Belum ada file dipilih');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(id == null ? 'Buat Permohonan Pinjam Pakai' : 'Edit Permohonan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Form
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Section 1: Data Peminjam
                    _buildSectionHeader('1. Data Peminjam (Instansi/Pihak Ketiga)'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          _buildTextField('Nomor Surat Permohonan', proposalNumberCtrl, hint: 'Contoh: 028/DISHUB/XI/2024'),
                          const SizedBox(height: 16),
                          _buildTextField('Nama Peminjam / Instansi', borrowerNameCtrl, hint: 'Contoh: Dinas Perhubungan Kab. Banjar'),
                          const SizedBox(height: 16),
                          _buildTextField('Alamat Peminjam', borrowerAddressCtrl, hint: 'Alamat lengkap instansi...'),
                          const SizedBox(height: 16),
                          _buildTextField('Kontak penanggung Jawab', borrowerContactCtrl, hint: 'No. HP / Telp'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Objek Pinjam Pakai
                    _buildSectionHeader('2. Objek Pinjam Pakai'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pilih Aset', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              _showAssetPicker(context, ref, selectedAssetId, selectedAssetName);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedAssetName.value ?? 'Pilih aset dari Master Data...',
                                    style: TextStyle(color: selectedAssetName.value == null ? Colors.grey : Colors.black87),
                                  ),
                                  const Icon(Icons.search, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          if (selectedAssetId.value != null) ...[
                            const SizedBox(height: 16),
                            Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                               child: const Row(children: [
                                 Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                 SizedBox(width: 8),
                                 Text('Kondisi Aset Tercatat: BAIK', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                               ]),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 3: Jangka Waktu
                   _buildSectionHeader('3. Jangka Waktu Peminjaman'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text('Tanggal Mulai', style: TextStyle(fontWeight: FontWeight.w600)),
                                 const SizedBox(height: 8),
                                 InkWell(
                                   onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context, 
                                        initialDate: startDate.value, 
                                        firstDate: DateTime.now(), 
                                        lastDate: DateTime(2030)
                                      );
                                      if (picked != null) startDate.value = picked;
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                     child: Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text(DateFormat('dd MMM yyyy').format(startDate.value))]),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text('Durasi (Tahun)', style: TextStyle(fontWeight: FontWeight.w600)),
                                 const SizedBox(height: 8),
                                 DropdownButtonFormField<int>(
                                   value: loanDuration.value,
                                   decoration: InputDecoration(
                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                   ),
                                   items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text('$e Tahun'))).toList(),
                                   onChanged: (val) => loanDuration.value = val!,
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Dokumen Pendukung
                    _buildSectionHeader('4. Dokumen Pendukung'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          _buildFileUpload('Surat Permohonan (PDF)', applicationLetterInfo),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildFileUpload('Draft Naskah Perjanjian (PDF)', agreementDocInfo),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Summary & Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                     Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Ringkasan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                           const Divider(),
                           const SizedBox(height: 12),
                           _buildSummaryRow('Tanggal Berakhir:', DateFormat('dd MMM yyyy').format(startDate.value.add(Duration(days: 365 * loanDuration.value)))),
                           const SizedBox(height: 8),
                           _buildSummaryRow('Status Awal:', 'DRAFT (Konsep)'),
                           const SizedBox(height: 24),
                           SizedBox(
                             width: double.infinity,
                             child: FilledButton(
                               onPressed: () {
                                 // Save Action
                                 final newLoan = LoanRequest(
                                   id: 'LN-${DateTime.now().millisecondsSinceEpoch}', 
                                   requestNumber: proposalNumberCtrl.text, 
                                   borrowerName: borrowerNameCtrl.text, 
                                   borrowerAddress: borrowerAddressCtrl.text, 
                                   borrowerContact: borrowerContactCtrl.text, 
                                   assetId: selectedAssetId.value ?? '', 
                                   assetName: selectedAssetName.value ?? 'Unknown', 
                                   assetCondition: 'Baik', 
                                   startDate: startDate.value, 
                                   durationYears: loanDuration.value, 
                                   endDate: startDate.value.add(Duration(days: 365 * loanDuration.value)), 
                                   status: 'draft', 
                                   createdAt: DateTime.now()
                                 );
                                 
                                 ref.read(loanListProvider.notifier).createLoan(newLoan);
                                 context.pop();
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permohonan berhasil dibuat')));
                               }, 
                               style: FilledButton.styleFrom(
                                 backgroundColor: AppTheme.primary,
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                               ),
                               child: const Text('Simpan Permohonan'),
                             ),
                           ),
                         ],
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFileUpload(String label, ValueNotifier<String?> fileInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
           children: [
             ElevatedButton.icon(
               onPressed: () {
                 // Mock File Picker
                 fileInfo.value = 'dokumen_terpilih.pdf (1.2 MB)';
               }, 
               icon: const Icon(Icons.upload_file, size: 18), 
               label: const Text('Upload File'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: Colors.blue,
                 elevation: 0,
                 side: BorderSide(color: Colors.blue.shade200),
               ),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Text(fileInfo.value ?? '', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
             ),
           ],
        ),
      ],
    );
  }

  void _showAssetPicker(BuildContext context, WidgetRef ref, ValueNotifier<String?> id, ValueNotifier<String?> name) {
    showDialog(context: context, builder: (context) {
       return Dialog(
         child: Container(
           width: 600,
           height: 500,
           padding: const EdgeInsets.all(24),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('Pilih Aset Tersedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               const SizedBox(height: 16),
               TextField(
                 decoration: InputDecoration(
                   hintText: 'Cari aset berdasarkan nama atau kode...', 
                   prefixIcon: const Icon(Icons.search), 
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                 ),
                 onChanged: (val) {
                   // Implement search filter inside list if needed
                 },
               ),
               const SizedBox(height: 16),
               Expanded(
                 child: Consumer(
                   builder: (context, ref, _) {
                     final assetsAsync = ref.watch(allAssetsProvider);
                     return assetsAsync.when(
                       data: (assets) {
                         if (assets.isEmpty) return const Center(child: Text('Tidak ada data aset'));
                         
                         return ListView.separated(
                           itemCount: assets.length,
                           separatorBuilder: (_,__) => const Divider(),
                           itemBuilder: (context, index) {
                             final asset = assets[index];
                             return ListTile(
                               title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                               subtitle: Text('${asset.qrCode} • ${asset.category}'),
                               trailing: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   _buildAssetConditionBadge(asset.condition),
                                   const SizedBox(width: 8),
                                   ElevatedButton(
                                     onPressed: () {
                                       id.value = asset.id;
                                       name.value = asset.name; // Could capture more info like condition
                                       Navigator.pop(context);
                                     }, 
                                     child: const Text('Pilih'),
                                   ),
                                 ],
                               ),
                             );
                           },
                         );
                       },
                       loading: () => const Center(child: CircularProgressIndicator()),
                       error: (e, s) => Center(child: Text('Error: $e')),
                     );
                   }
                 ),
               ),
             ],
           ),
         ),
       );
    });
  }
  
  Widget _buildAssetConditionBadge(AssetCondition status) {
    Color color;
    String label;
    switch(status) {
      case AssetCondition.good: color = Colors.green; label = 'Baik'; break;
      case AssetCondition.fair: color = Colors.orange; label = 'Cukup'; break;
      case AssetCondition.poor: color = Colors.amber; label = 'Kurang'; break;
      case AssetCondition.broken: color = Colors.red; label = 'Rusak'; break;
      default: color = Colors.grey; label = status.toString();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
