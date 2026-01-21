import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../models/stock_history.dart';
import '../../services/inventory_service.dart';

class StockHistoryDialog extends StatelessWidget {
  final InventoryItem item;

  const StockHistoryDialog({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 500, // Fixed width for dialog
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Riwayat Stok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: StreamBuilder<List<StockHistory>>(
                stream: inventoryService.streamItemHistory(item.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final historyList = snapshot.data ?? [];

                  if (historyList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Riwayat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final history = historyList[index];
                      final isFirst = index == 0;
                      final isLast = index == historyList.length - 1;

                      return _buildTimelineItem(
                        history: history,
                        isFirst: isFirst,
                        isLast: isLast,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required StockHistory history,
    required bool isFirst,
    required bool isLast,
  }) {
    final actionColor = _getActionColor(history.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: Colors.grey[300],
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: actionColor, width: 2),
                ),
                child: Icon(
                  _getActionIcon(history.action),
                  size: 18,
                  color: actionColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Slightly differentiate from white dialog bg
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          history.action.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(history.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Stock Update Row
                  Row(
                    children: [
                      Text(
                        '${history.previousStock}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${history.newStock} ${item.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      // Quantity Change badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (history.newStock > history.previousStock ? '+' : '') + 
                          history.quantity.toString(),
                          style: TextStyle(
                            color: actionColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // User info
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        history.performedByName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  
                  // Notes
                  if (history.notes != null && history.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        history.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(StockAction action) {
    switch (action) {
      case StockAction.add: return Icons.add;
      case StockAction.reduce: return Icons.remove;
      case StockAction.adjustment: return Icons.tune;
      case StockAction.fulfillRequest: return Icons.check_circle_outline;
      case StockAction.initialStock: return Icons.fiber_new;
      case StockAction.manual: return Icons.edit;
      case StockAction.systemCorrection: return Icons.settings_backup_restore;
    }
  }

  Color _getActionColor(StockAction action) {
    switch (action) {
      case StockAction.add:
      case StockAction.initialStock:
        return AppTheme.success;
      case StockAction.reduce:
      case StockAction.fulfillRequest:
        return AppTheme.warning;
      case StockAction.adjustment:
      case StockAction.manual:
        return AppTheme.primary;
      case StockAction.systemCorrection:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    // Basic formatting, can use external helper if available
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(timestamp);
  }
}
