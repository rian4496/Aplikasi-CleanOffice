// lib/widgets/inventory/inventory_analytics_dialog.dart
// Dialog untuk menampilkan inventory analytics (desktop mode)

import 'package:flutter/material.dart';
import '../../screens/inventory/inventory_analytics_screen.dart';

/// Dialog untuk menampilkan analytics inventory di desktop
class InventoryAnalyticsDialog extends StatelessWidget {
  const InventoryAnalyticsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const InventoryAnalyticsScreen(),
        ),
      ),
    );
  }
}

