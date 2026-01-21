// lib/widgets/web_admin/selectable_report_card.dart
// Report card with selection checkbox for batch operations - REFACTORED

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../riverpod/selection_state_provider.dart';

/// Selectable report card with checkbox for batch operations.
/// 
/// **Features:**
/// - Long press to enter selection mode
/// - Tap to toggle selection when in selection mode
/// - Visual feedback for selected items
/// - Urgent badge
/// - Status badge with color coding
/// 
/// **Usage:**
/// ```dart
/// SelectableReportCard(
///   report: report,
///   onTap: () => navigateToDetail(),
/// )
/// ```
class SelectableReportCard extends ConsumerWidget {
  final Report report;
  final VoidCallback? onTap;
  final bool showCheckbox;
  
  const SelectableReportCard({
    required this.report,
    this.onTap,
    this.showCheckbox = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionProvider);
    final isSelected = selectionState.isSelected(report.id);
    final shouldShowCheckbox = selectionState.isSelectionMode || showCheckbox;
    
    return GestureDetector(
      onTap: () {
        if (selectionState.isSelectionMode) {
          // In selection mode → toggle selection
          ref.read(selectionProvider.notifier).toggleSelection(report.id);
        } else {
          // Normal mode → call onTap
          onTap?.call();
        }
      },
      onLongPress: () {
        if (!selectionState.isSelectionMode) {
          // Enter selection mode with this item
          ref.read(selectionProvider.notifier).enterSelectionMode(report.id);
          
          // Haptic feedback
          HapticFeedback.mediumImpact();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Card Content
            Padding(
              padding: EdgeInsets.all(shouldShowCheckbox ? 12 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox (if in selection mode)
                  if (shouldShowCheckbox) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        ref.read(selectionProvider.notifier).toggleSelection(report.id);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: report.status.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                report.location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: report.status.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.status.displayName, // ✅ Use model method
                                style: TextStyle(
                                  color: report.status.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Description
                        Text(
                          report.description ?? 'No description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Footer Info
                        Row(
                          children: [
                            // User
                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              report.userName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Time
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.relativeTime(report.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Urgent Badge
                            if (report.isUrgent == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'URGENT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Overlay
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

