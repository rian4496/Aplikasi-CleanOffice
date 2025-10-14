import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../models/report_status_enum.dart';

/// Widget untuk menampilkan item laporan dalam list
/// Digunakan di admin dashboard dan verification screen
class ReportListItem extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final bool showCleaner;
  final bool showStatus;
  final bool compact;

  const ReportListItem({
    super.key,
    required this.report,
    this.onTap,
    this.showCleaner = true,
    this.showStatus = true,
    this.compact = false,
  });

  // TAMBAHAN: Helper function untuk convert status ke Icon
  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.schedule;
      case ReportStatus.assigned:
        return Icons.assignment_ind;
      case ReportStatus.inProgress:
        return Icons.pending_actions;
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.verified:
        return Icons.verified;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: compact ? _buildCompactLayout() : _buildFullLayout(),
        ),
      ),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon dengan status color - FIXED: Pakai helper function
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(report.status.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(
                  report.status,
                ), // FIXED: Tidak pakai IconData dynamic
                color: Color(report.status.colorValue),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (report.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 14,
                                color: Colors.red[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'URGEN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (report.description != null &&
                      report.description!.isNotEmpty)
                    Text(
                      report.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Info row
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                        Icons.person,
                        report.userName,
                        Colors.blue,
                      ),
                      if (showCleaner && report.cleanerName != null)
                        _buildInfoChip(
                          Icons.engineering,
                          report.cleanerName!,
                          Colors.orange,
                        ),
                      _buildInfoChip(
                        Icons.access_time,
                        _formatDateTime(report.date),
                        Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showStatus) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Color(report.status.colorValue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(
                      report.status.colorValue,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  report.status.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(report.status.colorValue),
                  ),
                ),
              ),
              if (report.completedAt != null)
                Text(
                  'Selesai: ${_formatDateTime(report.completedAt!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Icon - FIXED: Pakai helper function
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(report.status.colorValue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getStatusIcon(
              report.status,
            ), // FIXED: Tidak pakai IconData dynamic
            color: Color(report.status.colorValue),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.location,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (report.isUrgent)
                    Icon(Icons.priority_high, size: 16, color: Colors.red[700]),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                report.cleanerName ?? report.userName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Status badge
        if (showStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(report.status.colorValue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report.status.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(report.status.colorValue),
              ),
            ),
          ),
        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }
}
