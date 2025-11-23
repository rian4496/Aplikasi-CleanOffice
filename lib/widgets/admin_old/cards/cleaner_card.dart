// lib/widgets/admin/cards/cleaner_card.dart
// 👤 Cleaner Card
// Card showing cleaner info and performance

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class CleanerCard extends StatelessWidget {
  final String cleanerId;
  final String cleanerName;
  final String department;
  final bool isAvailable;
  final double rating;
  final int completedTasks;
  final int todayTasks;
  final VoidCallback? onTap;

  const CleanerCard({
    super.key,
    required this.cleanerId,
    required this.cleanerName,
    required this.department,
    this.isAvailable = true,
    this.rating = 0.0,
    this.completedTasks = 0,
    this.todayTasks = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AdminConstants.borderRadiusCard,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AdminConstants.screenPaddingHorizontal,
            vertical: AdminConstants.spaceSm,
          ),
          padding: const EdgeInsets.all(AdminConstants.spaceMd),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: AdminConstants.borderRadiusCard,
            boxShadow: AdminConstants.shadowCard,
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AdminColors.primaryLight.withOpacity(0.2),
                    child: Text(
                      cleanerName[0].toUpperCase(),
                      style: AdminTypography.h4.copyWith(
                        color: AdminColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spaceMd),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanerName,
                          style: AdminTypography.cardTitle.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          department,
                          style: AdminTypography.caption.copyWith(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminConstants.spaceSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AdminColors.success.withOpacity(0.15)
                          : AdminColors.textSecondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.schedule,
                          size: 12,
                          color: isAvailable
                              ? AdminColors.success
                              : AdminColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAvailable ? 'Available' : 'Busy',
                          style: AdminTypography.badge.copyWith(
                            color: isAvailable
                                ? AdminColors.success
                                : AdminColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AdminConstants.spaceMd),
              const Divider(height: 1),
              const SizedBox(height: AdminConstants.spaceMd),

              // Stats Row
              Row(
                children: [
                  // Rating
                  Expanded(
                    child: _buildStatItem(
                      Icons.star,
                      rating.toStringAsFixed(1),
                      'Rating',
                      AdminColors.warning,
                    ),
                  ),
                  
                  // Completed
                  Expanded(
                    child: _buildStatItem(
                      Icons.check_circle,
                      completedTasks.toString(),
                      'Completed',
                      AdminColors.success,
                    ),
                  ),
                  
                  // Today Tasks
                  Expanded(
                    child: _buildStatItem(
                      Icons.today,
                      todayTasks.toString(),
                      'Today',
                      AdminColors.info,
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

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: AdminTypography.h5.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AdminTypography.caption.copyWith(
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
