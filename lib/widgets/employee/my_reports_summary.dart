// lib/widgets/employee/my_reports_summary.dart
// Summary of user's reports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/report.dart';

class MyReportsSummary extends ConsumerWidget {
  final List<Report> myReports;

  const MyReportsSummary({
    super.key,
    required this.myReports,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = myReports.where((r) => 
      r.status == ReportStatus.pending || 
      r.status == ReportStatus.assigned
    ).toList();

    final completed = myReports.where((r) =>
      r.status == ReportStatus.completed || 
      r.status == ReportStatus.verified
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                pending.length.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Selesai',
                completed.length.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Pending Reports List
        if (pending.isNotEmpty) ...[
          const Text(
            'Laporan Pending',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...pending.take(3).map((report) => _buildReportItem(context, report)),
          if (pending.length > 3)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/employee/my-reports'),
              child: Text('Lihat Semua (${pending.length})'),
            ),
        ],
        // Recently Completed
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Baru Selesai',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...completed.take(2).map((report) => _buildReportItem(context, report)),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: report.status.color.withValues(alpha: 0.2),
          child: Icon(
            report.isUrgent == true ? Icons.warning : Icons.description,
            color: report.status.color,
            size: 20,
          ),
        ),
        title: Text(
          report.location,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.description ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: report.status.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: report.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM, HH:mm').format(report.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/report-detail',
            arguments: report,
          );
        },
      ),
    );
  }
}
