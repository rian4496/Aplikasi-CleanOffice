// lib/widgets/web_admin/admin_analytics_widget.dart
// Performance analytics widget with interactive charts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/report.dart';
import '../../services/export_service.dart';
import './export_dialog.dart';
import './charts/chart_container.dart';
import './charts/reports_trend_chart.dart';
import './charts/location_bar_chart.dart';
import './charts/status_pie_chart.dart';
import './charts/cleaner_performance_chart.dart';

class AdminAnalyticsWidget extends ConsumerWidget {
  final List<Report> reports;
  final List requests;
  final int totalCleaners;
  
  const AdminAnalyticsWidget({
    required this.reports,
    required this.requests,
    required this.totalCleaners,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Data Visualization & Analytics',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : ResponsiveHelper.headingFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.file_download_outlined, color: Colors.grey[700]),
                tooltip: 'Export',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const ExportDialog(),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(context)),
          
          // Interactive Charts Grid
          isMobile
              ? _buildMobileCharts()
              : isTablet
                  ? _buildTabletCharts()
                  : _buildDesktopCharts(),
        ],
      ),
    );
  }
  
  // ==================== MOBILE CHARTS ====================
  Widget _buildMobileCharts() {
    return Column(
      children: [
        ChartContainer(
          title: 'Trend Laporan',
          subtitle: 'Perkembangan laporan dari waktu ke waktu',
          height: 350,
          child: const ReportsTrendChart(),
        ),
        const SizedBox(height: 16),
        ChartContainer(
          title: 'Distribusi Status',
          subtitle: 'Persentase laporan berdasarkan status',
          height: 400,
          child: const StatusPieChart(),
        ),
        const SizedBox(height: 16),
        ChartContainer(
          title: 'Laporan per Lokasi',
          subtitle: 'Jumlah laporan dari setiap lokasi',
          height: 350,
          child: const LocationBarChart(),
        ),
        const SizedBox(height: 16),
        ChartContainer(
          title: 'Performa Cleaner',
          subtitle: 'Top 10 cleaner terbaik',
          height: 400,
          child: const CleanerPerformanceChart(),
        ),
      ],
    );
  }

  // ==================== TABLET CHARTS ====================
  Widget _buildTabletCharts() {
    return Column(
      children: [
        // Row 1: Trend + Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ChartContainer(
                title: 'Trend Laporan',
                subtitle: 'Perkembangan laporan dari waktu ke waktu',
                height: 350,
                child: const ReportsTrendChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartContainer(
                title: 'Status',
                subtitle: 'Distribusi status',
                height: 350,
                child: const StatusPieChart(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Location + Performance
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ChartContainer(
                title: 'Laporan per Lokasi',
                height: 350,
                child: const LocationBarChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartContainer(
                title: 'Performa Cleaner',
                height: 350,
                child: const CleanerPerformanceChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== DESKTOP CHARTS ====================
  Widget _buildDesktopCharts() {
    return Column(
      children: [
        // Row 1: Trend (full width)
        ChartContainer(
          title: 'Trend Laporan',
          subtitle: 'Perkembangan laporan dari waktu ke waktu',
          height: 350,
          child: const ReportsTrendChart(),
        ),
        const SizedBox(height: 16),
        // Row 2: Status + Location + Performance (3 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ChartContainer(
                title: 'Distribusi Status',
                height: 400,
                child: const StatusPieChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartContainer(
                title: 'Laporan per Lokasi',
                height: 400,
                child: const LocationBarChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartContainer(
                title: 'Top Cleaner',
                height: 400,
                child: const CleanerPerformanceChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

