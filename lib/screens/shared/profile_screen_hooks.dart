// lib/screens/shared/profile_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../models/user_role.dart';
import '../../providers/riverpod/auth_providers.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch provider for reactive profile data
    final profileAsyncValue = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(context, ref, error),
        data: (userProfile) {
          if (userProfile == null) {
            // ⚠️ REVIEW: Auto-redirect on null profile
            // TODO (Phase 5): Replace with go_router redirect
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Display content with pull-to-refresh
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(currentUserProfileProvider),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(userProfile),
                const SizedBox(height: 32),
                _buildUserInfoSection(userProfile),
                const SizedBox(height: 24),
                _buildActionCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ STATIC HELPER: Profile header
  Widget _buildProfileHeader(UserProfile userProfile) {
    final firstLetter = (userProfile.displayName.isNotEmpty)
        ? userProfile.displayName[0].toUpperCase()
        : '?';
    final photoURL = userProfile.photoURL;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryLight,
          backgroundImage: (photoURL != null && photoURL.isNotEmpty)
              ? CachedNetworkImageProvider(photoURL)
              : null,
          child: (photoURL == null || photoURL.isEmpty)
              ? Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.email,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // ✅ STATIC HELPER: User info section
  Widget _buildUserInfoSection(UserProfile userProfile) {
    final joinDateFormatted =
        DateFormat('MMMM yyyy', 'id_ID').format(userProfile.joinDate);
    final jobTitle = UserRole.getRoleDisplayName(userProfile.role);

    return Column(
      children: [
        _buildInfoItem(
          icon: Icons.work_outline,
          label: 'Jabatan',
          value: jobTitle,
          iconColor: AppTheme.primary,
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          icon: Icons.calendar_today_outlined,
          label: 'Bergabung Sejak',
          value: joinDateFormatted,
          iconColor: AppTheme.secondary,
        ),
        if (userProfile.location != null && userProfile.location!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Lokasi Kerja',
            value: userProfile.location!,
            iconColor: AppTheme.success,
          ),
        ]
      ],
    );
  }

  // ✅ STATIC HELPER: Info item
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ STATIC HELPER: Action card
  Widget _buildActionCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO (Phase 5): Replace with go_router navigation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppTheme.primary),
            title: const Text('Ubah Password'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO (Phase 5): Replace with go_router navigation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ STATIC HELPER: Error state
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 50),
            const SizedBox(height: 16),
            const Text('Gagal memuat profil', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: () => ref.invalidate(currentUserProfileProvider),
            ),
          ],
        ),
      ),
    );
  }
}

