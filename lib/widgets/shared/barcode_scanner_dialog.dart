// lib/widgets/shared/barcode_scanner_dialog.dart
// Reusable barcode scanner dialog using mobile_scanner

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';

/// Dialog for scanning barcodes using device camera
/// Returns the scanned barcode string or null if cancelled
class BarcodeScannerDialog extends StatefulWidget {
  final String title;
  
  const BarcodeScannerDialog({
    super.key,
    this.title = 'Scan Barcode',
  });

  /// Show the scanner dialog and return scanned barcode
  static Future<String?> show(BuildContext context, {String? title}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BarcodeScannerDialog(
        title: title ?? 'Scan Barcode',
      ),
    );
  }

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanned = false;
  String? _lastScanned;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isScanned = true;
      _lastScanned = barcode.rawValue;
    });

    // Show confirmation before returning
    _showConfirmation(barcode.rawValue!);
  }

  void _showConfirmation(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Barcode Terdeteksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 48, color: Colors.green[600]),
            const SizedBox(height: 16),
            Text(
              barcode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanned = false); // Allow rescan
            },
            child: const Text('Scan Ulang'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, barcode); // Return barcode
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gunakan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primary,
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scanner View
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  
                  // Scan overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Instructions
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      color: Colors.black54,
                      child: const Text(
                        'Arahkan kamera ke barcode produk',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Torch toggle
                  IconButton(
                    icon: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        return Icon(
                          state.torchState == TorchState.on
                              ? Icons.flash_on
                              : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                    onPressed: () => _controller.toggleTorch(),
                    tooltip: 'Toggle Flash',
                  ),
                  const SizedBox(width: 24),
                  // Camera switch
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 28),
                    onPressed: () => _controller.switchCamera(),
                    tooltip: 'Switch Camera',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
