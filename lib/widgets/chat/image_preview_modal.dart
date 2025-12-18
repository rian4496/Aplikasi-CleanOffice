// lib/widgets/chat/image_preview_modal.dart
// Modal untuk preview image full screen

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/design/admin_colors.dart';

/// Image Preview Modal
/// Full screen image viewer with zoom and download
class ImagePreviewModal extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const ImagePreviewModal({
    super.key,
    required this.imageUrl,
    this.caption,
  });

  /// Show image preview modal
  static void show(
    BuildContext context, {
    required String imageUrl,
    String? caption,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImagePreviewModal(
          imageUrl: imageUrl,
          caption: caption,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Download button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download akan segera tersedia'),
                  backgroundColor: AdminColors.info,
                ),
              );
            },
            tooltip: 'Download',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image viewer
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Caption (if available)
          if (caption != null && caption!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.7),
              child: Text(
                caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

