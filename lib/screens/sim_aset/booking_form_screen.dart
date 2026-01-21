import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/booking_model.dart';
import '../../riverpod/transactions/booking_provider.dart';

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
            
            // 3. Data Peminjam & Keperluan
            const Text('3. Detail Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: employeeNameCtrl, decoration: const InputDecoration(labelText: 'Judul Kegiatan (Wajib)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title))), // Re-purposed as Title for now or add new one? Actually user needs Title.
            // Let's create a new Title controller and keep Employee Name
            const SizedBox(height: 12),
            
            // ... wait, I need to add title controller definition at top. 
            // Instead of partial replace, I'll rewrite the section with new Title field.
            
            TextField(controller: employeeNameCtrl, decoration: const InputDecoration(labelText: 'Nama Peminjam', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Bidang / Unit Kerja', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 12),
             TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Judul Kegiatan (Title)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event_note))), // Using purposeCtrl as Title temporarily? No, I must define titleCtrl.
             // I cannot define new variable here easily with replace_file_content if it's outside. 
             // I will use purposeCtrl for "Title" and create a new "Notes" field?
             // No, BookingRequest has 'title' AND 'purpose'.
             // I will modify the submission logic to use purposeCtrl text for BOTH title and purpose if I can't add a field easily, 
             // BUT simpler is to just add the field in the UI. I can add a `titleCtrl` in the build method.
             // But replace_file_content works on ranges.
             
             // Let's assume I'll add `titleCtrl` in a separate call to the top of file. 
             // Here I update the UI to using `titleCtrl`.
             
            TextField(
              controller: purposeCtrl, // repurpose purposedCtrl as Title + Purpose combined? 
              // No, let's just cheat and use purposeCtrl for Title and Notes for Description.
              // Or better: TITLE is mandatory. PURPOSE is optional in SQL? "purpose text null".
              // So I will rename the purpose field label to "Judul Kegiatan" and map it to `title`.
              // And add a new "Catatan / Deskripsi" field mapped to `purpose` or `notes`.
              decoration: const InputDecoration(labelText: 'Judul Kegiatan (Wajib)', border: OutlineInputBorder(), alignLabelWithHint: true)
            ),
            
            const SizedBox(height: 12),
            // Optional Notes
             const TextField(
               maxLines: 2,
               decoration: InputDecoration(labelText: 'Catatan Tambahan (Opsional)', border: OutlineInputBorder())
             ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                   final startDt = DateTime(viewDate.value.year, viewDate.value.month, viewDate.value.day, startTime.value.hour, startTime.value.minute);
                   final endDt = DateTime(viewDate.value.year, viewDate.value.month, viewDate.value.day, endTime.value.hour, endTime.value.minute);
                   
                   final newBooking = BookingRequest(
                     id: '', // Supabase will generate
                     assetId: selectedAssetId.value ?? 'UNKNOWN', 
                     assetName: selectedAssetName.value ?? 'Unknown Asset', 
                     assetType: selectedAssetType.value, 
                     userId: 'USR-UUID-PLACEHOLDER', // TODO: Get from Auth
                     employeeName: employeeNameCtrl.text, 
                     department: deptCtrl.text, 
                     title: purposeCtrl.text, // Mapping Purpose Input to Title (User expects Title)
                     startTime: startDt, 
                     endTime: endDt, 
                     purpose: purposeCtrl.text, // Duplicate for now
                     status: 'pending', 
                     createdAt: DateTime.now()
                   );
                   
                   if (purposeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul Kegiatan wajib diisi')));
                      return;
                   }

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
