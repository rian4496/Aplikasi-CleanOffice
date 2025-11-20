// lib/widgets/inventory/inventory_form_side_panel.dart
// Side panel untuk form tambah/edit inventory (desktop mode)

import 'package:flutter/material.dart';
import '../../screens/inventory/inventory_add_edit_screen.dart';

/// Side panel untuk menampilkan form inventory di desktop
class InventoryFormSidePanel extends StatelessWidget {
  final String? itemId;

  const InventoryFormSidePanel({
    super.key,
    this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.centerRight,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: 500,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: InventoryAddEditScreen(itemId: itemId),
        ),
      ),
    );
  }
}
