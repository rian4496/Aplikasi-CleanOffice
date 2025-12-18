// lib/core/utils/image_optimizer.dart
// Image optimization utilities

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageOptimizer {
  /// Compress image for upload
  static Future<File?> compressImage(
    File imageFile, {
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Image compression error: $e');
      return imageFile; // Return original if compression fails
    }
  }

  /// Get optimized image size
  static Future<int> getImageSize(File imageFile) async {
    try {
      return await imageFile.length();
    } catch (e) {
      return 0;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

