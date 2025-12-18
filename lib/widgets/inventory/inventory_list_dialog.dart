// lib/widgets/inventory/inventory_list_dialog.dart
// Dialog untuk menampilkan inventory list (desktop mode)

import 'package:flutter/material.dart';
import '../../screens/inventory/inventory_list_screen.dart';

/// Dialog untuk menampilkan daftar inventory di desktop
class InventoryListDialog extends StatelessWidget {
  const InventoryListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const InventoryListScreen(),
        ),
      ),
    );
  }
}

