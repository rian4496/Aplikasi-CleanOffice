// lib/screens/cleaner/pending_reports_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/cleaner/cleaner_report_card.dart'; // <-- Gunakan widget baru
import '../cleaner/report_detail_cleaner_screen.dart';

class PendingReportsListScreen extends ConsumerWidget {
  const PendingReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil provider "Laporan Masuk"
    final pendingReports = ref.watch(pendingReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Masuk'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: pendingReports.when(
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyStateWidget.custom(
              icon: Icons.inbox_outlined,
              title: 'Belum ada laporan masuk',
              subtitle: 'Laporan dari karyawan akan muncul di sini',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pendingReportsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return CleanerReportCard( // <-- Gunakan widget baru
                  report: report,
                  animationIndex: index,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CleanerReportDetailScreen(reportId: report.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}