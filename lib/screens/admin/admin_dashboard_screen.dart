import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_status.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/supervisor/info_card.dart';
import '../../widgets/supervisor/report_list_item.dart';
import '../supervisor/verification_screen.dart';

/// Main dashboard screen untuk Supervisor
/// Menampilkan ringkasan statistik dan daftar laporan yang perlu diverifikasi
class SupervisorDashboardScreen extends ConsumerStatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  ConsumerState<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends ConsumerState<SupervisorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Supervisor'),
        backgroundColor: Colors.deepPurple[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
            tooltip: 'Notifikasi',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(needsVerificationReportsProvider);
          ref.invalidate(allReportsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple[700]!,
                      Colors.deepPurple[500]!,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.displayName ?? 'Supervisor',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: dashboardSummaryAsync.when(
                        data: (summary) => _buildSummaryCards(summary),
                        loading: () => _buildSummaryCardsLoading(),
                        error: (error, stack) => _buildErrorWidget(error),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: dashboardSummaryAsync.when(
                  data: (summary) => _buildQuickStats(summary),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 24),

              // Laporan Perlu Verifikasi Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Perlu Verifikasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all verification screen
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Recent Reports List
              needsVerificationAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Limit to 5 reports
                  final recentReports = reports.take(5).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentReports.length,
                    itemBuilder: (context, index) {
                      final report = recentReports[index];
                      return ReportListItem(
                        report: report,
                        onTap: () => _navigateToVerification(context, report),
                      );
                    },
                  );
                },
                loading: () => _buildReportsLoading(),
                error: (error, stack) => _buildErrorWidget(error),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to all reports view
        },
        icon: const Icon(Icons.view_list),
        label: const Text('Semua Laporan'),
        backgroundColor: Colors.deepPurple[700],
      ),
    );
  }

  Widget _buildSummaryCards(dynamic summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        InfoCard(
          title: 'Menunggu',
          value: summary.pendingCount.toString(),
          icon: Icons.schedule,
          color: Colors.orange,
          backgroundColor: Colors.white,
          onTap: () {
            // TODO: Filter by pending
          },
        ),
        InfoCard(
          title: 'Perlu Verifikasi',
          value: summary.needsVerificationCount.toString(),
          icon: Icons.pending_actions,
          color: Colors.blue,
          backgroundColor: Colors.white,
          onTap: () {
            // TODO: Navigate to verification list
          },
        ),
        InfoCard(
          title: 'Selesai Hari Ini',
          value: summary.completedTodayCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          backgroundColor: Colors.white,
          subtitle: '${summary.verifiedTodayCount} terverifikasi',
        ),
        InfoCard(
          title: 'Total Aktif',
          value: summary.totalActive.toString(),
          icon: Icons.trending_up,
          color: Colors.purple,
          backgroundColor: Colors.white,
          subtitle: '${summary.completionRate.toStringAsFixed(1)}% selesai',
        ),
      ],
    );
  }

  Widget _buildSummaryCardsLoading() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: const [
        InfoCard(
          title: 'Menunggu',
          value: '...',
          icon: Icons.schedule,
          color: Colors.orange,
          backgroundColor: Colors.white,
          isLoading: true,
        ),
        InfoCard(
          title: 'Perlu Verifikasi',
          value: '...',
          icon: Icons.pending_actions,
          color: Colors.blue,
          backgroundColor: Colors.white,
          isLoading: true,
        ),
        InfoCard(
          title: 'Selesai Hari Ini',
          value: '...',
          icon: Icons.check_circle,
          color: Colors.green,
          backgroundColor: Colors.white,
          isLoading: true,
        ),
        InfoCard(
          title: 'Total Aktif',
          value: '...',
          icon: Icons.trending_up,
          color: Colors.purple,
          backgroundColor: Colors.white,
          isLoading: true,
        ),
      ],
    );
  }

  Widget _buildQuickStats(dynamic summary) {
    final statusBreakdown = summary.statusBreakdown as Map<ReportStatus, int>;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breakdown Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ReportStatus.values.map((status) {
              final count = statusBreakdown[status] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(status.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(status.colorValue),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada laporan yang perlu diverifikasi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Semua laporan sudah ditangani! 🎉',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Container(
            height: 16,
            color: Colors.grey[300],
          ),
          subtitle: Container(
            height: 12,
            color: Colors.grey[200],
            margin: const EdgeInsets.only(top: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVerification(BuildContext context, report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(report: report),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Laporan'),
        content: const Text('Fitur filter akan segera tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
          ),
        ],
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
            child: const Text('KELUAR'),
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