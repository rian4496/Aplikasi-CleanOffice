import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design/admin_colors.dart';

class TicketTrendChart extends StatelessWidget {
  final List<double> trendKerusakan;
  final List<double> trendKebersihan;
  final List<double> trendStok;
  final bool isMobile;
  final bool useWrapper; // New parameter to control nested card behavior

  const TicketTrendChart({
    super.key,
    required this.trendKerusakan,
    required this.trendKebersihan,
    required this.trendStok,
    this.isMobile = false,
    this.useWrapper = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Fixed day labels: Senin to Minggu
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Calculate max Y for chart scale
    double maxY = 5.0;
    for (int i = 0; i < 7; i++) {
      final total = (i < trendKerusakan.length ? trendKerusakan[i] : 0.0) +
                    (i < trendKebersihan.length ? trendKebersihan[i] : 0.0) +
                    (i < trendStok.length ? trendStok[i] : 0.0);
      if (total > maxY) maxY = total.toDouble();
    }
    maxY = maxY + 2;

    // Adjust sizes based on isMobile
    final double barWidth = isMobile ? 8 : 14;
    final double fontSizeTitle = isMobile ? 16 : 18;
    final EdgeInsets padding = isMobile ? const EdgeInsets.all(12) : const EdgeInsets.all(24);
    final double barsSpace = isMobile ? 2 : 4;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Build Header (Title + Legend) - Only show Title if wrapper is used (or forced)
        // If useWrapper is false, we assume parent handles the title
        if (useWrapper) ...[
          isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Tren Tiket Minggu Ini',
                    style: GoogleFonts.inter(fontSize: fontSizeTitle, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Senin - Minggu',
                    style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _buildLegend(isMobile),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tren Tiket Minggu Ini',
                        style: GoogleFonts.inter(fontSize: fontSizeTitle, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senin - Minggu',
                        style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                  _buildLegend(isMobile),
                ],
              ),
          const SizedBox(height: 24),
        ] else ...[
           // If no wrapper, just show Legend (Mobile usually needs legend close to chart)
           _buildLegend(isMobile),
           const SizedBox(height: 16),
        ],

        SizedBox(
          height: isMobile ? 300 : 350, // Responsive height increased for mobile
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.blueGrey.shade800,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String label = '';
                    if (rodIndex == 0) label = 'Kerusakan';
                    if (rodIndex == 1) label = 'Kebersihan';
                    if (rodIndex == 2) label = 'Stok';
                    return BarTooltipItem(
                      '$label: ${rod.toY.toInt()}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < dayLabels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dayLabels[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 9 : 11, // Smaller font on mobile
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY > 10 ? 5 : 2,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 10 ? 5 : 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final kerusakan = i < trendKerusakan.length ? trendKerusakan[i] : 0.0;
                  final kebersihan = i < trendKebersihan.length ? trendKebersihan[i] : 0.0;
                  final stok = i < trendStok.length ? trendStok[i] : 0.0;
                  
                  return BarChartGroupData(
                    x: i,
                    barsSpace: barsSpace, 
                    barRods: [
                      BarChartRodData(
                        toY: kerusakan,
                        width: barWidth,
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: kebersihan,
                        width: barWidth,
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: stok,
                        width: barWidth,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.orange.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
      ],
    );

    if (useWrapper) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.divider.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    } else {
      // Just return content (Column)
      return Padding(
        padding: padding, // Apply padding to layout content properly
        child: content,
      );
    }
  }

  Widget _buildLegend(bool isMobile) {
    // For mobile, we use Wrap but with alignment start essentially behaving like a multiline row
    if (isMobile) {
       return Wrap(
         spacing: 12,
         runSpacing: 4,
         crossAxisAlignment: WrapCrossAlignment.center,
         children: [
            _legendItem('Kerusakan', Colors.red.shade400),
            _legendItem('Kebersihan', Colors.green.shade400),
            _legendItem('Stok', Colors.orange.shade400),
         ],
       );
    }
    return Row(
      children: [
        _legendItem('Kerusakan', Colors.red.shade400),
        const SizedBox(width: 12),
        _legendItem('Kebersihan', Colors.green.shade400),
        const SizedBox(width: 12),
        _legendItem('Stok', Colors.orange.shade400),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AdminColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
