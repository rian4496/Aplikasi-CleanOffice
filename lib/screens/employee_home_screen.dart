import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aplikasi_cleanoffice/models/report_model.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/employee_providers.dart';
import 'report_detail_screen.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  final _dateFormat = DateFormat('d MMM yyyy');

  String _formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  Widget _buildProgressItem(BuildContext context, String label, String value, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final user = FirebaseAuth.instance.currentUser;
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summaryAsync = ref.watch(employeeReportsSummaryProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Karyawan'),
        // Use theme's AppBar style, but override for a lighter look
        backgroundColor: AppTheme.primaryLight,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () => Navigator.pushNamed(context, '/employee/request'),
            tooltip: 'Minta Layanan',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/employee/requests'),
            tooltip: 'Riwayat',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      // backgroundColor is handled by theme
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeeReportsProvider);
            ref.invalidate(employeeReportsSummaryProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress status cards
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Add top padding
                  child: summaryAsync.when(
                    data: (summary) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressItem(
                          context,
                          'Terkirim',
                          summary.pending.toString(),
                          AppTheme.info,
                        ),
                        _buildProgressItem(
                          context,
                          'Dikerjakan',
                          summary.inProgress.toString(),
                          AppTheme.warning,
                        ),
                        _buildProgressItem(
                          context,
                          'Selesai',
                          summary.completed.toString(),
                          AppTheme.success,
                        ),
                      ],
                    ),
                    loading: () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressItem(context, 'Terkirim', '...', AppTheme.info),
                        _buildProgressItem(context, 'Dikerjakan', '...', AppTheme.warning),
                        _buildProgressItem(context, 'Selesai', '...', AppTheme.success),
                      ],
                    ),
                    error: (error, stack) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressItem(context, 'Terkirim', '0', AppTheme.info),
                        _buildProgressItem(context, 'Dikerjakan', '0', AppTheme.warning),
                        _buildProgressItem(context, 'Selesai', '0', AppTheme.success),
                      ],
                    ),
                  ),
                ),

                // Header dengan tombol Buat Laporan
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  // elevation, shape, color from CardTheme
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporkan Masalah Kebersihan',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/create_report'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onPrimary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Buat Laporan Baru',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Riwayat Laporan section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 8),
                          Text(
                            'Riwayat Laporan Anda',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Reports List
                      reportsAsync.when(
                        data: (reports) {
                          if (reports.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return _buildReportCard(context, report);
                            },
                          );
                        },
                        loading: () => _buildLoadingState(),
                        error: (error, stack) => _buildErrorState(context, error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_report_btn',
        onPressed: () {
          Navigator.pushNamed(context, '/create_report');
        },
        // backgroundColor and child color from theme
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(report.id),
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Laporan'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus laporan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('BATAL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('HAPUS', style: TextStyle(color: colorScheme.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          final actions = ref.read(employeeActionsProvider);
          await actions.deleteReport(report.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan dihapus'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menghapus: $e'),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        // elevation from CardTheme
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.cleaning_services_outlined,
              color: colorScheme.primary,
            ),
          ),
          title: Text(
            report.location,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_formatDate(report.date)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: report.status.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report.status.displayName,
              style: textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(
                  title: report.location,
                  date: _formatDate(report.date),
                  status: report.status.displayName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(
              'Belum ada laporan.',
              style: textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Buat laporan pertama Anda!',
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(employeeReportsProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('KELUAR', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}