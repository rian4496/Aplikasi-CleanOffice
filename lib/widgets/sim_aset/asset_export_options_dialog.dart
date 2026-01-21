// lib/widgets/sim_aset/asset_export_options_dialog.dart
// Dialog for choosing PDF export options

import 'package:flutter/material.dart';

enum PdfOrientation { landscape, portrait }

class AssetExportOptions {
  final PdfOrientation orientation;
  final bool includePhoto;

  const AssetExportOptions({
    this.orientation = PdfOrientation.landscape,
    this.includePhoto = false,
  });
}

class AssetExportOptionsDialog extends StatefulWidget {
  const AssetExportOptionsDialog({super.key});

  @override
  State<AssetExportOptionsDialog> createState() => _AssetExportOptionsDialogState();
}

class _AssetExportOptionsDialogState extends State<AssetExportOptionsDialog> {
  PdfOrientation _orientation = PdfOrientation.landscape;
  bool _includePhoto = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red),
          SizedBox(width: 12),
          Text('Opsi Export PDF'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orientation
          const Text(
            'Orientasi Halaman',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<PdfOrientation>(
                  title: const Text('Landscape'),
                  subtitle: const Text('Horizontal'),
                  value: PdfOrientation.landscape,
                  groupValue: _orientation,
                  onChanged: (value) => setState(() => _orientation = value!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<PdfOrientation>(
                  title: const Text('Portrait'),
                  subtitle: const Text('Vertikal'),
                  value: PdfOrientation.portrait,
                  groupValue: _orientation,
                  onChanged: (value) => setState(() => _orientation = value!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Photo Option
          const Text(
            'Opsi Tambahan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Sertakan Foto Aset'),
            subtitle: const Text('Menampilkan gambar di tabel (lebih lambat)'),
            value: _includePhoto,
            onChanged: (value) => setState(() => _includePhoto = value),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(AssetExportOptions(
              orientation: _orientation,
              includePhoto: _includePhoto,
            ));
          },
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Export PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Show the dialog and return AssetExportOptions or null if cancelled
Future<AssetExportOptions?> showAssetExportOptionsDialog(BuildContext context) {
  return showDialog<AssetExportOptions>(
    context: context,
    builder: (context) => const AssetExportOptionsDialog(),
  );
}
