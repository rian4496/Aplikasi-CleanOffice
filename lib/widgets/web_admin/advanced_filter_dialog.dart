import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../core/theme/app_theme.dart';

class AdvancedFilterDialog extends ConsumerStatefulWidget {
  final bool showSortOptions;

  const AdvancedFilterDialog({
    super.key,
    this.showSortOptions = true,
  });

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
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (Fixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort & Filter',
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(),
            ),

            // Scrollable Content
            Flexible(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thickness: WidgetStateProperty.all(4),
                  radius: const Radius.circular(2),
                  thumbColor: WidgetStateProperty.all(Colors.grey[300]),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort By Section
                        if (widget.showSortOptions) ...[
                          Text('Urutkan', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSortChip(ReportSortBy.newest, 'Terbaru', Icons.schedule),
                              _buildSortChip(ReportSortBy.oldest, 'Terlama', Icons.history),
                              _buildSortChip(ReportSortBy.urgent, 'Urgent', Icons.priority_high),
                              _buildSortChip(ReportSortBy.location, 'Lokasi', Icons.location_on),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

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
                              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
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
                          activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                          activeThumbColor: AppTheme.primary,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
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
                      notifier.setSortBy(_tempFilter.sortBy);
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(ReportSortBy sortBy, String label, IconData icon) {
    final isSelected = _tempFilter.sortBy == sortBy;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _tempFilter = _tempFilter.copyWith(sortBy: sortBy);
          });
        }
      },
      selectedColor: AppTheme.primary,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}

