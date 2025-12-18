// lib/services/supabase_storage_service.dart

// import 'dart:io'; // REMOVED for Web Compatibility
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Added XFile support
import '../core/config/supabase_config.dart';

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

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  StorageException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Supabase Storage Service
///
/// Replaces Appwrite Storage with Supabase Storage API
/// Handles file uploads, downloads, and deletions
class SupabaseStorageService {
  final Logger _logger = Logger('SupabaseStorageService');

  // Get Supabase storage client
  SupabaseStorageClient get _storage => Supabase.instance.client.storage;

  // ==================== UPLOAD IMAGE ====================

  /// Upload image to Supabase Storage with auto-compression
  ///
  /// [bytes] - Image bytes (from XFile.readAsBytes() or File.readAsBytes())
  /// [bucket] - Bucket name ('report-images', 'profile-images', 'inventory-images')
  /// [userId] - User ID for naming file
  /// [fileName] - Optional custom filename (default: userId_timestamp.jpg)
  ///
  /// Returns: StorageResult with public URL or error message
  Future<StorageResult<String>> uploadImage({
    required Uint8List bytes,
    required String bucket,
    required String userId,
    String? fileName,
  }) async {
    try {
      _logger.info('📤 Uploading image to bucket: $bucket');

      // Validate input
      if (bytes.isEmpty) {
        return StorageResult.failure('Image bytes kosong');
      }

      // Compress image
      final compressedBytes = await _compressImageBytes(bytes);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? '${userId}_$timestamp.jpg';

      // Upload to Supabase Storage
      await _storage.from(bucket).uploadBinary(
            finalFileName,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _storage.from(bucket).getPublicUrl(finalFileName);

      _logger.info('✅ Image uploaded: $publicUrl');
      return StorageResult.success(publicUrl);
    } on StorageException catch (e) {
      _logger.severe('❌ Storage error: ${e.message}', e, e.stackTrace);
      return StorageResult.failure('Storage error: ${e.message}');
    } catch (e, stackTrace) {
      _logger.severe('❌ Upload error', e, stackTrace);
      return StorageResult.failure('Gagal upload: $e');
    }
  }

  /// Upload report image (convenience method)
  ///
  /// [imageFile] - XFile object from image picker
  /// [userId] - User ID for tracking who uploaded
  ///
  /// Returns: Public URL string (throws on error)
  Future<String> uploadReportImage(XFile imageFile, String userId) async {
    try {
      _logger.info('📸 Uploading report image for user: $userId');

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload using the generic method
      final result = await uploadImage(
        bytes: bytes,
        bucket: SupabaseConfig.reportImagesBucket,
        userId: userId,
      );

      // ... (Rest of logic)
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw StorageException(message: result.error ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      // ... (Error handling)
      _logger.severe('❌ Upload report image error', e, stackTrace);
      if (e is StorageException) rethrow;
      throw StorageException(message: 'Gagal upload gambar laporan: $e', originalError: e);
    }
  }

  /// Upload inventory image (convenience method)
  ///
  /// [imageFile] - XFile object from image picker
  ///
  /// Returns: Public URL string (throws on error)
  Future<String> uploadInventoryImage(XFile imageFile) async {
    try {
      _logger.info('📦 Uploading inventory image');

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload using the generic method
      final result = await uploadImage(
        bytes: bytes,
        bucket: SupabaseConfig.inventoryImagesBucket,
        userId: 'inv',
      );

      // ... 
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw StorageException(message: result.error ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      _logger.severe('❌ Upload inventory image error', e, stackTrace);
      if (e is StorageException) rethrow;
      throw StorageException(message: 'Gagal upload gambar inventory: $e', originalError: e);
    }
  }

  /// Upload profile image (convenience method)
  ///
  /// [imageFile] - XFile object from image picker
  /// [userId] - User ID for naming file
  ///
  /// Returns: Public URL string (throws on error)
  Future<String> uploadProfileImage(XFile imageFile, String userId) async {

    try {
      _logger.info('👤 Uploading profile image for user: $userId');

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload using the generic method
      final result = await uploadImage(
        bytes: bytes,
        bucket: SupabaseConfig.profileImagesBucket,
        userId: userId,
      );

      // Check result and return URL or throw
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw StorageException(
          message: result.error ?? 'Upload failed',
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('❌ Upload profile image error', e, stackTrace);
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        message: 'Gagal upload foto profil: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== DELETE IMAGE ====================

  /// Delete image from Supabase Storage
  ///
  /// [imageUrl] - Public URL of the image to delete
  ///
  /// Returns: StorageResult with success status
  Future<StorageResult<bool>> deleteImage(String imageUrl) async {
    try {
      _logger.info('🗑️ Deleting image: $imageUrl');

      if (imageUrl.isEmpty) {
        return StorageResult.failure('URL image kosong');
      }

      // Extract bucket and file path from URL
      final parts = _parseFileUrl(imageUrl);
      if (parts == null) {
        return StorageResult.failure('Invalid image URL format');
      }

      // Delete file from storage
      await _storage.from(parts['bucket']!).remove([parts['filePath']!]);

      _logger.info('✅ Image deleted successfully');
      return StorageResult.success(true);
    } on StorageException catch (e) {
      _logger.severe('❌ Storage error: ${e.message}', e, e.stackTrace);
      return StorageResult.failure('Storage error: ${e.message}');
    } catch (e, stackTrace) {
      _logger.severe('❌ Delete error', e, stackTrace);
      return StorageResult.failure('Gagal delete: $e');
    }
  }

  /// Delete report image (convenience method)
  Future<bool> deleteReportImage(String imageUrl) async {
    final result = await deleteImage(imageUrl);
    if (result.isSuccess) {
      return true;
    } else {
      throw StorageException(message: result.error ?? 'Delete failed');
    }
  }

  /// Delete inventory image (convenience method)
  Future<bool> deleteInventoryImage(String imageUrl) async {
    final result = await deleteImage(imageUrl);
    if (result.isSuccess) {
      return true;
    } else {
      throw StorageException(message: result.error ?? 'Delete failed');
    }
  }

  /// Delete profile image (convenience method)
  Future<bool> deleteProfileImage(String imageUrl) async {
    final result = await deleteImage(imageUrl);
    if (result.isSuccess) {
      return true;
    } else {
      throw StorageException(message: result.error ?? 'Delete failed');
    }
  }

  // ==================== GET IMAGE URL ====================

  /// Get public URL for a file
  ///
  /// [bucket] - Bucket name
  /// [filePath] - File path in bucket
  ///
  /// Returns: Public URL to access the file
  String getPublicUrl(String bucket, String filePath) {
    return _storage.from(bucket).getPublicUrl(filePath);
  }

  /// Parse Supabase file URL to extract bucket and file path
  ///
  /// Expected format: https://{project}.supabase.co/storage/v1/object/public/{bucket}/{filePath}
  Map<String, String>? _parseFileUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find 'public' in path (Supabase public files)
      final publicIndex = pathSegments.indexOf('public');

      if (publicIndex != -1 && publicIndex + 2 < pathSegments.length) {
        final bucket = pathSegments[publicIndex + 1];
        final filePath = pathSegments.sublist(publicIndex + 2).join('/');

        return {
          'bucket': bucket,
          'filePath': filePath,
        };
      }

      return null;
    } catch (e) {
      _logger.warning('⚠️ Error parsing file URL: $e');
      return null;
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Compress image bytes to save storage & bandwidth
  /// Target: ~500KB max
  Future<Uint8List> _compressImageBytes(Uint8List bytes) async {
    try {
      final originalSize = bytes.length;

      // Skip compression if already small
      if (originalSize < 500 * 1024) {
        _logger.info('📦 Image already small (${_formatBytes(originalSize)}), skipping compression');
        return bytes;
      }

      // Compress with quality 70
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      final compressedSize = result.length;

      _logger.info(
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

  // ==================== LIST FILES (BONUS FEATURE) ====================

  /// List all files in a bucket (useful for debugging/admin)
  ///
  /// [bucket] - Bucket name
  /// [path] - Optional folder path
  ///
  /// Returns: List of file objects
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      _logger.info('📂 Listing files in bucket: $bucket${path != null ? '/$path' : ''}');

      final files = await _storage.from(bucket).list(
            path: path,
          );

      _logger.info('✅ Found ${files.length} files');
      return files;
    } catch (e, stackTrace) {
      _logger.severe('❌ List files error', e, stackTrace);
      throw StorageException(
        message: 'Gagal list files: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

