// lib/providers/riverpod/profile_providers.dart
// ✅ PROFILE PROVIDERS - Migrated to Supabase
//
// FEATURES:
// - Profile update actions
// - Profile picture upload/delete
// - Work schedule providers

// import 'dart:io'; // REMOVED for Web Compatibility
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../models/work_schedule.dart';
import '../../services/supabase_database_service.dart';
import '../../services/supabase_storage_service.dart' hide StorageException;
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../core/config/supabase_config.dart';
import './auth_providers.dart';
import './supabase_service_providers.dart';

final _logger = AppLogger('ProfileProviders');

// ==================== PROFILE ACTIONS NOTIFIER ====================

class ProfileActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  SupabaseDatabaseService get _database =>
      ref.read(supabaseDatabaseServiceProvider);
  SupabaseStorageService get _storage =>
      ref.read(supabaseStorageServiceProvider);

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Updating profile for user: ${updatedProfile.uid}');

      await _database.updateUserProfile(
        userId: updatedProfile.uid,
        displayName: updatedProfile.displayName,
        phoneNumber: updatedProfile.phoneNumber,
        photoUrl: updatedProfile.photoURL,
        location: updatedProfile.location,
      );

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
    dynamic imageFile, // Changed from File to dynamic for Web Compatibility
    Uint8List? imageBytes,
    required String userId,
  }) async {
    try {
      _logger.info('Uploading profile picture for user: $userId');

      Uint8List? bytes = imageBytes;
      if (bytes == null && imageFile != null) {
         // File logic removed. Callers must pass bytes.
         _logger.warning('Passing File object is deprecated. Use imageBytes.');
      }

      if (bytes == null) {
        throw const ValidationException(message: 'No image provided');
      }

      final result = await _storage.uploadImage(
        bytes: bytes,
        bucket: SupabaseConfig.profileImagesBucket,
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
        await _database.updateUserProfile(
          userId: currentProfile.uid,
          photoUrl: '', // Clear the photo URL
        );
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
    dynamic imageFile,
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

