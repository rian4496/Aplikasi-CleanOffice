// lib/widgets/web_admin/budget/budget_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/riverpod/budget_view_providers.dart';

class BudgetStatsWidget extends ConsumerWidget {
  const BudgetStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(budgetGlobalStatsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final percentFormat = NumberFormat.percentPattern();

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Total Pagu Anggaran',
            value: currencyFormat.format(stats.totalPagu),
            subtitle: '${stats.totalBudgets} Sumber Anggaran',
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'Total Realisasi',
            value: currencyFormat.format(stats.totalRealized),
            subtitle: 'Penyerapan: ${percentFormat.format(stats.realizationPercent)}',
            icon: Icons.check_circle_outline,
            color: _getRealizationColor(stats.realizationPercent),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'Sisa Anggaran',
            value: currencyFormat.format(stats.totalRemaining),
            subtitle: 'Dana Tersedia',
            icon: Icons.savings_outlined,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Color _getRealizationColor(double percent) {
    if (percent > 0.8) return Colors.green; // Good absorption
    if (percent > 0.5) return Colors.blue; 
    return Colors.orange; // Low absorption
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color, 
              fontSize: 12, 
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
}
