import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../core/design/admin_colors.dart';

class ReportPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;

  const ReportPreviewScreen({
    super.key,
    required this.title,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)), // Reduced font size
        backgroundColor: Colors.white, // Changed to white
        iconTheme: const IconThemeData(color: Colors.black), // Changed to black
        elevation: 0,
        shape: Border(
            bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      // Wrap body in Theme to force PdfPreview bottom bar to be white/neutral if possible,
      // or at least ensure it matches the requested style.
      // PdfPreview often uses the primary color for its bottom bar.
      body: Theme(
        data: Theme.of(context).copyWith(
          // Set primary color to white for the bar background
          primaryColor: Colors.white, 
          scaffoldBackgroundColor: Colors.grey.shade200, // Slightly darker background for the PDF preview area to contrast with the paper
          colorScheme: Theme.of(context).colorScheme.copyWith(
            surface: Colors.white, // Surface color for bars
            primary: Colors.white, // Button/Bar background
            onPrimary: Colors.black, // Button icon color (foreground)
            secondary: Colors.white,
            onSecondary: Colors.black,
          ),
          iconTheme: const IconThemeData(color: Colors.black), // Force black icons
        ),
        child: PdfPreview(
        build: (format) => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false, // Enforce the generated orientation
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: '$title.pdf',
        // Explicitly override actions to ensure icons are BLACK
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.print, color: Colors.black), 
            onPressed: (context, build, pageFormat) async {
               await Printing.layoutPdf(
                 onLayout: (format) => pdfBytes,
                 name: title,
               );
            },
          ),
          PdfPreviewAction(
            icon: const Icon(Icons.download_rounded, color: Colors.black),
            onPressed: (context, build, pageFormat) async {
              await Printing.sharePdf(bytes: pdfBytes, filename: '$title.pdf');
            },
          ),
        ],
      ),
      ),
    );
  }
}
