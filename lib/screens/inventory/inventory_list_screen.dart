// lib/screens/inventory/inventory_list_screen.dart
// Inventory list screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _searchQuery = '';
  InventoryCategory _selectedCategory = InventoryCategory.all;
  StockStatus? _selectedStatus;
  String _sortBy = 'name'; // 'name', 'stock', 'category'

  @override
  Widget build(BuildContext context) {
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
                    child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
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
                            fontSize: 16,
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
                  final filtered = _filterItems(items);
                  ref.read(inventorySelectionProvider.notifier)
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
          _buildCompactSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _filterItems(items);

                // Calculate stats
                final lowStockItems = items.where((item) =>
                  item.status == StockStatus.lowStock
                ).toList();
                final outOfStockItems = items.where((item) =>
                  item.status == StockStatus.outOfStock
                ).toList();

                if (filtered.isEmpty) {
                  // Show appropriate empty state
                  final hasFilters = _searchQuery.isNotEmpty ||
                    _selectedCategory != InventoryCategory.all ||
                    _selectedStatus != null;

                  if (hasFilters) {
                    return InventoryEmptyState.filtered(
                      onClearFilter: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = InventoryCategory.all;
                          _selectedStatus = null;
                        });
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
                            setState(() {
                              _selectedStatus = StockStatus.lowStock;
                            });
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
                            ref.read(inventorySelectionProvider.notifier)
                                .toggleItem(item.id);
                          } else {
                            // Show detail dengan platform-specific UI
                            ResponsiveUIHelper.showDetailView(
                              context: context,
                              mobileScreen: InventoryDetailScreen(itemId: item.id),
                              webDialog: InventoryDetailDialog(item: item),
                            );
                          }
                        },
                        onAddStock: () {
                          // TODO: Implement add stock dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tambah stok - coming soon')),
                          );
                        },
                        onEdit: () {
                          // TODO: Navigate to edit screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit - coming soon')),
                          );
                        },
                        onMore: () {
                          // TODO: Show more options
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('More options - coming soon')),
                          );
                        },
                        onLongPress: () {
                          if (!isSelectionMode) {
                            // Enable selection mode on long press
                            ref.read(selectionModeProvider.notifier).enable();
                            ref.read(inventorySelectionProvider.notifier)
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
          : (!isDesktop ? _buildBottomNavBar() : null),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar() {
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
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/reports_management',
                ),
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
              _buildNavItem(
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

  Widget _buildNavItem({
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

  /// Compact search bar with filter & sort icons
  Widget _buildCompactSearchBar() {
    final hasActiveFilters = _selectedCategory != InventoryCategory.all || _selectedStatus != null;

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
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            // Clear button (if searching)
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () {
                  setState(() => _searchQuery = '');
                },
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
                onTap: _showFilterDialog,
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
  void _showFilterDialog() {
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
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedCategory = InventoryCategory.all;
                          _selectedStatus = null;
                        });
                        setState(() {
                          _selectedCategory = InventoryCategory.all;
                          _selectedStatus = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 20),

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
                    initialValue: _selectedCategory,
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
                        setModalState(() => _selectedCategory = value);
                        setState(() => _selectedCategory = value);
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
                    initialValue: _selectedStatus,
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
                      setModalState(() => _selectedStatus = value);
                      setState(() => _selectedStatus = value);
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
                    initialValue: _sortBy,
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
                        setModalState(() => _sortBy = value);
                        setState(() => _sortBy = value);
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

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Convert enum to category string for comparison
      final matchesCategory = _selectedCategory == InventoryCategory.all ||
          (_selectedCategory == InventoryCategory.alat && item.category == 'alat') ||
          (_selectedCategory == InventoryCategory.consumable && item.category == 'consumable') ||
          (_selectedCategory == InventoryCategory.ppe && item.category == 'ppe');

      final matchesStatus = _selectedStatus == null ||
          item.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
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

}
