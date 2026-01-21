// lib/screens/employee/all_reports_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../riverpod/employee_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';

/// All Reports Screen - Full list with search, filter, and sort
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class AllReportsScreen extends HookConsumerWidget {
  const AllReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Search controller with auto-dispose
    final searchController = useTextEditingController();

    // ✅ HOOKS: Filter and sort states
    final searchQuery = useState('');
    final selectedStatus = useState<ReportStatus?>(null);
    final urgentOnly = useState(false);
    final sortBy = useState('date_desc');

    // ✅ HOOKS: Listen to search controller changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text.toLowerCase();
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // ✅ HOOKS: Handle navigation arguments (from Speed Dial)
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          if (args['filterStatus'] != null) {
            selectedStatus.value = args['filterStatus'] as ReportStatus;
          }
          if (args['filter'] == 'urgent') {
            urgentOnly.value = true;
          }
        }
      });
      return null;
    }, const []);

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
            onPressed: () => _showSortOptions(context, sortBy),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(
            context,
            searchController,
            searchQuery,
            selectedStatus,
            urgentOnly,
          ),

          // Active Filters Chips
          if (_hasActiveFilters(selectedStatus, urgentOnly))
            _buildActiveFilters(context, selectedStatus, urgentOnly),

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
                final filteredReports = _filterAndSortReports(
                  reports,
                  searchQuery.value,
                  selectedStatus.value,
                  urgentOnly.value,
                  sortBy.value,
                );

                if (filteredReports.isEmpty) {
                  if (_hasActiveFilters(selectedStatus, urgentOnly) ||
                      searchQuery.value.isNotEmpty) {
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
                      return _buildReportCard(context, report);
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

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  static Widget _buildSearchBar(
    BuildContext context,
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
    ValueNotifier<ReportStatus?> selectedStatus,
    ValueNotifier<bool> urgentOnly,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
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
              color: _hasActiveFilters(selectedStatus, urgentOnly)
                  ? AppTheme.primary
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: _hasActiveFilters(selectedStatus, urgentOnly)
                    ? Colors.white
                    : Colors.grey[700],
              ),
              onPressed: () => _showFilterDialog(context, selectedStatus, urgentOnly),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActiveFilters(
    BuildContext context,
    ValueNotifier<ReportStatus?> selectedStatus,
    ValueNotifier<bool> urgentOnly,
  ) {
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
            if (selectedStatus.value != null)
              _buildFilterChip(
                label: selectedStatus.value!.displayName,
                onDelete: () {
                  selectedStatus.value = null;
                },
              ),
            if (urgentOnly.value)
              _buildFilterChip(
                label: 'Urgent',
                onDelete: () {
                  urgentOnly.value = false;
                },
              ),
            // Clear All Button
            TextButton(
              onPressed: () => _clearFilters(selectedStatus, urgentOnly),
              child: const Text('Hapus Semua'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterChip({
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

  static Widget _buildReportCard(BuildContext context, Report report) {
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

  static Widget _buildStatusBadge(ReportStatus status) {
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

  // ==================== DIALOG HANDLERS ====================

  static void _showFilterDialog(
    BuildContext context,
    ValueNotifier<ReportStatus?> selectedStatus,
    ValueNotifier<bool> urgentOnly,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        ReportStatus? tempStatus = selectedStatus.value;
        bool tempUrgentOnly = urgentOnly.value;

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
                      title: const Text('Hanya yang Urgent'),
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
                ElevatedButton(
                  onPressed: () {
                    selectedStatus.value = tempStatus;
                    urgentOnly.value = tempUrgentOnly;
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildStatusFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.primary)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.primary)
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static void _showSortOptions(BuildContext context, ValueNotifier<String> sortBy) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Urutkan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Tanggal (Terbaru)'),
                value: 'date_desc',
                groupValue: sortBy.value,
                onChanged: (value) {
                  sortBy.value = value!;
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Tanggal (Terlama)'),
                value: 'date_asc',
                groupValue: sortBy.value,
                onChanged: (value) {
                  sortBy.value = value!;
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Judul (A-Z)'),
                value: 'title',
                groupValue: sortBy.value,
                onChanged: (value) {
                  sortBy.value = value!;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== FILTER & SORT LOGIC ====================

  static bool _hasActiveFilters(
    ValueNotifier<ReportStatus?> selectedStatus,
    ValueNotifier<bool> urgentOnly,
  ) {
    return selectedStatus.value != null || urgentOnly.value;
  }

  static void _clearFilters(
    ValueNotifier<ReportStatus?> selectedStatus,
    ValueNotifier<bool> urgentOnly,
  ) {
    selectedStatus.value = null;
    urgentOnly.value = false;
  }

  static List<Report> _filterAndSortReports(
    List<Report> reports,
    String searchQuery,
    ReportStatus? selectedStatus,
    bool urgentOnly,
    String sortBy,
  ) {
    var filtered = reports.where((report) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final matchesSearch = report.title.toLowerCase().contains(searchQuery) ||
            report.location.toLowerCase().contains(searchQuery) ||
            (report.description?.toLowerCase().contains(searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (selectedStatus != null && report.status != selectedStatus) {
        return false;
      }

      // Urgent filter
      if (urgentOnly && !report.isUrgent) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (sortBy) {
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

