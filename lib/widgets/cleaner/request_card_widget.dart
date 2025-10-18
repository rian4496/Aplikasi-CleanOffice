import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Request Card Widget untuk Cleaner
/// Dipakai untuk menampilkan item task/request di list
/// 
/// Usage:
/// ```dart
/// RequestCard(
///   location: 'Ruang Meeting A',
///   description: 'Perlu dibersihkan secepatnya',
///   isUrgent: true,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class RequestCard extends StatelessWidget {
  /// Lokasi/tempat yang perlu dibersihkan
  final String location;
  
  /// Deskripsi detail request
  final String description;
  
  /// Apakah request urgent/mendesak
  final bool isUrgent;
  
  /// Callback ketika card di-tap
  final VoidCallback onTap;
  
  /// Index untuk stagger animation (optional)
  final int? animationIndex;

  const RequestCard({
    super.key,
    required this.location,
    required this.description,
    this.isUrgent = false,
    required this.onTap,
    this.animationIndex,
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isUrgent
                ? AppTheme.error.withValues(alpha: 0.3)
                : AppTheme.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppTheme.error.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isUrgent
                  ? const Border(
                      left: BorderSide(color: AppTheme.error, width: 4),
                    )
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              
              // Leading Icon
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppTheme.error.withValues(alpha: 0.1)
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isUrgent ? Icons.priority_high : Icons.cleaning_services,
                  color: isUrgent ? AppTheme.error : AppTheme.primary,
                  size: 24,
                ),
              ),
              
              // Title (Location + Urgent Badge)
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Subtitle (Description)
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Trailing Icon
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}