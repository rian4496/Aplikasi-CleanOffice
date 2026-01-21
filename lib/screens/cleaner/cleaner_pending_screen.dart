import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../riverpod/cleaner_providers.dart';
import 'package:go_router/go_router.dart';

class CleanerPendingScreen extends HookConsumerWidget {
  const CleanerPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Pending Cleaning Reports (Available to claim)
    final pendingReportsAsync = ref.watch(pendingReportsProvider);
    
    // 2. Watch My Inventory Requests (Placeholder provider for now)
    // We'll need to create a provider for this if it doesn't exist.
    // final inventoryRequestsAsync = ref.watch(cleanerInventoryRequestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.modernBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Inbox & Tugas',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.inter(),
            tabs: const [
              Tab(text: 'Laporan Kebersihan'),
              Tab(text: 'Permintaan Alat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Cleaning Reports
            _buildCleaningReportsTab(context, ref, pendingReportsAsync),
            
            // Tab 2: Inventory Requests (Placeholder for now)
            _buildInventoryRequestsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCleaningReportsTab(BuildContext context, WidgetRef ref, AsyncValue<List<dynamic>> reportsAsync) {
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Tidak ada tugas baru', style: GoogleFonts.inter(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                   report.title,
                   style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                         const Icon(Icons.place_outlined, size: 14, color: Colors.grey),
                         const SizedBox(width: 4),
                         Text(report.location, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange[100]!),
                      ),
                      child: Text(
                        'Menunggu Petugas',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                     // Claim Action
                     final actions = ref.read(cleanerActionsProvider.notifier);
                     await actions.acceptReport(report.id);
                     ref.invalidate(pendingReportsProvider);
                     ref.invalidate(cleanerActiveReportsProvider);
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas diambil!')));
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Ambil'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInventoryRequestsTab(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(cleanerAssignedRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada permintaan alat',
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                     context.push('/console/cleaner/create_request');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Permintaan Baru'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                title: Text(request.location, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Text(request.description, style: GoogleFonts.inter(color: Colors.grey[600])),
                trailing: _buildRequestStatusChip(request.status.displayName),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildRequestStatusChip(String status) {
    Color color;
    switch(status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
