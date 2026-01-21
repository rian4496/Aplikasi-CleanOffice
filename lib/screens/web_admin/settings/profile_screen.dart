import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // All controllers at top level (hooks rule)
    final oldPassCtrl = useTextEditingController();
    final newPassCtrl = useTextEditingController();
    final confirmPassCtrl = useTextEditingController();
    final displayNameCtrl = useTextEditingController();
    final phoneCtrl = useTextEditingController();

    // Sync controllers with user data when it arrives
    useEffect(() {
      final user = userProfileAsync.value;
      if (user != null) {
        displayNameCtrl.text = user.displayName;
        phoneCtrl.text = user.phoneNumber ?? '';
      }
      return null;
    }, [userProfileAsync.value]);

    Widget buildProfileContent(dynamic user) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== HEADER (Adaptive) ====================
          if (isMobile) 
            _buildMinimalMobileHeader(user)
          else 
            _buildHeaderCard(user),
          
          SizedBox(height: isMobile ? 24 : 24),
          
          // ==================== FORM CONTENT ====================
          if (isMobile)
            Column(
              children: [
                _buildBiodataCard(context, ref, displayNameCtrl, phoneCtrl, user.email, isMobile: true),
                const SizedBox(height: 16),
                _buildSecurityCard(context, ref, oldPassCtrl, newPassCtrl, confirmPassCtrl, isMobile: true),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBiodataCard(context, ref, displayNameCtrl, phoneCtrl, user.email, isMobile: false),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSecurityCard(context, ref, oldPassCtrl, newPassCtrl, confirmPassCtrl, isMobile: false),
                ),
              ],
            ),
        ],
      );
    }
    
    // ==================== MOBILE LAYOUT ====================
    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white, // Clean white background
        appBar: AppBar(
           backgroundColor: Colors.white,
           elevation: 0,
           leading: IconButton(
             icon: const Icon(Icons.arrow_back, color: Colors.black87),
             onPressed: () {
               if (context.canPop()) {
                 context.pop();
               } else {
                 context.go('/admin/dashboard');
               }
             },
           ),
           title: const Text(
             'Profile',
             style: TextStyle(
               color: Colors.black87,
               fontWeight: FontWeight.bold,
               fontSize: 18,
             ),
           ),
           centerTitle: false,
        ),
        body: userProfileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) return const Center(child: Text('User not found'));
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: buildProfileContent(user),
            );
          }
        ),
      );
    }

    // ==================== DESKTOP LAYOUT ====================
    return AdminLayoutWrapper(
      title: 'Profil Saya',
      child: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: buildProfileContent(user),
          );
        },
      ),
    );
  }

  // ==================== MOBILE MINIMAL HEADER ====================
  Widget _buildMinimalMobileHeader(dynamic user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
            backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null || user.photoURL!.isEmpty
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DESKTOP HEADER CARD ====================
  Widget _buildHeaderCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminColors.primary, AdminColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null || user.photoURL!.isEmpty
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BIODATA CARD ====================
  Widget _buildBiodataCard(
    BuildContext context,
    WidgetRef ref,
    TextEditingController displayNameCtrl,
    TextEditingController phoneCtrl,
    String email, {
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: isMobile ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_outline, color: AdminColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Biodata',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(height: isMobile ? 24 : 32),
          
          // Form Fields
          _buildTextField('Nama Lengkap', displayNameCtrl),
          const SizedBox(height: 16),
          _buildTextField('Nomor Telepon', phoneCtrl),
          const SizedBox(height: 16),
          _buildTextField('Email', TextEditingController(text: email), enabled: false),
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authActionsProvider.notifier).updateDisplayName(displayNameCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              label: const Text('Simpan Perubahan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECURITY CARD ====================
  Widget _buildSecurityCard(
    BuildContext context,
    WidgetRef ref,
    TextEditingController oldPassCtrl,
    TextEditingController newPassCtrl,
    TextEditingController confirmPassCtrl, {
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: isMobile ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lock_outline, color: Colors.orange.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Keamanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(height: isMobile ? 24 : 32),
          
          // Form Fields
          _buildTextField('Kata Sandi Lama', oldPassCtrl, obscureText: true),
          const SizedBox(height: 16),
          _buildTextField('Kata Sandi Baru', newPassCtrl, obscureText: true),
          const SizedBox(height: 16),
          _buildTextField('Konfirmasi Kata Sandi', confirmPassCtrl, obscureText: true),
          const SizedBox(height: 24),
          
          // Change Password Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Validation
                if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap isi semua field'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (newPassCtrl.text != confirmPassCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kata sandi baru tidak cocok'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (newPassCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kata sandi minimal 6 karakter'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                try {
                  await ref.read(authActionsProvider.notifier).changePassword(
                    currentPassword: oldPassCtrl.text,
                    newPassword: newPassCtrl.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: Colors.green),
                  );
                  oldPassCtrl.clear();
                  newPassCtrl.clear();
                  confirmPassCtrl.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.vpn_key_outlined, size: 18),
              label: const Text('Ganti Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TEXT FIELD HELPER ====================
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.black87 : Colors.grey.shade600,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AdminColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            hintText: enabled ? 'Masukkan $label' : null,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ==================== ROLE DISPLAY NAME ====================
  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'kasubbag_umpeg':
        return 'Kasubbag Umpeg';
      case 'employee':
        return 'PEGAWAI';
      case 'cleaner':
        return 'CLEANER';
      default:
        return role.toUpperCase();
    }
  }
}
