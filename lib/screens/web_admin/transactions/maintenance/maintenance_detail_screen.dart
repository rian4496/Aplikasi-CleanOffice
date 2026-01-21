import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final String id;
  const MaintenanceDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(maintenanceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tiket', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (requests) {
          final request = requests.firstWhere(
            (r) => r.id == id, 
            orElse: () => throw Exception('Tiket tidak ditemukan'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status Banner
                _buildStatusBanner(request),
                const SizedBox(height: 24),

                // 2. Info Cards
                Text('Informasi Masalah', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(request.issueTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         Text(request.issueDescription ?? 'Tidak ada deskripsi detail.', style: TextStyle(color: Colors.grey[700], height: 1.5)),
                         const Divider(height: 32),
                         Row(
                           children: [
                             _buildDetailItem(Icons.inventory_2_outlined, 'Aset', request.assetName ?? 'Unknown Asset'),
                             const SizedBox(width: 32),
                             _buildDetailItem(Icons.calendar_today, 'Tanggal Lapor', DateFormat('dd MMM yyyy').format(request.createdAt ?? DateTime.now())),
                           ],
                         )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Technical Actions (Assign / Update)
                if (request.status != 'completed') ...[
                   Text('Tindakan Teknisi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   Card(
                     child: Padding(
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         children: [
                            if (request.status == 'reported')
                              ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person_add, color: Colors.white)),
                                title: const Text('Assign Teknisi'),
                                subtitle: const Text('Tugaskan teknisi untuk menangani tiket ini.'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  // Mock update to assigned
                                  _updateStatus(context, ref, request.id, 'assigned');
                                },
                              ),
                            if (request.status == 'assigned')
                              ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.build, color: Colors.white)),
                                title: const Text('Mulai Pengerjaan (In Progress)'),
                                subtitle: const Text('Tandai tiket sedang dikerjakan.'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                   _updateStatus(context, ref, request.id, 'in_progress');
                                },
                              ),
                            if (request.status == 'in_progress')
                              ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                                title: const Text('Selesaikan Tiket'),
                                subtitle: const Text('Tandai tiket sebagai selesai.'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                   _updateStatus(context, ref, request.id, 'completed');
                                },
                              ),
                         ],
                       ),
                     ),
                   ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, String status) async {
     try {
       await ref.read(maintenanceRepositoryProvider).updateStatus(id, status);
       ref.invalidate(maintenanceListProvider);
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
     } catch(e) {
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
     }
  }

  Widget _buildStatusBanner(MaintenanceRequest req) {
    Color bg;
    IconData icon;
    String text;

    if (req.priority == 'urgent' && req.status != 'completed') {
       bg = Colors.red;
       icon = Icons.warning;
       text = 'TIKET PRIORITAS TINGGI (URGENT)';
    } else {
       switch(req.status) {
         case 'completed': bg = Colors.green; icon = Icons.check_circle; text = 'TIKET SELESAI'; break;
         case 'in_progress': bg = Colors.orange; icon = Icons.timelapse; text = 'SEDANG DIPROSES'; break;
         default: bg = Colors.blue; icon = Icons.info; text = 'STATUS: ${req.status.toUpperCase()}';
       }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
     return Row(
       children: [
         Icon(icon, size: 20, color: Colors.grey),
         const SizedBox(width: 8),
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
             Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
           ],
         )
       ],
     );
  }
}
