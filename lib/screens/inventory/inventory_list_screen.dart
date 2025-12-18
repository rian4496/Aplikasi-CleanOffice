// lib/screens/inventory/inventory_list_screen.dart
// Inventory list screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added import
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/responsive_ui_helper.dart';

import '../../models/inventory_item.dart';
import '../../models/stock_history.dart'; // TransactionType
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/user_providers.dart';
import '../../providers/riverpod/inventory_selection_provider.dart';
import '../../widgets/inventory/batch_action_bar.dart';
import '../../widgets/shared/notification_bell.dart'; // Fixed import path
import '../../widgets/shared/drawer_menu_widget.dart'; // Fixed import path
import '../../core/utils/responsive_helper.dart'; // Added ResponsiveHelper import
import '../../widgets/inventory/inventory_dashboard_widget.dart'; // New Dashboard
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/inventory/inventory_empty_state.dart'; // Add this
import '../../widgets/inventory/inventory_form_dialog.dart';
// import 'inventory_add_edit_screen.dart'; // Deprecated for Add
import 'inventory_detail_screen.dart';
import '../../widgets/inventory/inventory_detail_dialog.dart';
// import '../../widgets/inventory/inventory_form_side_panel.dart'; // Deprecated for Add

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
  bool _isGridView = false; // Toggle state

  // ==================== DASHBOARD & STATS ====================
  Widget _buildDashboard() {
    // This could also be inside the scrollable area, 
    // but for "Command Center" feel, we might want it fixed or at the top.
    // For now, let's keep it simple at the top of the body.
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InventoryDashboardWidget(), // Use the new widget
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Filter Logic
    // ... (This part stays largely similar unless we move filters to sidebar)

    return Scaffold(
      backgroundColor: AppTheme.modernBg, // Use consistent BG
      appBar: AppBar(
        // ... (Keep AppBar as is or simplify)
        title: isSelectionMode
            ? Text('${selectedIds.length} dipilih')
            : const Text(
                'Inventaris & Stok',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
         leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).disable();
                },
              )
            : null,
        actions: [
          // Add Item Button (Moved from FAB)
          if (!isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => const InventoryFormDialog(),
                  );
                  ref.invalidate(allInventoryItemsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.library_add, size: 18, color: Colors.white),
                label: const Text('Tambah Item'),
              ),
            ),

          // Selection Mode Actions
          if (isSelectionMode)
             TextButton(
               onPressed: () {
                 itemsAsync.whenData((items) {
                   final filtered = _filterItems(items);
                   ref.read(inventorySelectionProvider.notifier)
                       .selectAll(filtered.map((e) => e.id).toList());
                 });
               },
               child: const Text('Pilih Semua', style: TextStyle(color: AppTheme.primary)),
             )
        ],
      ),
      body: Column(
        children: [
          // Dashboard Stats
          if (!isSelectionMode)
              _buildDashboard(),
          
          // Search & Filter Toolbar
          _buildCompactSearchBar(),
          
          // List Data
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _filterItems(items);
                
                if (filtered.isEmpty) {
                  final hasFilters = _searchQuery.isNotEmpty || 
                      _selectedCategory != InventoryCategory.all || 
                      _selectedStatus != null;
                  
                  return hasFilters 
                      ? InventoryEmptyState.filtered(
                          onClearFilter: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = InventoryCategory.all;
                              _selectedStatus = null;
                            });
                          }
                        )
                      : InventoryEmptyState.noItems();
                }

                return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(allInventoryItemsProvider),
                    child: _isGridView 
                      ? GridView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 80, 
                            left: 16, 
                            right: 16
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            // User requested 3x3 grid (3 columns)
                            crossAxisCount: isDesktop ? 3 : (ResponsiveHelper.isTablet(context) ? 3 : 2),
                            childAspectRatio: isDesktop ? 1.5 : 0.8, // Wider cards on desktop for 3 columns
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _buildInventoryCard(context, filtered[index], index, isSelectionMode, selectedIds),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 80, 
                            left: 16, 
                            right: 16
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _buildInventoryCard(context, filtered[index], index, isSelectionMode, selectedIds),
                        ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
       endDrawer: !isDesktop ? Drawer(child: DrawerMenuWidget(
          userProfile: ref.watch(currentUserProfileProvider).asData?.value,
          roleTitle: 'Admin', 
           menuItems: [ /* ... same items ... */ ],
           onLogout: () async { /* ... */ }
       )) : null,
       // floatingActionButton: Removed
       bottomNavigationBar: isSelectionMode 
          ? itemsAsync.maybeWhen(
              data: (items) => BatchActionBar(
                 allItems: items, 
                 onActionComplete: () => ref.invalidate(allInventoryItemsProvider)
              ),
              orElse: () => null
            )
          : (!isDesktop ? _buildBottomNavBar() : null),
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItem item, int index, bool isSelectionMode, Set<String> selectedIds) {
      final isSelected = selectedIds.contains(item.id);

      return InventoryCard(
        item: item,
        index: index,
        isSelectionMode: isSelectionMode,
        isSelected: isSelected,
        isGridMode: _isGridView, // Pass Grid Mode
        onTap: () {
            if (isSelectionMode) {
              ref.read(inventorySelectionProvider.notifier).toggleItem(item.id);
            } else {
              ResponsiveUIHelper.showDetailView(
                  context: context,
                  mobileScreen: InventoryDetailScreen(itemId: item.id),
                  webDialog: InventoryDetailDialog(item: item),
              );
            }
        },
        onAddStock: () {
          _showStockAdjustmentDialog(context, item, TransactionType.IN);
        },
        onEdit: () async {
          final result = await context.push('/admin/inventory/edit/${item.id}', extra: item);
          if (result == true) {
            ref.invalidate(allInventoryItemsProvider);
          }
        },
        onMore: () {
          _confirmDelete(item);
        },
      );
  }

  // Restored Compact Search Bar with Filter
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
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.search, color: Colors.grey[400], size: 22),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari item inventaris...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                onPressed: () => setState(() => _searchQuery = ''),
              ),

             // View Toggle Button (Added)
             IconButton(
               icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view, 
                  color: Colors.grey[600]
               ),
               tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
               onPressed: () {
                 setState(() {
                   _isGridView = !_isGridView;
                 });
               },
             ),
             
             // Initial Vertical Divider
             Container(width: 1, height: 24, color: Colors.grey[300]),

             // Filter Button (Restored)
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



  // Dialog for Stock Adjustment (Quick)
  void _showStockAdjustmentDialog(BuildContext context, InventoryItem item, TransactionType type) {
     // TODO: Implement simple dialog with quantity input
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar() {
    final userRole = ref.watch(currentUserRoleProvider)?.toLowerCase();
    
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
                onTap: () {
                  String route;
                  switch (userRole) {
                    case 'cleaner':
                      route = AppConstants.homeCleanerRoute;
                      break;
                    case 'employee':
                      route = AppConstants.homeEmployeeRoute;
                      break;
                    default:
                      route = AppConstants.homeAdminRoute;
                  }
                  Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
                },
              ),
              _buildNavItem(
                icon: userRole == 'cleaner' ? Icons.inbox_rounded : Icons.assignment_rounded,
                label: userRole == 'cleaner' ? 'Inbox' : 'Laporan',
                isActive: false,
                onTap: () {
                  if (userRole == 'cleaner') {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/reports_management');
                  }
                },
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
                  if (userRole == 'cleaner') {
                    // CleanerMoreBottomSheet.show(context); // TODO: Implement CleanerMoreBottomSheet
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Cleaner belum tersedia')));
                  } else {
                    // AdminMoreBottomSheet.show(context); // TODO: Implement AdminMoreBottomSheet
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Admin belum tersedia')));
                  }
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



  /// Show filter dialog (Redesigned with ChoiceChips)
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500, // Constrained width for desktop
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
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = InventoryCategory.all;
                            _selectedStatus = null;
                            _sortBy = 'name';
                          });
                          setState(() {
                            _selectedCategory = InventoryCategory.all;
                            _selectedStatus = null;
                            _sortBy = 'name';
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Kategori Filter (Chips)
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip<InventoryCategory>(
                        label: 'Semua',
                        value: InventoryCategory.all,
                        groupValue: _selectedCategory,
                        onSelected: (val) {
                          setModalState(() => _selectedCategory = val);
                          setState(() => _selectedCategory = val);
                        },
                      ),
                      _buildFilterChip<InventoryCategory>(
                        label: 'Alat Kebersihan',
                        value: InventoryCategory.alat,
                        groupValue: _selectedCategory,
                        onSelected: (val) {
                          setModalState(() => _selectedCategory = val);
                          setState(() => _selectedCategory = val);
                        },
                      ),
                      _buildFilterChip<InventoryCategory>(
                        label: 'Konsumabel',
                        value: InventoryCategory.consumable,
                        groupValue: _selectedCategory,
                        onSelected: (val) {
                          setModalState(() => _selectedCategory = val);
                          setState(() => _selectedCategory = val);
                        },
                      ),
                      _buildFilterChip<InventoryCategory>(
                        label: 'APD',
                        value: InventoryCategory.ppe,
                        groupValue: _selectedCategory,
                        onSelected: (val) {
                          setModalState(() => _selectedCategory = val);
                          setState(() => _selectedCategory = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Status Stok Filter (Chips)
                  const Text(
                    'Status Stok',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip<StockStatus?>(
                        label: 'Semua',
                        value: null,
                        groupValue: _selectedStatus,
                        onSelected: (val) {
                          setModalState(() => _selectedStatus = val);
                          setState(() => _selectedStatus = val);
                        },
                      ),
                      _buildFilterChip<StockStatus?>(
                        label: 'Aman',
                        value: StockStatus.inStock,
                        groupValue: _selectedStatus,
                        onSelected: (val) {
                          setModalState(() => _selectedStatus = val);
                          setState(() => _selectedStatus = val);
                        },
                        color: Colors.green,
                      ),
                      _buildFilterChip<StockStatus?>(
                        label: 'Menipis',
                        value: StockStatus.lowStock,
                        groupValue: _selectedStatus,
                        onSelected: (val) {
                          setModalState(() => _selectedStatus = val);
                          setState(() => _selectedStatus = val);
                        },
                        color: Colors.orange,
                      ),
                      _buildFilterChip<StockStatus?>(
                        label: 'Habis',
                        value: StockStatus.outOfStock,
                        groupValue: _selectedStatus,
                        onSelected: (val) {
                          setModalState(() => _selectedStatus = val);
                          setState(() => _selectedStatus = val);
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort Filter (Wrap)
                  const Text(
                    'Urutkan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        icon: const Icon(Icons.sort),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Nama (A-Z)')),
                          DropdownMenuItem(value: 'stock', child: Text('Stok Terendah')),
                          DropdownMenuItem(value: 'category', child: Text('Kategori')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _sortBy = val);
                            setState(() => _sortBy = val);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text('Anda yakin ingin menghapus "${item.name}"? Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        print('🚀 DIRECT DELETE TEST - Item: ${item.name}, ID: ${item.id}');
        
        // DIRECT SUPABASE UPDATE - Bypass service layer
        final supabase = Supabase.instance.client;
        
        print('📝 Step 1: Getting item from database...');
        final checkItem = await supabase
            .from('inventory_items')
            .select()
            .eq('id', item.id)
            .maybeSingle();
        
        print('✅ Item in DB: $checkItem');
        
        if (checkItem == null) {
          throw Exception('Item not found in database!');
        }
        
        print('📝 Step 2: Attempting DIRECT update...');
        final updateResponse = await supabase
            .from('inventory_items')
            .update({
              'deleted_at': DateTime.now().toIso8601String(),
              'is_active': false,
              'current_stock': 0,
            })
            .eq('id', item.id)
            .select();
        
        print('📊 Update Response: $updateResponse');
        print('📊 Response Type: ${updateResponse.runtimeType}');
        print('📊 Response Length: ${(updateResponse as List).length}');
        
        if (updateResponse.isEmpty) {
          throw Exception('UPDATE returned empty - RLS policy might be blocking!');
        }
        
        print('✅ DIRECT UPDATE SUCCESS!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item berhasil dihapus (DIRECT)')),
          );
          ref.invalidate(allInventoryItemsProvider);
        }
      } catch (e, stackTrace) {
        print('❌ DIRECT DELETE FAILED');
        print('Error: $e');
        print('StackTrace: $stackTrace');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Widget _buildFilterChip<T>({
    required String label,
    required T value,
    required T groupValue,
    required Function(T) onSelected,
    Color? color,
  }) {
    final isSelected = value == groupValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: Colors.transparent,
      selectedColor: (color ?? AppTheme.primary).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppTheme.primary) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? (color ?? AppTheme.primary) : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          (item.description?.toLowerCase().contains(q) ?? false) ||
          item.category.toLowerCase().contains(q);

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

// ==================== ENUMS ====================

enum InventoryCategory {
  all,
  alat,
  consumable,
  ppe,
}
