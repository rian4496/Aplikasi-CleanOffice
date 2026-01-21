// lib/widgets/cleaner/cleaner_report_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';

class CleanerReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final int animationIndex;

  const CleanerReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (animationIndex * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title + ID + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Kebersihan', // Or use report type if available dynamically
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B), // Slate-800
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#TKT-${report.id.substring(0, 8).toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8), // Slate-400
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: report.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: report.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Body: Icon + Category + Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cleaning_services_outlined, size: 16, color: Color(0xFF10B981)), // Emerald-500
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569)), // Slate-600
                          children: [
                             TextSpan(
                              text: 'Kebersihan', 
                              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF10B981))
                            ),
                            const TextSpan(text: ' • '),
                            TextSpan(text: report.description ?? 'Tidak ada deskripsi'),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)), // Slate-100
                const SizedBox(height: 12),
                
                // Footer: Location, User, Date
                Row(
                  children: [
                    _buildFooterItem(Icons.location_on_outlined, report.location),
                    const SizedBox(width: 16),
                    _buildFooterItem(Icons.person_outline, report.userName.split(' ')[0]), // First name only
                    const Spacer(),
                    Text(
                      DateFormatter.shortDate(report.date),
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Color(0xFF64748B)), // Slate-500
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
