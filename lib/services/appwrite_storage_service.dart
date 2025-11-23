// lib/services/appwrite_storage_service.dart

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../core/services/appwrite_client.dart';
import '../core/config/appwrite_config.dart';

/// Result pattern for error handling
class StorageResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  StorageResult.success(this.data)
      : error = null,
        isSuccess = true;

  StorageResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Appwrite Storage Service
///
/// Replaces Firebase Storage with Appwrite Storage API
/// Handles file uploads, downloads, and deletions
class AppwriteStorageService {
  final Logger _logger = Logger('AppwriteStorageService');

  // Get Appwrite storage service
  Storage get _storage => AppwriteClient().storage;

  // ==================== UPLOAD IMAGE ====================

  /// Upload image to Appwrite Storage with auto-compression
  ///
  /// [bytes] - Image bytes (from XFile.readAsBytes() or File.readAsBytes())
  /// [folder] - Folder name ('reports', 'profiles', 'inventory')
  /// [userId] - User ID for naming file
  /// [fileName] - Optional custom filename (default: userId_timestamp.jpg)
  ///
  /// Returns: StorageResult with file URL or error message
  Future<StorageResult<String>> uploadImage({
    required Uint8List bytes,
    required String folder,
    required String userId,
    String? fileName,
  }) async {
    try {
      // Validate input
      if (bytes.isEmpty) {
        return StorageResult.failure('Image bytes kosong');
      }

      // Compress image
      final compressedBytes = await _compressImageBytes(bytes);

      // Generate unique filename with folder prefix
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? '$folder/${userId}_$timestamp.jpg';

      // Upload to Appwrite Storage (single bucket with folder structure)
      final file = await _storage.createFile(
        bucketId: AppwriteConfig.mainBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: compressedBytes,
          filename: finalFileName,
        ),
      );

      // Get file view URL
      final fileUrl = _getFileViewUrl(AppwriteConfig.mainBucketId, file.$id);

      debugPrint('✅ Image uploaded: $fileUrl');
      return StorageResult.success(fileUrl);
    } on AppwriteException catch (e) {
      _logger.severe('❌ Appwrite error: ${e.message}', e);
      return StorageResult.failure('Appwrite error: ${e.message}');
    } catch (e, stackTrace) {
      _logger.severe('❌ Upload error', e, stackTrace);
      return StorageResult.failure('Gagal upload: $e');
    }
  }

  /// Upload inventory image (convenience method)
  ///
  /// [imageFile] - File object from image picker
  ///
  /// Returns: File URL string (throws on error)
  Future<String> uploadInventoryImage(File imageFile) async {
    try {
      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload using the generic method
      final result = await uploadImage(
        bytes: bytes,
        folder: AppwriteConfig.inventoryFolder,
        userId: 'inv',
      );

      // Check result and return URL or throw
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.error ?? 'Upload failed');
      }
    } catch (e) {
      _logger.severe('❌ Upload inventory image error: $e');
      throw Exception('Gagal upload gambar: $e');
    }
  }

  /// Upload report image (convenience method)
  Future<String> uploadReportImage(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final result = await uploadImage(
        bytes: bytes,
        folder: AppwriteConfig.reportsFolder,
        userId: userId,
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.error ?? 'Upload failed');
      }
    } catch (e) {
      _logger.severe('❌ Upload report image error: $e');
      throw Exception('Gagal upload gambar laporan: $e');
    }
  }

  /// Upload profile image (convenience method)
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final result = await uploadImage(
        bytes: bytes,
        folder: AppwriteConfig.profilesFolder,
        userId: userId,
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.error ?? 'Upload failed');
      }
    } catch (e) {
      _logger.severe('❌ Upload profile image error: $e');
      throw Exception('Gagal upload foto profil: $e');
    }
  }

  // ==================== DELETE IMAGE ====================

  /// Delete image from Appwrite Storage
  ///
  /// [imageUrl] - Full URL of the image to delete
  ///
  /// Returns: StorageResult with success status
  Future<StorageResult<bool>> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        return StorageResult.failure('URL image kosong');
      }

      // Extract bucket and file ID from URL
      final parts = _parseFileUrl(imageUrl);
      if (parts == null) {
        return StorageResult.failure('Invalid image URL format');
      }

      await _storage.deleteFile(
        bucketId: parts['bucketId']!,
        fileId: parts['fileId']!,
      );

      debugPrint('✅ Image deleted: $imageUrl');
      return StorageResult.success(true);
    } on AppwriteException catch (e) {
      _logger.severe('❌ Appwrite error: ${e.message}', e);
      return StorageResult.failure('Appwrite error: ${e.message}');
    } catch (e) {
      _logger.severe('❌ Delete error: $e');
      return StorageResult.failure('Gagal delete: $e');
    }
  }

  // ==================== GET IMAGE URL ====================

  /// Get file view URL
  ///
  /// [bucketId] - Bucket ID
  /// [fileId] - File ID
  ///
  /// Returns: Full URL to view the file
  String _getFileViewUrl(String bucketId, String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }

  /// Get file download URL
  String getFileDownloadUrl(String bucketId, String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/download?project=${AppwriteConfig.projectId}';
  }

  /// Parse file URL to extract bucket and file IDs
  ///
  /// Expected format: https://...endpoint.../storage/buckets/{bucketId}/files/{fileId}/view
  Map<String, String>? _parseFileUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find 'buckets' and 'files' in path
      final bucketsIndex = pathSegments.indexOf('buckets');
      final filesIndex = pathSegments.indexOf('files');

      if (bucketsIndex != -1 && filesIndex != -1 &&
          bucketsIndex + 1 < pathSegments.length &&
          filesIndex + 1 < pathSegments.length) {
        return {
          'bucketId': pathSegments[bucketsIndex + 1],
          'fileId': pathSegments[filesIndex + 1],
        };
      }

      return null;
    } catch (e) {
      _logger.warning('Error parsing file URL: $e');
      return null;
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Compress image bytes to save storage & bandwidth
  /// Target: ~500KB max
  Future<Uint8List> _compressImageBytes(Uint8List bytes) async {
    try {
      final originalSize = bytes.length;

      // Compress with quality 70
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      final compressedSize = result.length;

      debugPrint(
        '📦 Compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)}',
      );

      return result;
    } catch (e) {
      _logger.warning('⚠️ Compress error: $e');
      return bytes; // Return original if error
    }
  }

  /// Format bytes to KB/MB
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
