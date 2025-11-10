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
        // Header - Improved
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_alt, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Filter Lanjutan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Tutup',
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
                // Status Filter - Improved
                _buildSection(
                  title: 'Status',
                  icon: Icons.checklist_rounded,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ReportStatus.values.map((status) {
                      final isSelected = _tempFilter.statuses?.contains(status.toString()) ?? false;
                      return FilterChip(
                        label: Text(
                          status.displayName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: status.color.withOpacity(0.9),
                        backgroundColor: Colors.grey[100],
                        checkmarkColor: Colors.white,
                        elevation: isSelected ? 2 : 0,
                        shadowColor: status.color.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                
                // Urgent Filter - Improved
                _buildSection(
                  title: 'Prioritas',
                  icon: Icons.priority_high_rounded,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (_tempFilter.isUrgent ?? false) 
                          ? Colors.red[50] 
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_tempFilter.isUrgent ?? false)
                            ? Colors.red[300]!
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: (_tempFilter.isUrgent ?? false) 
                                ? Colors.red[700] 
                                : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hanya Laporan Urgent',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: (_tempFilter.isUrgent ?? false)
                                  ? Colors.red[900]
                                  : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 28, top: 4),
                        child: Text(
                          'Filter hanya laporan yang ditandai urgent',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      value: _tempFilter.isUrgent ?? false,
                      activeTrackColor: Colors.red[700],
                      onChanged: (value) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(
                            isUrgent: value,
                            clearUrgent: !value,
                          );
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Date Range - Improved
                _buildSection(
                  title: 'Rentang Tanggal',
                  icon: Icons.date_range_rounded,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDateButton(
                                context: context,
                                icon: Icons.event_rounded,
                                label: _tempFilter.startDate != null
                                    ? DateFormat('dd MMM yyyy', 'id_ID').format(_tempFilter.startDate!)
                                    : 'Dari Tanggal',
                                onPressed: () => _selectStartDate(context),
                                hasDate: _tempFilter.startDate != null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.blue[700],
                              ),
                            ),
                            Expanded(
                              child: _buildDateButton(
                                context: context,
                                icon: Icons.event_rounded,
                                label: _tempFilter.endDate != null
                                    ? DateFormat('dd MMM yyyy', 'id_ID').format(_tempFilter.endDate!)
                                    : 'Sampai Tanggal',
                                onPressed: () => _selectEndDate(context),
                                hasDate: _tempFilter.endDate != null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_tempFilter.startDate != null || _tempFilter.endDate != null) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          label: const Text(
                            'Hapus Rentang Tanggal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
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
                
                // Quick Date Presets - Improved
                _buildSection(
                  title: 'Preset Tanggal',
                  icon: Icons.access_time_rounded,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildDatePreset('Hari Ini', () => _setToday(), Icons.today_rounded),
                        _buildDatePreset('Kemarin', () => _setYesterday(), Icons.history_rounded),
                        _buildDatePreset('7 Hari Terakhir', () => _setLast7Days(), Icons.calendar_view_week_rounded),
                        _buildDatePreset('30 Hari Terakhir', () => _setLast30Days(), Icons.calendar_view_month_rounded),
                        _buildDatePreset('Bulan Ini', () => _setThisMonth(), Icons.calendar_month_rounded),
                        _buildDatePreset('Bulan Lalu', () => _setLastMonth(), Icons.skip_previous_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Actions - Improved
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Reset',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                onPressed: () {
                  setState(() {
                    _tempFilter = const ReportFilter();
                  });
                },
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  'Terapkan (${_tempFilter.activeFilterCount})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 2,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
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
  
  Widget _buildDateButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool hasDate,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        backgroundColor: hasDate ? Colors.white : Colors.blue[50],
        side: BorderSide(
          color: hasDate ? Colors.blue[600]! : Colors.blue[300]!,
          width: hasDate ? 2 : 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: hasDate ? Colors.blue[700] : Colors.blue[500],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.w500,
                color: hasDate ? Colors.blue[900] : Colors.blue[700],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDatePreset(String label, VoidCallback onTap, IconData icon) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
      avatar: Icon(icon, size: 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.3),
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
