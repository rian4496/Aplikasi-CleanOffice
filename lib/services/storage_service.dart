// lib/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Result pattern untuk error handling yang clean
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

/// Service untuk handle Firebase Storage
/// Features:
/// - Upload image dengan auto-compression
/// - Delete image
/// - Get image URL
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ========================================
  // UPLOAD IMAGE
  // ========================================
  
  /// Upload image ke Firebase Storage dengan auto-compression
  /// 
  /// [bytes] - Image bytes (dari XFile.readAsBytes() atau File.readAsBytes())
  /// [folder] - Folder tujuan ('reports' atau 'profiles')
  /// [userId] - User ID untuk naming file
  /// [fileName] - Optional custom filename (default: userId_timestamp.jpg)
  /// 
  /// Returns: StorageResult dengan URL download atau error message
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

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? '${userId}_$timestamp.jpg';
      final storagePath = '$folder/$finalFileName';

      // Upload ke Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      debugPrint('✅ Image uploaded: $downloadUrl');
      return StorageResult.success(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.message}');
      return StorageResult.failure('Firebase error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return StorageResult.failure('Gagal upload: $e');
    }
  }

  // ========================================
  // DELETE IMAGE
  // ========================================
  
  /// Delete image dari Firebase Storage
  /// 
  /// [imageUrl] - URL lengkap dari image yang akan dihapus
  /// 
  /// Returns: StorageResult dengan success status
  Future<StorageResult<bool>> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        return StorageResult.failure('URL image kosong');
      }

      // Get reference dari URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      debugPrint('✅ Image deleted: $imageUrl');
      return StorageResult.success(true);
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.message}');
      return StorageResult.failure('Firebase error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return StorageResult.failure('Gagal delete: $e');
    }
  }

  // ========================================
  // GET IMAGE URL
  // ========================================
  
  /// Get download URL dari path di Storage
  /// 
  /// [storagePath] - Path file di Storage (misal: 'reports/user123_123456.jpg')
  /// 
  /// Returns: StorageResult dengan download URL
  Future<StorageResult<String>> getImageUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      
      return StorageResult.success(url);
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.message}');
      return StorageResult.failure('Firebase error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Get URL error: $e');
      return StorageResult.failure('Gagal get URL: $e');
    }
  }

  // ========================================
  // PRIVATE HELPER METHODS
  // ========================================

  /// Compress image bytes untuk hemat storage & bandwidth
  /// Target: ~500KB max
  Future<Uint8List> _compressImageBytes(Uint8List bytes) async {
    try {
      final originalSize = bytes.length;

      // Compress dengan quality 70
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      final compressedSize = result.length;
      
      debugPrint('📦 Compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)}');
      
      return result;
    } catch (e) {
      debugPrint('⚠️ Compress error: $e');
      return bytes; // Return original kalau error
    }
  }

  /// Format bytes ke KB/MB
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ========================================
// RIVERPOD PROVIDER
// ========================================

/// Provider untuk StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});