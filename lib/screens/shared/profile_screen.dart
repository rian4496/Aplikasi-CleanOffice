// lib/screens/shared/profile_screen.dart - MODIFIED LAYOUT & REACTIVE DATA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:intl/intl.dart'; // Untuk format tanggal

// Import provider dan layar lain
import '../../providers/riverpod/auth_providers.dart';
import '../../models/user_profile.dart'; // Import UserProfile model
import '../../models/user_role.dart'; // Import UserRole
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart'; // Untuk AppConstants
import 'edit_profile_screen.dart'; // Layar Edit
import 'change_password_screen.dart'; // Layar Ubah Password

class ProfileScreen extends ConsumerWidget { // Ubah jadi ConsumerWidget
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Tambah WidgetRef ref
    // Tonton provider untuk data profil yang reaktif
    final profileAsyncValue = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar( // Gunakan AppBar standar
        title: const Text('Profil'),
        backgroundColor: AppTheme.primaryDark, // Atau AppTheme.primary
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white), // Tombol back putih
        titleTextStyle: const TextStyle( // Pastikan title putih
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(context, ref, error), // Helper error state
        data: (userProfile) {
          if (userProfile == null) {
            // Handle jika user tidak ditemukan/logout
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
             });
             return const Center(child: CircularProgressIndicator()); // Tampilkan loading sementara redirect
          }

          // Tampilkan konten utama jika data ada
          return RefreshIndicator(
             onRefresh: () async => ref.invalidate(currentUserProfileProvider), // Pull-to-refresh
             child: ListView( // Ganti CustomScrollView jadi ListView
               padding: const EdgeInsets.all(16.0),
               children: [
                 const SizedBox(height: 20),
                 _buildProfileHeader(userProfile), // Kirim UserProfile
                 const SizedBox(height: 32),
                 _buildUserInfoSection(userProfile), // Kirim UserProfile
                 const SizedBox(height: 24),
                 _buildActionCard(context), // Card untuk tombol aksi
               ],
             ),
          );
        },
      ),
    );
  }

  // Widget Header (Avatar, Nama, Email, Role Chip) - Menggunakan UserProfile
  Widget _buildProfileHeader(UserProfile userProfile) {
    final firstLetter = (userProfile.displayName.isNotEmpty)
        ? userProfile.displayName[0].toUpperCase()
        : '?';
    final photoURL = userProfile.photoURL;

    return Column(
      children: [
        CircleAvatar(
          radius: 50, // Ukuran avatar
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

  // Widget untuk Info Tambahan (Jabatan, Bergabung Sejak) - Menggunakan UserProfile
  Widget _buildUserInfoSection(UserProfile userProfile) {
     final joinDateFormatted = DateFormat('MMMM yyyy', 'id_ID').format(userProfile.joinDate);
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
         // Tambahkan lokasi jika ada dan tidak kosong
         if (userProfile.location != null && userProfile.location!.isNotEmpty) ...[
           const SizedBox(height: 16),
           _buildInfoItem(
             icon: Icons.location_on_outlined,
             label: 'Lokasi Kerja',
             value: userProfile.location!,
             iconColor: AppTheme.success, // Atau warna lain
           ),
         ]
      ],
    );
  }

  // Helper widget untuk item info (Jabatan, Tanggal)
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Kurangi padding vertikal
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10), // Shadow lebih halus
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Padding icon
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20), // Background icon lebih transparan
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20), // Ukuran icon
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
                // SizedBox(height: 2), // Kurangi jarak
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15, // Ukuran font value
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

  // Widget Card untuk Tombol Aksi (Edit Profil, Ubah Password)
  Widget _buildActionCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Agar Divider tidak keluar batas Card
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Navigasi ke EditProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              // Tidak perlu menunggu hasil atau invalidate, provider akan handle
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16), // Divider di dalam Card
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppTheme.primary),
            title: const Text('Ubah Password'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Navigasi ke ChangePasswordScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

   // Helper widget untuk menampilkan state error
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
             Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
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