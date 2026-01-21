// lib/screens/shared/profile_screen.dart
// ✅ RECREATED: Pixel-Perfect Match with User Screenshot
// 🎨 Design System: Clean Minimalist, Centered Profile, Rounded Cards
// 🔤 Typography: Inter (Google Fonts)

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../../../services/web_notification_service_interface.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../riverpod/auth_providers.dart';
import '../../models/user_profile.dart';
import '../../models/user_role.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(currentUserProfileProvider);

    // Notification Service State (Web Only)
    final notificationService = useMemoized(() => WebNotificationService());
    final notificationEnabled = useState(notificationService.isEnabled);
    final permissionStatus = useState(notificationService.permissionStatus);
    
    // Check permission on mount
    useEffect(() {
      if (kIsWeb) {
        Future.microtask(() async {
           permissionStatus.value = notificationService.permissionStatus;
           notificationEnabled.value = notificationService.isEnabled;
        });
      }
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background as per screenshot
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (userProfile) {
           if (userProfile == null) return const Center(child: Text('User not found'));
           
           return SingleChildScrollView(
             padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
             child: Column(
               children: [
                 const SizedBox(height: 20),
                 
                 // 1. Avatar Section
                 Center(child: _buildAvatar(userProfile)),
                 
                 const SizedBox(height: 24),
                 
                 // 2. Name & Email & Role
                 Text(
                   userProfile.displayName,
                   style: GoogleFonts.inter(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: const Color(0xFF1E293B), // Slate-900
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   userProfile.email,
                   style: GoogleFonts.inter(
                     fontSize: 14,
                     color: const Color(0xFF64748B), // Slate-500
                   ),
                 ),
                 const SizedBox(height: 16),
                 
                 // Role Badge (Blue Pill)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                   decoration: BoxDecoration(
                     color: const Color(0xFFEFF6FF), // Blue-50
                     borderRadius: BorderRadius.circular(99),
                   ),
                   child: Text(
                     UserRole.getRoleDisplayName(userProfile.role).toUpperCase(),
                     style: GoogleFonts.inter(
                       fontSize: 12,
                       fontWeight: FontWeight.bold,
                       color: const Color(0xFF3B82F6), // Blue-500
                       letterSpacing: 1,
                     ),
                   ),
                 ),
                 
                 const SizedBox(height: 48), // Large spacing before menu
                 
                 // 3. Menu Items
                 
                 // WEB NOTIFICATION SECTION
                 if (kIsWeb) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifikasi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: permissionStatus.value == 'granted' ? Colors.green.withValues(alpha: 0.1) : (permissionStatus.value == 'denied' ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFEFF6FF)),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Icon(
                                  permissionStatus.value == 'granted' ? Icons.notifications_active_rounded : (permissionStatus.value == 'denied' ? Icons.notifications_off_rounded : Icons.notifications_outlined),
                                  color: permissionStatus.value == 'granted' ? Colors.green : (permissionStatus.value == 'denied' ? Colors.red : const Color(0xFF3B82F6)),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Notifikasi Push Browser', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                    Text(
                                      permissionStatus.value == 'granted' ? 'Notifikasi aktif' : (permissionStatus.value == 'denied' ? 'Izin ditolak browser' : 'Aktifkan notifikasi'),
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: notificationEnabled.value,
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) async {
                                  if (val) {
                                    final result = await notificationService.requestPermission();
                                    permissionStatus.value = result;
                                    notificationEnabled.value = result == 'granted';
                                    if (result == 'granted' && context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi diaktifkan'), backgroundColor: Colors.green));
                                       notificationService.showNotification(title: 'SIM-ASET', body: 'Notifikasi aktif!');
                                    }
                                  } else {
                                     notificationEnabled.value = false; // Just UI update
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                 ],

                 // EXISTING MENU ITEMS
                 _buildMenuItem(
                   icon: Icons.settings_outlined, // Standard cog
                   iconBg: const Color(0xFFF1F5F9), // Slate-100
                   iconColor: const Color(0xFF475569), // Slate-600
                   title: 'Pengaturan Akun',
                   subtitle: 'Ubah profil dan password',
                   onTap: () {
                     // Screenshot implies generic settings or specific edit actions
                     // We can route to existing edit/password screens or show a bottom sheet
                     // For now, mapping to existing screens logic inside a consistent action
                     _showSettingsOptions(context);
                   },
                 ),
                 
                 const SizedBox(height: 16),
                 
                 _buildMenuItem(
                   icon: Icons.logout_rounded,
                   iconBg: const Color(0xFFFEF2F2), // Red-50
                   iconColor: const Color(0xFFEF4444), // Red-500
                   title: 'Keluar',
                   subtitle: 'Akhiri sesi aplikasi',
                   onTap: () {
                      _showLogoutDialog(context, ref);
                   },
                 ),
               ],
             ),
           );
        },
      ),
    );
  }

  Widget _buildAvatar(UserProfile profile) {
    // Screenshot: Blue ring, light blue bg circle, "H" text blue centered
    return Container(
      padding: const EdgeInsets.all(4), // Ring spacing
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2), // Blue-200 ring
      ),
      child: Container(
        height: 100, // Large avatar
        width: 100,
        decoration: const BoxDecoration(
          color: Color(0xFFDBEAFE), // Blue-100 fill
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: (profile.photoURL != null && profile.photoURL!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: profile.photoURL!,
                fit: BoxFit.cover,
                errorWidget: (_,__,___) => _defaultAvatar(profile),
              )
             : _defaultAvatar(profile),
        ),
      ),
    );
  }
  
  Widget _defaultAvatar(UserProfile profile) {
     return Center(
       child: Text(
         profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : '?',
         style: GoogleFonts.inter(
           fontSize: 40,
           fontWeight: FontWeight.bold,
           color: const Color(0xFF3B82F6), // Blue-500 text
         ),
       ),
     );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)), // Slate-100 border
          boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.02),
               blurRadius: 4,
               offset: const Offset(0, 2),
             ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: iconBg,
                 borderRadius: BorderRadius.circular(12),
               ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8), // Slate-400
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)), // Slate-300
          ],
        ),
      ),
    );
  }

  void _showSettingsOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text('Edit Profil', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text('Ubah Password', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin mengakhiri sesi?', style: GoogleFonts.inter()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
               Navigator.pop(context);
               await ref.read(authActionsProvider.notifier).logout();
               if (context.mounted) {
                 Navigator.pushNamedAndRemoveUntil(context, AppConstants.loginRoute, (route) => false);
               }
            },
            child: Text('Keluar', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
