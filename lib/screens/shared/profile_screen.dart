// lib/screens/shared/profile_screen.dart - FINAL VERSION

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/riverpod/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),
                  
                  // Fetch user data from Firestore
                  _buildUserInfoFromFirestore(user.uid),
                  
                  const SizedBox(height: 24),
                  _buildMenuItems(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    // Get first letter of name for avatar
    final firstLetter = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName![0].toUpperCase()
        : 'U';

    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withAlpha(50),
            border: Border.all(color: AppTheme.primary, width: 3),
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Name
        Text(
          user.displayName ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        
        // Email
        Text(
          user.email ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // ✅ FETCH USER DATA FROM FIRESTORE
  Widget _buildUserInfoFromFirestore(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildUserInfoCard(
            jobTitle: 'User',
            joinDate: 'Unknown',
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        
        // ✅ MAP ROLE TO JOB TITLE
        final role = userData['role'] as String? ?? 'user';
        final jobTitle = _getJobTitle(role);
        
        // ✅ FORMAT JOIN DATE - Support both 'joinDate' and 'createdAt'
        final joinDateTimestamp = userData['joinDate'] as Timestamp? ?? 
                                  userData['createdAt'] as Timestamp?;
        final joinDate = _formatJoinDate(joinDateTimestamp);

        return _buildUserInfoCard(
          jobTitle: jobTitle,
          joinDate: joinDate,
        );
      },
    );
  }

  // ✅ MAP ROLE TO JOB TITLE IN INDONESIAN
  String _getJobTitle(String role) {
    switch (role.toLowerCase()) {
      case 'employee':
        return 'Karyawan';
      case 'cleaner':
        return 'Petugas Kebersihan';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }

  // ✅ FORMAT JOIN DATE
  String _formatJoinDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      final date = timestamp.toDate();
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildUserInfoCard({
    required String jobTitle,
    required String joinDate,
  }) {
    return Column(
      children: [
        // Jabatan
        _buildInfoItem(
          icon: Icons.work_outline,
          label: 'Jabatan',
          value: jobTitle,
          iconColor: AppTheme.primary,
        ),
        const SizedBox(height: 16),
        
        // Bergabung Sejak
        _buildInfoItem(
          icon: Icons.calendar_today,
          label: 'Bergabung Sejak',
          value: joinDate,
          iconColor: AppTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildMenuItems(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profil',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur edit profil segera hadir')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Ubah Password',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ubah password segera hadir')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          titleColor: AppTheme.error,
          iconColor: AppTheme.error,
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}