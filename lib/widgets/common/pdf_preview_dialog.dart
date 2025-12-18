import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfPreviewDialog extends StatelessWidget {
  final String title;
  final String docNumber;
  final VoidCallback? onPrint;
  final VoidCallback? onDownload;

  const PdfPreviewDialog({
    super.key, 
    required this.title, 
    required this.docNumber,
    this.onPrint,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(docNumber, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 32),

            // Content (Mock PDF View)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('PDF Preview Mockup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Content for $docNumber', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 32),
                      // Mock Pages
                      Container(
                        height: 200,
                        width: 150,
                        color: Colors.white,
                        child: const Center(child: Text('Page 1')),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onDownload ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: onPrint ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Document'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
