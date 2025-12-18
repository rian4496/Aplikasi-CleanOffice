// lib/widgets/web_admin/budget/budget_list_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/master/budget.dart';

class BudgetListCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;
  final bool isSelected;
  final Function(Budget) onEdit;
  final Function(Budget) onDelete;

  const BudgetListCard({
    super.key,
    required this.budget,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final percent = budget.totalAmount > 0 
        ? ((budget.totalAmount - budget.remainingAmount) / budget.totalAmount) // Realization %
        : 0.0;
    
    // Color logic
    Color progressColor = Colors.green;
    if (percent < 0.3) progressColor = Colors.orange; // Low realization (start of year?)
    if (percent > 0.95) progressColor = Colors.red; // Near limit

    // Remaining warning
    final remainingPercent = 1.0 - percent;
    Color cardBorderColor = isSelected ? AppTheme.primary : Colors.grey[200]!;
    if (remainingPercent < 0.1) cardBorderColor = Colors.red.withOpacity(0.5); // Warning border

    return Card(
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor, width: isSelected ? 2 : 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Year - Source | Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${budget.fiscalYear}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        budget.sourceName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                  _buildStatusChip(budget.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pagu Anggaran', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        Text(currencyFormat.format(budget.totalAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Realisasi', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        Text(
                          currencyFormat.format(budget.totalAmount - budget.remainingAmount), 
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sisa', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        Text(
                          currencyFormat.format(budget.remainingAmount), 
                          style: TextStyle(
                            fontWeight: FontWeight.w600, 
                            color: budget.remainingAmount < (budget.totalAmount * 0.1) ? Colors.red : Colors.green[700]
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: Colors.grey[100],
                  color: progressColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Penyerapan: ${(percent * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  if (isSelected) 
                     Row(
                       children: [
                         IconButton(
                           icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                           onPressed: () => onEdit(budget),
                           tooltip: 'Edit',
                           padding: EdgeInsets.zero,
                           constraints: const BoxConstraints(),
                         ),
                         const SizedBox(width: 12),
                         IconButton(
                           icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                           onPressed: () => onDelete(budget),
                           tooltip: 'Hapus',
                           padding: EdgeInsets.zero,
                           constraints: const BoxConstraints(),
                         ),
                       ],
                     ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'active') color = Colors.green;
    if (status == 'planning') color = Colors.blue;
    if (status == 'closed') color = Colors.black45;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
