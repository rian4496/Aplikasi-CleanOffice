import 'package:flutter/material.dart';

/// Stats Card Widget untuk Cleaner
/// Dipakai untuk menampilkan statistik: Ditugaskan, Proses, Selesai
/// 
/// Usage:
/// ```dart
/// StatsCard(
///   icon: Icons.assignment_outlined,
///   label: 'Ditugaskan',
///   value: '5',
///   color: AppTheme.info,
/// )
/// ```
class StatsCard extends StatelessWidget {
  /// Icon yang ditampilkan di atas angka
  final IconData icon;
  
  /// Label di bawah angka (contoh: "Ditugaskan", "Proses")
  final String label;
  
  /// Nilai/angka yang ditampilkan (contoh: "5", "12")
  final String value;
  
  /// Warna tema untuk card (icon, border, text)
  final Color color;
  
  /// Background color untuk card (biasanya versi transparan dari color)
  final Color? backgroundColor;

  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Kalau backgroundColor tidak dikirim, pakai color dengan alpha 0.1
    final bgColor = backgroundColor ?? color.withValues(alpha: 0.1);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            
            // Value (angka)
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
