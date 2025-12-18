// lib/widgets/shared/request_card_widget.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/request.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_theme.dart';

/// Reusable Request Card Widget untuk semua role (Employee, Cleaner, Admin)
/// 
/// Widget ini menampilkan informasi request dalam bentuk card yang bisa
/// di-customize sesuai kebutuhan masing-masing screen.
/// 
/// Features:
/// - Display request info (location, description, status, urgent badge)
/// - Show assignee info (optional)
/// - Compact mode untuk nested lists
/// - Thumbnail image support
/// - Status badge dengan color coding
/// - Preferred time display
/// - Smooth animations
/// 
/// Usage:
/// ```dart
/// // Standard mode
/// RequestCardWidget(
///   request: request,
///   onTap: () => Navigator.push(...),
///   showAssignee: true,
/// )
/// 
/// // Compact mode
/// RequestCardWidget(
///   request: request,
///   onTap: () => _handleTap(),
///   compact: true,
///   showAssignee: false,
/// )
/// ```
class RequestCardWidget extends StatelessWidget {
  /// Request object yang akan ditampilkan
  final Request request;
  
  /// Callback ketika card di-tap
  final VoidCallback onTap;
  
  /// Tampilkan info cleaner yang assigned (optional)
  /// Akan show avatar + nama jika ada assignedTo
  final bool showAssignee;
  
  /// Mode compact untuk nested lists (height lebih kecil, less padding)
  final bool compact;
  
  /// Index untuk stagger animation (optional)
  final int? animationIndex;
  
  /// Show thumbnail image atau tidak (default true)
  final bool showThumbnail;

  const RequestCardWidget({
    super.key,
    required this.request,
    required this.onTap,
    this.showAssignee = false,
    this.compact = false,
    this.animationIndex,
    this.showThumbnail = true,
  });

  @override
  Widget build(BuildContext context) {
    final index = animationIndex ?? 0;

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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: request.isUrgent
              ? BorderSide(color: AppTheme.error, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
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
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: compact ? _buildCompactLayout() : _buildStandardLayout(),
            ),
          ),
        ),
      ),
    );
  }

  /// Layout standard dengan thumbnail dan info lengkap
  Widget _buildStandardLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        if (showThumbnail) ...[
          _buildThumbnail(),
          const SizedBox(width: 12),
        ],
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location dengan urgent badge
              _buildLocationRow(),
              
              // Description
              if (request.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDescription(),
              ],
              
              const SizedBox(height: 10),
              
              // Bottom row: Date, Time, Status, Assignee
              _buildBottomRow(),
            ],
          ),
        ),
      ],
    );
  }

  /// Layout compact untuk nested lists (single line)
  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Leading icon berdasarkan status
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            request.isUrgent ? Icons.priority_high : Icons.location_on,
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Location + Status badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.location,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(compact: true),
                ],
              ),
              if (request.preferredDateTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  _formatPreferredTime(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Trailing icon
        const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ],
    );
  }

  /// Build location row dengan urgent badge
  Widget _buildLocationRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            request.location,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
    );
  }

  /// Build description text
  Widget _buildDescription() {
    return Text(
      request.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
      ),
    );
  }

  /// Build bottom row dengan date, time, status, assignee
  Widget _buildBottomRow() {
    return Row(
      children: [
        // Created date
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
        
        // Preferred time
        if (request.preferredDateTime != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.schedule,
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            _formatPreferredTime(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        
        const Spacer(),
        
        // Assignee info (jika showAssignee = true dan ada assignedTo)
        if (showAssignee && request.assignedTo != null) ...[
          _buildAssigneeChip(),
          const SizedBox(width: 8),
        ],
        
        // Status badge
        _buildStatusChip(),
      ],
    );
  }

  /// Build thumbnail image
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: request.imageUrl != null && request.imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: request.imageUrl!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey[400]),
              ),
            )
          : Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.cleaning_services,
                color: Colors.grey[400],
                size: 30,
              ),
            ),
    );
  }

  /// Build status chip dengan color coding
  Widget _buildStatusChip({bool compact = false}) {
    final color = _getStatusColor();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusLabel(),
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Build assignee chip dengan avatar + nama
  Widget _buildAssigneeChip() {
    if (request.assignedToName == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: AppTheme.secondary,
            child: const Icon(
              Icons.person,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            request.assignedToName!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color berdasarkan RequestStatus
  Color _getStatusColor() {
    switch (request.status) {
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

  /// Get status label Indonesia
  String _getStatusLabel() {
    switch (request.status) {
      case RequestStatus.pending:
        return 'Menunggu';
      case RequestStatus.assigned:
        return 'Ditugaskan';
      case RequestStatus.inProgress:
        return 'Proses';
      case RequestStatus.completed:
        return 'Selesai';
      case RequestStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  /// Format preferred time untuk display
  String _formatPreferredTime() {
    if (request.preferredDateTime == null) return '';
    
    final time = request.preferredDateTime!;
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
    
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr, $timeStr';
  }
}
