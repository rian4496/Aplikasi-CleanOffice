// lib/screens/sim_aset/qr_scanner_screen.dart
// SIM-ASET: QR Code Scanner Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../riverpod/asset_providers.dart';
import 'asset_detail_screen.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastScannedCode;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code Aset'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'Ganti Kamera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          
          // Overlay
          _buildOverlay(),
          
          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
          
          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Mencari aset...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: AppTheme.primary,
          borderWidth: 3,
          overlayColor: Colors.black54,
          borderRadius: 16,
          cutOutSize: 280,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_scanner, size: 40, color: AppTheme.primary),
          const SizedBox(height: 12),
          const Text(
            'Arahkan kamera ke QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan QR Code terlihat jelas dalam kotak scan',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          if (_lastScannedCode != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Terakhir: $_lastScannedCode',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Manual input option
          OutlinedButton.icon(
            onPressed: _showManualInput,
            icon: const Icon(Icons.keyboard),
            label: const Text('Input Manual'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;
    
    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    await _findAssetByQrCode(code);
  }

  Future<void> _findAssetByQrCode(String qrCode) async {
    try {
      final asset = await ref.read(assetByQrCodeProvider(qrCode).future);
      
      if (!mounted) return;
      
      if (asset != null) {
        // Found! Navigate to detail
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AssetDetailScreen(asset: asset),
          ),
        );
      } else {
        // Not found
        _showNotFoundDialog(qrCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showNotFoundDialog(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Aset Tidak Ditemukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tidak ada aset dengan kode:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                qrCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Scan Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to create asset with this QR
            },
            child: const Text('Daftarkan Aset'),
          ),
        ],
      ),
    );
  }

  void _showManualInput() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Kode Manual'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kode QR Aset',
            hintText: 'BRIDA-XXXXXXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _findAssetByQrCode(code);
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  void _switchCamera() {
    _controller?.switchCamera();
  }
}

// Custom overlay shape for scanner
class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double cutOutSize;

  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        _getCutOutRect(rect),
        Radius.circular(borderRadius),
      ));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        _getCutOutRect(rect),
        Radius.circular(borderRadius),
      ))
      ..fillType = PathFillType.evenOdd;
  }

  Rect _getCutOutRect(Rect rect) {
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;
    final cutOutLeft = rect.left + (rect.width - cutOutWidth) / 2;
    final cutOutTop = rect.top + (rect.height - cutOutHeight) / 2 - 100;
    return Rect.fromLTWH(cutOutLeft, cutOutTop, cutOutWidth, cutOutHeight);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(getOuterPath(rect), paint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = _getCutOutRect(rect);
    final rrect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

