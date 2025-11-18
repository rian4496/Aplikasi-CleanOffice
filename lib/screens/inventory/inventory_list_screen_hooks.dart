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
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../utils/responsive_ui_helper.dart';
import './inventory_detail_screen.dart';

/// Inventory List Screen - List with search, filters, sorting, and batch actions
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class InventoryListScreen extends HookConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State management
    final searchQuery = useState('');
    final selectedCategory = useState<String?>(null);
    final selectedStatus = useState<StockStatus?>(null);
    final sortBy = useState('name'); // 'name', 'stock', 'category'

    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);
    final isInDialog = ResponsiveHelper.isDesktop(context);

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
        // Sembunyikan back button jika di web/dialog
        automaticallyImplyLeading: !isInDialog,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).disable();
                },
              )
            : (isInDialog ? null : null),
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
            )
          else ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.checklist, size: 20),
                      SizedBox(width: 12),
                      Text('Mode Pilih'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                CheckedPopupMenuItem(
                  value: 'sort_name',
                  checked: sortBy.value == 'name',
                  child: const Text('Urutkan: Nama A-Z'),
                ),
                CheckedPopupMenuItem(
                  value: 'sort_stock',
                  checked: sortBy.value == 'stock',
                  child: const Text('Urutkan: Stok Terendah'),
                ),
                CheckedPopupMenuItem(
                  value: 'sort_category',
                  checked: sortBy.value == 'category',
                  child: const Text('Urutkan: Kategori'),
                ),
              ],
              onSelected: (value) {
                if (value == 'select') {
                  ref.read(selectionModeProvider.notifier).enable();
                } else if (value == 'sort_name') {
                  sortBy.value = 'name';
                } else if (value == 'sort_stock') {
                  sortBy.value = 'stock';
                } else if (value == 'sort_category') {
                  sortBy.value = 'category';
                }
              },
            ),
            // Tambahkan tombol close untuk dialog
            if (isInDialog)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Tutup',
              ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(searchQuery),
          _buildCompactFilters(selectedCategory, selectedStatus),
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

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allInventoryItemsProvider);
                  },
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = selectedIds.contains(item.id);

                      return InventoryCard(
                        item: item,
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
      bottomNavigationBar: itemsAsync.maybeWhen(
        data: (items) => BatchActionBar(
          allItems: items,
          onActionComplete: () {
            ref.invalidate(allInventoryItemsProvider);
          },
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build search bar
  static Widget _buildSearchBar(ValueNotifier<String> searchQuery) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari item...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => searchQuery.value = value,
      ),
    );
  }

  /// Build compact filters (category + status dropdowns)
  static Widget _buildCompactFilters(
    ValueNotifier<String?> selectedCategory,
    ValueNotifier<StockStatus?> selectedStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedCategory.value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.grid_view, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Semua Kategori'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'alat',
                      child: Row(
                        children: [
                          Icon(Icons.cleaning_services,
                              size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Alat Kebersihan'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'consumable',
                      child: Row(
                        children: [
                          Icon(Icons.water_drop, size: 18, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text('Bahan Habis Pakai'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ppe',
                      child: Row(
                        children: [
                          Icon(Icons.security, size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Alat Pelindung Diri'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => selectedCategory.value = value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Status Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StockStatus?>(
                  value: selectedStatus.value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Semua Status'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.inStock,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 18, color: AppTheme.success),
                          const SizedBox(width: 8),
                          const Text('Stok Cukup'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.lowStock,
                      child: Row(
                        children: [
                          Icon(Icons.warning, size: 18, color: AppTheme.warning),
                          const SizedBox(width: 8),
                          const Text('Stok Rendah'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.outOfStock,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 18, color: AppTheme.error),
                          const SizedBox(width: 8),
                          const Text('Habis'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => selectedStatus.value = value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filter and sort items
  static List<InventoryItem> _filterItems(
    List<InventoryItem> items,
    String searchQuery,
    String? selectedCategory,
    StockStatus? selectedStatus,
    String sortBy,
  ) {
    var filtered = items.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == null || item.category == selectedCategory;
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

  /// Build empty state
  static Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Tidak ada item', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
