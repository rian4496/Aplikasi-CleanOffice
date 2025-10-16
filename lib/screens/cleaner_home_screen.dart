import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/logging/app_logger.dart';
import '../core/theme/app_theme.dart'; // Impor AppTheme untuk warna status
import '../core/utils/date_formatter.dart';
import '../providers/riverpod/auth_providers.dart';
import '../providers/riverpod/cleaner_providers.dart';
import 'cleaner/request_detail_screen.dart';
import 'cleaner/create_cleaning_report_screen.dart';

final _logger = AppLogger('CleanerHomeScreen');

class CleanerHomeScreen extends ConsumerWidget {
  const CleanerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BARU: Ambil tema dan textTheme untuk digunakan di seluruh widget
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.profileRoute),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableRequestsProvider);
          ref.invalidate(cleanerStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(context, ref, textTheme),
                const SizedBox(height: 16),
                _buildStatisticsRow(ref, textTheme),
                const SizedBox(height: 24),
                _buildRequestsList(context, ref, textTheme),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCleaningReportScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildWelcomeCard(
      BuildContext context, WidgetRef ref, TextTheme textTheme) {
    final userProfile = ref.watch(currentUserProfileProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userProfile.when(
              data: (profile) => Text(
                'Selamat Datang,\n${profile?.displayName ?? "Petugas Kebersihan"}!',
                // DIUBAH: Menggunakan gaya dari TextTheme
                style: textTheme.headlineMedium,
              ),
              loading: () => const Text('Memuat...'),
              error: (err, stack) => const Text('Selamat Datang!'),
            ),
            const SizedBox(height: 8),
            Text(
              'Hari ini: ${DateFormatter.fullDate(DateTime.now())}',
              // DIUBAH: Menggunakan gaya dari TextTheme
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(WidgetRef ref, TextTheme textTheme) {
    final cleanerStats = ref.watch(cleanerStatsProvider);

    return cleanerStats.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: _buildStatisticCard(
              textTheme: textTheme,
              icon: Icons.check_circle,
              title: 'Selesai',
              value: stats['completed'].toString(),
              // DIUBAH: Menggunakan warna dari AppTheme
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatisticCard(
              textTheme: textTheme,
              icon: Icons.pending_actions,
              title: 'Dalam Proses',
              value: stats['inProgress'].toString(),
              // DIUBAH: Menggunakan warna dari AppTheme
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Text('Gagal memuat statistik'),
    );
  }

  Widget _buildStatisticCard({
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              // DIUBAH: Menggunakan gaya dari TextTheme, dengan warna custom
              style: textTheme.headlineMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              // DIUBAH: Menggunakan gaya dari TextTheme
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
      BuildContext context, WidgetRef ref, TextTheme textTheme) {
    final availableRequests = ref.watch(availableRequestsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permintaan Terbaru',
          // DIUBAH: Menggunakan gaya dari TextTheme
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        availableRequests.when(
          data: (requests) {
            if (requests.isEmpty) {
              return _buildEmptyState(
                icon: Icons.inbox_outlined,
                title: 'Tidak ada permintaan baru',
                subtitle: 'Permintaan baru akan muncul di sini',
              );
            }
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                // DIUBAH: Divider sekarang menggunakan tema
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestTile(context, request);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(ref, error.toString()),
        ),
      ],
    );
  }

  Widget _buildRequestTile(
      BuildContext context, Map<String, dynamic> request) {
    final theme = Theme.of(context); // Ambil tema untuk warna
    final isUrgent = request['isUrgent'] as bool? ?? false;

    return ListTile(
      leading: CircleAvatar(
        // DIUBAH: Menggunakan warna dari tema dengan opacity
        backgroundColor:
            isUrgent ? theme.colorScheme.error.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          isUrgent ? Icons.priority_high : Icons.cleaning_services,
          // DIUBAH: Menggunakan warna utama dari tema
          color: isUrgent ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
      ),
      title: Text(request['location'] as String? ?? 'Lokasi tidak diketahui'),
      subtitle: Text(
        request['description'] as String? ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RequestDetailScreen(requestId: request['id'] as String),
          ),
        );
      },
    );
  }
  
  // Widget _buildEmptyState dan _buildErrorState tetap sama (tidak perlu diubah)

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    // ... (kode tidak berubah)
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    // ... (kode tidak berubah)
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(availableRequestsProvider);
                ref.invalidate(cleanerAssignedRequestsProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // ... (kode tidak berubah)
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        final authActions = ref.read(authActionsProvider.notifier);
        await authActions.logout();
        
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        _logger.error('Logout error', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}