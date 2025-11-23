// lib/widgets/admin/cards/mobile_report_card.dart
// 📋 Mobile Report Card
// Compact report card for list view with selection support

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../models/report.dart';
import 'package:timeago/timeago.dart' as timeago;

class MobileReportCard extends StatelessWidget {
  final Report report;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelectionChanged;

  const MobileReportCard({
    super.key,
    required this.report,
    this.selectable = false,
    this.selected = false,
    this.onTap,
    this.onSelectionChanged,
  });

  Color _getStatusColor(String status) {
    return AdminColors.getStatusColor(status.toLowerCase().replaceAll(' ', ''));
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in progress':
      case 'inprogress':
        return Icons.play_circle;
      case 'needs verification':
      case 'needsverification':
        return Icons.fact_check;
      case 'completed':
      case 'verified':
        return Icons.check_circle;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    final timeAgo = timeago.format(report.createdAt, locale: 'id');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selectable && onSelectionChanged != null
            ? () => onSelectionChanged!(!selected)
            : onTap,
        onLongPress: selectable && onSelectionChanged != null
            ? () => onSelectionChanged!(!selected)
            : null,
        borderRadius: AdminConstants.borderRadiusCard,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AdminConstants.screenPaddingHorizontal,
            vertical: AdminConstants.spaceSm,
          ),
          padding: const EdgeInsets.all(AdminConstants.spaceMd),
          decoration: BoxDecoration(
            color: selected
                ? AdminColors.primaryLight.withOpacity(0.1)
                : AdminColors.surface,
            borderRadius: AdminConstants.borderRadiusCard,
            border: selected
                ? Border.all(color: AdminColors.primary, width: 2)
                : null,
            boxShadow:
                selected ? AdminConstants.shadowElevated : AdminConstants.shadowCard,
          ),
          child: Row(
            children: [
              // Thumbnail or Icon
              if (report.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                  child: Image.network(
                    report.images.first,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),

              const SizedBox(width: AdminConstants.spaceMd),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report number & status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Report #${report.id}',
                            style: AdminTypography.cardTitle.copyWith(
                              color: AdminColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AdminConstants.spaceSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status).withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AdminConstants.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(report.status),
                                size: 12,
                                color: _getStatusColor(report.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                report.status,
                                style: AdminTypography.badge.copyWith(
                                  color: _getStatusColor(report.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Text(
                      report.location,
                      style: AdminTypography.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Department & timestamp
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: AdminConstants.iconXs,
                          color: AdminColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.department,
                            style: AdminTypography.caption.copyWith(
                              color: AdminColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: AdminTypography.caption.copyWith(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: AdminTypography.caption.copyWith(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Checkbox (if selectable)
              if (selectable) ...[
                const SizedBox(width: AdminConstants.spaceSm),
                Checkbox(
                  value: selected,
                  onChanged: onSelectionChanged,
                  activeColor: AdminColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AdminColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
      ),
      child: Icon(
        Icons.description,
        color: AdminColors.primary,
        size: AdminConstants.iconMd,
      ),
    );
  }
}
