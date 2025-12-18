// lib/services/storage_service.dart
// Storage service - Using Supabase Storage

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Added XFile support

import 'supabase_storage_service.dart';

// Re-export StorageResult for backward compatibility
export 'supabase_storage_service.dart' show StorageResult;

/// Service untuk handle Storage - delegates to SupabaseStorageService
class StorageService {
  final SupabaseStorageService _supabaseStorage = SupabaseStorageService();

  // ========================================
  // UPLOAD IMAGE
  // ========================================

  Future<StorageResult<String>> uploadImage({
    required Uint8List bytes,
    required String bucket,
    required String userId,
    String? fileName,
  }) async {
    return _supabaseStorage.uploadImage(
      bytes: bytes,
      bucket: bucket,
      userId: userId,
      fileName: fileName,
    );
  }

  Future<String> uploadInventoryImage(XFile imageFile) async {
    return _supabaseStorage.uploadInventoryImage(imageFile);
  }

  Future<String> uploadReportImage(XFile imageFile, String userId) async {
    return _supabaseStorage.uploadReportImage(imageFile, userId);
  }

  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    return _supabaseStorage.uploadProfileImage(imageFile, userId);
  }

  // ========================================
  // DELETE IMAGE
  // ========================================

  Future<StorageResult<bool>> deleteImage(String imageUrl) async {
    return _supabaseStorage.deleteImage(imageUrl);
  }

  // ========================================
  // GET IMAGE URL
  // ========================================

  Future<StorageResult<String>> getImageUrl(String bucket, String filePath) async {
    try {
      final url = _supabaseStorage.getPublicUrl(bucket, filePath);
      return StorageResult.success(url);
    } catch (e) {
      debugPrint('Get URL error: $e');
      return StorageResult.failure('Gagal get URL: $e');
    }
  }
}

// ========================================
// RIVERPOD PROVIDER
// ========================================

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

