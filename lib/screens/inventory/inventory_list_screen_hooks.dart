// lib/screens/inventory/inventory_list_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/inventory_item.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/inventory_selection_provider.dart';
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/inventory/batch_action_bar.dart';
import '../../widgets/inventory/inventory_detail_dialog.dart';
import '../../widgets/inventory/category_filter_chips.dart';
import '../../widgets/inventory/inventory_stats_card.dart';
import '../../widgets/inventory/low_stock_alert_banner.dart';
import '../../widgets/inventory/inventory_empty_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/responsive_ui_helper.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';
import './inventory_detail_screen.dart';

/// Inventory List Screen - List with search, filters, sorting, and batch actions
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class InventoryListScreen extends HookConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management
    final searchQuery = useState('');
    final selectedCategory = useState<InventoryCategory>(InventoryCategory.all);
    final selectedStatus = useState<StockStatus?>(null);
    final sortBy = useState('name'); // 'name', 'stock', 'category'

    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${selectedIds.length} dipilih')
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Semua Inventaris',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Kelola dan pantau semua item',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Hapus tombol back
        automaticallyImplyLeading: false,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).disable();
                },
              )
            : null,
        actions: [
          if (isSelectionMode)
            TextButton(
              onPressed: () {
                // Select all
                itemsAsync.whenData((items) {
                  final filtered = _filterItems(
                    items,
                    searchQuery.value,
                    selectedCategory.value,
                    selectedStatus.value,
                    sortBy.value,
                  );
                  ref
                      .read(inventorySelectionProvider.notifier)
                      .selectAll(filtered.map((e) => e.id).toList());
                });
              },
              child: const Text(
                'Pilih Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Compact search bar with filter & sort icons
          _buildCompactSearchBar(
            context,
            ref,
            searchQuery,
            selectedCategory,
            selectedStatus,
            sortBy,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _filterItems(
                  items,
                  searchQuery.value,
                  selectedCategory.value,
                  selectedStatus.value,
                  sortBy.value,
                );

                // Calculate stats
                final lowStockItems = items.where((item) =>
                  item.status == StockStatus.lowStock
                ).toList();
                final outOfStockItems = items.where((item) =>
                  item.status == StockStatus.outOfStock
                ).toList();

                if (filtered.isEmpty) {
                  // Show appropriate empty state
                  final hasFilters = searchQuery.value.isNotEmpty ||
                    selectedCategory.value != InventoryCategory.all ||
                    selectedStatus.value != null;

                  if (hasFilters) {
                    return InventoryEmptyState.filtered(
                      onClearFilter: () {
                        searchQuery.value = '';
                        selectedCategory.value = InventoryCategory.all;
                        selectedStatus.value = null;
                      },
                    );
                  } else {
                    return InventoryEmptyState.noItems();
                  }
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allInventoryItemsProvider);
                  },
                  child: ListView.builder(
                    itemCount: filtered.length + 2, // +2 for stats card and alert banner
                    itemBuilder: (context, index) {
                      // Stats card at index 0
                      if (index == 0) {
                        return InventoryStatsCard(
                          totalItems: items.length,
                          lowStockCount: lowStockItems.length,
                          outOfStockCount: outOfStockItems.length,
                          totalValue: 0, // TODO: Calculate total value
                        );
                      }

                      // Alert banner at index 1 (only if there are low stock items)
                      if (index == 1) {
                        if (lowStockItems.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return LowStockAlertBanner(
                          lowStockItems: lowStockItems,
                          onViewAll: () {
                            selectedStatus.value = StockStatus.lowStock;
                          },
                        );
                      }

                      // Inventory cards start from index 2
                      final itemIndex = index - 2;
                      final item = filtered[itemIndex];
                      final isSelected = selectedIds.contains(item.id);

                      return InventoryCard(
                        item: item,
                        index: itemIndex, // For pastel background rotation
                        isSelectionMode: isSelectionMode,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelectionMode) {
                            // Toggle selection
                            ref
                                .read(inventorySelectionProvider.notifier)
                                .toggleItem(item.id);
                          } else {
                            // Show detail dengan platform-specific UI
                            ResponsiveUIHelper.showDetailView(
                              context: context,
                              mobileScreen:
                                  InventoryDetailScreen(itemId: item.id),
                              webDialog: InventoryDetailDialog(item: item),
                            );
                          }
                        },
                        onAddStock: () {
                          // TODO: Implement add stock dialog
                        },
                        onEdit: () {
                          // TODO: Navigate to edit screen
                        },
                        onMore: () {
                          // TODO: Show more options
                        },
                        onLongPress: () {
                          if (!isSelectionMode) {
                            // Enable selection mode on long press
                            ref.read(selectionModeProvider.notifier).enable();
                            ref
                                .read(inventorySelectionProvider.notifier)
                                .selectItem(item.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSelectionMode
          ? itemsAsync.maybeWhen(
              data: (items) => BatchActionBar(
                allItems: items,
                onActionComplete: () {
                  ref.invalidate(allInventoryItemsProvider);
                },
              ),
              orElse: () => const SizedBox.shrink(),
            )
          : (!isDesktop ? _buildBottomNavBar(context, ref) : null),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Compact search bar with filter & sort icons
  static Widget _buildCompactSearchBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String> searchQuery,
    ValueNotifier<InventoryCategory> selectedCategory,
    ValueNotifier<StockStatus?> selectedStatus,
    ValueNotifier<String> sortBy,
  ) {
    final hasActiveFilters = selectedCategory.value != InventoryCategory.all || selectedStatus.value != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Search icon
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.search, color: Colors.grey[400], size: 22),
            ),
            // Search input
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari item inventaris...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                onChanged: (value) => searchQuery.value = value,
              ),
            ),
            // Clear button (if searching)
            if (searchQuery.value.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () => searchQuery.value = '',
              ),
            // Divider
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
            ),
            // Filter icon button with badge
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFilterDialog(context, selectedCategory, selectedStatus, sortBy),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.tune,
                        color: hasActiveFilters ? AppTheme.primary : Colors.grey[600],
                        size: 22,
                      ),
                      if (hasActiveFilters)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show filter dialog (centered, scrollable)
  static void _showFilterDialog(
    BuildContext context,
    ValueNotifier<InventoryCategory> selectedCategory,
    ValueNotifier<StockStatus?> selectedStatus,
    ValueNotifier<String> sortBy,
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Inventaris',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        selectedCategory.value = InventoryCategory.all;
                        selectedStatus.value = null;
                        setModalState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category dropdown
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.grey[200],
                    hoverColor: Colors.grey[100],
                    focusColor: Colors.grey[200],
                    splashColor: Colors.grey[100],
                  ),
                  child: DropdownButtonFormField<InventoryCategory>(
                    initialValue: selectedCategory.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    items: const [
                    DropdownMenuItem(
                      value: InventoryCategory.all,
                      child: Row(
                        children: [
                          Icon(Icons.select_all, size: 20, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Semua Kategori'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: InventoryCategory.alat,
                      child: Row(
                        children: [
                          Icon(Icons.cleaning_services, size: 20, color: Color(0xFF3B82F6)),
                          SizedBox(width: 12),
                          Text('Alat Kebersihan'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: InventoryCategory.consumable,
                      child: Row(
                        children: [
                          Icon(Icons.inventory, size: 20, color: Color(0xFF10B981)),
                          SizedBox(width: 12),
                          Text('Bahan Habis Pakai'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: InventoryCategory.ppe,
                      child: Row(
                        children: [
                          Icon(Icons.safety_check, size: 20, color: Color(0xFFF59E0B)),
                          SizedBox(width: 12),
                          Text('APD'),
                        ],
                      ),
                    ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory.value = value;
                        setModalState(() {});
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Status dropdown
                const Text(
                  'Status Stok',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.grey[200],
                    hoverColor: Colors.grey[100],
                    focusColor: Colors.grey[200],
                    splashColor: Colors.grey[100],
                  ),
                  child: DropdownButtonFormField<StockStatus?>(
                    initialValue: selectedStatus.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, size: 20, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Semua Status'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.inStock,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Color(0xFF10B981)),
                          SizedBox(width: 12),
                          Text('Stok Cukup'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.lowStock,
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, size: 20, color: Color(0xFFF59E0B)),
                          SizedBox(width: 12),
                          Text('Stok Rendah'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.outOfStock,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 20, color: Color(0xFFEF4444)),
                          SizedBox(width: 12),
                          Text('Habis'),
                        ],
                      ),
                    ),
                    ],
                    onChanged: (value) {
                      selectedStatus.value = value;
                      setModalState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Sort dropdown
                const Text(
                  'Urutkan Berdasarkan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.grey[200],
                    hoverColor: Colors.grey[100],
                    focusColor: Colors.grey[200],
                    splashColor: Colors.grey[100],
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: sortBy.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 20, color: Color(0xFF3B82F6)),
                          SizedBox(width: 12),
                          Text('Nama A-Z'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'stock',
                      child: Row(
                        children: [
                          Icon(Icons.trending_down, size: 20, color: Color(0xFFF59E0B)),
                          SizedBox(width: 12),
                          Text('Stok Terendah'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'category',
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 20, color: Color(0xFF10B981)),
                          SizedBox(width: 12),
                          Text('Kategori'),
                        ],
                      ),
                    ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        sortBy.value = value;
                        setModalState(() {});
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  /// Filter and sort items
  static List<InventoryItem> _filterItems(
    List<InventoryItem> items,
    String searchQuery,
    InventoryCategory selectedCategory,
    StockStatus? selectedStatus,
    String sortBy,
  ) {
    var filtered = items.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());

      // Convert enum to category string for comparison
      final matchesCategory = selectedCategory == InventoryCategory.all ||
          (selectedCategory == InventoryCategory.alat && item.category == 'alat') ||
          (selectedCategory == InventoryCategory.consumable && item.category == 'consumable') ||
          (selectedCategory == InventoryCategory.ppe && item.category == 'ppe');

      final matchesStatus =
          selectedStatus == null || item.status == selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // Apply sorting
    switch (sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'stock':
        filtered.sort((a, b) => a.currentStock.compareTo(b.currentStock));
        break;
      case 'category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return filtered;
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  static Widget _buildBottomNavBar(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeAdminRoute,
                  (route) => false,
                ),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/reports_management',
                ),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  AdminMoreBottomSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF5D5FEF);
    final inactiveColor = Colors.grey[600]!;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

