// lib/screens/sim_aset/asset_detail_screen.dart
// SIM-ASET: Asset Detail Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../models/ticket.dart';
import '../shared/ticket_form_screen.dart';
import 'asset_maintenance_history_screen.dart'; // Added
import 'asset_form_screen.dart';

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
    return Container(
      color: AppTheme.modernBg,
      child: Column(
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
                          title: 'Informasi Dasar',
                          icon: Icons.info_outline,
                          items: [
                            _InfoItem('Nama', asset.name),
                            _InfoItem('Kode QR', asset.qrCode),
                            _InfoItem('Deskripsi', asset.description ?? '-'),
                            _InfoItem('Status', asset.status.displayName),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoCard(
                          title: 'Klasifikasi',
                          icon: Icons.category_outlined,
                          items: [
                            _InfoItem('Kategori', asset.category),
                            _InfoItem('Lokasi', asset.locationName ?? '-'),
                            _InfoItem('Kondisi', asset.condition.displayName),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoCard(
                          title: 'Informasi Pembelian',
                          icon: Icons.shopping_cart_outlined,
                          items: [
                            _InfoItem('Tanggal Pembelian', asset.purchaseDateFormatted ?? '-'),
                            _InfoItem('Harga Pembelian', asset.purchasePriceFormatted ?? '-'),
                            _InfoItem('Garansi Sampai', asset.warrantyUntilFormatted ?? '-'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (asset.notes != null && asset.notes!.isNotEmpty)
                          _buildInfoCard(
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
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
                Icon(Icons.image, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada gambar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
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
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
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
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}

