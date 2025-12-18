// lib/widgets/inventory/inventory_card.dart
// Modern Compact Inventory Tile

import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../core/design/inventory_design_tokens.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final int index; // Kept for consistency
  final VoidCallback? onTap;
  final VoidCallback? onAddStock;
  final VoidCallback? onEdit;
  final VoidCallback? onMore; // Used as delete/menu trigger if needed
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final bool isGridMode;

  const InventoryCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
    this.onAddStock,
    this.onEdit,
    this.onMore,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.isGridMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridMode) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  // ==================== LIST LAYOUT (Compact Row) ====================
  Widget _buildListCard(BuildContext context) {
    // Get colors
    final categoryColors = InventoryDesignTokens.getCategoryColors(item.category);
    final statusColors = InventoryDesignTokens.getStatusColors(
      item.currentStock,
      item.maxStock,
      item.minStock,
    );
    
    // Check low stock
    final isLowStock = item.currentStock <= item.minStock;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16, // Standard margin
        vertical: 6,   // Reduced vertical margin for compactness
      ),
      decoration: _buildCardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12), // Compact padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
              children: [
                 // Selection Checkbox
                if (isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap?.call(),
                  ),
                  const SizedBox(width: 8),
                ],

                // 1. Category Icon
                // 1. Image or Category Icon
                _buildItemImage(48),
                
                const SizedBox(width: 16),
                
                // 2. Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Wrap content
                    children: [
                      // Name & Badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            _buildCompactBadge(
                              label: item.currentStock == 0 ? 'Habis' : 'Tipis', 
                              color: Colors.red.shade50, 
                              textColor: Colors.red,
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.stockPercentage / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(statusColors.color),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Stock Detail Text
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${item.currentStock}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColors.color,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${item.maxStock} ${item.unit}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const TextSpan(text: '  •  '),
                            TextSpan(
                              text: 'Min: ${item.minStock}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 3. Actions (Only if not selection mode)
                if (!isSelectionMode)
                   _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== GRID LAYOUT (Vertical Card) ====================
  Widget _buildGridCard(BuildContext context) {
    // Get colors
    final categoryColors = InventoryDesignTokens.getCategoryColors(item.category);
    final statusColors = InventoryDesignTokens.getStatusColors(
      item.currentStock,
      item.maxStock,
      item.minStock,
    );
    final isLowStock = item.currentStock <= item.minStock;

    return Container(
      decoration: _buildCardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image or Category Icon
                    _buildItemImage(48),
                    if (isLowStock)
                       _buildCompactBadge(
                          label: item.currentStock == 0 ? 'Habis' : '!', 
                          color: Colors.red.shade50, 
                          textColor: Colors.red,
                        ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.stockPercentage / 100,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(statusColors.color),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Stock Text & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.currentStock}/${item.maxStock}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColors.color,
                      ),
                    ),
                    
                    // Quick Add Tiny Button
                    if (!isSelectionMode && onAddStock != null)
                      InkWell(
                        onTap: onAddStock,
                        child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 24),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
      border: isSelected
          ? Border.all(color: Theme.of(context).primaryColor, width: 2)
          : Border.all(color: Colors.grey.shade100),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          // Menu Button
          PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) {
              onEdit!();
            } else if (value == 'delete' && onMore != null) {
                onMore!();
            }
          },
          itemBuilder: (context) => [
            if (onEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Edit Item'),
                  ],
                ),
              ),
            if (onMore != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Hapus Item'),
                  ],
                ),
              ),
          ],
          ),
      ],
    );
  }


  Widget _buildItemImage(double size) {
    final categoryColors = InventoryDesignTokens.getCategoryColors(item.category);
    
    // If no image, show category icon (Fallback)
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: categoryColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          categoryColors.icon,
          color: categoryColors.primary,
          size: size * 0.5,
        ),
      );
    }

    // Show Image
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        item.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              categoryColors.icon, 
              color: Colors.grey, 
              size: size * 0.5
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactBadge({required String label, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
