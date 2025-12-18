import 'package:flutter/material.dart';

/// Tab Badge Widget - Badge count untuk tab
/// Menampilkan angka notifikasi di samping tab title
/// 
/// Usage:
/// ```dart
/// Tab(
///   child: TabBadge(
///     label: 'Permintaan Baru',
///     count: 5,
///     color: AppTheme.primary,
///   ),
/// )
/// ```
class TabBadge extends StatelessWidget {
  /// Label/text tab
  final String label;
  
  /// Jumlah badge (kalau 0 atau null, badge tidak muncul)
  final int? count;
  
  /// Warna badge
  final Color color;
  
  /// Apakah tab ini selected (untuk styling)
  final bool isSelected;

  const TabBadge({
    super.key,
    required this.label,
    this.count,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Kalau count null atau 0, badge tidak ditampilkan
    final showBadge = count != null && count! > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label text
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        // Badge count
        if (showBadge) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count! > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Enhanced Tab Badge dengan icon
/// Untuk tab yang butuh icon + badge
/// 
/// Usage:
/// ```dart
/// Tab(
///   child: TabBadgeWithIcon(
///     icon: Icons.notifications,
///     label: 'Notifikasi',
///     count: 12,
///     color: AppTheme.error,
///   ),
/// )
/// ```
class TabBadgeWithIcon extends StatelessWidget {
  /// Icon tab
  final IconData icon;
  
  /// Label/text tab
  final String label;
  
  /// Jumlah badge
  final int? count;
  
  /// Warna badge
  final Color color;

  const TabBadgeWithIcon({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = count != null && count! > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        
        // Label
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        // Badge
        if (showBadge) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count! > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
