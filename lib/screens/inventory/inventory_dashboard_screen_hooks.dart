// lib/screens/inventory/inventory_dashboard_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Inventory Dashboard with analytics and overview

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../models/user_role.dart';
import '../../services/inventory_service.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/web_admin/admin_sidebar.dart';
import '../../widgets/inventory/inventory_form_side_panel.dart';
import '../../widgets/inventory/inventory_detail_dialog.dart';
import '../../widgets/inventory/stock_requests_dialog.dart';
import '../../widgets/inventory/inventory_list_dialog.dart';
import '../../widgets/inventory/inventory_analytics_dialog.dart';
import '../../widgets/inventory/stock_prediction_dialog.dart';
import '../../utils/responsive_ui_helper.dart';
import './inventory_add_edit_screen.dart';
import './inventory_detail_screen.dart';
import './inventory_list_screen.dart';
import './inventory_analytics_screen.dart';
import './stock_prediction_screen.dart';
import './stock_prediction_screen.dart';
import './inventory_request_list_screen.dart';

/// Inventory Dashboard Screen - Main hub with overview and quick actions
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class InventoryDashboardScreen extends HookConsumerWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppTheme.modernBg,

      // ==================== APP BAR (Mobile Only) ====================
      appBar: !isDesktop ? _buildMobileAppBar(context, isAdmin) : null,

      // ==================== DRAWER (Mobile Only) ====================
      drawer: !isDesktop ? Drawer(child: _buildMobileDrawer(context)) : null,

      // ==================== BODY ====================
      body: isDesktop
          ? _buildDesktopLayout(context, isAdmin)
          : _buildMobileLayout(context, isAdmin),

      // ==================== FAB (Mobile Only) ====================
      floatingActionButton: (!isDesktop && isAdmin) ? _buildFAB(context) : null,
    );
  }

  // ==================== STATIC HELPERS: LAYOUT BUILDERS ====================

  /// Build desktop layout with sidebar
  static Widget _buildDesktopLayout(BuildContext context, bool isAdmin) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'inventory'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background)
              _buildDesktopHeader(context, isAdmin),

              // Scrollable Content
              Expanded(
                child: _buildContent(context, isAdmin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build mobile layout
  static Widget _buildMobileLayout(BuildContext context, bool isAdmin) {
    return _buildContent(context, isAdmin);
  }

  /// Build content (shared between desktop and mobile)
  static Widget _buildContent(BuildContext context, bool isAdmin) {
    return StreamBuilder<List<InventoryItem>>(
      stream: InventoryService().streamAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];
        final isDesktop = ResponsiveHelper.isDesktop(context);
        final sectionSpacing = isDesktop ? 32.0 : 24.0;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : ResponsiveHelper.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Remove redundant header on desktop (already have blue header bar)
                if (!isDesktop) ...[
                  _buildHeader(context),
                  SizedBox(height: sectionSpacing),
                ],

                // Summary Cards
                _buildSummaryCards(context, items, isDesktop),
                SizedBox(height: sectionSpacing),

                // Quick Actions
                _buildQuickActions(context, isAdmin),
                SizedBox(height: sectionSpacing),

                // Low Stock Alert
                _buildLowStockAlert(context, items),
                SizedBox(height: sectionSpacing),

                // Category Breakdown
                _buildCategoryBreakdown(context, items, isDesktop),
                SizedBox(height: sectionSpacing),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== MOBILE APP BAR ====================

  static AppBar _buildMobileAppBar(BuildContext context, bool isAdmin) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'Dashboard Inventaris',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        StreamBuilder<List<InventoryItem>>(
          stream: InventoryService().streamLowStockItems(),
          builder: (context, snapshot) {
            final lowStockCount = snapshot.data?.length ?? 0;

            return Badge(
              label: Text(lowStockCount.toString()),
              isLabelVisible: lowStockCount > 0,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.list_alt, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/inventory_list');
                },
                tooltip: 'Lihat Semua Item',
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================== DESKTOP HEADER (Blue Bar) ====================

  static Widget _buildDesktopHeader(BuildContext context, bool isAdmin) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Title
            const Text(
              'Dashboard Inventaris',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Add Item Button (Admin only)
            if (isAdmin) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await ResponsiveUIHelper.showFormView(
                    context: context,
                    mobileScreen: const InventoryAddEditScreen(),
                    webDialog: const InventoryFormSidePanel(),
                  );
                  // Note: Refresh handled by StreamBuilder
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // View All Items Button
            StreamBuilder<List<InventoryItem>>(
              stream: InventoryService().streamLowStockItems(),
              builder: (context, snapshot) {
                final lowStockCount = snapshot.data?.length ?? 0;

                return Badge(
                  label: Text(lowStockCount.toString()),
                  isLabelVisible: lowStockCount > 0,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.list_alt, color: Colors.white, size: 22),
                    onPressed: () {
                      Navigator.pushNamed(context, '/inventory_list');
                    },
                    tooltip: 'Lihat Semua Item',
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // Notification Icon
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            const SizedBox(width: 16),

            // Profile Avatar
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MOBILE DRAWER ====================

  static Widget _buildMobileDrawer(BuildContext context) {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.dashboard,
          title: 'Dashboard Admin',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home_admin',
              (route) => false,
            );
          },
        ),
        DrawerMenuItem(
          icon: Icons.analytics,
          title: 'Analitik',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/analytics');
          },
        ),
        DrawerMenuItem(
          icon: Icons.assignment_outlined,
          title: 'Kelola Laporan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.room_service_outlined,
          title: 'Kelola Permintaan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/requests_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.people_outline,
          title: 'Kelola Petugas',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/cleaner_management');
          },
        ),
        DrawerMenuItem(
          icon: Icons.inventory_2,
          title: 'Inventaris',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.list,
          title: 'Daftar Item',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/inventory_list');
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
      onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
      roleTitle: 'Administrator',
    );
  }

  // ==================== HEADER ====================

  static Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Inventaris',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitoring stok dan manajemen inventaris',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUMMARY CARDS ====================

  static Widget _buildSummaryCards(
      BuildContext context, List<InventoryItem> items, bool isDesktop) {
    final totalItems = items.length;
    final lowStockItems = items
        .where((i) =>
            i.status == StockStatus.lowStock || i.status == StockStatus.outOfStock)
        .length;
    final outOfStockItems =
        items.where((i) => i.status == StockStatus.outOfStock).length;
    final totalStockValue = items.fold(0, (sum, item) => sum + item.currentStock);

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isDesktop ? 20 : 16,
      mainAxisSpacing: isDesktop ? 20 : 16,
      childAspectRatio: isDesktop ? 1.3 : 1.2,
      children: [
        _buildSummaryCard(
          icon: Icons.inventory_2_rounded,
          label: 'Total Item',
          value: totalItems.toString(),
          color: AppTheme.primary,
          isDesktop: isDesktop,
        ),
        _buildSummaryCard(
          icon: Icons.trending_down_rounded,
          label: 'Stok Menipis',
          value: lowStockItems.toString(),
          color: AppTheme.warning,
          isDesktop: isDesktop,
        ),
        _buildSummaryCard(
          icon: Icons.remove_circle_rounded,
          label: 'Habis',
          value: outOfStockItems.toString(),
          color: AppTheme.error,
          isDesktop: isDesktop,
        ),
        _buildSummaryCard(
          icon: Icons.assessment_rounded,
          label: 'Total Stok',
          value: NumberFormat.compact().format(totalStockValue),
          color: AppTheme.info,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  static Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDesktop,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDesktop ? () {} : null,
        borderRadius: BorderRadius.circular(12),
        hoverColor: isDesktop ? color.withValues(alpha: 0.03) : null,
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 32 : 24,
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isDesktop ? 6 : 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================

  static Widget _buildQuickActions(BuildContext context, bool isAdmin) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.primary, size: isDesktop ? 24 : 20),
              const SizedBox(width: 8),
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 16),

          // Responsive Grid Layout
          isDesktop
              ? _buildDesktopActionsGrid(context, isAdmin)
              : _buildMobileActionsGrid(context, isAdmin),
        ],
      ),
    );
  }

  // Desktop: 3-column grid with large cards
  static Widget _buildDesktopActionsGrid(BuildContext context, bool isAdmin) {
    final actions = _getActionsList(context, isAdmin);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: actions
          .map((action) => _buildActionCard(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                subtitle: action['subtitle'] as String?,
                color: action['color'] as Color,
                onPressed: action['onPressed'] as VoidCallback,
              ))
          .toList(),
    );
  }

  // Mobile: 2-column compact grid
  static Widget _buildMobileActionsGrid(BuildContext context, bool isAdmin) {
    final actions = _getActionsList(context, isAdmin);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: actions
          .map((action) => _buildCompactActionCard(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                color: action['color'] as Color,
                onPressed: action['onPressed'] as VoidCallback,
              ))
          .toList(),
    );
  }

  // Get actions list based on user role
  static List<Map<String, dynamic>> _getActionsList(BuildContext context, bool isAdmin) {
    final actions = <Map<String, dynamic>>[];

    if (isAdmin) {
      actions.add({
        'icon': Icons.add_circle_rounded,
        'label': 'Tambah Item',
        'subtitle': 'Buat item baru',
        'color': AppTheme.success,
        'onPressed': () async {
          await ResponsiveUIHelper.showFormView(
            context: context,
            mobileScreen: const InventoryAddEditScreen(),
            webDialog: const InventoryFormSidePanel(),
          );
        },
      });
    }

    actions.addAll([
      {
        'icon': Icons.shopping_cart_rounded,
        'label': isAdmin ? 'Kelola Permintaan' : 'Permintaan Saya',
        'subtitle': isAdmin ? 'Atur permintaan stok' : 'Lihat status',
        'color': AppTheme.info,
        'onPressed': () {
          ResponsiveUIHelper.showWideDialog(
            context: context,
            mobileScreen: const InventoryRequestListScreen(),
            webDialog: const StockRequestsDialog(),
          );
        },
      },
      {
        'icon': Icons.view_list_rounded,
        'label': 'Semua Item',
        'subtitle': 'Daftar lengkap',
        'color': AppTheme.primary,
        'onPressed': () {
          ResponsiveUIHelper.showWideDialog(
            context: context,
            mobileScreen: const InventoryListScreen(),
            webDialog: const InventoryListDialog(),
          );
        },
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Analitik',
        'subtitle': 'Laporan & grafik',
        'color': Colors.deepPurple,
        'onPressed': () {
          ResponsiveUIHelper.showWideDialog(
            context: context,
            mobileScreen: const InventoryAnalyticsScreen(),
            webDialog: const InventoryAnalyticsDialog(),
          );
        },
      },
    ]);

    if (isAdmin) {
      actions.add({
        'icon': Icons.insights_rounded,
        'label': 'Prediksi Stok',
        'subtitle': 'AI prediction (Beta)',
        'color': Colors.teal,
        'onPressed': () {
          ResponsiveUIHelper.showWideDialog(
            context: context,
            mobileScreen: const StockPredictionScreen(),
            webDialog: const StockPredictionDialog(),
          );
        },
      });
    }

    return actions;
  }

  // Desktop Action Card with gradient and hover effect
  static Widget _buildActionCard({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Compact Action Card
  static Widget _buildCompactActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOW STOCK ALERT ====================

  static Widget _buildLowStockAlert(BuildContext context, List<InventoryItem> items) {
    final lowStockItems = items
        .where((i) =>
            i.status == StockStatus.lowStock || i.status == StockStatus.outOfStock)
        .toList();

    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: AppTheme.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Peringatan Stok Menipis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${lowStockItems.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.length > 5 ? 5 : lowStockItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = lowStockItems[index];
              return InkWell(
                onTap: () {
                  ResponsiveUIHelper.showDetailView(
                    context: context,
                    mobileScreen: InventoryDetailScreen(itemId: item.id),
                    webDialog: InventoryDetailDialog(item: item),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.currentStock} ${item.unit} (Min: ${item.minStock})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: item.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (lowStockItems.length > 5) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inventory_list');
              },
              child: Text('Lihat semua (${lowStockItems.length - 5} lainnya)'),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== CATEGORY BREAKDOWN ====================

  static Widget _buildCategoryBreakdown(
      BuildContext context, List<InventoryItem> items, bool isDesktop) {
    final categories = ItemCategory.values;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Breakdown per Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryItems =
                  items.where((i) => i.category == category.name).toList();
              final totalStock =
                  categoryItems.fold(0, (sum, item) => sum + item.currentStock);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: category.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(category.icon, color: category.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${categoryItems.length}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: category.color,
                                ),
                              ),
                              Text(
                                ' item',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$totalStock stok',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== ERROR ====================

  static Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  // ==================== FAB ====================

  static Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await ResponsiveUIHelper.showFormView(
          context: context,
          mobileScreen: const InventoryAddEditScreen(),
          webDialog: const InventoryFormSidePanel(),
        );
      },
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Tambah Item',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

