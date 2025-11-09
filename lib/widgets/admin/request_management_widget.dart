// lib/widgets/admin/request_management_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

/// Request Management Widget untuk Admin Dashboard
/// 
/// Widget ini menampilkan semua request dalam sistem dengan fitur:
/// - Statistics summary (pending, assigned, in_progress, completed)
/// - Filter by status
/// - Assign/reassign cleaner
/// - Force cancel request
/// - Search functionality
/// - Pull to refresh
/// 
/// Usage:
/// ```dart
/// // Di admin home screen
/// RequestManagementWidget(
///   onRequestUpdated: () {
///     // Refresh dashboard
///   },
/// )
/// ```
class RequestManagementWidget extends ConsumerStatefulWidget {
  /// Callback setelah request di-update (assign/cancel)
  final VoidCallback? onRequestUpdated;

  const RequestManagementWidget({
    super.key,
    this.onRequestUpdated,
  });

  @override
  ConsumerState<RequestManagementWidget> createState() =>
      _RequestManagementWidgetState();
}

class _RequestManagementWidgetState
    extends ConsumerState<RequestManagementWidget> {
  RequestStatus? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Manajemen Request',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Statistics
        _buildStatistics(),
        const SizedBox(height: 20),
        
        // Filter & Search
        _buildFilters(),
        const SizedBox(height: 16),
        
        // Request list
        _buildRequestList(),
      ],
    );
  }

  /// Build statistics summary
  Widget _buildStatistics() {
    final requestsAsync = ref.watch(allRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final pending = requests
            .where((r) => r.status == RequestStatus.pending)
            .length;
        final assigned = requests
            .where((r) => r.status == RequestStatus.assigned)
            .length;
        final inProgress = requests
            .where((r) => r.status == RequestStatus.inProgress)
            .length;
        final completed = requests
            .where((r) => r.status == RequestStatus.completed)
            .length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Pending',
                value: pending.toString(),
                color: AppTheme.warning,
                icon: Icons.pending,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Ditugaskan',
                value: assigned.toString(),
                color: AppTheme.secondary,
                icon: Icons.assignment_ind,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Proses',
                value: inProgress.toString(),
                color: AppTheme.info,
                icon: Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Selesai',
                value: completed.toString(),
                color: AppTheme.success,
                icon: Icons.check_circle,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  /// Build single stat card
  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
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
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Build filters (status dropdown + search)
  Widget _buildFilters() {
    return Row(
      children: [
        // Status filter dropdown
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RequestStatus?>(
                value: _selectedFilter,
                isExpanded: true,
                hint: const Text('Filter Status'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Status'),
                  ),
                  ...RequestStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusLabel(status)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Search field
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari lokasi...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
        ),
      ],
    );
  }

  /// Build request list
  Widget _buildRequestList() {
    final requestsAsync = ref.watch(allRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final filtered = _applyFilters(requests);

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allRequestsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final request = filtered[index];
              return _buildRequestCard(request, index);
            },
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat request',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(allRequestsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Apply filters (status + search)
  List<Request> _applyFilters(List<Request> requests) {
    var filtered = requests;

    // Filter by status
    if (_selectedFilter != null) {
      filtered = filtered.where((r) => r.status == _selectedFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final location = r.location.toLowerCase();
        final description = r.description.toLowerCase();
        final requester = r.requestedByName.toLowerCase();
        return location.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            requester.contains(_searchQuery);
      }).toList();
    }

    // Sort by created date (latest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Build request card dengan admin actions
  Widget _buildRequestCard(Request request, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(request.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location + Status badge + Urgent badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (request.isUrgent) _buildUrgentBadge(),
                    const SizedBox(width: 8),
                    _buildStatusChip(request.status),
                  ],
                ),
                
                // Requester info
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Pemohon: ${request.requestedByName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.shortDate(request.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                // Assignee (jika ada)
                if (request.assignedTo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.cleaning_services, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Petugas: ${request.assignedToName ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Admin actions (jika request aktif)
                if (request.isActive) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      // Assign/Reassign button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAssignCleanerDialog(request),
                          icon: Icon(
                            request.assignedTo != null
                                ? Icons.swap_horiz
                                : Icons.person_add,
                            size: 16,
                          ),
                          label: Text(
                            request.assignedTo != null
                                ? 'Reassign'
                                : 'Assign',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondary,
                            side: const BorderSide(color: AppTheme.secondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Cancel button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleForceCancel(request),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(RequestStatus status) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Build urgent badge
  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'URGENT',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.inbox,
      title: _searchQuery.isNotEmpty
          ? 'Tidak ada request yang sesuai'
          : 'Belum ada request',
      subtitle: 'Coba ubah filter atau kata kunci pencarian',
    );
  }

  /// Show assign cleaner dialog
  Future<void> _showAssignCleanerDialog(Request request) async {
    final cleanersAsync = ref.read(availableCleanersProvider);
    
    await cleanersAsync.when(
      data: (cleaners) async {
        if (cleaners.isEmpty) {
          _showSnackBar('Tidak ada cleaner tersedia', isError: true);
          return;
        }

        final selectedCleaner = await showDialog<CleanerProfile>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              request.assignedTo != null
                  ? 'Reassign Cleaner'
                  : 'Assign Cleaner',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cleaners.length,
                itemBuilder: (context, index) {
                  final cleaner = cleaners[index];
                  final isCurrentAssignee = cleaner.id == request.assignedTo;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentAssignee
                          ? AppTheme.success
                          : AppTheme.secondary,
                      child: Text(cleaner.name[0].toUpperCase()),
                    ),
                    title: Text(cleaner.name),
                    subtitle: Text('${cleaner.activeTaskCount} tugas aktif'),
                    trailing: isCurrentAssignee
                        ? const Icon(Icons.check_circle, color: AppTheme.success)
                        : null,
                    onTap: isCurrentAssignee
                        ? null
                        : () => Navigator.pop(context, cleaner),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        );

        if (selectedCleaner == null) return;

        try {
          final requestService = ref.read(requestServiceProvider);
          final currentUser = FirebaseAuth.instance.currentUser;
          
          if (currentUser == null) {
            _showSnackBar('User tidak ditemukan', isError: true);
            return;
          }

          await requestService.adminAssignRequest(
            requestId: request.id,
            cleanerId: selectedCleaner.id,
            cleanerName: selectedCleaner.name,
            adminId: currentUser.uid,
          );

          _showSnackBar(
            'Request berhasil di-assign ke ${selectedCleaner.name}',
            isError: false,
          );
          
          widget.onRequestUpdated?.call();
        } catch (e) {
          _showSnackBar(
            'Gagal assign request: ${e.toString()}',
            isError: true,
          );
        }
      },
      loading: () {
        _showSnackBar('Memuat data cleaner...', isError: false);
      },
      error: (e, _) {
        _showSnackBar('Gagal memuat data cleaner', isError: true);
      },
    );
  }

  /// Handle force cancel request
  Future<void> _handleForceCancel(Request request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Request'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan request di ${request.location}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(requestActionsProvider).cancelRequest(request.id);
      
      _showSnackBar('Request berhasil dibatalkan', isError: false);
      widget.onRequestUpdated?.call();
    } catch (e) {
      _showSnackBar('Gagal membatalkan request: $e', isError: true);
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Navigate to detail
  void _navigateToDetail(String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppTheme.warning;
      case RequestStatus.assigned:
        return AppTheme.secondary;
      case RequestStatus.inProgress:
        return AppTheme.info;
      case RequestStatus.completed:
        return AppTheme.success;
      case RequestStatus.cancelled:
        return AppTheme.error;
    }
  }

  /// Get status label
  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.assigned:
        return 'Ditugaskan';
      case RequestStatus.inProgress:
        return 'Proses';
      case RequestStatus.completed:
        return 'Selesai';
      case RequestStatus.cancelled:
        return 'Batal';
    }
  }
}