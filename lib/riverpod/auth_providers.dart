import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';

/// Logger untuk auth
final _logger = AppLogger('AuthProviders');

// ==================== AUTH STATE PROVIDERS ====================

/// Provider untuk Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider untuk current Firebase user (stream)
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provider untuk current user UID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.uid).value;
});

// ==================== USER PROFILE PROVIDERS ====================

/// Provider untuk Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider untuk current user profile (stream)
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) {
      _logger.info('No authenticated user');
      return null;
    }

    try {
      _logger.info('Loading profile for user: ${user.uid}');
      final docSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) {
        _logger.warning('User profile not found for: ${user.uid}');
        return null;
      }

      final profile = UserProfile.fromMap(
        docSnapshot.data()!..['uid'] = user.uid,
      );

      _logger.info('Profile loaded successfully: ${profile.displayName}');
      return profile;
    } catch (e, stackTrace) {
      _logger.error('Error loading user profile', e, stackTrace);
      return null;
    }
  });
});

/// Provider untuk user role
final currentUserRoleProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.whenData((profile) => profile?.role).value;
});

/// Provider untuk user department
final currentUserDepartmentIdProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.whenData((profile) => profile?.departmentId).value;
});

// ==================== AUTH ACTIONS NOTIFIER ====================

/// Notifier untuk auth actions (login, register, logout)
class AuthActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Attempting login for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _logger.logAuth('login_success', userId: userCredential.user?.uid);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      _logger.logAuth('login_failed', err: e);
      final exception = AuthException.fromFirebaseAuth(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected login error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String role = 'employee',
  }) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Attempting registration for: $email');

      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(message: 'Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(displayName.trim());

      // Create user profile in Firestore
      final userProfile = UserProfile(
        uid: user.uid,
        displayName: displayName.trim(),
        email: email.trim(),
        role: role,
        joinDate: DateTime.now(),
        status: 'active',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toMap());

      _logger.logAuth('registration_success', userId: user.uid);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      _logger.logAuth('registration_failed', err: e);
      final exception = AuthException.fromFirebaseAuth(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected registration error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _logger.info('Logging out user');
      await _auth.signOut();
      _logger.logAuth('logout_success');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Logout error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      _logger.info('Password reset email sent');
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Password reset error', e, stackTrace);
      final exception = AuthException.fromFirebaseAuth(e);
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Unexpected password reset error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Changing password for user: ${user.uid}');

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      _logger.info('Password changed successfully');
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      final exception = AuthException.fromFirebaseAuth(e);
      state = AsyncValue.error(exception, stackTrace);
      throw exception;
    } catch (e, stackTrace) {
      _logger.error('Unexpected change password error', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Updating display name for user: ${user.uid}');
      await user.updateDisplayName(displayName.trim());

      // Also update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName.trim(),
      });

      _logger.info('Display name updated successfully');
    } catch (e, stackTrace) {
      _logger.error('Update display name error', e, stackTrace);
      rethrow;
    }
  }
}

/// Provider untuk auth actions
final authActionsProvider =
    NotifierProvider<AuthActionsNotifier, AsyncValue<void>>(
      () => AuthActionsNotifier(),
    );

// ==================== HELPER PROVIDERS ====================

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user != null).value ?? false;
});

/// Check if user is admin/supervisor
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'admin';
});

/// Check if user is cleaner
final isCleanerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'cleaner';
});

/// Check if user is employee
final isEmployeeProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'employee';
});
