import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../models/work_schedule.dart'; // TAMBAHAN: Import WorkSchedule model
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './auth_providers.dart';

final _logger = AppLogger('ProfileProviders');

// ==================== STORAGE PROVIDER ====================

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// ==================== PROFILE ACTIONS NOTIFIER ====================

class ProfileActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  FirebaseStorage get _storage => ref.read(firebaseStorageProvider);
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Updating profile for user: ${updatedProfile.uid}');

      await _firestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update(updatedProfile.toMap());

      _logger.info('Profile updated successfully');
      state = const AsyncValue.data(null);

      // Refresh current user profile
      ref.invalidate(currentUserProfileProvider);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Update profile error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected update profile error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      _logger.info('Uploading profile picture for user: $userId');

      // Delete old picture if exists
      try {
        final oldRef = _storage.ref().child('profile_pictures/$userId.jpg');
        await oldRef.delete();
        _logger.info('Old profile picture deleted');
      } catch (e) {
        _logger.warning('No old profile picture to delete');
      }

      // Upload new picture
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _logger.info('Profile picture uploaded successfully');
      return downloadUrl;
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Upload profile picture error', e, stackTrace);
      throw StorageException.fromFirebase(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected upload error', e, stackTrace);
      rethrow;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String photoUrl, String userId) async {
    try {
      _logger.info('Deleting profile picture for user: $userId');

      // Delete from storage
      final storageRef = _storage.refFromURL(photoUrl);
      await storageRef.delete();

      // Update user profile
      await _auth.currentUser?.updatePhotoURL(null);

      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'photoURL': null,
      });

      _logger.info('Profile picture deleted successfully');

      // Refresh profile
      ref.invalidate(currentUserProfileProvider);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Delete profile picture error', e, stackTrace);
      throw StorageException.fromFirebase(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected delete error', e, stackTrace);
      rethrow;
    }
  }

  /// Update profile with new photo
  Future<void> updateProfileWithPhoto({
    required File imageFile,
    required UserProfile profile,
  }) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Updating profile with new photo');

      // Upload image first
      final photoUrl = await uploadProfilePicture(imageFile, profile.uid);

      // Update auth profile
      await _auth.currentUser?.updatePhotoURL(photoUrl);

      // Update profile with new photo URL
      final updatedProfile = profile.copyWith(photoURL: photoUrl);
      await updateProfile(updatedProfile);

      _logger.info('Profile and photo updated successfully');
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

/// Provider untuk work schedules (stream)
final userSchedulesProvider = StreamProvider.family<List<WorkSchedule>, String>(
  (ref, userId) {
    final firestore = ref.watch(firestoreProvider);

    return firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return WorkSchedule.fromMap(doc.id, doc.data());
                } catch (e) {
                  _logger.warning('Error parsing schedule ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<WorkSchedule>()
              .toList(); // Filter out null values
        });
  },
);

/// Provider untuk current user's schedules
final currentUserSchedulesProvider = StreamProvider<List<WorkSchedule>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('schedules')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return WorkSchedule.fromMap(doc.id, doc.data());
              } catch (e) {
                _logger.warning('Error parsing schedule ${doc.id}: $e');
                return null;
              }
            })
            .whereType<WorkSchedule>()
            .toList(); // Filter out null values
      });
});
