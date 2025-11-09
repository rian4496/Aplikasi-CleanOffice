// lib/screens/employee/all_reports_screen.dart
// 📋 All Reports Screen - FINAL WITH ARGUMENTS HANDLING
// Full list dengan search, filter, dan sort functionality
// Handles filter arguments from Speed Dial navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';

class AllReportsScreen extends ConsumerStatefulWidget {
  const AllReportsScreen({super.key});

  @override
  ConsumerState<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends ConsumerState<AllReportsScreen> {
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ReportStatus? _selectedStatus;
  bool _urgentOnly = false;
  String _sortBy = 'date_desc'; // date_desc, date_asc, title

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Check for arguments passed from navigation (e.g., from Speed Dial)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          if (args['filterStatus'] != null) {
            _selectedStatus = args['filterStatus'] as ReportStatus;
          }
          if (args['filter'] == 'urgent') {
            _urgentOnly = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(employeeReportsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Semua Laporan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Active Filters Chips
          if (_hasActiveFilters()) _buildActiveFilters(),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorEmptyState(
                title: 'Terjadi kesalahan',
                subtitle: error.toString(),
                onRetry: () => ref.invalidate(employeeReportsProvider),
              ),
              data: (reports) {
                final filteredReports = _filterAndSortReports(reports);

                if (filteredReports.isEmpty) {
                  if (_hasActiveFilters() || _searchQuery.isNotEmpty) {
                    return EmptyStateWidget.noSearchResults();
                  }
                  return EmptyStateWidget.noReports(
                    onCreateReport: () => Navigator.pushNamed(
                      context,
                      '/create_report',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(employeeReportsProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: _hasActiveFilters()
                  ? AppTheme.primary
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: _hasActiveFilters() ? Colors.white : Colors.grey[700],
              ),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIVE FILTERS CHIPS ====================
  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filter: ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedStatus != null)
              _buildFilterChip(
                label: _selectedStatus!.displayName,
                onDelete: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
              ),
            if (_urgentOnly)
              _buildFilterChip(
                label: 'Urgent',
                onDelete: () {
                  setState(() {
                    _urgentOnly = false;
                  });
                },
              ),
            // Clear All Button
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Hapus Semua'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==================== REPORT CARD ====================
  Widget _buildReportCard(Report report) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/report_detail',
          arguments: report,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Urgent Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (report.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: AppTheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Description
            if (report.description != null && report.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                report.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey[200], height: 1),

            const SizedBox(height: 12),

            // Bottom Info Row
            Row(
              children: [
                // Status Badge
                _buildStatusBadge(report.status),
                const Spacer(),
                // Date
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(report.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FILTER DIALOG ====================
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        ReportStatus? tempStatus = _selectedStatus;
        bool tempUrgentOnly = _urgentOnly;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Laporan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // All Status
                        _buildStatusFilterChip(
                          label: 'Semua',
                          isSelected: tempStatus == null,
                          onTap: () {
                            setDialogState(() {
                              tempStatus = null;
                            });
                          },
                        ),
                        // Individual Status
                        ...ReportStatus.values.map((status) {
                          return _buildStatusFilterChip(
                            label: status.displayName,
                            isSelected: tempStatus == status,
                            color: status.color,
                            onTap: () {
                              setDialogState(() {
                                tempStatus = status;
                              });
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Urgent Filter
                    const Text(
                      'Prioritas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Urgent saja'),
                      value: tempUrgentOnly,
                      onChanged: (value) {
                        setDialogState(() {
                          tempUrgentOnly = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempStatus = null;
                      tempUrgentOnly = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _urgentOnly = tempUrgentOnly;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color?.withValues(alpha: 0.2) ?? AppTheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppTheme.primary) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ==================== SORT OPTIONS ====================
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Urutkan Berdasarkan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSortOption(
                title: 'Tanggal Terbaru',
                value: 'date_desc',
                icon: Icons.arrow_downward,
              ),
              _buildSortOption(
                title: 'Tanggal Terlama',
                value: 'date_asc',
                icon: Icons.arrow_upward,
              ),
              _buildSortOption(
                title: 'Judul (A-Z)',
                value: 'title',
                icon: Icons.sort_by_alpha,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _sortBy == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primary : Colors.grey[900],
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppTheme.primary)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // ==================== HELPERS ====================
  bool _hasActiveFilters() {
    return _selectedStatus != null || _urgentOnly;
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _urgentOnly = false;
    });
  }

  List<Report> _filterAndSortReports(List<Report> reports) {
    var filtered = reports;

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final title = report.title.toLowerCase();
        final location = report.location.toLowerCase();
        final description = report.description?.toLowerCase() ?? '';

        return title.contains(_searchQuery) ||
            location.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Status Filter
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    // Urgent Filter
    if (_urgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }
}