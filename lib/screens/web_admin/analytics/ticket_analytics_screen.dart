// lib/screens/web_admin/analytics/ticket_analytics_screen.dart
// 📊 Ticket Analytics Screen
// Full analytics dashboard for ticket statistics

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/design/admin_colors.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../riverpod/ticket_analytics_provider.dart';

class TicketAnalyticsScreen extends ConsumerWidget {
  const TicketAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketAnalyticsProvider);
    final notifier = ref.read(ticketAnalyticsProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 900;

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back Button and Period Filter (Desktop only header logic inside)
          if (!isMobile) _buildHeader(context, state, notifier, isMobile),
          
          // Mobile Period Filter (if mobile, show it here or in AppBar?)
          // Mobile layout usually needs the filter. Let's put it at the top of body.
          // Mobile Period Filter & Header
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                           if (Navigator.canPop(context)) {
                             Navigator.pop(context);
                           } else {
                             context.go('/admin/dashboard');
                           }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tight fit
                        ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Analitik Tiket',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AnalyticsPeriod>(
                      value: state.period,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      isDense: true,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: AnalyticsPeriod.thisWeek, child: Text('Minggu Ini')),
                        DropdownMenuItem(value: AnalyticsPeriod.thisMonth, child: Text('Bulan Ini')),
                        DropdownMenuItem(value: AnalyticsPeriod.threeMonths, child: Text('3 Bulan')),
                        DropdownMenuItem(value: AnalyticsPeriod.oneYear, child: Text('1 Tahun')),
                      ],
                      onChanged: (value) {
                        if (value != null) notifier.setPeriod(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(height: isMobile ? 0 : 24),

          // Loading State
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Quick Stats Row
            _buildQuickStats(state, isMobile),
            const SizedBox(height: 24),

            // Charts Row (Line + Pie)
            if (isMobile)
              Column(
                children: [
                  _buildVolumeTrendChart(state, isMobile),
                  const SizedBox(height: 16),
                  _buildStatusPieChart(state, isMobile),
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: _buildVolumeTrendChart(state, isMobile)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildStatusPieChart(state, isMobile)),
                  ],
                ),
              ),
            SizedBox(height: isMobile ? 16 : 24),

            // Category Breakdown Chart
            _buildCategoryBreakdownChart(state, isMobile),
            SizedBox(height: isMobile ? 16 : 24),

            // Top Locations
            _buildTopLocations(state, isMobile),
          ],
        ],
      );
    }

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: buildContent(),
          ),
        ),
      );
    }

    return AdminLayoutWrapper(
      title: 'Analitik Tiket',
      currentNavIndex: 0,
      onNavigationChanged: (_) {},
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: buildContent(),
      ),
    );
  }

  // Header for Desktop
  Widget _buildHeader(BuildContext context, TicketAnalyticsState state, TicketAnalyticsNotifier notifier, bool isMobile) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/admin/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        
        Expanded(
          child: Text(
            'Analitik Tiket',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AnalyticsPeriod>(
              value: state.period,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              isDense: true,
              items: const [
                DropdownMenuItem(value: AnalyticsPeriod.thisWeek, child: Text('Minggu Ini')),
                DropdownMenuItem(value: AnalyticsPeriod.thisMonth, child: Text('Bulan Ini')),
                DropdownMenuItem(value: AnalyticsPeriod.threeMonths, child: Text('3 Bulan')),
                DropdownMenuItem(value: AnalyticsPeriod.oneYear, child: Text('1 Tahun')),
              ],
              onChanged: (value) {
                if (value != null) notifier.setPeriod(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ... [Keep other methods same until _buildCategoryBreakdownChart] ...

  // Placeholder for skipping methods in replace (Need to make sure I don't delete them if I use replace_file_content with range? 
  // Wait, I cannot skip methods in a contiguous block replacement. 
  // Tools allow using START/END line. I must be careful.
  // The user prompt implies I should only replace specific chunks if possible or use multiple chunks.
  // But wait, the previous `build` method is lines 20-78. 
  // `_buildCategoryBreakdownChart` is lines 521-662.
  // These are far apart. I should use `multi_replace_file_content` or just separate calls.
  // I will use `replace_file_content` for `build` first, then another call for the chart.
  // Actually, I can do it in two calls.
  // Let me just do the `build` method first.]


  Widget _buildQuickStats(TicketAnalyticsState state, bool isMobile) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.1 : 1.8,
      children: [
        _buildStatCard(
          'Total Tiket',
          state.totalTickets.toString(),
          Icons.confirmation_number_outlined,
          Colors.blue,
          state.totalChange,
        ),
        _buildStatCard(
          'Selesai',
          state.completedTickets.toString(),
          Icons.check_circle_outline,
          Colors.green,
          state.totalTickets > 0 ? (state.completedTickets / state.totalTickets * 100) : 0,
          isPercentage: true,
        ),
        _buildStatCard(
          'Pending',
          state.pendingTickets.toString(),
          Icons.pending_outlined,
          Colors.orange,
          state.totalTickets > 0 ? (state.pendingTickets / state.totalTickets * 100) : 0,
          isPercentage: true,
        ),
        _buildStatCard(
          'Avg. Respon',
          '${state.avgResponseTimeHours.toStringAsFixed(1)} jam',
          Icons.timer_outlined,
          Colors.purple,
          state.responseTimeChange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double change, {bool isPercentage = false}) {
    final isPositive = change >= 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPercentage ? '${change.toStringAsFixed(0)}%' : '${change.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeTrendChart(TicketAnalyticsState state, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, size: isMobile ? 18 : 20, color: AppTheme.primary),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trend Volume Tiket',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '7 hari terakhir',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 28),
          SizedBox(
            height: isMobile ? 180 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getInterval(state.volumeTrend),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < state.volumeLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              state.volumeLabels[index],
                              style: GoogleFonts.inter(
                                fontSize: 11, 
                                color: Colors.grey.shade600, 
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: _getInterval(state.volumeTrend),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: state.volumeTrend.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()} tiket',
                          GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: AppTheme.primary.withValues(alpha: 0.3), strokeWidth: 2, dashArray: [5, 5]),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 8,
                            color: AppTheme.primary,
                            strokeWidth: 3,
                            strokeColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(TicketAnalyticsState state, bool isMobile) {
    final total = state.statusDistribution.values.fold(0, (a, b) => a + b);
    final colors = [Colors.amber, Colors.blue, Colors.green, Colors.red];
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: isMobile ? 18 : 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Distribusi Status',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 160 : 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: state.statusDistribution.entries.toList().asMap().entries.map((entry) {
                      final color = colors[entry.key % colors.length];
                      final value = entry.value.value;
                      return PieChartSectionData(
                        value: value.toDouble(),
                        color: color,
                        radius: 30,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: state.statusDistribution.entries.toList().asMap().entries.map((entry) {
              final color = colors[entry.key % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('${entry.value.key} (${entry.value.value})', style: const TextStyle(fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownChart(TicketAnalyticsState state, bool isMobile) {
    double maxY = 5.0;
    for (int i = 0; i < state.trendKerusakan.length; i++) {
      final total = state.trendKerusakan[i] + state.trendKebersihan[i] + state.trendStok[i];
      if (total > maxY) maxY = total;
    }
    maxY += 2;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Adaptive: Legend moves to bottom on mobile)
          if (isMobile)
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Breakdown per Kategori',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 20, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Breakdown per Kategori',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                _buildCategoryLegend(),
              ],
            ),
            
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < state.categoryLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.categoryLabels[index],
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxY > 10 ? 5 : 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 10 ? 5 : 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                barGroups: List.generate(state.trendKerusakan.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: state.trendKerusakan[i],
                        width: 12,
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: state.trendKebersihan[i],
                        width: 12,
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: state.trendStok[i],
                        width: 12,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.orange.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          
          if (isMobile) ...[
            const SizedBox(height: 24),
            Center(child: _buildCategoryLegend(isWrap: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryLegend({bool isWrap = false}) {
    final children = [
      _legendDot('Kerusakan', Colors.red.shade400),
      const SizedBox(width: 12),
      _legendDot('Kebersihan', Colors.green.shade400),
      const SizedBox(width: 12),
      _legendDot('Stok', Colors.orange.shade400),
    ];
    
    if (isWrap) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: children.where((w) => w is! SizedBox).toList(),
      );
    }
    
    return Row(
      children: children,
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTopLocations(TicketAnalyticsState state, bool isMobile) {
    // Calculate completion rates per category
    final kerusakanTotal = state.trendKerusakan.fold(0.0, (a, b) => a + b);
    final kebersihanTotal = state.trendKebersihan.fold(0.0, (a, b) => a + b);
    final stokTotal = state.trendStok.fold(0.0, (a, b) => a + b);
    
    final completedRatio = state.totalTickets > 0 
        ? state.completedTickets / state.totalTickets 
        : 0.0;
    
    final responseScore = state.avgResponseTimeHours < 2 ? 1.0 
        : state.avgResponseTimeHours < 4 ? 0.8 
        : state.avgResponseTimeHours < 8 ? 0.6 
        : 0.4;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Performa',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Statistik kinerja periode ini',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Performance Cards Grid
          isMobile
              ? Column(children: [
                  _buildPerformanceCard(
                    'Tingkat Penyelesaian',
                    '${(completedRatio * 100).toStringAsFixed(0)}%',
                    completedRatio,
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildPerformanceCard(
                    'Skor Respon',
                    responseScore >= 0.8 ? 'Baik' : responseScore >= 0.6 ? 'Cukup' : 'Perlu Perhatian',
                    responseScore,
                    responseScore >= 0.8 ? Colors.blue : responseScore >= 0.6 ? Colors.amber : Colors.red,
                    Icons.speed_rounded,
                  ),
                ])
              : Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceCard(
                        'Tingkat Penyelesaian',
                        '${(completedRatio * 100).toStringAsFixed(0)}%',
                        completedRatio,
                        Colors.green,
                        Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceCard(
                        'Skor Respon',
                        responseScore >= 0.8 ? 'Baik' : responseScore >= 0.6 ? 'Cukup' : 'Perlu Perhatian',
                        responseScore,
                        responseScore >= 0.8 ? Colors.blue : responseScore >= 0.6 ? Colors.amber : Colors.red,
                        Icons.speed_rounded,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          
          // Category Summary Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryChip('Kerusakan', kerusakanTotal.toInt(), Colors.red),
                _buildCategoryChip('Kebersihan', kebersihanTotal.toInt(), Colors.green),
                _buildCategoryChip('Stok', stokTotal.toInt(), Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceCard(String title, String value, double progress, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  double _getInterval(List<double> data) {
    if (data.isEmpty) return 2;
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    if (max <= 50) return 10;
    return 20;
  }
}
