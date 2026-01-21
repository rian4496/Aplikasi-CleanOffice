import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../riverpod/cleaner_providers.dart';

class CleanerScheduleScreen extends HookConsumerWidget {
  const CleanerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Jadwal Kebersihan',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: activeReportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return _buildEmptyState();
          }

          // Sort reports by date
          final sortedReports = List<Report>.from(reports)
            ..sort((a, b) => a.date.compareTo(b.date));

          // Group by Date (Today, Tomorrow, Later)
          // For simplicity, we just show a list with date headers logic inside ListView or simplified grouping.
          // Let's simple group:
          final Map<String, List<Report>> grouped = {};
          for (var report in sortedReports) {
            final dateKey = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(report.date); // Requires locale setup or just d MMM yyyy
            // Fallback unique key
            final key =  DateFormat('d MMMM yyyy').format(report.date);
            if (!grouped.containsKey(key)) grouped[key] = [];
            grouped[key]!.add(report);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final dayReports = grouped[dateKey]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      dateKey,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ...dayReports.map((report) => _buildScheduleCard(context, report)).toList(),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada jadwal tugas',
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Report report) {
    final isUrgent = report.isUrgent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? const Color(0xFFFECACA) : Colors.grey[200]!, // Red border if urgent
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 4, 
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column (Mock time or from date)
          Column(
            children: [
              Text(
                DateFormat('HH:mm').format(report.date),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isUrgent)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Urgent',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.red[700], fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Divider
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red[400] : AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isUrgent ? 'Insidental' : 'Rutin',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
