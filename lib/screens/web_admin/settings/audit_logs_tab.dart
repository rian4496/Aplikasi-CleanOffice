// lib/screens/web_admin/settings/audit_logs_tab.dart
// Audit Logs Tab for Admin Settings

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../models/audit_log.dart';
import '../../../riverpod/audit_log_providers.dart';
import '../../../services/supabase_database_service.dart';

class AuditLogsTab extends HookConsumerWidget {
  const AuditLogsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogListProvider);
    final filter = ref.watch(auditLogFilterProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    // Filter actions for dropdown
    final actions = [
      'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'REJECT'
    ];
    
    final entityTypes = [
      'user', 'asset', 'procurement', 'loan', 'disposal', 'ticket', 'report'
    ];

    void showDetailDialog(AuditLog log) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(_getActionIcon(log.action), color: _getActionColor(log.action)),
              const SizedBox(width: 8),
              Text(log.actionDisplayName),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Waktu', DateFormat('dd/MM/yyyy HH:mm:ss').format(log.createdAt)),
                  _buildDetailRow('User', log.userEmail ?? '-'),
                  _buildDetailRow('Tipe', log.entityTypeDisplayName),
                  _buildDetailRow('Entity ID', log.entityId ?? '-'),
                  _buildDetailRow('Deskripsi', log.description ?? '-'),
                  if (log.oldData != null) ...[
                    const SizedBox(height: 16),
                    const Text('Data Lama:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(log.oldData.toString(), style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                  if (log.newData != null) ...[
                    const SizedBox(height: 16),
                    const Text('Data Baru:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(log.newData.toString(), style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.history, size: 28),
            const SizedBox(width: 8),
            Text('Audit Logs', style: AdminTypography.h3),
          ],
        ),
        const SizedBox(height: 16),
        
        // Filters Row
        // Responsive Filters
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Date Range & Action Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            filter.startDate != null 
                              ? '${DateFormat('dd/MM').format(filter.startDate!)} - ${DateFormat('dd/MM').format(filter.endDate ?? DateTime.now())}'
                              : 'Tanggal',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                              initialDateRange: DateTimeRange(
                                start: filter.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                                end: filter.endDate ?? DateTime.now(),
                              ),
                            );
                            if (range != null) {
                              ref.read(auditLogFilterProvider.notifier).setDateRange(range.start, range.end);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: filter.action,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Action',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Semua')),
                            ...actions.map((a) => DropdownMenuItem(value: a, child: Text(AuditAction.getDisplayName(a), overflow: TextOverflow.ellipsis))),
                          ],
                          onChanged: (v) => ref.read(auditLogFilterProvider.notifier).setAction(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 2. Type & Search Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: filter.entityType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipe',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Semua')),
                            ...entityTypes.map((t) => DropdownMenuItem(value: t, child: Text(AuditEntityType.getDisplayName(t), overflow: TextOverflow.ellipsis))),
                          ],
                          onChanged: (v) => ref.read(auditLogFilterProvider.notifier).setEntityType(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Cari...',
                            prefixIcon: Icon(Icons.search, size: 16),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (v) => searchQuery.value = v.toLowerCase(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 3. Actions Row (Refresh & Delete)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref.invalidate(auditLogListProvider),
                        tooltip: 'Refresh',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(Icons.delete_sweep, color: Colors.red.shade700, size: 18),
                        label: Text('Hapus > 30 Hari', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () async {
                           // ... keep existing delete logic
                           final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Log Lama?'),
                              content: const Text('Semua log > 30 hari akan dihapus permanen.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            try {
                              final dbService = SupabaseDatabaseService();
                              final deletedCount = await dbService.deleteOldAuditLogs();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dihapus $deletedCount log'), backgroundColor: Colors.green));
                                ref.invalidate(auditLogListProvider);
                              }
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            }

            // Desktop Layout (Original Wrap)
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 180,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      filter.startDate != null 
                        ? '${DateFormat('dd/MM').format(filter.startDate!)} - ${DateFormat('dd/MM').format(filter.endDate ?? DateTime.now())}'
                        : 'Pilih Tanggal',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: filter.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                          end: filter.endDate ?? DateTime.now(),
                        ),
                      );
                      if (range != null) {
                        ref.read(auditLogFilterProvider.notifier).setDateRange(range.start, range.end);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: filter.action,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Action', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ...actions.map((a) => DropdownMenuItem(value: a, child: Text(AuditAction.getDisplayName(a)))),
                    ],
                    onChanged: (v) => ref.read(auditLogFilterProvider.notifier).setAction(v),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: filter.entityType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Tipe', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ...entityTypes.map((t) => DropdownMenuItem(value: t, child: Text(AuditEntityType.getDisplayName(t)))),
                    ],
                    onChanged: (v) => ref.read(auditLogFilterProvider.notifier).setEntityType(v),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(hintText: 'Cari...', prefixIcon: Icon(Icons.search, size: 18), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => searchQuery.value = v.toLowerCase(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(auditLogListProvider),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(border: Border.all(color: Colors.red.shade300), borderRadius: BorderRadius.circular(4), color: Colors.red.shade50),
                  child: TextButton.icon(
                    icon: Icon(Icons.delete_sweep, color: Colors.red.shade700, size: 16),
                    label: Text('Hapus > 30 Hari', style: TextStyle(color: Colors.red.shade700, fontSize: 11)),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Log Lama?'),
                          content: const Text('Semua log > 30 hari akan dihapus permanen.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          final dbService = SupabaseDatabaseService();
                          final deletedCount = await dbService.deleteOldAuditLogs();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dihapus $deletedCount log'), backgroundColor: Colors.green));
                            ref.invalidate(auditLogListProvider);
                          }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                        }
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        
        // Data Table
        Expanded(
          child: logsAsync.when(
            data: (logs) {
              // Apply local search filter
              final filteredLogs = logs.where((log) {
                if (searchQuery.value.isEmpty) return true;
                return (log.userEmail?.toLowerCase().contains(searchQuery.value) ?? false) ||
                       (log.description?.toLowerCase().contains(searchQuery.value) ?? false);
              }).toList();
              
              if (filteredLogs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Tidak ada log ditemukan', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                     return ListView.separated(
                       padding: const EdgeInsets.all(16),
                       itemCount: filteredLogs.length,
                       separatorBuilder: (_,__) => const SizedBox(height: 12),
                       itemBuilder: (context, index) => _MobileAuditCard(
                         log: filteredLogs[index], 
                         onTap: () => showDetailDialog(filteredLogs[index]),
                       ),
                     );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 800),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AdminColors.primaryLight.withAlpha((0.1 * 255).toInt())),
                          columns: const [
                            DataColumn(label: Text('Waktu')),
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Action')),
                            DataColumn(label: Text('Tipe')),
                            DataColumn(label: Text('Deskripsi')),
                            DataColumn(label: Text('')),
                          ],
                          rows: filteredLogs.map((log) => DataRow(
                            cells: [
                              DataCell(Text(log.formattedTime, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(log.userEmail ?? '-', style: const TextStyle(fontSize: 12))),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getActionIcon(log.action), size: 16, color: _getActionColor(log.action)),
                                  const SizedBox(width: 4),
                                  Text(log.actionDisplayName, style: const TextStyle(fontSize: 12)),
                                ],
                              )),
                              DataCell(Chip(
                                label: Text(log.entityTypeDisplayName, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              )),
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    log.description ?? '-',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.visibility, size: 18),
                                  onPressed: () => showDetailDialog(log),
                                  tooltip: 'Lihat Detail',
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                  );
                }
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }


  IconData _getActionIcon(String action) {
    switch (action) {
      case 'LOGIN': return Icons.login;
      case 'LOGOUT': return Icons.logout;
      case 'CREATE': return Icons.add_circle;
      case 'UPDATE': return Icons.edit;
      case 'DELETE': return Icons.delete;
      case 'APPROVE': return Icons.check_circle;
      case 'REJECT': return Icons.cancel;
      case 'EXPORT': return Icons.download;
      default: return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'LOGIN': return Colors.blue;
      case 'LOGOUT': return Colors.grey;
      case 'CREATE': return Colors.green;
      case 'UPDATE': return Colors.orange;
      case 'DELETE': return Colors.red;
      case 'APPROVE': return Colors.teal;
      case 'REJECT': return Colors.deepOrange;
      case 'EXPORT': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _MobileAuditCard extends StatelessWidget {
  final AuditLog log;
  final VoidCallback onTap;

  const _MobileAuditCard({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // Expand Action to push Time to edge
                child: Row(
                  children: [
                    Icon(_getActionIcon(log.action), size: 18, color: _getActionColor(log.action)),
                    const SizedBox(width: 8),
                    Flexible( // Flexible text to wrap if needed
                      child: Text(log.actionDisplayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(log.formattedTime, style: TextStyle(color: Colors.grey[600], fontSize: 10)), // Smaller font
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.description ?? '-',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(50), // Stadium shape like original Chip
                ),
                child: Text(
                  log.entityTypeDisplayName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), // Removed color override to match simpler original look if needed, or keep black/default
                ),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Detail', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(log.userEmail ?? 'No User', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'LOGIN': return Icons.login;
      case 'LOGOUT': return Icons.logout;
      case 'CREATE': return Icons.add_circle;
      case 'UPDATE': return Icons.edit;
      case 'DELETE': return Icons.delete;
      case 'APPROVE': return Icons.check_circle;
      case 'REJECT': return Icons.cancel;
      case 'EXPORT': return Icons.download;
      default: return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'LOGIN': return Colors.blue;
      case 'LOGOUT': return Colors.grey;
      case 'CREATE': return Colors.green;
      case 'UPDATE': return Colors.orange;
      case 'DELETE': return Colors.red;
      case 'APPROVE': return Colors.teal;
      case 'REJECT': return Colors.deepOrange;
      case 'EXPORT': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
