import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../core/theme/app_theme.dart';

class AdvancedFilterDialog extends ConsumerStatefulWidget {
  const AdvancedFilterDialog({super.key});

  @override
  ConsumerState<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends ConsumerState<AdvancedFilterDialog> {
  late ReportFilterState _tempFilter;
  
  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(reportFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Lanjutan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Status Filter
            Text('Status', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportStatus.values.map((status) {
                final isSelected = _tempFilter.statusFilter?.contains(status) ?? false;
                return FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final statuses = List<ReportStatus>.from(_tempFilter.statusFilter ?? []);
                      if (selected) {
                        statuses.add(status);
                      } else {
                        statuses.remove(status);
                      }
                      _tempFilter = _tempFilter.copyWith(statusFilter: statuses);
                    });
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primary : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Urgent Filter
            SwitchListTile(
              title: const Text('Hanya Urgent'),
              value: _tempFilter.showUrgentOnly,
              activeColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(showUrgentOnly: value);
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date Range
            Text('Rentang Tanggal', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _tempFilter.startDate != null
                          ? DateFormat('dd MMM yyyy').format(_tempFilter.startDate!)
                          : 'Dari',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _tempFilter.startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(startDate: date);
                        });
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _tempFilter.endDate != null
                          ? DateFormat('dd MMM yyyy').format(_tempFilter.endDate!)
                          : 'Sampai',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _tempFilter.endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(endDate: date);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(reportFilterProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    final notifier = ref.read(reportFilterProvider.notifier);
                    notifier.setStatusFilter(_tempFilter.statusFilter);
                    notifier.setDateRange(_tempFilter.startDate, _tempFilter.endDate);
                    if (_tempFilter.showUrgentOnly != ref.read(reportFilterProvider).showUrgentOnly) {
                      notifier.toggleUrgentFilter();
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terapkan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
