// lib/widgets/completion_photo_dialog.dart
// ✅ FIXED: Web support dengan UniversalImage

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'universal_image.dart';

/// Dialog untuk upload foto bukti penyelesaian
/// Digunakan oleh cleaner saat menandai pekerjaan selesai
/// ✅ UPDATED: Support web dengan Uint8List
class CompletionPhotoDialog {
  /// Static method untuk show dialog dengan return Future of XFile
  /// Returns XFile instead of File for cross-platform compatibility
  static Future<XFile?> show(
    BuildContext context, {
    String? title,
    String? description,
  }) async {
    return await showDialog<XFile?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        XFile? selectedImage;
        Uint8List? imageBytes;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Center( // ✅ ADDED: Center wrapper
              child: ConstrainedBox( // ✅ ADDED: Max width constraint
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: AlertDialog(
              title: Text(
                title ?? 'Upload Foto Bukti Penyelesaian',
                style: const TextStyle(fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description ??
                          'Upload foto sebagai bukti bahwa pekerjaan sudah selesai',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),

                    // Image Preview - ✅ Using UniversalImage
                    if (isLoading)
                      // Loading indicator
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                          minHeight: 150,
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Memuat foto...'),
                            ],
                          ),
                        ),
                      )
                    else if (selectedImage != null && imageBytes != null)
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                          minHeight: 150,
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            UniversalImage(
                              imageBytes: imageBytes,
                              width: 450, // ✅ Fixed width instead of double.infinity
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                    imageBytes = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                          minHeight: 150,
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada foto',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Action Buttons - ✅ Web-friendly layout
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          if (!kIsWeb) // Camera only on mobile
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : () async {
                                  setState(() => isLoading = true);
                                  try {
                                    final result = await _pickImage(ImageSource.camera);
                                    if (result != null) {
                                      setState(() {
                                        selectedImage = result['file'];
                                        imageBytes = result['bytes'];
                                      });
                                    }
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Kamera'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          if (!kIsWeb) const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : () async {
                                setState(() => isLoading = true);
                                try {
                                  final result = await _pickImage(ImageSource.gallery);
                                  if (result != null) {
                                    setState(() {
                                      selectedImage = result['file'];
                                      imageBytes = result['bytes'];
                                    });
                                  }
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galeri'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('BATAL'),
                ),
                ElevatedButton(
                  onPressed: (selectedImage == null || isLoading)
                      ? null
                      : () => Navigator.pop(context, selectedImage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('LANJUTKAN'),
                ),
              ],
            ), // AlertDialog
              ), // ConstrainedBox
            ); // Center
          },
        );
      },
    );
  }

  /// Pick image from camera or gallery
  /// Returns Map with 'file' (XFile) and 'bytes' (Uint8List)
  /// Optimized with lower image quality and resolution to prevent lag
  static Future<Map<String, dynamic>?> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,    // ✅ Further reduced from 1280 for web
        maxHeight: 800,   // ✅ Further reduced from 1280 for web
        imageQuality: 60, // ✅ Further reduced from 70 for faster loading
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return {
          'file': pickedFile,
          'bytes': bytes,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}