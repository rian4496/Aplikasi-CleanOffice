// lib/riverpod/auth_providers.dart
// ✅ MIGRATED TO SUPABASE

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../models/user_profile.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import './supabase_service_providers.dart';
import '../services/presence_service.dart';

/// Logger untuk auth
final _logger = AppLogger('AuthProviders');

// ==================== AUTH STATE PROVIDERS ====================

/// Provider untuk current Supabase user
/// Mengambil user sekali dan bisa di-invalidate manual jika perlu
final authStateProvider = FutureProvider<supabase.User?>((ref) async {
  final authService = ref.watch(supabaseAuthServiceProvider);
  
  try {
    // Get current session from Supabase
    final session = supabase.Supabase.instance.client.auth.currentSession;
    return session?.user;
  } catch (e) {
    _logger.error('Error getting auth state', e);
    return null;
  }
});

/// Provider untuk current user UID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.id).value;
});

// ==================== USER PROFILE PROVIDERS ====================

/// Provider untuk current user profile
/// Mengambil profile sekali dan bisa di-invalidate manual jika perlu
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.watch(supabaseAuthServiceProvider);

  try {
    // Get current user from Supabase Auth
    final session = supabase.Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    if (user == null) {
      _logger.info('No authenticated user');
      return null;
    }

    _logger.info('Loading profile for user: ${user.id}');
    final profile = await authService.getUserProfile(user.id);

    if (profile == null) {
      _logger.warning('User profile not found for: ${user.id}');
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

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      _logger.info('Attempting login for: $email');

      final authService = ref.read(supabaseAuthServiceProvider);
      final userProfile = await authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _logger.logAuth('login_success', userId: userProfile.uid);
      state = const AsyncValue.data(null);

      // Start presence tracking
      ref.read(presenceServiceProvider).startPresence(userProfile.uid);

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

      final authService = ref.read(supabaseAuthServiceProvider);
      final userProfile = await authService.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        name: displayName.trim(),
        role: role,
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
      
      // Stop presence tracking first
      ref.read(presenceServiceProvider).stopPresence();
      
      final authService = ref.read(supabaseAuthServiceProvider);
      await authService.signOut();
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
      final authService = ref.read(supabaseAuthServiceProvider);
      await authService.sendPasswordResetEmail(email.trim());
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
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session?.user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Changing password for user: ${session!.user.id}');

      final authService = ref.read(supabaseAuthServiceProvider);
      await authService.updatePassword(newPassword);

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
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session?.user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Updating display name for user: ${session!.user.id}');

      final authService = ref.read(supabaseAuthServiceProvider);
      await authService.updateUserProfile(
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

/// Check if user is kasubbag
final isKasubbagProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'kasubbag_umpeg';
});

/// Check if user is teknisi
final isTeknisiProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == 'teknisi';
});

// ==================== DATABASE-BACKED USER ROLE ====================

/// Provider untuk user role dari tabel user_roles (Admin-assigned)
/// Falls back to profile role if no database record exists
final userRoleRecordProvider = FutureProvider<String>((ref) async {
  final session = supabase.Supabase.instance.client.auth.currentSession;
  final userId = session?.user.id;
  
  if (userId == null) {
    return 'employee'; // Default
  }

  try {
    final response = await supabase.Supabase.instance.client
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null && response['role'] != null) {
      _logger.info('User role from database: ${response['role']}');
      return response['role'] as String;
    }

    // Fallback to profile role
    final profileRole = ref.read(currentUserRoleProvider);
    _logger.info('User role from profile (fallback): $profileRole');
    return profileRole ?? 'employee';
  } catch (e) {
    _logger.error('Error fetching user role from database', e);
    return ref.read(currentUserRoleProvider) ?? 'employee';
  }
});

// ==================== LEGACY COMPATIBILITY ====================
// Alias for screens still using 'currentUserProvider' name
final currentUserProvider = currentUserProfileProvider;

// ==================== USERS LOOKUP MAP ====================
/// Provider for all users as a Map (id -> displayName)
/// Used for O(1) lookup of user names (e.g., assignee names)
final usersMapProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final response = await supabase.Supabase.instance.client
        .from('users')
        .select('id, display_name');
    
    final Map<String, String> usersMap = {};
    for (final user in response) {
      usersMap[user['id'] as String] = user['display_name'] as String? ?? 'Unknown';
    }
    
    _logger.info('Users map loaded: ${usersMap.length} users');
    return usersMap;
  } catch (e) {
    _logger.error('Error loading users map', e);
    return {};
  }
});
