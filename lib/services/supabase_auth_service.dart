// lib/services/supabase_auth_service.dart
// Supabase Authentication Service for CleanOffice App

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../core/config/supabase_config.dart';
import '../core/logging/app_logger.dart';
import '../core/error/exceptions.dart';
import '../models/user_profile.dart';

class SupabaseAuthService {
  final _logger = AppLogger('SupabaseAuthService');
  final SupabaseClient _client = Supabase.instance.client;

  // ==================== AUTH STATE ====================

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== SIGN UP ====================

  /// Sign up with email and password
  /// Creates Auth user and user profile in database
  Future<UserProfile> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _logger.info('🔐 Starting registration for: $email');

      // 1. Create Auth user with metadata
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': name,
          'role': role,
        },
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'Gagal membuat akun. Silakan coba lagi.',
          code: 'signup-failed',
        );
      }

      final user = response.user!;
      _logger.info('✅ Auth user created: ${user.id}');

      // 2. Profile will be auto-created by database trigger (handle_new_user)
      // Wait a bit for trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Fetch the created profile
      final profile = await getUserProfile(user.id);

      if (profile == null) {
        _logger.warning('⚠️ Profile not auto-created, creating manually...');
        // Fallback: Create profile manually if trigger failed
        await _createUserProfile(
          userId: user.id,
          email: email,
          displayName: name,
          role: role,
        );

        final retryProfile = await getUserProfile(user.id);
        if (retryProfile == null) {
          throw const AuthException(
            message: 'Gagal membuat profil user',
            code: 'profile-creation-failed',
          );
        }
        return retryProfile;
      }

      _logger.info('✅ Registration complete for: $email');
      return profile;
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } on AuthApiException catch (e, stackTrace) {
      _logger.error('❌ Auth API error during signup', e, stackTrace);

      // Handle specific Supabase auth errors
      String message;
      String? code;

      if (e.statusCode == '422' || e.statusCode == '400') {
        if (e.message.toLowerCase().contains('email')) {
          message = 'Format email tidak valid';
          code = 'invalid-email';
        } else if (e.message.toLowerCase().contains('password')) {
          message = 'Password terlalu lemah (minimal 6 karakter)';
          code = 'weak-password';
        } else {
          message = e.message;
          code = e.code;
        }
      } else if (e.statusCode == '429') {
        message = 'Terlalu banyak percobaan. Tunggu sebentar';
        code = 'too-many-requests';
      } else {
        message = e.message;
        code = e.code;
      }

      throw AuthException(
        message: message,
        code: code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error during signup', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal menyimpan data user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error during signup', e, stackTrace);
      throw AuthException(
        message: 'Terjadi kesalahan tidak terduga. Silakan coba lagi.',
        code: 'unknown-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create user profile in database (fallback if trigger fails)
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    required String role,
  }) async {
    try {
      await _client.from(SupabaseConfig.usersTable).insert({
        'id': userId,
        'email': email,
        'display_name': displayName,
        'role': role,
        'status': 'inactive',
        'verification_status': 'pending',
      });

      _logger.info('✅ User profile created manually: $userId');
    } catch (e) {
      _logger.error('❌ Failed to create user profile manually', e);
      rethrow;
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in with email and password
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('🔐 Attempting login for: $email');

      // 1. Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'Email atau password salah',
          code: 'invalid-credentials',
        );
      }

      final user = response.user!;
      _logger.info('✅ Auth login successful: ${user.id}');

      // 2. Get user profile from database
      final profile = await getUserProfile(user.id);

      if (profile == null) {
        _logger.error('❌ Profile not found for user: ${user.id}');
        throw const AuthException(
          message: 'Profil user tidak ditemukan',
          code: 'profile-not-found',
        );
      }

      // 3. Check verification status
      if (profile.verificationStatus != 'approved') {
        _logger.warning('⚠️ User not verified: ${profile.verificationStatus}');
        // Sign out user
        await _client.auth.signOut();

        throw AuthException(
          message: profile.verificationStatus == 'rejected'
              ? 'Akun Anda ditolak oleh admin. Hubungi admin untuk info lebih lanjut.'
              : 'Akun Anda belum diverifikasi. Tunggu approval dari admin.',
          code: 'not-verified',
        );
      }

      // 4. Check if account is active
      if (!profile.isActive) {
        _logger.warning('⚠️ User account is inactive');
        await _client.auth.signOut();

        throw const AuthException(
          message: 'Akun Anda tidak aktif. Hubungi admin.',
          code: 'account-inactive',
        );
      }

      _logger.info('✅ Login complete for: $email (role: ${profile.role})');
      return profile;
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } on AuthApiException catch (e, stackTrace) {
      _logger.error('❌ Auth API error during login', e, stackTrace);

      String message;
      String? code;

      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials')) {
        message = 'Email atau password salah';
        code = 'invalid-credentials';
      } else if (e.statusCode == '429') {
        message = 'Terlalu banyak percobaan. Tunggu sebentar';
        code = 'too-many-requests';
      } else {
        message = e.message;
        code = e.code;
      }

      throw AuthException(
        message: message,
        code: code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error during login', e, stackTrace);
      throw AuthException(
        message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
        code: 'unknown-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _logger.info('🔐 Signing out user: $currentUserId');
      await _client.auth.signOut();
      _logger.info('✅ Sign out successful');
    } catch (e, stackTrace) {
      _logger.error('❌ Error during sign out', e, stackTrace);
      throw AuthException(
        message: 'Gagal logout. Silakan coba lagi.',
        code: 'signout-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('📧 Sending password reset email to: $email');

      await _client.auth.resetPasswordForEmail(email);

      _logger.info('✅ Password reset email sent to: $email');
    } on AuthApiException catch (e, stackTrace) {
      _logger.error('❌ Error sending password reset email', e, stackTrace);
      throw AuthException(
        message: 'Gagal mengirim email reset password: ${e.message}',
        code: 'password-reset-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error sending password reset', e, stackTrace);
      throw AuthException(
        message: 'Gagal mengirim email reset password',
        code: 'unknown-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update password (user must be logged in)
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!isLoggedIn) {
        throw const AuthException(
          message: 'User tidak login',
          code: 'not-authenticated',
        );
      }

      _logger.info('🔐 Updating password for user: $currentUserId');

      await _client.auth.updateUser(UserAttributes(password: newPassword));

      _logger.info('✅ Password updated successfully');
    } on AuthApiException catch (e, stackTrace) {
      _logger.error('❌ Error updating password', e, stackTrace);
      throw AuthException(
        message: 'Gagal mengubah password: ${e.message}',
        code: 'password-update-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating password', e, stackTrace);
      throw AuthException(
        message: 'Gagal mengubah password',
        code: 'unknown-error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== USER PROFILE ====================

  /// Get user profile from database
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        _logger.warning('⚠️ No profile found for user: $userId');
        return null;
      }

      return UserProfile.fromSupabase(response);
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error fetching profile', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal mengambil profil user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error fetching profile', e, stackTrace);
      return null;
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;
    return getUserProfile(currentUserId!);
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? location,
  }) async {
    try {
      if (!isLoggedIn) {
        throw const AuthException(
          message: 'User tidak login',
          code: 'not-authenticated',
        );
      }

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (location != null) updates['location'] = location;

      if (updates.isEmpty) return;

      _logger.info('📝 Updating profile for user: $currentUserId');

      await _client
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', currentUserId!);

      _logger.info('✅ Profile updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating profile', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update profil: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating profile', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update profil',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Update user verification status (admin only)
  Future<void> updateUserVerificationStatus({
    required String userId,
    required String status, // 'approved' or 'rejected'
  }) async {
    try {
      _logger.info('📝 Updating verification status for user: $userId to $status');

      final updates = <String, dynamic>{
        'verification_status': status,
      };

      // If approved, also set status to active
      if (status == 'approved') {
        updates['status'] = 'active';
      }

      await _client
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);

      _logger.info('✅ Verification status updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating verification status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status verifikasi: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating verification', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status verifikasi',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update user status (admin only)
  Future<void> updateUserStatus({
    required String userId,
    required String status, // 'active', 'inactive', or 'deleted'
  }) async {
    try {
      _logger.info('📝 Updating status for user: $userId to $status');

      await _client
          .from(SupabaseConfig.usersTable)
          .update({'status': status})
          .eq('id', userId);

      _logger.info('✅ User status updated successfully');
    } on PostgrestException catch (e, stackTrace) {
      _logger.error('❌ Database error updating user status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status user: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error updating status', e, stackTrace);
      throw DatabaseException(
        message: 'Gagal update status user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
