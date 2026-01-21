// lib/screens/web_admin/reports/reports_list_screen.dart
// 📋 Reports List Screen
// Mobile reports management with search, filters, and batch actions

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/web_admin/layout/mobile_admin_app_bar.dart';
import '../../../widgets/web_admin/layout/admin_bottom_nav.dart';
import '../../../widgets/web_admin/search/search_bar_widget.dart';
import '../../../widgets/web_admin/filters/horizontal_filter_chips.dart';
import '../../../widgets/web_admin/cards/mobile_report_card.dart';
import '../../../widgets/web_admin/actions/batch_action_bar.dart';
import '../../../models/report.dart';
import '../../../riverpod/report_providers.dart';

class ReportsListScreen extends HookConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider(null));
    final searchQuery = useState('');
    final selectedFilter = useState('all');
    final selectedReportIds = useState<Set<String>>({});
    final isSelectionMode = selectedReportIds.value.isNotEmpty;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: MobileAdminAppBar(
        title: 'Laporan',
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => selectedReportIds.value = {},
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        actions: isSelectionMode
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showAdvancedFilter(context);
                  },
                ),
                const SizedBox(width: AdminConstants.spaceSm),
              ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            hintText: 'Cari laporan...',
            onChanged: (value) => searchQuery.value = value,
          ),

          // Filter Chips
          HorizontalFilterChips(
            chips: const [
              FilterChipData(id: 'all', label: 'Semua'),
              FilterChipData(id: 'pending', label: 'Pending'),
              FilterChipData(id: 'inprogress', label: 'In Progress'),
              FilterChipData(id: 'needsverify', label: 'Needs Verify'),
              FilterChipData(id: 'verified', label: 'Verified'),
            ],
            selectedChipId: selectedFilter.value,
            onSelected: (chipId) => selectedFilter.value = chipId,
          ),

          const SizedBox(height: AdminConstants.spaceSm),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                // Filter reports
                var filteredReports = _filterReports(
                  reports,
                  searchQuery.value,
                  selectedFilter.value,
                );

                if (filteredReports.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allReportsProvider);
                  },
                  child: ListView.builder(
                    itemCount: filteredReports.length,
                    padding: const EdgeInsets.only(
                      bottom: 80, // Space for batch action bar
                    ),
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      final isSelected =
                          selectedReportIds.value.contains(report.id);

                      return MobileReportCard(
                        report: report,
                        selectable: true,
                        selected: isSelected,
                        onTap: () {
                          // Navigate to report detail
                        },
                        onSelectionChanged: (selected) {
                          final newSelection = Set<String>.from(
                            selectedReportIds.value,
                          );
                          if (selected) {
                            newSelection.add(report.id);
                          } else {
                            newSelection.remove(report.id);
                          }
                          selectedReportIds.value = newSelection;
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(ref, error),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSelectionMode
          ? null
          : AdminBottomNav(
              currentIndex: 1,
              onTap: (index) {
                // Handle navigation
              },
            ),
      bottomSheet: isSelectionMode
          ? BatchActionBar(
              selectedCount: selectedReportIds.value.length,
              actions: [
                BatchAction(
                  icon: Icons.person,
                  label: 'Assign',
                  onTap: () {
                    _handleBatchAssign(
                      context,
                      selectedReportIds.value.toList(),
                    );
                  },
                ),
                BatchAction(
                  icon: Icons.check_circle,
                  label: 'Verify',
                  onTap: () {
                    _handleBatchVerify(
                      context,
                      selectedReportIds.value.toList(),
                    );
                  },
                ),
                BatchAction(
                  icon: Icons.download,
                  label: 'Export',
                  onTap: () {
                    _handleBatchExport(
                      context,
                      selectedReportIds.value.toList(),
                    );
                  },
                ),
              ],
              onClearSelection: () => selectedReportIds.value = {},
            )
          : null,
    );
  }

  List<Report> _filterReports(
    List<Report> reports,
    String query,
    String filter,
  ) {
    var filtered = reports;

    // Filter by status
    if (filter != 'all') {
      filtered = filtered.where((r) {
        final status = r.status.name.toLowerCase().replaceAll(' ', '');
        return status == filter;
      }).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered.where((r) {
        final searchLower = query.toLowerCase();
        return r.id.toLowerCase().contains(searchLower) ||
            r.location.toLowerCase().contains(searchLower) ||
            r.department.toLowerCase().contains(searchLower) ||
            (r.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AdminColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Tidak ada laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            Text(
              'Belum ada laporan yang sesuai dengan filter',
              style: TextStyle(
                color: AdminColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Gagal Memuat Laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceSm),
            Text(
              error.toString(),
              style: TextStyle(
                color: AdminColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(allReportsProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminConstants.radiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Lanjutan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            // TODO: Add advanced filter options
            const Text('Coming soon...'),
            const SizedBox(height: AdminConstants.spaceMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Terapkan Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBatchAssign(BuildContext context, List<String> reportIds) {
    // TODO: Implement batch assign
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assign ${reportIds.length} laporan'),
      ),
    );
  }

  void _handleBatchVerify(BuildContext context, List<String> reportIds) {
    // TODO: Implement batch verify
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verifikasi ${reportIds.length} laporan'),
      ),
    );
  }

  void _handleBatchExport(BuildContext context, List<String> reportIds) {
    // TODO: Implement batch export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export ${reportIds.length} laporan'),
      ),
    );
  }
}

