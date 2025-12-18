import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/booking_model.dart';
import '../../providers/transactions/booking_provider.dart';

class BookingFormScreen extends HookConsumerWidget {
  const BookingFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controllers
    final employeeNameCtrl = useTextEditingController();
    final deptCtrl = useTextEditingController();
    final purposeCtrl = useTextEditingController();
    
    // State
    final selectedAssetId = useState<String?>(null);
    final selectedAssetName = useState<String?>(null);
    final selectedAssetType = useState<String>('vehicle');
    
    final viewDate = useState(DateTime.now());
    final startTime = useState(const TimeOfDay(hour: 9, minute: 0));
    final endTime = useState(const TimeOfDay(hour: 12, minute: 0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Booking Aset Baru', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Pilih Aset
            const Text('1. Aset yang dipinjam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showAssetPicker(context, selectedAssetId, selectedAssetName, selectedAssetType),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: Icon(_getIconForType(selectedAssetType.value), color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedAssetName.value ?? 'Pilih Aset...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selectedAssetName.value == null ? Colors.grey : Colors.black87)),
                          if(selectedAssetName.value != null) Text('Unit: ${selectedAssetId.value}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Waktu Pemakaian
            const Text('2. Waktu Pemakaian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                       final d = await showDatePicker(context: context, initialDate: viewDate.value, firstDate: DateTime.now(), lastDate: DateTime(2025));
                       if(d!=null) viewDate.value = d;
                    },
                    child: Row(children: [const Icon(Icons.calendar_today, size: 18), const SizedBox(width: 12), Text(DateFormat('EEEE, dd MMMM yyyy').format(viewDate.value), style: const TextStyle(fontWeight: FontWeight.bold))]),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: startTime.value);
                            if(t!=null) startTime.value = t;
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Mulai Jam', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(startTime.value.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: endTime.value);
                            if(t!=null) endTime.value = t;
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Selesai Jam', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(endTime.value.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
             // 3. Detail Peminjam
            const Text('3. Data Peminjam & Keperluan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: employeeNameCtrl, decoration: const InputDecoration(labelText: 'Nama Peminjam', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Bidang / Unit Kerja', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 12),
            TextField(
              controller: purposeCtrl, 
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Keperluan (Jelaskan detail)', border: OutlineInputBorder(), alignLabelWithHint: true)
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                   // Mock Save
                   final startDt = DateTime(viewDate.value.year, viewDate.value.month, viewDate.value.day, startTime.value.hour, startTime.value.minute);
                   final endDt = DateTime(viewDate.value.year, viewDate.value.month, viewDate.value.day, endTime.value.hour, endTime.value.minute);
                   
                   final newBooking = BookingRequest(
                     id: 'BK-${DateTime.now().millisecondsSinceEpoch}', 
                     assetId: selectedAssetId.value ?? 'UNKNOWN', 
                     assetName: selectedAssetName.value ?? 'Unknown Asset', 
                     assetType: selectedAssetType.value, 
                     employeeId: 'EMP-XX', 
                     employeeName: employeeNameCtrl.text, 
                     department: deptCtrl.text, 
                     startTime: startDt, 
                     endTime: endDt, 
                     purpose: purposeCtrl.text, 
                     status: 'pending', 
                     createdAt: DateTime.now()
                   );
                   
                   ref.read(bookingListProvider.notifier).createBooking(newBooking);
                   context.pop();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil diajukan!')));
                }, 
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Ajukan Booking'),
              ),
            )
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if(type=='vehicle') return Icons.directions_car;
    if(type=='room') return Icons.meeting_room;
    return Icons.camera_alt;
  }

  void _showAssetPicker(BuildContext context, ValueNotifier<String?> id, ValueNotifier<String?> name, ValueNotifier<String> type) {
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
                     leading: const Icon(Icons.directions_car, color: Colors.blue),
                     title: const Text('Toyota Innova Reborn (DA 1234 A)'),
                     subtitle: const Text('Kendaraan Operasional'),
                     onTap: () {
                       id.value = 'AST-CAR-005'; name.value = 'Toyota Innova Reborn'; type.value = 'vehicle';
                       Navigator.pop(context);
                     },
                   ),
                   ListTile(
                     leading: const Icon(Icons.meeting_room, color: Colors.green),
                     title: const Text('Ruang Rapat Utama (Lt 2)'),
                     subtitle: const Text('Fasilitas Gedung'),
                     onTap: () {
                       id.value = 'AST-ROOM-101'; name.value = 'Ruang Rapat Utama'; type.value = 'room';
                       Navigator.pop(context);
                     },
                   ),
                    ListTile(
                     leading: const Icon(Icons.camera_alt, color: Colors.purple),
                     title: const Text('Drone DJI Mavic 3'),
                     subtitle: const Text('Peralatan Dokumentasi'),
                     onTap: () {
                       id.value = 'AST-EQP-010'; name.value = 'Drone DJI Mavic 3'; type.value = 'equipment';
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
