// lib/services/storage_service.dart
// Storage service - Using Appwrite Storage

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/appwrite_storage_service.dart';

// Re-export StorageResult from appwrite_storage_service for backward compatibility
export '../services/appwrite_storage_service.dart' show StorageResult;

/// Service untuk handle Storage - delegates to AppwriteStorageService
/// Features:
/// - Upload image dengan auto-compression
/// - Delete image
/// - Get image URL
class StorageService {
  final AppwriteStorageService _appwriteStorage = AppwriteStorageService();

  // ========================================
  // UPLOAD IMAGE
  // ========================================

  /// Upload image ke Storage dengan auto-compression
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
    return _appwriteStorage.uploadImage(
      bytes: bytes,
      folder: folder,
      userId: userId,
      fileName: fileName,
    );
  }

  /// Upload inventory image (convenience method)
  ///
  /// [imageFile] - File object dari image picker
  ///
  /// Returns: Download URL string (throws on error)
  Future<String> uploadInventoryImage(File imageFile) async {
    return _appwriteStorage.uploadInventoryImage(imageFile);
  }

  /// Upload report image (convenience method)
  Future<String> uploadReportImage(File imageFile, String userId) async {
    return _appwriteStorage.uploadReportImage(imageFile, userId);
  }

  /// Upload profile image (convenience method)
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return _appwriteStorage.uploadProfileImage(imageFile, userId);
  }

  // ========================================
  // DELETE IMAGE
  // ========================================

  /// Delete image dari Storage
  ///
  /// [imageUrl] - URL lengkap dari image yang akan dihapus
  ///
  /// Returns: StorageResult dengan success status
  Future<StorageResult<bool>> deleteImage(String imageUrl) async {
    return _appwriteStorage.deleteImage(imageUrl);
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
    // For Appwrite, we construct the URL directly
    // This is a simplified implementation - actual URL format depends on Appwrite setup
    try {
      // The storagePath format is typically: folder/filename
      // We can't directly get URL from path in Appwrite like Firebase
      // This would need the file ID, so we return an error for now
      debugPrint('getImageUrl called with path: $storagePath');
      return StorageResult.failure(
        'Direct path to URL conversion not supported. Use file URLs from upload response.',
      );
    } catch (e) {
      debugPrint('Get URL error: $e');
      return StorageResult.failure('Gagal get URL: $e');
    }
  }
}

// ========================================
// RIVERPOD PROVIDER
// ========================================

/// Provider untuk StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
