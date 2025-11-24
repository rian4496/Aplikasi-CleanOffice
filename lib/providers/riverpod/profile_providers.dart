// lib/providers/riverpod/profile_providers.dart
// ✅ PROFILE PROVIDERS - Migrated to Appwrite
//
// FEATURES:
// - Profile update actions
// - Profile picture upload/delete
// - Work schedule providers

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../models/work_schedule.dart';
import '../../services/appwrite_database_service.dart';
import '../../services/appwrite_storage_service.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';
import './inventory_providers.dart' show appwriteDatabaseServiceProvider;
import './request_providers.dart' show appwriteStorageServiceProvider;

final _logger = AppLogger('ProfileProviders');

// ==================== PROFILE ACTIONS NOTIFIER ====================

class ProfileActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AppwriteDatabaseService get _database =>
      ref.read(appwriteDatabaseServiceProvider);
  AppwriteStorageService get _storage =>
      ref.read(appwriteStorageServiceProvider);

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Updating profile for user: ${updatedProfile.uid}');

      await _database.updateUserProfile(updatedProfile);

      _logger.info('Profile updated successfully');
      state = const AsyncValue.data(null);

      // Refresh current user profile
      ref.invalidate(currentUserProfileProvider);
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Update profile error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      throw const DatabaseException(
        message: 'Gagal mengupdate profil. Silakan coba lagi.',
      );
    }
  }

  /// Upload profile picture (supports both File and Uint8List)
  Future<String?> uploadProfilePicture({
    File? imageFile,
    Uint8List? imageBytes,
    required String userId,
  }) async {
    try {
      _logger.info('Uploading profile picture for user: $userId');

      Uint8List? bytes = imageBytes;
      if (bytes == null && imageFile != null) {
        bytes = await imageFile.readAsBytes();
      }

      if (bytes == null) {
        throw const ValidationException(message: 'No image provided');
      }

      final result = await _storage.uploadImage(
        bytes: bytes,
        folder: 'profile_pictures',
        userId: userId,
      );

      if (result.isSuccess && result.data != null) {
        _logger.info('Profile picture uploaded successfully');
        return result.data;
      } else {
        _logger.error('Upload profile picture failed: ${result.error}');
        throw StorageException(message: result.error ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      _logger.error('Upload profile picture error', e, stackTrace);
      rethrow;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String photoUrl, String userId) async {
    try {
      _logger.info('Deleting profile picture for user: $userId');

      // Delete from storage
      await _storage.deleteImage(photoUrl);

      // Update user profile to remove photo URL
      final currentProfile = ref.read(currentUserProfileProvider).value;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(photoURL: null);
        await _database.updateUserProfile(updatedProfile);
      }

      _logger.info('Profile picture deleted successfully');

      // Refresh profile
      ref.invalidate(currentUserProfileProvider);
    } catch (e, stackTrace) {
      _logger.error('Delete profile picture error', e, stackTrace);
      throw const StorageException(
        message: 'Gagal menghapus foto profil. Silakan coba lagi.',
      );
    }
  }

  /// Update profile with new photo
  Future<void> updateProfileWithPhoto({
    File? imageFile,
    Uint8List? imageBytes,
    required UserProfile profile,
  }) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Updating profile with new photo');

      // Upload image first
      final photoUrl = await uploadProfilePicture(
        imageFile: imageFile,
        imageBytes: imageBytes,
        userId: profile.uid,
      );

      if (photoUrl != null) {
        // Update profile with new photo URL
        final updatedProfile = profile.copyWith(photoURL: photoUrl);
        await updateProfile(updatedProfile);
        _logger.info('Profile and photo updated successfully');
      }

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Update profile with photo error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final profileActionsProvider =
    NotifierProvider<ProfileActionsNotifier, AsyncValue<void>>(
      () => ProfileActionsNotifier(),
    );

// ==================== WORK SCHEDULE PROVIDERS ====================
// Note: Work schedules are not included in the simplified Appwrite schema
// These providers return empty lists as placeholders
// TODO: Implement when schedules collection is added to Appwrite

/// Provider untuk work schedules (stream)
final userSchedulesProvider = StreamProvider.family<List<WorkSchedule>, String>(
  (ref, userId) {
    // TODO: Implement with Appwrite when schedules collection is added
    _logger.info('Work schedules not yet implemented in Appwrite');
    return Stream.value([]);
  },
);

/// Provider untuk current user's schedules
final currentUserSchedulesProvider = StreamProvider<List<WorkSchedule>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  // TODO: Implement with Appwrite when schedules collection is added
  _logger.info('Work schedules not yet implemented in Appwrite');
  return Stream.value([]);
});
