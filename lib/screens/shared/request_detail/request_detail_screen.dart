// lib/screens/shared/request_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../models/request.dart';
import '../../../riverpod/request_providers.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

/// Request Detail Screen - Menampilkan detail lengkap request
/// 
/// Screen ini menampilkan semua informasi request dan menyediakan
/// action buttons berdasarkan role user:
/// 
/// **Employee (Requester):**
/// - Cancel request (jika status pending/assigned)
/// 
/// **Cleaner:**
/// - Self-assign (jika status pending)
/// - Start work (jika status assigned dan user adalah assignee)
/// - Complete work dengan upload foto (jika status in_progress)
/// 
/// **Admin:**
/// - Assign/reassign cleaner
/// - Force cancel request
/// 
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => RequestDetailScreen(requestId: 'xxx'),
///   ),
/// );
/// ```
class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  Uint8List? _completionImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    // Watch request stream
    final requestAsync = ref.watch(requestByIdProvider(widget.requestId));
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Layanan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return _buildNotFound();
          }
          return _buildContent(request, currentUser);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(Request request, user) {
    return Stack(
      children: [
        // Main scrollable content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image banner (jika ada)
              if (request.imageUrl != null) _buildImageBanner(request.imageUrl!),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Location + Status + Urgent badge
                    _buildHeader(request),
                    const SizedBox(height: 16),
                    
                    // Description
                    _buildSection(
                      title: 'Deskripsi',
                      child: Text(
                        request.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                    
                    // Request info
                    _buildSection(
                      title: 'Informasi Request',
                      child: _buildInfoRows(request),
                    ),
                    
                    // Requester info
                    _buildSection(
                      title: 'Pemohon',
                      child: _buildRequesterCard(request),
                    ),
                    
                    // Assignee info (jika sudah assigned)
                    if (request.assignedTo != null)
                      _buildSection(
                        title: 'Petugas',
                        child: _buildAssigneeCard(request),
                      ),
                    
                    // Completion info (jika sudah completed)
                    if (request.status == RequestStatus.completed)
                      _buildSection(
                        title: 'Penyelesaian',
                        child: _buildCompletionInfo(request),
                      ),
                    
                    const SizedBox(height: 80), // Space untuk action buttons
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Role-based action buttons (positioned at bottom)
        _buildActionButtons(request, user),
        
        // Loading overlay saat upload
        if (_isUploading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mengupload foto...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build image banner di atas
  Widget _buildImageBanner(String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageDialog(imageUrl),
      child: Container(
        width: double.infinity,
        height: 250,
        color: Colors.grey[200],
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image, size: 48),
          ),
        ),
      ),
    );
  }

  /// Build header dengan location, status, urgent badge
  Widget _buildHeader(Request request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        Text(
          request.location,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Status badge + Urgent badge
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip(request.status),
            if (request.isUrgent) _buildUrgentBadge(),
          ],
        ),
      ],
    );
  }

  /// Build status chip dengan color coding
  Widget _buildStatusChip(RequestStatus status) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build urgent badge
  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.priority_high, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'URGENT',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build section wrapper dengan title
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// Build info rows (created date, preferred time)
  Widget _buildInfoRows(Request request) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Dibuat',
              value: DateFormatter.fullDate(request.createdAt),
            ),
            if (request.preferredDateTime != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.schedule,
                label: 'Waktu Diinginkan',
                value: DateFormatter.fullDateTime(request.preferredDateTime!),
                valueColor: AppTheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build single info row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build requester card
  Widget _buildRequesterCard(Request request) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            request.requestedByName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          request.requestedByName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Pemohon'),
      ),
    );
  }

  /// Build assignee card
  Widget _buildAssigneeCard(Request request) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondary,
          child: Text(
            (request.assignedToName ?? 'C')[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          request.assignedToName ?? 'Cleaner',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Petugas Ditugaskan'),
      ),
    );
  }

  /// Build completion info
  Widget _buildCompletionInfo(Request request) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Icons.check_circle,
              label: 'Diselesaikan pada',
              value: request.completedAt != null
                  ? DateFormatter.fullDateTime(request.completedAt!)
                  : '-',
              valueColor: AppTheme.success,
            ),
            
            // Completion image (jika ada)
            if (request.completionImageUrl != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Foto Setelah Dibersihkan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showImageDialog(request.completionImageUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: request.completionImageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show image dialog (fullscreen)
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(imageUrl: imageUrl),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build not found state
  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Request tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
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

  /// Get status icon
  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.pending;
      case RequestStatus.assigned:
        return Icons.assignment_ind;
      case RequestStatus.inProgress:
        return Icons.hourglass_empty;
      case RequestStatus.completed:
        return Icons.check_circle;
      case RequestStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get status label
  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Menunggu';
      case RequestStatus.assigned:
        return 'Ditugaskan';
      case RequestStatus.inProgress:
        return 'Dalam Proses';
      case RequestStatus.completed:
        return 'Selesai';
      case RequestStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  // ==================== ROLE-BASED ACTIONS ====================
  
  /// Build action buttons berdasarkan role dan status
  Widget _buildActionButtons(Request request, user) {
    if (user == null) return const SizedBox.shrink();
    
    final userId = user.uid;
    final isRequester = request.requestedBy == userId;
    final isAssignee = request.assignedTo == userId;
    
    if (isRequester && !isAssignee) {
      return _buildEmployeeActions(request);
    } else if (isAssignee) {
      return _buildCleanerActions(request);
    }
    
    return const SizedBox.shrink();
  }

  /// Employee actions: Cancel request
  Widget _buildEmployeeActions(Request request) {
    final canCancel = request.status == RequestStatus.pending ||
        request.status == RequestStatus.assigned;
    
    if (!canCancel) return const SizedBox.shrink();
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _handleCancelRequest(request),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Batalkan Request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Cleaner actions: Self-assign, Start, Complete
  Widget _buildCleanerActions(Request request) {
    Widget? actionButton;
    
    if (request.status == RequestStatus.pending) {
      actionButton = ElevatedButton.icon(
        onPressed: () => _handleSelfAssign(request),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Ambil Tugas Ini'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (request.status == RequestStatus.assigned) {
      actionButton = ElevatedButton.icon(
        onPressed: () => _handleStartWork(request),
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Mulai Pekerjaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.info,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (request.status == RequestStatus.inProgress) {
      actionButton = ElevatedButton.icon(
        onPressed: () => _handleCompleteWork(request),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text('Selesaikan Pekerjaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    
    if (actionButton == null) return const SizedBox.shrink();
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: actionButton,
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================
  
  /// Handle cancel request (Employee)
  Future<void> _handleCancelRequest(Request request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Request'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan request ini?',
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
      await ref
          .read(requestActionsProvider)
          .cancelRequest(request.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request berhasil dibatalkan'),
          backgroundColor: AppTheme.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan request: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// Handle self-assign (Cleaner)
  Future<void> _handleSelfAssign(Request request) async {
    try {
      await ref
          .read(requestActionsProvider)
          .selfAssignRequest(request.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil mengambil tugas'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil tugas: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// Handle start work (Cleaner)
  Future<void> _handleStartWork(Request request) async {
    try {
      await ref
          .read(requestActionsProvider)
          .startRequest(request.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pekerjaan dimulai'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulai pekerjaan: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// Handle complete work dengan upload foto (Cleaner)
  Future<void> _handleCompleteWork(Request request) async {
    // Show image picker dialog
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto completion wajib diupload'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    
    // Read bytes from picked file
    final bytes = await pickedFile.readAsBytes();
    
    setState(() {
      _completionImage = bytes;
      _isUploading = true;
    });
    
    try {
      await ref
          .read(requestActionsProvider)
          .completeRequest(
            requestId: request.id,
            completionImageBytes: _completionImage,
          );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pekerjaan selesai!'),
          backgroundColor: AppTheme.success,
        ),
      );
      
      setState(() => _isUploading = false);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyelesaikan: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
      
      setState(() => _isUploading = false);
    }
  }
}
