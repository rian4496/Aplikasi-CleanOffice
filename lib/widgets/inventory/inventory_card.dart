// lib/widgets/inventory/inventory_card.dart
// Inventory item card

import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../core/theme/app_theme.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const InventoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppTheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selection checkbox (only in selection mode)
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap?.call(),
                      activeColor: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  CircleAvatar(
                    backgroundColor: item.statusColor.withValues(alpha: 0.2),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: item.statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryLabel(item.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        color: item.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok: ${item.currentStock}/${item.maxStock} ${item.unit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${item.stockPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.stockPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(item.statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'alat':
        return Icons.cleaning_services;
      case 'consumable':
        return Icons.water_drop;
      case 'ppe':
        return Icons.security;
      default:
        return Icons.inventory;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'alat':
        return 'Alat Kebersihan';
      case 'consumable':
        return 'Bahan Habis Pakai';
      case 'ppe':
        return 'Alat Pelindung Diri';
      default:
        return category;
    }
  }
}
