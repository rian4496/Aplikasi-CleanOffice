import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';

final _logger = AppLogger('RequestDetailScreen');

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestByIdProvider(widget.requestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permintaan'),
        backgroundColor: Colors.indigo[700],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return _buildNotFoundState();
          }
          return _buildContent(request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> request) {
    final status = request['status'] as String? ?? 'pending';
    final isUrgent = request['isUrgent'] as bool? ?? false;
    final currentUserId = ref.watch(currentUserIdProvider);
    final assignedCleanerId = request['cleanerId'] as String?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(request, status, isUrgent),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image if exists
                if (request['imageUrl'] != null &&
                    (request['imageUrl'] as String).isNotEmpty)
                  _buildImage(request['imageUrl'] as String),

                if (request['imageUrl'] != null)
                  const SizedBox(height: AppConstants.defaultPadding),

                // Info sections
                _buildInfoSection(
                  'Lokasi',
                  request['location'] as String? ?? '-',
                  Icons.location_on,
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                _buildInfoSection(
                  'Deskripsi',
                  request['description'] as String? ?? '-',
                  Icons.description,
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                _buildInfoSection(
                  'Pelapor',
                  request['userName'] as String? ?? '-',
                  Icons.person,
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                if (request['userEmail'] != null)
                  _buildInfoSection(
                    'Email',
                    request['userEmail'] as String,
                    Icons.email,
                  ),

                if (request['userEmail'] != null)
                  const SizedBox(height: AppConstants.defaultPadding),

                _buildInfoSection(
                  'Dibuat',
                  _formatDateTime(request['createdAt']),
                  Icons.calendar_today,
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Timeline
                _buildTimeline(request),

                const SizedBox(height: AppConstants.largePadding),

                // Action Buttons
                _buildActionButtons(status, assignedCleanerId, currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Map<String, dynamic> request,
    String status,
    bool isUrgent,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.priority_high, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request['location'] as String? ?? 'Lokasi tidak diketahui',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 64)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTimeline(Map<String, dynamic> request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem(
              'Dibuat',
              request['createdAt'],
              Icons.add_circle_outline,
              Colors.blue,
            ),
            if (request['acceptedAt'] != null)
              _buildTimelineItem(
                'Diterima',
                request['acceptedAt'],
                Icons.check_circle_outline,
                Colors.green,
              ),
            if (request['startedAt'] != null)
              _buildTimelineItem(
                'Mulai Dikerjakan',
                request['startedAt'],
                Icons.play_circle_outline,
                Colors.orange,
              ),
            if (request['completedAt'] != null)
              _buildTimelineItem(
                'Selesai',
                request['completedAt'],
                Icons.done_all,
                Colors.purple,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    dynamic timestamp,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    String timeText = '-';
    if (timestamp != null && timestamp is Timestamp) {
      timeText = DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    String status,
    String? assignedCleanerId,
    String? currentUserId,
  ) {
    // If completed, no actions
    if (status == 'completed') {
      return _buildInfoCard(
        'Permintaan ini sudah diselesaikan',
        Icons.check_circle,
        AppConstants.successColor,
      );
    }

    // If pending, show Accept button
    if (status == 'pending') {
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _acceptRequest(),
        icon: const Icon(Icons.check),
        label: const Text('Terima Permintaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
        ),
      );
    }

    // If accepted/in_progress and assigned to current user
    if (assignedCleanerId == currentUserId) {
      if (status == 'accepted') {
        return ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _startRequest(),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Mulai Pengerjaan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.warningColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
          ),
        );
      } else if (status == 'in_progress') {
        return ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _completeRequest(),
          icon: const Icon(Icons.done),
          label: const Text('Tandai Selesai'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
          ),
        );
      }
    }

    // If assigned to someone else
    if (assignedCleanerId != null && assignedCleanerId != currentUserId) {
      return _buildInfoCard(
        'Permintaan ini sedang ditangani petugas lain',
        Icons.info_outline,
        AppConstants.infoColor,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(String message, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'Permintaan tidak ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        return AppConstants.successColor;
      case 'in_progress':
        return AppConstants.infoColor;
      case 'completed':
        return Colors.purple;
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
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }
    return '-';
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _acceptRequest() async {
    final confirmed = await _showConfirmDialog(
      'Terima Permintaan',
      'Apakah Anda yakin ingin menerima permintaan ini?',
      'TERIMA',
      AppConstants.successColor,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.acceptRequest(widget.requestId);

      if (!mounted) return;
      _showSuccessSnackbar('Permintaan berhasil diterima');
    } on FirestoreException catch (e) {
      _logger.error('Accept request error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _startRequest() async {
    final confirmed = await _showConfirmDialog(
      'Mulai Pengerjaan',
      'Apakah Anda siap memulai pengerjaan?',
      'MULAI',
      AppConstants.warningColor,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.startRequest(widget.requestId);

      if (!mounted) return;
      _showSuccessSnackbar('Pengerjaan dimulai');
    } on FirestoreException catch (e) {
      _logger.error('Start request error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeRequest() async {
    final confirmed = await _showConfirmDialog(
      'Tandai Selesai',
      'Apakah Anda yakin pekerjaan sudah selesai?',
      'SELESAI',
      Colors.purple,
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.completeRequest(widget.requestId);

      if (!mounted) return;
      _showSuccessSnackbar('Pekerjaan berhasil diselesaikan!');

      // Go back after completion
      Navigator.pop(context);
    } on FirestoreException catch (e) {
      _logger.error('Complete request error', e);
      _showErrorSnackbar(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showErrorSnackbar(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(actionText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
