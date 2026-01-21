// lib/widgets/sim_aset/custodian_history_dialog.dart
// SIM-ASET: Dialog to view custodian change history

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transactions/custodian_history_model.dart';

class CustodianHistoryDialog extends StatelessWidget {
  final String assetId;
  final String assetName;

  const CustodianHistoryDialog({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  Future<List<CustodianHistory>> _fetchHistory() async {
    final response = await Supabase.instance.client
        .from('asset_custodian_history')
        .select('''
          *,
          old_custodian:old_custodian_id(full_name, nip),
          new_custodian:new_custodian_id(full_name, nip)
        ''')
        .eq('asset_id', assetId)
        .order('changed_at', ascending: false);

    return (response as List)
        .map((json) => CustodianHistory.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.history, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Pemegang Aset',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          assetName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: FutureBuilder<List<CustodianHistory>>(
                future: _fetchHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text('Error: ${snapshot.error}'),
                          ],
                        ),
                      ),
                    );
                  }

                  final history = snapshot.data ?? [];

                  if (history.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada riwayat perubahan pemegang',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildHistoryItem(item, index == 0);
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

  Widget _buildHistoryItem(CustodianHistory item, bool isLatest) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isLatest ? AppTheme.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 16,
              color: isLatest ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  dateFormat.format(item.changedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                
                // Change description
                if (item.oldCustodianName == null && item.newCustodianName != null)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Pemegang awal: '),
                        TextSpan(
                          text: item.newCustodianName ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else if (item.newCustodianName == null && item.oldCustodianName != null)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Pemegang dihapus (sebelumnya: '),
                        TextSpan(
                          text: item.oldCustodianName ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ')'),
                      ],
                    ),
                  )
                else
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      children: [
                        TextSpan(
                          text: item.oldCustodianName ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const TextSpan(text: '  →  '),
                        TextSpan(
                          text: item.newCustodianName ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Reason
                if (item.changeReason != null && item.changeReason!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.changeReason!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
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
