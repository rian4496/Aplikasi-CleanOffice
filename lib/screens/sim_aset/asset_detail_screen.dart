// lib/screens/sim_aset/asset_detail_screen.dart
// SIM-ASET: Asset Detail Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../models/ticket.dart';
import '../shared/ticket_form_screen.dart';
import '../../riverpod/dropdown_providers.dart' hide locationsProvider;
import '../../riverpod/asset_providers.dart';
import '../../models/sim_aset/asset_category.dart'; // Added
import 'asset_maintenance_history_screen.dart';
import 'asset_form_screen.dart';
import '../../widgets/sim_aset/custodian_history_dialog.dart';

class AssetDetailScreen extends ConsumerWidget {
  final Asset asset;
  final String? assetType;

  const AssetDetailScreen({
    super.key, 
    required this.asset,
    this.assetType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(assetCategoriesProvider);
    final locationsAsync = ref.watch(locationsProvider);
    
    // Logic 1: Resolve Category Name
    String categoryName = asset.category;
    if (categoriesAsync.hasValue) {
      final category = categoriesAsync.value!.firstWhere(
        (c) => c.id == asset.categoryId,
        orElse: () => AssetCategory(
          id: '', 
          name: asset.category, 
          code: '',
          createdAt: DateTime.now(),
        ), 
      );
      if (category.id.isNotEmpty) {
        categoryName = category.name;
      }
    }

    // Logic 1.5: Resolve Location Name
    String locationName = asset.locationName ?? '-';
    if (locationsAsync.hasValue && asset.locationId != null) {
      final locations = locationsAsync.value!.where((l) => l.id == asset.locationId);
      if (locations.isNotEmpty) {
        locationName = locations.first.name;
      }
    }

    // Logic 2: Check if vehicle for "Nomor Polisi" label
    final isVehicle = categoryName.toLowerCase().contains('kendaraan') || 
                      (assetType == 'movable' && categoryName.toLowerCase().contains('dinas')); // Heuristic

    // Logic 3: Check if immovable asset (no QR code needed)
    final isImmovable = assetType == 'immovable';

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: Column(
        children: [
          // Custom AppBar/Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (assetType != null) {
                      context.go('/admin/assets?type=$assetType');
                    } else {
                      context.go('/admin/master/aset');
                    }
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detail Aset',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                // Hide QR code button for vehicles AND immovable assets
                if (!isVehicle && !isImmovable)
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () => _showQrCode(context),
                    tooltip: 'Lihat QR Code',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEdit(context),
                  tooltip: 'Edit',
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with image
                  _buildHeader(context),
                  
                  // Info sections
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          context: context,
                          title: 'Informasi Dasar',
                          icon: Icons.info_outline,
                          items: [
                            _InfoItem('Nama', asset.name),
                            _InfoItem(
                              isVehicle ? 'Nomor Polisi' : 'Kode QR', 
                              asset.qrCode
                            ),
                            _InfoItem('Merk / Brand', asset.brand != '-' ? asset.brand : '-'),
                            _InfoItem('Tipe / Model', asset.model != '-' ? asset.model : '-'),
                            _InfoItem('Deskripsi', asset.description ?? '-'),
                            _InfoItem('Status', asset.status.displayName),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoCard(
                          context: context,
                          title: 'Klasifikasi',
                          icon: Icons.category_outlined,
                          items: [
                            _InfoItem('Kategori', categoryName),
                            _InfoItem('Lokasi', locationName),
                            _InfoItem('Kondisi', asset.condition.displayName),
                            // Show custodian only for movable assets
                            if (assetType == 'movable' && asset.custodianName != null)
                              _InfoItem('Pemegang', '${asset.custodianName}${asset.custodianNip != null ? ' (${asset.custodianNip})' : ''}'),
                            if (assetType == 'movable' && asset.custodianName == null)
                              _InfoItem('Pemegang', '-'),
                          ],
                          trailing: assetType == 'movable' ? TextButton.icon(
                            onPressed: () => _showCustodianHistory(context),
                            icon: const Icon(Icons.history, size: 16),
                            label: const Text('Riwayat'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ) : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Hide purchase info for immovable assets
                        if (!isImmovable)
                          _buildInfoCard(
                            context: context,
                            title: 'Informasi Pembelian',
                            icon: Icons.shopping_cart_outlined,
                            items: [
                              _InfoItem('Tanggal Pembelian', asset.purchaseDateFormatted ?? '-'),
                              _InfoItem('Harga Pembelian', asset.purchasePriceFormatted ?? '-'),
                              _InfoItem('Garansi Sampai', asset.warrantyUntilFormatted ?? '-'),
                            ],
                          ),
                        if (!isImmovable)
                          const SizedBox(height: 16),
                        
                        if (asset.notes != null && asset.notes!.isNotEmpty)
                          _buildInfoCard(
                            context: context,
                            title: 'Catatan',
                            icon: Icons.note_alt_outlined,
                            items: [
                              _InfoItem('', asset.notes!),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Responsive image height based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final imageHeight = isMobile ? 180.0 : 300.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24, 
        vertical: isMobile ? 16 : 24,
      ),
      child: GestureDetector(
        onTap: () {
          if (asset.imageUrl != null) {
            _showImagePreview(context, asset.imageUrl!);
          }
        },
        child: Container(
          height: imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: isMobile ? 6 : 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: asset.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(asset.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: asset.imageUrl == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: isMobile ? 48 : 80, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada gambar',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 13 : 16,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: isMobile ? 16 : 20),
                            const SizedBox(width: 6),
                            Text(
                              'Lihat Foto',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }



  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Full screen interactive image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                  imageUrl, 
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: Colors.white);
                  },
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isMobile = screenWidth < 600;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.label.isNotEmpty)
                            Text(
                              item.label,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.label.isNotEmpty)
                            SizedBox(
                              width: 140,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showMaintenanceHistory(context),
              icon: const Icon(Icons.history),
              label: const Text('Riwayat Maintenance'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _createMaintenanceRequest(context),
              icon: const Icon(Icons.build, color: Colors.white),
              label: const Text('Request Maintenance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Aset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.qr_code_2, size: 150),
            ),
            const SizedBox(height: 16),
            Text(
              asset.qrCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asset.name,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Print QR
              Navigator.pop(context);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final typeParam = assetType != null ? '?type=$assetType' : '';
    context.go('/admin/assets/edit/${asset.id}$typeParam', extra: asset);
  }

  void _showMaintenanceHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetMaintenanceHistoryScreen(
          assetId: asset.id,
          assetName: asset.name,
        ),
      ),
    );
  }

  void _createMaintenanceRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketFormScreen(
          initialType: TicketType.kerusakan,
          initialAssetId: asset.id,
        ),
      ),
    );
  }

  void _showCustodianHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustodianHistoryDialog(
        assetId: asset.id,
        assetName: asset.name,
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}

