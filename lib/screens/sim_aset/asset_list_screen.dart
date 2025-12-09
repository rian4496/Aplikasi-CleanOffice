// lib/screens/sim_aset/asset_list_screen.dart
// SIM-ASET: Asset List Screen with DataTable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../providers/riverpod/asset_providers.dart';
import '../../providers/riverpod/master_data_providers.dart';
import '../../widgets/admin/admin_sidebar.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends ConsumerStatefulWidget {
  const AssetListScreen({super.key});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedCondition;
  int? _expandedRowIndex;

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(allAssetsProvider);
    final categoriesAsync = ref.watch(assetCategoriesProvider);
    final conditionsAsync = ref.watch(assetConditionsProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar for wide screens
          if (isWideScreen)
            const AdminSidebar(currentRoute: 'assets'),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Toolbar
                _buildToolbar(context, categoriesAsync, conditionsAsync),
                
                // DataTable
                Expanded(
                  child: assetsAsync.when(
                    data: (assets) => _buildDataTable(context, _filterAssets(assets)),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aset'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Back button for mobile
          if (MediaQuery.of(context).size.width <= 900)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          
          const Icon(Icons.inventory_2, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen Aset',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Kelola data aset BRIDA',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          
          // Export buttons
          OutlinedButton.icon(
            onPressed: _exportToPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Export Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AsyncValue categoriesAsync,
    AsyncValue conditionsAsync,
  ) {
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
            child: categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua')),
                  ...categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error'),
            ),
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
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua')),
                  ...conditions.map((c) => DropdownMenuItem(
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

  Widget _buildDataTable(BuildContext context, List<Asset> assets) {
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Column(
            children: [
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
                    Expanded(flex: 1, child: Text('QR', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                child: Text(asset.category),
                              ),
                              
                              // Location
                              Expanded(
                                flex: 2,
                                child: Text(asset.locationName ?? '-'),
                              ),
                              
                              // Condition
                              Expanded(
                                flex: 1,
                                child: _buildConditionBadge(asset.condition),
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
              
              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: ${assets.length} aset'),
                    // Pagination could be added here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
              _detailRow('Tanggal Pembelian', asset.purchaseDateFormatted ?? '-'),
              _detailRow('Harga Pembelian', asset.purchasePriceFormatted ?? '-'),
              _detailRow('Garansi Sampai', asset.warrantyUntilFormatted ?? '-'),
            ],
          ),
        ),
        
        // QR Code
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

  List<Asset> _filterAssets(List<Asset> assets) {
    return assets.where((asset) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!asset.name.toLowerCase().contains(query) &&
            !asset.qrCode.toLowerCase().contains(query) &&
            !(asset.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      
      // Category filter
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetFormScreen(asset: asset),
      ),
    ).then((_) => ref.invalidate(allAssetsProvider));
  }

  void _navigateToDetail(BuildContext context, Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetDetailScreen(asset: asset),
      ),
    );
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
    // TODO: Implement delete
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur hapus belum diimplementasi')),
    );
  }

  void _exportToPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF - Coming soon')),
    );
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export Excel - Coming soon')),
    );
  }
}
