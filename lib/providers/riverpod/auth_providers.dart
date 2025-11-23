import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;
import '../../models/user_profile.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../services/appwrite_auth_service.dart';

/// Logger untuk auth
final _logger = AppLogger('AuthProviders');

// ==================== AUTH STATE PROVIDERS ====================

/// Provider untuk Appwrite Auth Service instance
final appwriteAuthServiceProvider = Provider<AppwriteAuthService>((ref) {
  return AppwriteAuthService();
});

/// Provider untuk current Appwrite user
/// Mengambil user sekali dan bisa di-invalidate manual jika perlu
final authStateProvider = FutureProvider<models.User?>((ref) async {
  final authService = ref.watch(appwriteAuthServiceProvider);

  try {
    final user = await authService.getCurrentUser();
    return user;
  } catch (e) {
    return null;
  }
});

/// Provider untuk current user UID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.$id).value;
});

// ==================== USER PROFILE PROVIDERS ====================

/// Provider untuk current user profile
/// Mengambil profile sekali dan bisa di-invalidate manual jika perlu
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.watch(appwriteAuthServiceProvider);

  try {
    final user = await authService.getCurrentUser();

    if (user == null) {
      _logger.info('No authenticated user');
      return null;
    }

    _logger.info('Loading profile for user: ${user.$id}');
    final profile = await authService.getUserProfile(user.$id);

    if (profile == null) {
      _logger.warning('User profile not found for: ${user.$id}');
      return null;
    }

    _logger.info('Profile loaded successfully: ${profile.displayName}');
    return profile;
  } catch (e, stackTrace) {
    _logger.error('Error loading user profile', e, stackTrace);
    return null;
  }
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

  AppwriteAuthService get _authService => ref.read(appwriteAuthServiceProvider);

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Attempting login for: $email');

      final userProfile = await _authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _logger.logAuth('login_success', userId: userProfile.uid);
      state = const AsyncValue.data(null);

      // Refresh the auth state
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProfileProvider);
    } catch (e, stackTrace) {
      _logger.logAuth('login_failed', err: e);
      final exception = e is AuthException ? e : AuthException(message: e.toString());
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String role = 'employee',
    String? departmentId,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Attempting registration for: $email');

      final userProfile = await _authService.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        name: displayName.trim(),
        role: role,
        departmentId: departmentId,
        phoneNumber: phoneNumber,
      );

      _logger.logAuth('registration_success', userId: userProfile.uid);
      state = const AsyncValue.data(null);

      // Refresh the auth state
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProfileProvider);
    } catch (e, stackTrace) {
      _logger.logAuth('registration_failed', err: e);
      final exception = e is AuthException ? e : AuthException(message: e.toString());
      state = AsyncValue.error(exception, stackTrace);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _logger.info('Logging out user');
      await _authService.signOut();
      _logger.logAuth('logout_success');
      state = const AsyncValue.data(null);

      // Refresh the auth state
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProfileProvider);
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
      await _authService.sendPasswordResetEmail(email.trim());
      _logger.info('Password reset email sent');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      _logger.error('Password reset error', e, stackTrace);
      final exception = e is AuthException ? e : AuthException(message: e.toString());
      state = AsyncValue.error(exception, stackTrace);
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
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Changing password for user: ${user.$id}');

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _logger.info('Password changed successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      final exception = e is AuthException ? e : AuthException(message: e.toString());
      state = AsyncValue.error(exception, stackTrace);
      throw exception;
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Updating display name for user: ${user.$id}');

      await _authService.updateUserProfile(
        userId: user.$id,
        displayName: displayName.trim(),
      );

      _logger.info('Display name updated successfully');

      // Refresh the profile
      ref.invalidate(currentUserProfileProvider);
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
