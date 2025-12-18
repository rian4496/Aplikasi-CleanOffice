// lib/widgets/inventory/inventory_detail_dialog.dart
// Dialog wrapper untuk inventory detail (desktop mode)

import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../screens/inventory/inventory_detail_screen.dart';

/// Dialog untuk menampilkan detail inventory item di desktop
class InventoryDetailDialog extends StatelessWidget {
  final InventoryItem item;

  const InventoryDetailDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InventoryDetailScreen(itemId: item.id),
        ),
      ),
    );
  }
}

