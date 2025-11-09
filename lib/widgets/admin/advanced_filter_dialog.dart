// lib/widgets/admin/advanced_filter_dialog.dart
// Advanced filter dialog with multiple filter options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/filter_model.dart';
import '../../models/report.dart';
import '../../providers/riverpod/filter_state_provider.dart';


class AdvancedFilterDialog extends ConsumerStatefulWidget {
  const AdvancedFilterDialog({super.key});

  @override
  ConsumerState<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends ConsumerState<AdvancedFilterDialog> {
  late ReportFilter _tempFilter;
  
  @override
  void initState() {
    super.initState();
    // Initialize with current filter
    final filterState = ref.read(filterProvider);
    _tempFilter = filterState.reportFilter;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Full screen dialog for mobile
      return Dialog.fullscreen(
        child: _buildContent(context),
      );
    } else {
      // Standard dialog for desktop
      return Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildContent(context),
        ),
      );
    }
  }
  
  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_alt, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Filter Lanjutan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Filter
                _buildSection(
                  title: 'Status',
                  icon: Icons.checklist,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReportStatus.values.map((status) {
                      final isSelected = _tempFilter.statuses?.contains(status.toString()) ?? false;
                      return FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        selectedColor: status.color,
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          setState(() {
                            final statuses = List<String>.from(_tempFilter.statuses ?? []);
                            if (selected) {
                              statuses.add(status.toString());
                            } else {
                              statuses.remove(status.toString());
                            }
                            _tempFilter = _tempFilter.copyWith(
                              statuses: statuses.isEmpty ? null : statuses,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Urgent Filter
                _buildSection(
                  title: 'Prioritas',
                  icon: Icons.priority_high,
                  child: SwitchListTile(
                    title: const Text('Hanya Laporan Urgent'),
                    subtitle: const Text('Filter hanya laporan yang ditandai urgent'),
                    value: _tempFilter.isUrgent ?? false,
                    onChanged: (value) {
                      setState(() {
                        _tempFilter = _tempFilter.copyWith(
                          isUrgent: value,
                          clearUrgent: !value,
                        );
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Date Range
                _buildSection(
                  title: 'Rentang Tanggal',
                  icon: Icons.date_range,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                _tempFilter.startDate != null
                                    ? DateFormat('dd MMM yyyy').format(_tempFilter.startDate!)
                                    : 'Dari Tanggal',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onPressed: () => _selectStartDate(context),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward, size: 16),
                          ),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                _tempFilter.endDate != null
                                    ? DateFormat('dd MMM yyyy').format(_tempFilter.endDate!)
                                    : 'Sampai Tanggal',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onPressed: () => _selectEndDate(context),
                            ),
                          ),
                        ],
                      ),
                      if (_tempFilter.startDate != null || _tempFilter.endDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Date Range'),
                          onPressed: () {
                            setState(() {
                              _tempFilter = _tempFilter.copyWith(clearDateRange: true);
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Date Presets
                _buildSection(
                  title: 'Preset Tanggal',
                  icon: Icons.access_time,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDatePreset('Hari Ini', () => _setToday()),
                      _buildDatePreset('Kemarin', () => _setYesterday()),
                      _buildDatePreset('7 Hari Terakhir', () => _setLast7Days()),
                      _buildDatePreset('30 Hari Terakhir', () => _setLast30Days()),
                      _buildDatePreset('Bulan Ini', () => _setThisMonth()),
                      _buildDatePreset('Bulan Lalu', () => _setLastMonth()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Actions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    _tempFilter = const ReportFilter();
                  });
                },
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text('Terapkan (${_tempFilter.activeFilterCount})'),
                onPressed: () {
                  // Apply filter
                  ref.read(filterProvider.notifier).updateFilter(_tempFilter);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  Widget _buildDatePreset(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.event, size: 16),
    );
  }
  
  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempFilter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _tempFilter.endDate ?? DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _tempFilter = _tempFilter.copyWith(startDate: date);
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempFilter.endDate ?? DateTime.now(),
      firstDate: _tempFilter.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _tempFilter = _tempFilter.copyWith(endDate: date);
      });
    }
  }
  
  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    });
  }
  
  void _setYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
        endDate: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
      );
    });
  }
  
  void _setLast7Days() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(weekAgo.year, weekAgo.month, weekAgo.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    });
  }
  
  void _setLast30Days() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(monthAgo.year, monthAgo.month, monthAgo.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    });
  }
  
  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    });
  }
  
  void _setLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        startDate: DateTime(lastMonth.year, lastMonth.month, 1),
        endDate: DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59),
      );
    });
  }
}
