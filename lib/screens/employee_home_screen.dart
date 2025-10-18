// lib/screens/employee_home_screen.dart - FIXED VERSION

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aplikasi_cleanoffice/models/report_model.dart';
import 'package:aplikasi_cleanoffice/models/report_status_enum.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/employee_providers.dart';
import 'package:aplikasi_cleanoffice/core/constants/app_strings.dart';
import 'package:aplikasi_cleanoffice/widgets/employee/progress_card_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/employee/report_card_widget.dart';
import 'package:aplikasi_cleanoffice/widgets/employee/empty_state_widget.dart';
import 'report_detail_screen.dart';

/// REFACTORED Employee Home Screen dengan:
/// - Enhanced UI/UX dengan animations
/// - Search & Filter functionality
/// - Quick action buttons
/// - Optimistic updates
/// - Better loading states
/// - Improved code organization
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
  String _sortBy = 'newest'; // newest, oldest, urgent, location

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

// ==================== DRAWER MENU ====================

Widget _buildDrawer(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return Drawer(
    child: Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header dengan profil user
          _buildDrawerHeader(user),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Beranda',
                  onTap: () {
                    Navigator.pop(context); // Tutup drawer
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Riwayat Laporan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/request_history');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.cleaning_services_outlined,
                  title: 'Minta Layanan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create_request');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/settings');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur belum tersedia')),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout(context);
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerHeader(User? user) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white, // Warna latar belakang header
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey[300],
          child: user?.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    user!.photoURL!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.grey[600],
                ),
        ),
        const SizedBox(height: 12),
        
        // Nama
        Text(
          user?.displayName ?? 'User',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        
        // Email
        Text(
          user?.email ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isLogout = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isLogout ? AppTheme.error : Colors.grey[700],
      size: 24,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: isLogout ? AppTheme.error : Colors.grey[900],
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  );
}

  // ==================== FILTER & SORT LOGIC ====================

  List<Report> _filterAndSortReports(List<Report> reports) {
    var filtered = reports.where((r) => !_deletedReports.contains(r)).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.location.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((r) => r.status == _filterStatus).toList();
    }

    // Filter urgent only
    if (_showUrgentOnly) {
      filtered = filtered.where((r) => r.isUrgent).toList();
    }

    // Sort
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

  void _handleDelete(Report report) async {
    // Add to deleted list (optimistic update)
    setState(() {
      _deletedReports.add(report);
    });

    // Show snackbar with undo
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    
    final snackBar = scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(AppStrings.reportDeleted),
        action: SnackBarAction(
          label: AppStrings.undo,
          onPressed: () {
            // Undo delete
            setState(() {
              _deletedReports.remove(report);
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    // Wait for snackbar to close
    final reason = await snackBar.closed;
    
    // If not undone, actually delete from database
    if (reason != SnackBarClosedReason.action && mounted) {
      try {
        final actions = ref.read(employeeActionsProvider);
        await actions.deleteReport(report.id);
        
        // Remove from deleted list after successful delete
        if (mounted) {
          setState(() {
            _deletedReports.remove(report);
          });
        }
      } catch (e) {
        if (mounted) {
          // Restore if delete failed
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
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    final reportsAsync = ref.watch(employeeReportsProvider);
    final summaryAsync = ref.watch(employeeReportsSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      endDrawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeReportsProvider);
          ref.invalidate(employeeReportsSummaryProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Progress Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildProgressCards(summaryAsync),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildQuickActions(context),
              ),
            ),

            // Search & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchAndFilter(),
              ),
            ),

            // Reports List
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

  // ==================== APP BAR ====================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // ==================== PROGRESS CARDS ====================

  Widget _buildProgressCards(AsyncValue<EmployeeReportsSummary> summaryAsync) {
    return summaryAsync.when(
      data: (summary) => Row(
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
      ),
      loading: () => _buildProgressSkeleton(),
      error: (error, stackTrace) => _buildProgressSkeleton(),
    );
  }

  Widget _buildProgressSkeleton() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Card(
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ==================== QUICK ACTIONS ====================

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

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search Bar
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
        
        // Active Filters
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

  Widget _buildFAB(BuildContext context) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create_report'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  // ==================== DIALOGS ====================

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

  void _navigateToDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          title: report.location,
          date: report.date.toString(),
          status: report.status.displayName,
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
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// ==================== HELPER WIDGETS ====================
// Note: Widgets ini di luar class _EmployeeHomeScreenState

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