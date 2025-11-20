// lib/widgets/inventory/stock_requests_dialog.dart
// Dialog untuk menampilkan stock requests (desktop mode)

import 'package:flutter/material.dart';
import '../../screens/inventory/stock_requests_screen.dart';

/// Dialog untuk menampilkan daftar stock requests di desktop
class StockRequestsDialog extends StatelessWidget {
  const StockRequestsDialog({super.key});

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
          child: const StockRequestsScreen(),
        ),
      ),
    );
  }
}
