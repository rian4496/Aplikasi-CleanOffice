import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';

// Maksudnya "Kartu" adalah tampilan vertikal seperti ini Pak:
// [ Foto Aset ]
// ----------------
// Nama Aset (Bold)
// Kode QR
// Lokasi | Kondisi
// [Tombol Edit] [Tombol Hapus]

class MobileAssetCard extends StatelessWidget {
  final Asset asset;
  final String? locationName;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileAssetCard({
    super.key,
    required this.asset,
    this.locationName,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced Margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
            blurRadius: 4, // Reduced blur
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap ?? onEdit, // Default to detail if onTap provided, else edit
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10), // Reduced Padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Center align for compact look
              children: [
                // 1. Asset Image (Left) - Smaller
                Hero(
                  tag: 'asset_img_${asset.id}',
                  child: Container(
                    width: 60, // Reduced from 90
                    height: 60, // Reduced from 90
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      image: asset.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(asset.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: asset.imageUrl == null
                        ? Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 24)
                        : null,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 2. Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Row: Code + Condition
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.qrCode,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                         // Condition Badge - Mini
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: asset.condition.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              asset.condition.displayName,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: asset.condition.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Asset Name
                      Text(
                        asset.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Reduced from 16
                          color: Color(0xFF2D3238),
                        ),
                        maxLines: 1, // Single line for compactness
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),

                      // Location & Actions Row
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationName ?? asset.locationName ?? 'Tidak diketahui',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Mini Actions
                          GestureDetector(
                            onTap: onEdit,
                            child: Icon(Icons.edit, size: 16, color: Colors.blue[400]),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: onDelete,
                            child: Icon(Icons.delete, size: 16, color: Colors.red[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// _ActionButton class removed as it is inlined now
