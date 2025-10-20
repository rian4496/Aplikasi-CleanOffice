// lib/screens/employee/employee_home_screen.dart - WITH END DRAWER and BUILDER

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aplikasi_cleanoffice/models/report.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/employee_providers.dart';
import 'package:aplikasi_cleanoffice/core/constants/app_strings.dart';
import 'package:aplikasi_cleanoffice/widgets/employee/progress_card_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/employee/report_card_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/shared/empty_state_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/shared/drawer_menu_widget.dart'; // <-- Pastikan ini diimpor
import '../../core/constants/app_constants.dart'; // <-- Tambahkan ini jika belum ada
import 'report_detail_screen.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() =>
      _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // State
  String _searchQuery = '';
  ReportStatus? _filterStatus;
  bool _showUrgentOnly = false;
  String _sortBy = 'newest';

  // Temporary list untuk optimistic updates
  final List<Report> _deletedReports = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // ==================== FILTER & SORT LOGIC ====================
  // (Kode _filterAndSortReports tetap sama)
   List<Report> _filterAndSortReports(List<Report> reports) {
    var filtered = reports.where((r) => !_deletedReports.contains(r)).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.location.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((r) => r.status == _filterStatus).toList();
    }

    if (_showUrgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    switch (_sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'urgent':
        filtered.sort((a, b) {
          if (a.isUrgent == b.isUrgent) return b.date.compareTo(a.date);
          return a.isUrgent ? -1 : 1;
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

  // ==================== DELETE WITH UNDO ====================
  // (Kode _handleDelete tetap sama)
  void _handleDelete(Report report) async {
    setState(() {
      _deletedReports.add(report);
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final snackBar = scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(AppStrings.reportDeleted),
        action: SnackBarAction(
          label: AppStrings.undo,
          onPressed: () {
            setState(() {
              _deletedReports.remove(report);
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    final reason = await snackBar.closed;

    if (reason != SnackBarClosedReason.action && mounted) {
      try {
        final actions = ref.read(employeeActionsProvider);
        await actions.deleteReport(report.id);

        if (mounted) {
          setState(() {
            _deletedReports.remove(report);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _deletedReports.remove(report);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.errorDeleteFailed}: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Seharusnya tidak terjadi jika navigasi sudah benar,
      // tapi sebagai fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (context.mounted) Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      });
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context), // AppBar akan dimodifikasi
      // VVV MODIFIKASI: Gunakan endDrawer VVV
      endDrawer: _buildDrawer(context), // Tambahkan endDrawer
      // ^^^ MODIFIKASI ^^^
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate provider untuk refresh data
          ref.invalidate(employeeReportsProvider);
          ref.invalidate(employeeReportsSummaryProvider); // Refresh summary juga
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildProgressCards(summary),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildQuickActions(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchAndFilter(),
              ),
            ),
            reportsAsync.when(
              data: (reports) => _buildReportsList(reports),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ==================== APP BAR (MODIFIED) ====================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false, // Sembunyikan tombol back default
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        // Tambahkan tombol notifikasi jika perlu
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
             Navigator.pushNamed(context, '/notifications');
          },
          tooltip: 'Notifikasi',
        ),
        // VVV MODIFIKASI: Tambahkan Builder dan IconButton menu VVV
        Builder(
          builder: (buttonContext) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(buttonContext).openEndDrawer(); // Buka endDrawer
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        // ^^^ MODIFIKASI ^^^
        const SizedBox(width: 8), // Padding kanan
      ],
    );
  }

  // ==================== DRAWER MENU ====================
  // (Kode _buildDrawer tetap sama, menggunakan DrawerMenuWidget)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: DrawerMenuWidget(
        menuItems: [
          DrawerMenuItem(
            icon: Icons.home_outlined,
            title: 'Beranda',
            onTap: () => Navigator.pop(context),
          ),
          DrawerMenuItem(
            icon: Icons.history,
            title: 'Riwayat Laporan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/request_history');
            },
          ),
          DrawerMenuItem(
            icon: Icons.cleaning_services_outlined,
            title: 'Minta Layanan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/create_request');
            },
          ),
          DrawerMenuItem(
            icon: Icons.person_outline,
            title: 'Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.profileRoute);
            },
          ),
          DrawerMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        onLogout: () => _handleLogout(context),
        roleTitle: 'Karyawan', // Sesuaikan role title jika perlu
      ),
    );
  }

  // ==================== PROGRESS CARDS ====================
  // (Kode _buildProgressCards tetap sama)
   Widget _buildProgressCards(EmployeeReportsSummary summary) {
    return Row(
      children: [
        ProgressCard(
          label: AppStrings.progressSent,
          value: summary.pending.toString(),
          color: AppTheme.info,
          icon: Icons.send_outlined,
          onTap: () => setState(() {
            _filterStatus = ReportStatus.pending;
          }),
        ),
        const SizedBox(width: 12),
        ProgressCard(
          label: AppStrings.progressInProgress,
          value: summary.inProgress.toString(),
          color: AppTheme.warning,
          icon: Icons.pending_actions_outlined,
          onTap: () => setState(() {
            _filterStatus = ReportStatus.inProgress;
          }),
        ),
        const SizedBox(width: 12),
        ProgressCard(
          label: AppStrings.progressCompleted,
          value: summary.completed.toString(),
          color: AppTheme.success,
          icon: Icons.check_circle_outline,
          onTap: () => setState(() {
            _filterStatus = ReportStatus.completed;
          }),
        ),
      ],
    );
  }


  // ==================== QUICK ACTIONS ====================
  // (Kode _buildQuickActions tetap sama)
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Buat Laporan',
            color: AppTheme.primary,
            onTap: () => Navigator.pushNamed(context, '/create_report'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionButton(
            icon: Icons.priority_high,
            label: AppStrings.quickActionUrgent,
            color: AppTheme.error,
            onTap: () => setState(() {
              _showUrgentOnly = !_showUrgentOnly;
            }),
            isActive: _showUrgentOnly,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionButton(
            icon: Icons.sort,
            label: 'Urutkan',
            color: AppTheme.secondary,
            onTap: _showSortDialog,
          ),
        ),
      ],
    );
  }

  // ==================== SEARCH & FILTER ====================
  // (Kode _buildSearchAndFilter tetap sama)
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: AppStrings.searchReports,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
        if (_filterStatus != null || _showUrgentOnly) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (_filterStatus != null)
                Chip(
                  label: Text(_filterStatus!.displayName),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _filterStatus = null),
                  backgroundColor: _filterStatus!.color.withAlpha(50),
                  labelStyle: TextStyle(color: _filterStatus!.color),
                ),
              if (_showUrgentOnly)
                Chip(
                  label: const Text('Urgen'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _showUrgentOnly = false),
                  backgroundColor: AppTheme.error.withAlpha(50),
                  labelStyle: const TextStyle(color: AppTheme.error),
                ),
            ],
          ),
        ],
      ],
    );
  }


  // ==================== REPORTS LIST ====================
  // (Kode _buildReportsList tetap sama)
   Widget _buildReportsList(List<Report> reports) {
    final filteredReports = _filterAndSortReports(reports);

    if (filteredReports.isEmpty) {
      return SliverFillRemaining(
        child: _searchQuery.isNotEmpty
            ? EmptyStateWidget.noSearchResults()
            : EmptyStateWidget.noReports(
                onCreateReport: () =>
                    Navigator.pushNamed(context, '/create_report'),
              ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final report = filteredReports[index];

            return TweenAnimationBuilder<double>(
              key: ValueKey(report.id),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Dismissible(
                key: ValueKey(report.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (direction) => _confirmDelete(context),
                onDismissed: (direction) => _handleDelete(report),
                child: ReportCardWidget(
                  report: report,
                  onTap: () => _navigateToDetail(report),
                  onDelete: () => _showDeleteDialog(report),
                ),
              ),
            );
          },
          childCount: filteredReports.length,
        ),
      ),
    );
  }


  // ==================== LOADING & ERROR STATES ====================
  // (Kode _buildLoadingState dan _buildErrorState tetap sama)
  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildShimmerCard(),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              const Text(
                AppStrings.errorGeneric,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(employeeReportsProvider);
                },
                child: const Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ==================== FAB ====================
  // (Kode _buildFAB tetap sama)
  Widget _buildFAB(BuildContext context) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create_report'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white, // Pastikan warna icon/teks putih
      ),
    );
  }

  // ==================== DIALOGS ====================
  // (Kode _showSortDialog, _confirmDelete, _showDeleteDialog tetap sama)
  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
            SortOption(
              title: AppStrings.sortByNewest,
              isSelected: _sortBy == 'newest',
              onTap: () {
                setState(() => _sortBy = 'newest');
                Navigator.pop(context);
              },
            ),
            SortOption(
              title: AppStrings.sortByOldest,
              isSelected: _sortBy == 'oldest',
              onTap: () {
                setState(() => _sortBy = 'oldest');
                Navigator.pop(context);
              },
            ),
            SortOption(
              title: AppStrings.sortByUrgent,
              isSelected: _sortBy == 'urgent',
              onTap: () {
                setState(() => _sortBy = 'urgent');
                Navigator.pop(context);
              },
            ),
            SortOption(
              title: AppStrings.sortByLocation,
              isSelected: _sortBy == 'location',
              onTap: () {
                setState(() => _sortBy = 'location');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteReport),
        content: const Text(AppStrings.deleteReportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteDialog(Report report) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed) {
      _handleDelete(report);
    }
  }

  // ==================== NAVIGATION ====================
  // (Kode _navigateToDetail dan _handleLogout tetap sama)
   void _navigateToDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          report: report,  // ✅ Pass Report object lengkap, bukan string!
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      // Gunakan pushReplacementNamed agar user tidak bisa kembali ke home setelah logout
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }

} // Penutup class state

// ==================== HELPER WIDGETS ====================
// (Kode QuickActionButton dan SortOption tetap sama)
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha(40) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center, // Tambahkan ini jika perlu
              maxLines: 1, // Pastikan tidak wrap jika label panjang
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SortOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SortOption({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected ? AppTheme.primary.withAlpha(20) : null,
    );
  }
}