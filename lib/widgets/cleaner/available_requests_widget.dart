// lib/widgets/cleaner/available_requests_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../screens/shared/request_detail/request_detail_screen.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

/// Available Requests Widget untuk Cleaner Dashboard
/// 
/// Widget ini menampilkan list request yang berstatus pending dan bisa
/// di-self-assign oleh cleaner. Fitur:
/// - Show pending requests sorted by urgency
/// - Quick self-assign button
/// - Filter urgent/normal
/// - Empty state
/// - Pull to refresh
/// - Tap card untuk lihat detail
/// 
/// Usage:
/// ```dart
/// // Di cleaner home screen
/// AvailableRequestsWidget(
///   onRequestAssigned: () {
///     // Refresh dashboard atau navigate
///   },
/// )
/// ```
class AvailableRequestsWidget extends ConsumerStatefulWidget {
  /// Callback setelah request berhasil di-assign
  final VoidCallback? onRequestAssigned;

  const AvailableRequestsWidget({
    super.key,
    this.onRequestAssigned,
  });

  @override
  ConsumerState<AvailableRequestsWidget> createState() =>
      _AvailableRequestsWidgetState();
}

class _AvailableRequestsWidgetState
    extends ConsumerState<AvailableRequestsWidget> {
  bool _showUrgentOnly = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan filter
        _buildHeader(),
        const SizedBox(height: 16),
        
        // Request list
        _buildRequestList(),
      ],
    );
  }

  /// Build header dengan title dan filter toggle
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Request Tersedia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Filter chip - Urgent only
        FilterChip(
          label: const Text(
            'Urgent',
            style: TextStyle(fontSize: 12),
          ),
          selected: _showUrgentOnly,
          onSelected: (selected) {
            setState(() => _showUrgentOnly = selected);
          },
          backgroundColor: Colors.white,
          selectedColor: AppTheme.error.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.error,
          side: BorderSide(
            color: _showUrgentOnly
                ? AppTheme.error
                : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ],
    );
  }

  /// Build request list
  Widget _buildRequestList() {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        // Filter urgent if needed
        final filtered = _showUrgentOnly
            ? requests.where((r) => r.isUrgent).toList()
            : requests;

        // Sort: urgent first, then by created date
        filtered.sort((a, b) {
          if (a.isUrgent && !b.isUrgent) return -1;
          if (!a.isUrgent && b.isUrgent) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingRequestsProvider);
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
                onPressed: () => ref.invalidate(pendingRequestsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build request card dengan quick action
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
          side: request.isUrgent
              ? BorderSide(color: AppTheme.error, width: 2)
              : BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(request.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: request.isUrgent
                  ? LinearGradient(
                      colors: [
                        AppTheme.error.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location + Urgent badge
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
                      if (request.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.priority_high,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  // Description
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Requested by + Time
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.requestedByName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.shortDate(request.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Preferred time (jika ada)
                  if (request.preferredDateTime != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Diinginkan: ${_formatPreferredTime(request.preferredDateTime!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Action button - Self Assign
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSelfAssign(request),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Ambil Tugas Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: _showUrgentOnly ? Icons.priority_high : Icons.check_circle,
      title: _showUrgentOnly
          ? 'Tidak ada request urgent'
          : 'Semua request sudah diambil',
      subtitle: 'Request baru akan muncul di sini',
    );
  }

  /// Handle self assign request
  Future<void> _handleSelfAssign(Request request) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ambil Tugas'),
        content: Text(
          'Ambil tugas pembersihan di ${request.location}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
            ),
            child: const Text('Ya, Ambil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref
          .read(requestActionsProvider)
          .selfAssignRequest(request.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil mengambil tugas: ${request.location}'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Callback
      widget.onRequestAssigned?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil tugas: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Navigate to detail screen
  void _navigateToDetail(String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }

  /// Format preferred time
  String _formatPreferredTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final requestDate = DateTime(time.year, time.month, time.day);

    String dateStr;
    if (requestDate == today) {
      dateStr = 'Hari ini';
    } else if (requestDate == tomorrow) {
      dateStr = 'Besok';
    } else {
      dateStr = DateFormatter.shortDate(time);
    }

    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return '$dateStr, $timeStr';
  }
}