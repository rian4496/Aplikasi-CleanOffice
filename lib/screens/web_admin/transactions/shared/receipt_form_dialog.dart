import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/terbilang_helper.dart';
import '../../../../services/receipt_generator_service.dart';

class ReceiptFormDialog extends HookWidget {
  final Map<String, dynamic> initialData;

  const ReceiptFormDialog({
    super.key,
    this.initialData = const {},
  });

  @override
  Widget build(BuildContext context) {
    // Controllers
    final receivedFromController = useTextEditingController(text: initialData['receivedFrom'] ?? '');
    final amountController = useTextEditingController(text: (initialData['amount'] ?? 0).toString());
    final descriptionController = useTextEditingController(text: initialData['description'] ?? '');
    
    // Signatories
    final kpaNameController = useTextEditingController(text: 'Ir. HUSIN NAFARIN, MS'); // Default from Screenshot
    final kpaNipController = useTextEditingController(text: '19630127 199103 1 004');
    final treasurerNameController = useTextEditingController(text: 'JAPATAR SIMATUPANG, A.Md');
    final treasurerNipController = useTextEditingController(text: '19581218 199102 1 001');
    final recipientNameController = useTextEditingController(text: 'AHMAD RIPANI'); // Placeholder
    
    final date = useState(DateTime.now());
    final isGenerating = useState(false);
    final terbilang = useState('');

    // Update Terbilang when amount changes
    useEffect(() {
      void listener() {
        final val = double.tryParse(amountController.text) ?? 0;
        terbilang.value = TerbilangHelper.convert(val);
      }
      amountController.addListener(listener);
      listener(); // Initial
      return () => amountController.removeListener(listener);
    }, [amountController]);

    Future<void> handleGenerate() async {
      isGenerating.value = true;
      try {
        await ReceiptGeneratorService.generateReceipt({
          'receivedFrom': receivedFromController.text,
          'amount': double.tryParse(amountController.text) ?? 0,
          'amountInWords': terbilang.value,
          'description': descriptionController.text,
          'date': date.value,
          'location': 'Banjarbaru',
          'kpaName': kpaNameController.text,
          'kpaNip': kpaNipController.text,
          'treasurerName': treasurerNameController.text,
          'treasurerNip': treasurerNipController.text,
          'recipientName': recipientNameController.text,
        });
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kuitansi berhasil di-generate!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isGenerating.value = false;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Cetak Kuitansi', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                 IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
               ],
             ),
             const Divider(height: 32),
             
             Expanded(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // 1. Transaction Info
                     Text('Info Transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                     const SizedBox(height: 16),
                     
                     _buildTextField('Sudah Terima Dari', receivedFromController),
                     const SizedBox(height: 12),
                     
                     Row(
                       children: [
                         Expanded(child: _buildTextField('Jumlah Uang (Rp)', amountController, isNumber: true)),
                         const SizedBox(width: 16),
                         Expanded(
                           child: InkWell(
                             onTap: () async {
                               final picked = await showDatePicker(
                                 context: context,
                                 initialDate: date.value,
                                 firstDate: DateTime(2000),
                                 lastDate: DateTime(2100),
                               );
                               if (picked != null) date.value = picked;
                             },
                             child: InputDecorator(
                               decoration: const InputDecoration(labelText: 'Tanggal Kuitansi', border: OutlineInputBorder()),
                               child: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(date.value)),
                             ),
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Container(
                       padding: const EdgeInsets.all(12),
                       width: double.infinity,
                       color: Colors.grey[100],
                       child: Text(
                         'Terbilang: ${terbilang.value} RUPIAH',
                         style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                       ),
                     ),
                     const SizedBox(height: 12),
                     
                     _buildTextField('Untuk Keperluan', descriptionController, maxLines: 3),
                     
                     const SizedBox(height: 24),
                     
                     // 2. Signatories
                     Text('Penandatangan', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                     const SizedBox(height: 16),
                     
                     Row(
                       children: [
                         Expanded(child: _buildTextField('Nama KPA', kpaNameController)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildTextField('NIP KPA', kpaNipController)),
                       ],
                     ),
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(child: _buildTextField('Nama Bendahara', treasurerNameController)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildTextField('NIP Bendahara', treasurerNipController)),
                       ],
                     ),
                      const SizedBox(height: 12),
                     _buildTextField('Nama Penerima', recipientNameController),
                   ],
                 ),
               ),
             ),
             
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: isGenerating.value ? null : handleGenerate,
                 icon: isGenerating.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.print),
                 label: Text(isGenerating.value ? 'Generating...' : 'Generate Excel Kuitansi'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primary,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
