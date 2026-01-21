// lib/widgets/web_admin/budget/budget_detail_drawer.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/master/budget.dart';

class BudgetDetailDrawer extends StatelessWidget {
  final Budget budget;
  final VoidCallback onClose;
  final Function(Budget) onEdit;
  final Function(Budget) onDelete;

  const BudgetDetailDrawer({
    super.key,
    required this.budget,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final percent = budget.totalAmount > 0 
        ? ((budget.totalAmount - budget.remainingAmount) / budget.totalAmount) 
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(-4, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detail Anggaran', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling works even if content fits
              padding: const EdgeInsets.all(24),
              children: [
                // Icon & Title
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, size: 32, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    budget.sourceName,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tahun Anggaran ${budget.fiscalYear}',
                      style: GoogleFonts.sourceCodePro(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Section
                Text('Ringkasan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                
                _buildStatRow('Pagu Anggaran', currencyFormat.format(budget.totalAmount), Colors.black),
                const SizedBox(height: 12),
                _buildStatRow('Realisasi (Terpakai)', currencyFormat.format(budget.totalAmount - budget.remainingAmount), Colors.blue[700]!),
                const SizedBox(height: 12),
                _buildStatRow('Sisa Anggaran', currencyFormat.format(budget.remainingAmount), Colors.green[700]!),
                const SizedBox(height: 12),
                
                // Progress
                Text('Penyerapan: ${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Colors.grey[100],
                    color: percent > 0.8 ? Colors.green : (percent > 0.5 ? Colors.blue : Colors.orange),
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onEdit(budget),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onDelete(budget),
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // History (Placeholder)
                Text('Riwayat Transaksi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.history, color: Colors.grey[400], size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi tercatat.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {}, 
                        child: const Text('Lihat Detail Log'),
                      )
                    ],
                  ),
                ),
                
                // Extra padding to avoid obstruction (Increased to 300)
                const SizedBox(height: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor, fontSize: 15)),
      ],
    );
  }
}
