// lib/widgets/admin/batch_action_bar.dart
// Bottom action bar for batch operations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/selection_state_provider.dart';
import '../../services/batch_service.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';

class BatchActionBar extends ConsumerWidget {
  final VoidCallback onClose;
  
  const BatchActionBar({
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = ref.watch(selectionProvider).selectedCount;
    final selectedIds = ref.watch(selectionProvider).selectedIds.toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ref.read(selectionProvider.notifier).clearSelection();
                onClose();
              },
              tooltip: 'Close selection',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$selectedCount dipilih',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Actions
            _buildActionButton(
              context,
              ref,
              icon: Icons.verified_user,
              label: 'Verify',
              tooltip: 'Verify selected reports',
              onPressed: () => _bulkVerify(context, ref, selectedIds.toList()),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              icon: Icons.person_add,
              label: 'Assign',
              tooltip: 'Assign to cleaner',
              onPressed: () => _showAssignDialog(context, ref, selectedIds.toList()),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              tooltip: 'More actions',
              onSelected: (value) {
                switch (value) {
                  case 'mark_urgent':
                    _bulkMarkUrgent(context, ref, selectedIds.toList(), true);
                    break;
                  case 'unmark_urgent':
                    _bulkMarkUrgent(context, ref, selectedIds.toList(), false);
                    break;
                  case 'delete':
                    _bulkDelete(context, ref, selectedIds.toList());
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_urgent',
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Mark Urgent'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'unmark_urgent',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline),
                      SizedBox(width: 12),
                      Text('Unmark Urgent'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.white,
        foregroundColor: color != null ? Colors.white : AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  Future<void> _bulkVerify(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Verifying ${ids.length} reports...'),
          ],
        ),
      ),
    );
    
    try {
      await ref.read(batchServiceProvider).bulkVerify(ids);
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ref.read(selectionProvider.notifier).clearSelection();
        onClose();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${ids.length} reports verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _bulkMarkUrgent(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
    bool isUrgent,
  ) async {
    try {
      await ref.read(batchServiceProvider).bulkMarkUrgent(ids, isUrgent);
      
      if (context.mounted) {
        ref.read(selectionProvider.notifier).clearSelection();
        onClose();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUrgent
                  ? '✓ ${ids.length} reports marked as urgent'
                  : '✓ ${ids.length} reports unmarked as urgent',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${ids.length} reports permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Deleting ${ids.length} reports...'),
            ],
          ),
        ),
      );
      
      try {
        await ref.read(batchServiceProvider).bulkDelete(ids);
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ref.read(selectionProvider.notifier).clearSelection();
          onClose();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${ids.length} reports deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  void _showAssignDialog(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) {
    final cleanersAsync = ref.watch(availableCleanersProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign ke Petugas'),
        content: SizedBox(
          width: 300,
          child: cleanersAsync.when(
            data: (cleaners) {
              if (cleaners.isEmpty) {
                return const Text('Tidak ada petugas yang tersedia');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih petugas untuk ${ids.length} laporan:'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cleaners.length,
                      itemBuilder: (context, index) {
                        final cleaner = cleaners[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(cleaner.name[0].toUpperCase()),
                          ),
                          title: Text(cleaner.name),
                          subtitle: Text('Tugas aktif: ${cleaner.activeTaskCount}'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            Navigator.pop(context);
                            // Assign all selected reports to this cleaner
                            await _batchAssignToCleaner(context, ref, ids, cleaner);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Text('Error: $error'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _batchAssignToCleaner(
    BuildContext context,
    WidgetRef ref,
    List<String> reportIds,
    CleanerProfile cleaner,
  ) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mengassign laporan...')),
        );
      }

      final actions = ref.read(verificationActionsProvider);
      
      // Assign each report to the cleaner
      for (final reportId in reportIds) {
        // Get report first
        final report = await ref.read(reportByIdProvider(reportId).future);
        if (report != null) {
          await actions.assignToCleaner(report, cleaner.id, cleaner.name);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reportIds.length} laporan berhasil di-assign ke ${cleaner.name}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh after successful assignment
        onClose();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
