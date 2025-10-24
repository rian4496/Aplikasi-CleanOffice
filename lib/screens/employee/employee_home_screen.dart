import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ FIXED: Import paths sesuai struktur lib/core/
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../shared/report_detail_screen.dart';
import 'create_report_screen.dart';
import 'report_history_screen.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ReportStatus? _selectedStatusFilter;
  bool _showUrgentOnly = false;
  String _sortBy = 'newest'; // newest, oldest, urgent, location
  
  // 🆕 Undo functionality
  Report? _lastDeletedReport; // Simpan report yang dihapus untuk undo

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== GREETING BASED ON TIME ====================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // ==================== STATISTICS ====================

  Map<String, int> _getStatistics(List<Report> reports) {
    return {
      'total': reports.length,
      'pending': reports.where((r) => r.status == ReportStatus.pending).length,
      'in_progress': reports.where((r) => r.status == ReportStatus.inProgress).length,
      'completed': reports.where((r) => r.status == ReportStatus.completed).length,
      'verified': reports.where((r) => r.status == ReportStatus.verified).length,
      'urgent': reports.where((r) => r.isUrgent).length,
    };
  }

  Widget _buildStatsCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SEARCH & FILTER ====================

  List<Report> _filterAndSortReports(List<Report> reports) {
    var filtered = reports.where((report) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesLocation = report.location.toLowerCase().contains(query);
        final matchesDescription = report.description?.toLowerCase().contains(query) ?? false;
        if (!matchesLocation && !matchesDescription) return false;
      }

      // Status filter
      if (_selectedStatusFilter != null && report.status != _selectedStatusFilter) {
        return false;
      }

      // Urgent filter
      if (_showUrgentOnly && !report.isUrgent) {
        return false;
      }

      return true;
    }).toList();

    // Sort - ✅ FIXED: Pakai report.date
    switch (_sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'urgent':
        filtered.sort((a, b) {
          if (a.isUrgent && !b.isUrgent) return -1;
          if (!a.isUrgent && b.isUrgent) return 1;
          return b.date.compareTo(a.date);
        });
        break;
      case 'location':
        filtered.sort((a, b) => a.location.compareTo(b.location));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urutkan Berdasarkan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Terbaru', 'newest', Icons.access_time),
            _buildSortOption('Terlama', 'oldest', Icons.history),
            _buildSortOption('Urgent', 'urgent', Icons.priority_high),
            _buildSortOption('Lokasi', 'location', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primary : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusFilter('Semua', null, Icons.list),
            _buildStatusFilter('Pending', ReportStatus.pending, Icons.schedule),
            _buildStatusFilter('Dikerjakan', ReportStatus.inProgress, Icons.construction),
            _buildStatusFilter('Selesai', ReportStatus.completed, Icons.check_circle),
            _buildStatusFilter('Terverifikasi', ReportStatus.verified, Icons.verified),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('Hanya Urgent'),
              secondary: const Icon(Icons.priority_high, color: AppTheme.error),
              value: _showUrgentOnly,
              activeColor: AppTheme.error,
              onChanged: (value) {
                setState(() => _showUrgentOnly = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(String label, ReportStatus? status, IconData icon) {
    final isSelected = _selectedStatusFilter == status;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primary : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: () {
        setState(() => _selectedStatusFilter = status);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildActiveFilters() {
    final hasFilters = _selectedStatusFilter != null || _showUrgentOnly || _searchQuery.isNotEmpty;
    
    if (!hasFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_searchQuery.isNotEmpty)
            _buildFilterChip(
              label: 'Pencarian: "$_searchQuery"',
              onRemove: () => setState(() {
                _searchQuery = '';
                _searchController.clear();
              }),
            ),
          if (_selectedStatusFilter != null)
            _buildFilterChip(
              label: _getStatusLabel(_selectedStatusFilter!),
              onRemove: () => setState(() => _selectedStatusFilter = null),
            ),
          if (_showUrgentOnly)
            _buildFilterChip(
              label: 'Urgent',
              color: AppTheme.error,
              onRemove: () => setState(() => _showUrgentOnly = false),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    Color? color,
  }) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      backgroundColor: (color ?? AppTheme.primary).withValues(alpha: 0.1),
      deleteIconColor: color ?? AppTheme.primary,
      labelStyle: TextStyle(color: color ?? AppTheme.primary),
    );
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.assigned:
        return 'Ditugaskan';
      case ReportStatus.inProgress:
        return 'Dikerjakan';
      case ReportStatus.completed:
        return 'Selesai';
      case ReportStatus.verified:
        return 'Terverifikasi';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  // ==================== DELETE REPORT WITH UNDO ====================

  Future<void> _deleteReport(Report report) async {
    try {
      final actions = ref.read(employeeActionsProvider);
      await actions.deleteReport(report.id);

      if (!mounted) return;

      // 🆕 Save deleted report for undo
      setState(() {
        _lastDeletedReport = report;
      });

      // 🆕 Show success snackbar with UNDO option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.reportDeleted),
          duration: const Duration(seconds: 5), // ⏱️ Kasih waktu 5 detik untuk undo
          action: SnackBarAction(
            label: AppStrings.undo,
            onPressed: () {
              // ✅ UNDO: Restore deleted report
              if (_lastDeletedReport != null) {
                _restoreReport(_lastDeletedReport!);
              }
            },
          ),
        ),
      ).closed.then((reason) {
        // 🗑️ Auto-clear setelah SnackBar hilang (jika tidak di-undo)
        if (reason != SnackBarClosedReason.action && mounted) {
          setState(() {
            _lastDeletedReport = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus laporan: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // ==================== RESTORE DELETED REPORT (UNDO) ====================

  Future<void> _restoreReport(Report report) async {
    try {
      final actions = ref.read(employeeActionsProvider);
      
      // ✅ Recreate the report with same data (dengan ID baru)
      await actions.createReport(
        location: report.location,
        description: report.description ?? '',
        imageUrl: report.imageUrl,
        isUrgent: report.isUrgent,
      );

      if (!mounted) return;

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Laporan berhasil dipulihkan'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );

      // 🗑️ Clear the saved report
      setState(() {
        _lastDeletedReport = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulihkan laporan: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // ==================== REPORT LIST ====================

  Widget _buildReportCard(Report report) {
    final statusColor = _getStatusColor(report.status);
    final statusLabel = _getStatusLabel(report.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status Badge + Urgent Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (report.isUrgent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.priority_high, size: 14, color: AppTheme.error),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              color: AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                    onPressed: () => _confirmDelete(report),
                    tooltip: 'Hapus Laporan',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.location,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Description
              if (report.description != null && report.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  report.description!,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Footer: Date + Image indicator - ✅ FIXED: Pakai report.date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.fullDateTime(report.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (report.imageUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.image, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Ada Foto',
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
      case ReportStatus.assigned:
        return AppTheme.warning;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.completed:
      case ReportStatus.verified:
        return AppTheme.success;
      case ReportStatus.rejected:
        return AppTheme.error;
    }
  }

  void _showReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // TODO: [WEEK-1] Create shared ReportDetailScreen
        // For now, navigate to employee-specific screen
        builder: (context) => const Placeholder(), // Replace with actual screen
      ),
    );
  }

  void _confirmDelete(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus laporan ini? Anda bisa membatalkan dalam 5 detik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport(report);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(employeeReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportHistoryScreen(),
                ),
              );
            },
            tooltip: 'Riwayat Laporan',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeReportsProvider);
        },
        child: reportsAsync.when(
          data: (reports) => _buildContent(reports),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(employeeReportsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Placeholder(), // TODO: Replace with CreateReportScreen
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildContent(List<Report> allReports) {
    final stats = _getStatistics(allReports);
    final filteredReports = _filterAndSortReports(allReports);

    return CustomScrollView(
      slivers: [
        // Greeting
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang di ${AppConstants.appName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        // Statistics Cards
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                SizedBox(
                  width: 140,
                  child: _buildStatsCard(
                    title: 'Total Laporan',
                    count: stats['total']!,
                    icon: Icons.description,
                    color: AppTheme.primary,
                    onTap: () => setState(() {
                      _selectedStatusFilter = null;
                      _showUrgentOnly = false;
                    }),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: _buildStatsCard(
                    title: 'Pending',
                    count: stats['pending']!,
                    icon: Icons.schedule,
                    color: AppTheme.warning,
                    onTap: () => setState(() {
                      _selectedStatusFilter = ReportStatus.pending;
                      _showUrgentOnly = false;
                    }),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: _buildStatsCard(
                    title: 'Dikerjakan',
                    count: stats['in_progress']!,
                    icon: Icons.construction,
                    color: Colors.blue,
                    onTap: () => setState(() {
                      _selectedStatusFilter = ReportStatus.inProgress;
                      _showUrgentOnly = false;
                    }),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: _buildStatsCard(
                    title: 'Selesai',
                    count: stats['completed']!,
                    icon: Icons.check_circle,
                    color: AppTheme.success,
                    onTap: () => setState(() {
                      _selectedStatusFilter = ReportStatus.completed;
                      _showUrgentOnly = false;
                    }),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: _buildStatsCard(
                    title: 'Urgent',
                    count: stats['urgent']!,
                    icon: Icons.priority_high,
                    color: AppTheme.error,
                    onTap: () => setState(() {
                      _showUrgentOnly = true;
                      _selectedStatusFilter = null;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    label: 'Buat Laporan',
                    icon: Icons.add_circle_outline,
                    color: AppTheme.primary,
                    onTap: () {
                      // TODO: Navigate to CreateReportScreen
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    label: 'Filter Urgent',
                    icon: Icons.priority_high,
                    color: AppTheme.error,
                    onTap: () => setState(() => _showUrgentOnly = !_showUrgentOnly),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi atau deskripsi...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _showSortOptions,
                  tooltip: 'Urutkan',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
        ),

        // Active Filters
        SliverToBoxAdapter(child: _buildActiveFilters()),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Reports List Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filteredReports.length} Laporan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Reports List
        filteredReports.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty || _selectedStatusFilter != null || _showUrgentOnly
                            ? Icons.search_off
                            : Icons.description_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _selectedStatusFilter != null || _showUrgentOnly
                            ? 'Tidak ada laporan yang sesuai'
                            : 'Belum ada laporan',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedStatusFilter != null || _showUrgentOnly) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedStatusFilter = null;
                              _showUrgentOnly = false;
                            });
                          },
                          child: const Text('Reset Filter'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildReportCard(filteredReports[index]),
                  childCount: filteredReports.length,
                ),
              ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildDrawer() {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: AppTheme.primary),
                ),
                const SizedBox(height: 12),
                profileAsync.when(
                  data: (profile) => Text(
                    profile?.displayName ?? 'Employee',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  loading: () => const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                  error: (_, __) => const Text(
                    'Error',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Text(
                  'Karyawan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Laporan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportHistoryScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text('Keluar', style: TextStyle(color: AppTheme.error)),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && mounted) {
                // ✅ FIXED: Pakai .notifier.logout()
                await ref.read(authActionsProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
    );
  }
}