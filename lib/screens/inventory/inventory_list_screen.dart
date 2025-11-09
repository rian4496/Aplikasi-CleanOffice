// lib/screens/inventory/inventory_list_screen.dart
// Inventory list screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory_item.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/inventory_selection_provider.dart';
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/inventory/batch_action_bar.dart';
import '../../core/theme/app_theme.dart';
import './inventory_detail_screen.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  StockStatus? _selectedStatus;
  String _sortBy = 'name'; // 'name', 'stock', 'category'

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode
            ? '${selectedIds.length} dipilih'
            : 'Inventaris'),
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
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
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
            )
          else
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
                  checked: _sortBy == 'name',
                  child: const Text('Urutkan: Nama A-Z'),
                ),
                CheckedPopupMenuItem(
                  value: 'sort_stock',
                  checked: _sortBy == 'stock',
                  child: const Text('Urutkan: Stok Terendah'),
                ),
                CheckedPopupMenuItem(
                  value: 'sort_category',
                  checked: _sortBy == 'category',
                  child: const Text('Urutkan: Kategori'),
                ),
              ],
              onSelected: (value) {
                if (value == 'select') {
                  ref.read(selectionModeProvider.notifier).enable();
                } else if (value == 'sort_name') {
                  setState(() => _sortBy = 'name');
                } else if (value == 'sort_stock') {
                  setState(() => _sortBy = 'stock');
                } else if (value == 'sort_category') {
                  setState(() => _sortBy = 'category');
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildStatusFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _filterItems(items);
                
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
                            ref.read(inventorySelectionProvider.notifier)
                                .toggleItem(item.id);
                          } else {
                            // Navigate to detail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InventoryDetailScreen(
                                  itemId: item.id,
                                ),
                              ),
                            );
                          }
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

  Widget _buildSearchBar() {
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
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCategoryChip('Semua', null),
          const SizedBox(width: 8),
          _buildCategoryChip('Alat', 'alat'),
          const SizedBox(width: 8),
          _buildCategoryChip('Consumable', 'consumable'),
          const SizedBox(width: 8),
          _buildCategoryChip('PPE', 'ppe'),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusChip('Semua Status', null, Colors.grey),
          const SizedBox(width: 8),
          _buildStatusChip('Stok Cukup', StockStatus.inStock, AppTheme.success),
          const SizedBox(width: 8),
          _buildStatusChip('Stok Rendah', StockStatus.lowStock, AppTheme.warning),
          const SizedBox(width: 8),
          _buildStatusChip('Habis', StockStatus.outOfStock, AppTheme.error),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? category : null);
      },
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primary,
    );
  }

  Widget _buildStatusChip(String label, StockStatus? status, Color color) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = selected ? status : null);
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      avatar: isSelected
          ? null
          : CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.3),
              radius: 8,
            ),
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null ||
          item.category == _selectedCategory;
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

  Widget _buildEmptyState() {
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
