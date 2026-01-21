import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/inventory_movement.dart';
import '../../../riverpod/supabase_service_providers.dart';

final stockMovementsProvider = FutureProvider.autoDispose.family<List<StockMovement>, Map<String, dynamic>>((ref, filters) async {
  final service = ref.read(supabaseDatabaseServiceProvider);
  return service.getStockMovements(
    startDate: filters['startDate'] as DateTime?,
    endDate: filters['endDate'] as DateTime?,
    movementType: filters['movementType'] as String?, // 'IN' or 'OUT'
    itemId: filters['itemId'] as String?,
  );
});

class StockMovementReportScreen extends ConsumerStatefulWidget {
  const StockMovementReportScreen({super.key});

  @override
  ConsumerState<StockMovementReportScreen> createState() => _StockMovementReportScreenState();
}

class _StockMovementReportScreenState extends ConsumerState<StockMovementReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _movementType; // 'IN', 'OUT', or null for all

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
  }

  Map<String, dynamic> get _filters => {
    'startDate': _startDate,
    'endDate': _endDate,
    'movementType': _movementType,
    'itemId': null,
  };

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(stockMovementsProvider(_filters));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Laporan Pergerakan Stok', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/dashboard');
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Date Range
                _buildDateFilter('Dari', _startDate, (date) => setState(() => _startDate = date)),
                _buildDateFilter('Sampai', _endDate, (date) => setState(() => _endDate = date)),
                
                // Movement Type Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _movementType,
                      hint: const Text('Semua Tipe'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                        DropdownMenuItem(
                          value: 'IN',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Masuk'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'OUT',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Keluar'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _movementType = val),
                    ),
                  ),
                ),

                // Refresh Button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(stockMovementsProvider(_filters)),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Data Table
          Expanded(
            child: movementsAsync.when(
              data: (movements) {
                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Tidak ada data pergerakan stok', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tipe', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Referensi', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: movements.map((m) => DataRow(
                        cells: [
                          DataCell(Text(m.performedAt != null 
                              ? DateFormat('dd/MM/yyyy HH:mm').format(m.performedAt!) 
                              : '-')),
                          DataCell(Text(m.itemName ?? '-')),
                          DataCell(_buildTypeBadge(m.type)),
                          DataCell(Text(m.quantity.toString())),
                          DataCell(Text(m.referenceId ?? '-')),
                          DataCell(
                            Tooltip(
                              message: m.notes ?? '',
                              child: Text(
                                m.notes ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(String label, DateTime? date, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
              style: TextStyle(color: date != null ? Colors.black87 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isIn = type == 'IN';
    final bg = isIn ? Colors.green[50]! : Colors.red[50]!;
    final fg = isIn ? Colors.green[700]! : Colors.red[700]!;
    final icon = isIn ? Icons.arrow_downward : Icons.arrow_upward;
    final label = isIn ? 'Masuk' : 'Keluar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
