// lib/widgets/universal_image.dart
// ✅ Cross-platform image widget (Android + Web)

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String? imageUrl;        // Network URL
  final File? imageFile;         // Mobile: File from image_picker
  final Uint8List? imageBytes;   // Web: bytes from image_picker
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // Priority: bytes > file > url
    if (imageBytes != null) {
      // Web or mobile bytes
      imageWidget = Image.memory(
        imageBytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (imageFile != null && !kIsWeb) {
      // Mobile: File
      imageWidget = Image.file(
        imageFile!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Network URL
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // No image provided
      return _buildPlaceholder();
    }

    // Wrap with border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }
}

/// Image picker helper untuk cross-platform
class UniversalImagePicker {
  /// Convert XFile to appropriate format for platform
  static Future<Map<String, dynamic>> processPickedImage(dynamic pickedFile) async {
    if (pickedFile == null) {
      return {'file': null, 'bytes': null};
    }

    if (kIsWeb) {
      // Web: convert to bytes
      final bytes = await pickedFile.readAsBytes();
      return {'file': null, 'bytes': bytes as Uint8List};
    } else {
      // Mobile: use File
      return {'file': File(pickedFile.path), 'bytes': null};
    }
  }
}
