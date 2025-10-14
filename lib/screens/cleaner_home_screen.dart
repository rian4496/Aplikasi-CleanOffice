import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/logging/app_logger.dart';
import '../providers/riverpod/auth_providers.dart';
import '../providers/riverpod/cleaner_providers.dart';
import 'cleaner/request_detail_screen.dart';
import 'cleaner/create_cleaning_report_screen.dart';

final _logger = AppLogger('CleanerHomeScreen');

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final cleanerStats = ref.watch(cleanerStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petugas'),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                Navigator.pushNamed(context, AppConstants.profileRoute),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
            tooltip: 'Keluar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Permintaan Baru', icon: Icon(Icons.inbox)),
            Tab(text: 'Tugas Saya', icon: Icon(Icons.assignment)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Welcome & Stats Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo[700]!, Colors.indigo[500]!],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userProfile.when(
                        data: (profile) => Text(
                          'Selamat Datang,\n${profile?.displayName ?? "Petugas"}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        loading: () => const Text(
                          'Memuat...',
                          style: TextStyle(color: Colors.white),
                        ),
                        error: (error, stack) => const Text(
                          'Petugas',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat(
                          'EEEE, dd MMMM yyyy',
                          'id_ID',
                        ).format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // Statistics Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    0,
                    AppConstants.defaultPadding,
                    AppConstants.defaultPadding,
                  ),
                  child: cleanerStats.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Selesai',
                            stats['completed'].toString(),
                            Icons.check_circle,
                            AppConstants.successColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: _buildStatCard(
                            'Dalam Proses',
                            stats['inProgress'].toString(),
                            Icons.pending_actions,
                            AppConstants.warningColor,
                          ),
                        ),
                      ],
                    ),
                    loading: () => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Selesai',
                            '...',
                            Icons.check_circle,
                            AppConstants.successColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: _buildStatCard(
                            'Proses',
                            '...',
                            Icons.pending_actions,
                            AppConstants.warningColor,
                          ),
                        ),
                      ],
                    ),
                    error: (error, stack) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Selesai',
                            '0',
                            Icons.check_circle,
                            AppConstants.successColor,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: _buildStatCard(
                            'Proses',
                            '0',
                            Icons.pending_actions,
                            AppConstants.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAvailableRequestsTab(), _buildMyTasksTab()],
            ),
          ),
        ],
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
        backgroundColor: Colors.indigo[700],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRequestsTab() {
    final availableRequests = ref.watch(availableRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(availableRequestsProvider);
      },
      child: availableRequests.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Tidak ada permintaan baru',
              subtitle: 'Permintaan baru akan muncul di sini',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildMyTasksTab() {
    final myTasks = ref.watch(cleanerAssignedRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cleanerAssignedRequestsProvider);
      },
      child: myTasks.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(
              icon: Icons.assignment_outlined,
              title: 'Belum ada tugas',
              subtitle: 'Tugas yang Anda terima akan muncul di sini',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request, isMyTask: true);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request, {
    bool isMyTask = false,
  }) {
    final isUrgent = request['isUrgent'] as bool? ?? false;
    final status = request['status'] as String? ?? 'pending';
    final createdAt = (request['createdAt'] as Timestamp?)?.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RequestDetailScreen(requestId: request['id'] as String),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: isUrgent ? Colors.red[100] : Colors.indigo[100],
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Icon(
                      isUrgent ? Icons.priority_high : Icons.cleaning_services,
                      color: isUrgent ? Colors.red[700] : Colors.indigo[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['location'] as String? ??
                              'Lokasi tidak diketahui',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request['description'] as String? ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Text(
                        'URGEN',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (createdAt != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM HH:mm').format(createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  if (isMyTask)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
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
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppConstants.warningColor;
      case 'accepted':
        return AppConstants.infoColor;
      case 'in_progress':
        return AppConstants.primaryColor;
      case 'completed':
        return AppConstants.successColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'in_progress':
        return 'Dikerjakan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Future<void> _handleLogout() async {
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

    if (shouldLogout == true && mounted) {
      try {
        final authActions = ref.read(authActionsProvider.notifier);
        await authActions.logout();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        _logger.error('Logout error', e);
        if (!mounted) return;
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
