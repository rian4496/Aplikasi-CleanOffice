// lib/widgets/sim_aset/pdf_preview_dialog.dart
// Custom scrollable PDF preview dialog

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PdfPreviewDialog extends StatefulWidget {
  final Future<Uint8List> Function() pdfGenerator;
  final String title;
  final String fileName;

  const PdfPreviewDialog({
    super.key,
    required this.pdfGenerator,
    required this.title,
    required this.fileName,
  });

  @override
  State<PdfPreviewDialog> createState() => _PdfPreviewDialogState();
}

class _PdfPreviewDialogState extends State<PdfPreviewDialog> {
  Uint8List? _pdfBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    final bytes = await widget.pdfGenerator();
    setState(() {
      _pdfBytes = bytes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Preview area - scrollable
            Expanded(
              child: _loading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Generating PDF...'),
                        ],
                      ),
                    )
                  : _pdfBytes != null
                      ? PdfPreview(
                          build: (format) async => _pdfBytes!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          allowPrinting: false,
                          allowSharing: false,
                          pdfFileName: widget.fileName,
                        )
                      : const Center(child: Text('Gagal generate PDF')),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pdfBytes != null
                        ? () async {
                            await Printing.layoutPdf(
                              onLayout: (format) async => _pdfBytes!,
                              name: widget.fileName,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Cetak / Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
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

/// Show custom PDF preview dialog
Future<void> showPdfPreviewDialog({
  required BuildContext context,
  required Future<Uint8List> Function() pdfGenerator,
  required String title,
  required String fileName,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PdfPreviewDialog(
      pdfGenerator: pdfGenerator,
      title: title,
      fileName: fileName,
    ),
  );
}
