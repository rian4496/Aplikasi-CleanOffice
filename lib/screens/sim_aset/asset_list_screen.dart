// lib/screens/sim_aset/asset_list_screen.dart
// SIM-ASET: Asset List Screen with DataTable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_cleanoffice/widgets/sim_aset/mobile_asset_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../riverpod/asset_providers.dart';
import '../../riverpod/dropdown_providers.dart' hide locationsProvider;
import '../../riverpod/agency_providers.dart';
import '../../services/asset_export_service.dart';
import '../../widgets/sim_aset/asset_export_options_dialog.dart';
import '../../widgets/web_admin/layout/admin_sidebar.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends ConsumerStatefulWidget {
  final String? assetType; // 'movable', 'immovable', or null for all
  
  const AssetListScreen({super.key, this.assetType});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedCondition;
  int? _expandedRowIndex;

  // Get current route based on assetType
  String get _currentRoute {
    switch (widget.assetType) {
      case 'movable':
        return 'assets_movable';
      case 'immovable':
        return 'assets_immovable';
      default:
        return 'assets';
    }
  }

  // Get page title based on assetType
  String get _pageTitle {
    switch (widget.assetType) {
      case 'movable':
        return 'Aset Bergerak';
      case 'immovable':
        return 'Aset Tidak Bergerak';
      default:
        return 'Manajemen Aset';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(allAssetsProvider);
    final categoriesAsync = ref.watch(assetCategoriesProvider);
    final conditionsAsync = ref.watch(assetConditionsProvider);
    final typesAsync = ref.watch(assetTypesProvider);
    final locationsAsync = ref.watch(locationsProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    // ShellRoute handles the Scaffold and Sidebar for Desktop.
    // However, if we are on Mobile (not isWideScreen), we might need a Scaffold if the Shell passes through.
    // But AdminShellLayout logic returns child on mobile.
    // So if Mobile, we return Scaffold. If Desktop, we return content.
    // Actually, to keep it simple and consistent:
    // If the Shell is handling the outer frame, we just return the content.
    // But on mobile, we need the AppBar defined here (or in the shell).
    // Let's assume this widget is the "Page Content".

    final content = Column(
      children: [
        // Header
        _buildHeader(context, isWideScreen),
        
        // Toolbar
        _buildToolbar(context, categoriesAsync, conditionsAsync),
        
        // DataTable - combine assets with categories for proper filtering
        Expanded(
          child: assetsAsync.when(
            data: (assets) => categoriesAsync.when(
              data: (categories) => locationsAsync.when(
                data: (locations) => _buildDataTable(context, _filterAssets(assets, categories), categories, locations),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading locations: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading categories: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );

    // If wrapped in Shell (Desktop), return content.
    // If standalone (Mobile navigation), wrap in Scaffold with Sidebar/Drawer support if needed?
    // Current mobile sidebar is generally a Drawer.
    // For now, consistent with AdminDashboardScreen:
    // On Desktop, Shell handles structure.
    // On Mobile, we treat it as a full screen with Back button (handled in _buildHeader).
    
    // To ensure background color consistency
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: content,
      floatingActionButton: !isWideScreen ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () {
               if (widget.assetType != null) {
                 _navigateToForm(context, null);
               } else {
                 // Show selection for generic
                 showModalBottomSheet(
                   context: context, 
                   builder: (c) => Container(
                     padding: const EdgeInsets.all(16),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const Text('Pilih Jenis Aset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 16),
                         ListTile(leading: const Icon(Icons.commute), title: const Text('Aset Bergerak'), onTap: () { Navigator.pop(c); _navigateToFormWithType(context, 'movable'); }),
                         ListTile(leading: const Icon(Icons.domain), title: const Text('Aset Tidak Bergerak'), onTap: () { Navigator.pop(c); _navigateToFormWithType(context, 'immovable'); }),
                       ],
                     ),
                   )
                 );
               }
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.9)]),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.add, color: Colors.white, size: 20),
                   const SizedBox(width: 8),
                   Text('Tambah Aset', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
         ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context, bool isWideScreen) {
    // Determine if we came from folder navigation (has assetType)
    final hasAssetTypeFilter = widget.assetType != null;
    
    // Check if Mobile
    final isMobile = !isWideScreen;
    final topPadding = isMobile ? MediaQuery.of(context).padding.top : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16 + topPadding, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Simple back button (only when navigated from folder)
          if (hasAssetTypeFilter) ...[
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
              onPressed: () => context.go('/admin/master/aset'),
              tooltip: 'Kembali ke Master Aset',
            ),
            const SizedBox(width: 8),
          ],
          
          const Icon(Icons.inventory_2, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pageTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.assetType == 'movable' 
                      ? 'Kendaraan, Peralatan, Elektronik, dll'
                      : widget.assetType == 'immovable'
                          ? 'Gedung, Tanah, Infrastruktur, dll'
                          : 'Kelola data aset BRIDA',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // const Spacer(), // Removed Spacer as Expanded handles the space
          
          // Export dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: Colors.grey[700]),
            tooltip: 'Export Data',
            onSelected: (value) {
              if (value == 'pdf') {
                _exportToPdf();
              } else if (value == 'excel') {
                _exportToExcel();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Text('Export Excel (.xlsx)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Export PDF (Print)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (!isMobile) ...[
          // Add Button (Popup if type unknown, Direct if type known)
          if (widget.assetType != null)
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context, null),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Tambah Aset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            )
          else
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              tooltip: 'Pilih jenis aset',
              onSelected: (type) => _navigateToFormWithType(context, type),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'movable',
                  child: Row(
                    children: [
                      Icon(Icons.commute, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Text('Aset Bergerak'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'immovable',
                  child: Row(
                    children: [
                      Icon(Icons.domain, color: Colors.orange, size: 20),
                      SizedBox(width: 12),
                      Text('Aset Tidak Bergerak'),
                    ],
                  ),
                ),
              ],
              child: ElevatedButton.icon(
                onPressed: null, // Let PopupMenu handle tap
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tambah Aset'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }



  Widget _buildToolbar(
    BuildContext context,
    AsyncValue categoriesAsync,
    AsyncValue conditionsAsync,
  ) {
    // Responsive Check
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile Toolbar (Stacked)
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.grey[50],
        child: Column(
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari aset...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            
            // Filters Row
            Row(
              children: [
                Expanded(
                  child: _buildCategoryDropdown(categoriesAsync),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: conditionsAsync.when(
                    data: (conditions) => DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      decoration: InputDecoration(
                        labelText: 'Kondisi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(value: null, child: Text('Semua')),
                        ...conditions.map((c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedCondition = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 8),
             // Reset Button Full Width
             SizedBox(
               width: double.infinity,
               child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _selectedCategory = null;
                    _selectedCondition = null;
                  }),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Filter'),
               ),
             ),
          ],
        ),
      );
    }

    // Desktop Toolbar
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari aset...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          
          // Category filter
          Expanded(
            child: _buildCategoryDropdown(categoriesAsync),
          ),
          const SizedBox(width: 12),
          
          // Condition filter
          Expanded(
            child: conditionsAsync.when(
              data: (conditions) => DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Kondisi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(value: null, child: Text('Semua')),
                  ...conditions.map((c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(c.icon, size: 16, color: c.color),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedCondition = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error'),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Clear filters
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Reset Filter',
            onPressed: () => setState(() {
              _searchQuery = '';
              _selectedCategory = null;
              _selectedCondition = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(AsyncValue categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        // Filter categories based on asset type
        List<dynamic> filteredCategories;
        if (widget.assetType == 'movable') {
          filteredCategories = categories.where((c) => 
            ['kendaraan', 'komputer', 'lab', 'elektronik', 'furniture', 'alat_kantor'].contains(c.code)
          ).toList();
        } else if (widget.assetType == 'immovable') {
          filteredCategories = categories.where((c) => 
            ['gedung', 'tanah', 'infrastruktur', 'instalasi'].contains(c.code)
          ).toList();
        } else {
          filteredCategories = categories;
        }
        
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(value: null, child: Text('Semua', overflow: TextOverflow.ellipsis)),
            ...filteredCategories.map((c) => DropdownMenuItem<String>(
              value: c.id,
              child: Text(c.name, overflow: TextOverflow.ellipsis),
            )),
          ],
          onChanged: (value) => setState(() => _selectedCategory = value),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildDataTable(BuildContext context, List<Asset> assets, List<dynamic> categories, List<dynamic> locations) {
    // Responsive Check
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data aset',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Aset Pertama'),
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return _buildMobileList(context, assets, locations);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Count (Top of Table)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Total Data: ${assets.length} aset',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),

              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 40), // Expand button
                    Expanded(flex: 1, child: Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('Nama Aset', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Kondisi', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              
              // Data rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final isExpanded = _expandedRowIndex == index;
                  
                  return Column(
                    children: [
                      // Main row
                      InkWell(
                        onTap: () => _navigateToDetail(context, asset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Expand button
                              IconButton(
                                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                onPressed: () => setState(() {
                                  _expandedRowIndex = isExpanded ? null : index;
                                }),
                              ),
                              
                              // QR Code
                              Expanded(
                                flex: 1,
                                child: Text(
                                  asset.qrCode.length > 8 
                                      ? '${asset.qrCode.substring(0, 8)}...' 
                                      : asset.qrCode,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              
                              // Name
                              Expanded(
                                flex: 3,
                                child: Text(
                                  asset.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              
                              // Category
                              Expanded(
                                flex: 2,
                                child: Builder(
                                  builder: (context) {
                                    final matches = categories.where((c) => c.id == asset.categoryId);
                                    final cat = matches.isNotEmpty ? matches.first : null;
                                    return Text(cat?.name ?? asset.categoryDisplayName);
                                  }
                                ),
                              ),
                              
                              // Location
                              Expanded(
                                flex: 2,
                                child: Builder(
                                  builder: (context) {
                                    final locMatches = locations.where((l) => l.id == asset.locationId);
                                    final loc = locMatches.isNotEmpty ? locMatches.first : null;
                                    return Text(loc?.name ?? asset.locationName ?? '-');
                                  }
                                ),
                              ),
                              
                              // Condition
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildConditionBadge(asset.condition),
                                ),
                              ),
                              
                              // Actions
                              SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: Colors.blue,
                                      onPressed: () => _navigateToForm(context, asset),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: Colors.red,
                                      onPressed: () => _confirmDelete(context, asset),
                                      tooltip: 'Hapus',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Expanded detail
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue[50],
                          child: _buildExpandedDetail(asset),
                        ),
                    ],
                  );
                },
              ),
              
              // Footer removed (moved total to header)
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile List View
  Widget _buildMobileList(BuildContext context, List<Asset> assets, List<dynamic> locations) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asset = assets[index];
        
        // Resolve location name
        final locMatches = locations.where((l) => l.id == asset.locationId);
        final locName = locMatches.isNotEmpty ? locMatches.first.name : null;

        return MobileAssetCard(
          asset: asset,
          locationName: locName,
          onTap: () => _navigateToDetail(context, asset),
          onEdit: () => _navigateToForm(context, asset),
          onDelete: () => _confirmDelete(context, asset),
        );
      },
    );
  }

  Widget _buildConditionBadge(AssetCondition condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: condition.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(condition.icon, size: 14, color: condition.color),
          const SizedBox(width: 4),
          Text(
            condition.displayName,
            style: TextStyle(
              fontSize: 12,
              color: condition.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(Asset asset) {
    final isImmovable = widget.assetType == 'immovable';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: asset.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(asset.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: asset.imageUrl == null
              ? const Icon(Icons.image, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Deskripsi', asset.description ?? '-'),
              _detailRow('Status', asset.status.displayName),
              // Hide purchase info for immovable assets
              if (!isImmovable) ...[
                _detailRow('Tanggal Pembelian', asset.purchaseDateFormatted ?? '-'),
                _detailRow('Harga Pembelian', asset.purchasePriceFormatted ?? '-'),
                _detailRow('Garansi Sampai', asset.warrantyUntilFormatted ?? '-'),
              ],
            ],
          ),
        ),
        
        // QR Code - hide for immovable assets
        if (!isImmovable)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_2, size: 60),
              ),
              const SizedBox(height: 4),
              Text(
                asset.qrCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Asset> _filterAssets(List<Asset> assets, List<dynamic> categories) {
    // Define which category codes belong to movable/immovable
    const movableCodes = ['kendaraan', 'komputer', 'lab', 'elektronik', 'furniture', 'alat_kantor'];
    const immovableCodes = ['gedung', 'tanah', 'infrastruktur', 'instalasi'];
    
    // Create a lookup map: categoryId -> categoryCode
    final categoryCodeMap = <String, String>{};
    for (final cat in categories) {
      categoryCodeMap[cat.id] = cat.code ?? '';
    }
    
    return assets.where((asset) {
      // Filter by asset type (movable/immovable) using category_id lookup
      if (widget.assetType != null && asset.categoryId != null) {
        final categoryCode = categoryCodeMap[asset.categoryId] ?? '';
        
        if (widget.assetType == 'movable') {
          if (!movableCodes.contains(categoryCode)) {
            return false;
          }
        } else if (widget.assetType == 'immovable') {
          if (!immovableCodes.contains(categoryCode)) {
            return false;
          }
        }
      } else if (widget.assetType != null && asset.categoryId == null) {
      // If no category_id set, INCLUDE in all views (since assets lacks this column)
      // Previously: return false; - This was causing all assets to be hidden!
    }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!asset.name.toLowerCase().contains(query) &&
            !asset.qrCode.toLowerCase().contains(query) &&
            !(asset.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      
      // Category filter (dropdown selection)
      if (_selectedCategory != null && asset.categoryId != _selectedCategory) {
        return false;
      }
      
      // Condition filter
      if (_selectedCondition != null && asset.conditionId != _selectedCondition) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _navigateToForm(BuildContext context, Asset? asset) {
    if (asset != null) {
      // Preserve assetType in URL to ensure context is kept
      final typeParam = widget.assetType != null ? '?type=${widget.assetType}' : '';
      context.go('/admin/assets/edit/${asset.id}$typeParam', extra: asset);
    } else {
      // Pass assetType to form if navigated from folder
      final typeParam = widget.assetType != null ? '?type=${widget.assetType}' : '';
      context.go('/admin/assets/new$typeParam');
    }
  }

  void _navigateToFormWithType(BuildContext context, String type) {
    context.go('/admin/assets/new?type=$type');
  }

  void _navigateToDetail(BuildContext context, Asset asset) {
    final typeParam = widget.assetType != null ? '?type=${widget.assetType}' : '';
    context.go('/admin/assets/detail/${asset.id}$typeParam', extra: asset);
  }

  void _confirmDelete(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aset'),
        content: Text('Yakin ingin menghapus "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAsset(asset);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAsset(Asset asset) async {
    try {
      await Supabase.instance.client.from('assets').delete().eq('id', asset.id);
      
      // Refresh list
      ref.invalidate(allAssetsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus aset: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportToPdf() async {
    // Show options dialog first
    final options = await showAssetExportOptionsDialog(context);
    if (options == null) return; // User cancelled

    final assetsAsync = ref.read(allAssetsProvider);
    final categoriesAsync = ref.read(assetCategoriesProvider);
    final locationsAsync = ref.read(locationsProvider);
    final agencyAsync = ref.read(agencyProfileProvider);
    
    assetsAsync.whenData((assets) {
      categoriesAsync.whenData((categories) {
        locationsAsync.whenData((locations) {
          final filtered = _filterAssets(assets, categories);
          if (filtered.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada data untuk di-export')),
            );
            return;
          }
          
          // Get signer from agency profile (use first signer if available)
          final signer = agencyAsync.value?.signers.isNotEmpty == true 
              ? agencyAsync.value!.signers.first 
              : null;
          final city = agencyAsync.value?.city ?? 'Banjarbaru';
          
          AssetExportService.exportToPdf(
            context, 
            filtered,
            categories: categories,
            locations: locations,
            isLandscape: options.orientation == PdfOrientation.landscape,
            includePhoto: options.includePhoto,
            signer: signer,
            city: city,
          );
        });
      });
    });
  }

  void _exportToExcel() {
    final assetsAsync = ref.read(allAssetsProvider);
    final categoriesAsync = ref.read(assetCategoriesProvider);
    assetsAsync.whenData((assets) {
      categoriesAsync.whenData((categories) {
        final filtered = _filterAssets(assets, categories);
        if (filtered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data untuk di-export')),
          );
          return;
        }
        AssetExportService.exportToExcel(context, filtered);
      });
    });
  }
}

