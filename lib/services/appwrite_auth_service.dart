// lib/services/appwrite_auth_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:logging/logging.dart';
import '../core/services/appwrite_client.dart';
import '../core/config/appwrite_config.dart';
import '../models/user_profile.dart';

/// Appwrite Authentication Service
///
/// Replaces Firebase Auth with Appwrite Account API
/// Provides email/password authentication and user management
class AppwriteAuthService {
  final Logger _logger = Logger('AppwriteAuthService');

  // Get Appwrite services
  Account get _account => AppwriteClient().account;
  Databases get _databases => AppwriteClient().databases;

  // ==================== AUTHENTICATION ====================

  /// Sign in with email and password
  ///
  /// Returns UserProfile on success
  /// Throws AppwriteException on failure
  ///
  /// If user exists in Auth but not in Database, auto-creates profile
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Signing in user: $email');

      // Clear any existing session first to avoid conflicts
      try {
        await _account.deleteSession(sessionId: 'current');
        _logger.info('Cleared existing session before login');
      } catch (_) {
        // Ignore - no session exists
      }

      // Create email session
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      _logger.info('✅ Session created: ${session.$id}');

      // Get user profile from database
      var userProfile = await getUserProfile(session.userId);

      // Auto-create profile if not exists (for users created in Console)
      if (userProfile == null) {
        _logger.warning('Profile not found, creating for user: ${session.userId}');

        // Get account details
        final user = await _account.get();

        // Determine role from email
        String role = 'employee';
        if (email.contains('admin')) {
          role = 'admin';
        } else if (email.contains('cleaner') || email.contains('petugas')) {
          role = 'cleaner';
        }

        // Create profile
        userProfile = UserProfile(
          uid: user.$id,
          displayName: user.name.isNotEmpty ? user.name : email.split('@').first,
          email: email,
          role: role,
          joinDate: DateTime.now(),
          status: 'active',
        );

        await _createUserProfile(userProfile);
        _logger.info('✅ Auto-created profile for user: ${user.$id}');
      }

      return userProfile;
    } on AppwriteException catch (e) {
      _logger.severe('❌ Sign in failed: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      _logger.severe('❌ Sign in error', e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  ///
  /// Creates account and user profile document
  Future<UserProfile> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? departmentId,
    String? departmentName,
    String? phoneNumber,
  }) async {
    try {
      _logger.info('Creating new account: $email');

      // Clear any existing session first
      try {
        await _account.deleteSession(sessionId: 'current');
        _logger.info('Cleared existing session');
      } catch (_) {
        // Ignore - no session exists
      }

      // Create account
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      _logger.info('✅ Account created: ${account.$id}');

      // Create session automatically
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Create user profile in database
      final userProfile = UserProfile(
        uid: account.$id,
        displayName: name,
        email: email,
        role: role,
        joinDate: DateTime.now(),
        departmentId: departmentId,
        phoneNumber: phoneNumber,
        status: 'active',
      );

      await _createUserProfile(userProfile);

      _logger.info('✅ User profile created');

      return userProfile;
    } on AppwriteException catch (e) {
      _logger.severe('❌ Sign up failed: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      _logger.severe('❌ Sign up error', e, stackTrace);
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _logger.info('Signing out user');

      // Delete current session
      await _account.deleteSession(sessionId: 'current');

      _logger.info('✅ User signed out');
    } on AppwriteException catch (e) {
      _logger.warning('Sign out warning: ${e.message}');
      // Ignore errors on sign out (session might already be invalid)
    } catch (e) {
      _logger.warning('Sign out error: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Sending password reset email to: $email');

      // TODO: Configure reset URL in Appwrite Console
      // Format: https://your-app.com/reset-password
      await _account.createRecovery(
        email: email,
        url: 'https://cleanoffice.app/reset-password', // Change this!
      );

      _logger.info('✅ Password reset email sent');
    } on AppwriteException catch (e) {
      _logger.severe('❌ Password reset failed: ${e.message}', e);
      throw _handleAuthException(e);
    }
  }

  /// Change current user's password
  ///
  /// Requires re-authentication (current password)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getCurrentUser();

      if (user == null) {
        throw Exception('No user logged in');
      }

      _logger.info('Changing password for user: ${user.$id}');

      // Appwrite requires re-authentication by email session
      // First, verify current password by creating a session
      try {
        await _account.createEmailPasswordSession(
          email: user.email,
          password: currentPassword,
        );
      } catch (e) {
        throw Exception('Current password is incorrect');
      }

      // Update password
      await _account.updatePassword(
        password: newPassword,
        oldPassword: currentPassword,
      );

      _logger.info('✅ Password changed successfully');
    } on AppwriteException catch (e) {
      _logger.severe('❌ Change password failed: ${e.message}', e);
      throw _handleAuthException(e);
    }
  }

  // ==================== USER PROFILE ====================

  /// Get current authenticated user (Appwrite account)
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // Not authenticated
        return null;
      }
      rethrow;
    }
  }

  /// Get user profile from database
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
      );

      return UserProfile.fromMap(doc.data);
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        _logger.warning('User profile not found: $userId');
        return null;
      }
      _logger.severe('Error getting user profile: ${e.message}', e);
      rethrow;
    }
  }

  /// Get current user profile (combines account + profile data)
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;

      return await getUserProfile(user.$id);
    } catch (e) {
      _logger.severe('Error getting current user profile: $e');
      return null;
    }
  }

  /// Create user profile document in database
  Future<void> _createUserProfile(UserProfile profile) async {
    try {
      await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: profile.uid, // Use same ID as account
        data: {
          'uid': profile.uid,
          'displayName': profile.displayName,
          'email': profile.email,
          'photoURL': profile.photoURL,
          'phoneNumber': profile.phoneNumber,
          'role': profile.role,
          'joinDate': profile.joinDate.toIso8601String(),
          'departmentId': profile.departmentId,
          'staffId': profile.staffId,
          'status': profile.status,
          'location': profile.location,
          'deletedAt': null,
          'deletedBy': null,
        },
      );
    } on AppwriteException catch (e) {
      _logger.severe('Error creating user profile: ${e.message}', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? departmentId,
    String? staffId,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (departmentId != null) updates['departmentId'] = departmentId;
      if (staffId != null) updates['staffId'] = staffId;
      if (location != null) updates['location'] = location;

      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
        data: updates,
      );

      // Also update account name if provided
      if (displayName != null) {
        await _account.updateName(name: displayName);
      }

      _logger.info('✅ User profile updated');
    } on AppwriteException catch (e) {
      _logger.severe('Error updating user profile: ${e.message}', e);
      rethrow;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Check if user has active session
  Future<bool> hasActiveSession() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current session
  Future<models.Session?> getCurrentSession() async {
    try {
      final session = await _account.getSession(sessionId: 'current');
      return session;
    } catch (e) {
      return null;
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Convert Appwrite exceptions to user-friendly messages
  Exception _handleAuthException(AppwriteException e) {
    switch (e.code) {
      case 401:
        return Exception('Email atau password salah');
      case 409:
        return Exception('Email sudah terdaftar');
      case 429:
        return Exception('Terlalu banyak percobaan, coba lagi nanti');
      case 400:
        if (e.message?.contains('password') ?? false) {
          return Exception('Password terlalu lemah (minimal 8 karakter)');
        }
        return Exception('Data tidak valid');
      default:
        return Exception(e.message ?? 'Terjadi kesalahan');
    }
  }
}
