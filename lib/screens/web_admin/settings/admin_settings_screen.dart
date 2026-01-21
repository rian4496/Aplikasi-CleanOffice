import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../riverpod/settings_provider.dart';
import '../../../models/app_settings.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import '../../../services/web_notification_service_interface.dart';

class AdminSettingsScreen extends HookConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final notificationService = WebNotificationService();
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    // State for notification permission
    final notificationEnabled = useState(notificationService.isEnabled);
    final permissionStatus = useState(notificationService.permissionStatus);

    Widget buildContent(AppSettings settings) {
      return Column(
        children: [

          _buildCard(
            title: 'Notifikasi',
            isMobile: isMobile,
            child: Column(
              children: [
                // Browser Push Notification Toggle
                SwitchListTile(
                  title: const Text('Notifikasi Push Browser'),
                  subtitle: Text(
                    permissionStatus.value == 'granted'
                        ? 'Notifikasi aktif'
                        : permissionStatus.value == 'denied'
                            ? 'Izin ditolak'
                            : 'Aktifkan notifikasi',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                  secondary: Icon(
                    permissionStatus.value == 'granted'
                        ? Icons.notifications_active
                        : permissionStatus.value == 'denied'
                            ? Icons.notifications_off
                            : Icons.notifications_outlined,
                    color: permissionStatus.value == 'granted'
                        ? Colors.green
                        : permissionStatus.value == 'denied'
                            ? Colors.red
                            : AdminColors.primary,
                  ),
                  value: notificationEnabled.value,
                  onChanged: (val) async {
                    if (val) {
                      final result = await notificationService.requestPermission();
                      permissionStatus.value = result;
                      notificationEnabled.value = result == 'granted';
                      
                      if (result == 'granted') {
                        notificationService.showNotification(
                          title: 'SIM-ASET',
                          body: 'Notifikasi berhasil diaktifkan! 🎉',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi browser diaktifkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else if (result == 'denied') {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Izin notifikasi ditolak'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    } else {
                      notificationEnabled.value = false;
                    }
                  },
                ),
                const Divider(),
                // Sound Toggle
                SwitchListTile(
                  secondary: Icon(
                    settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: settings.soundEnabled ? Colors.green : Colors.grey,
                  ),
                  title: const Text('Suara Notifikasi'),
                  subtitle: const Text('Mainkan suara saat notifikasi masuk'),
                  value: settings.soundEnabled,
                  onChanged: (val) {
                     ref.read(settingsProvider.notifier).setSoundEnabled(val);
                     if (val) {
                       // Play test sound
                       notificationService.playSound();
                     }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // ==================== MOBILE LAYOUT ====================
    if (isMobile) {
      return Scaffold(
         backgroundColor: Colors.grey[50], // Light background
         appBar: AppBar(
           backgroundColor: Colors.white,
           elevation: 0,
           leadingWidth: 140, // Wider for text
           leading: TextButton.icon(
             icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
             label: const Text('Pengaturan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
             style: TextButton.styleFrom(
               padding: const EdgeInsets.only(left: 8),
               alignment: Alignment.centerLeft,
             ),
             onPressed: () {
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               } else {
                 context.go('/admin/dashboard');
               }
             },
           ),
           // Hide title if back button has text
           title: null, 
         ),
         body: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (settings) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: buildContent(settings),
            ),
         ),
      );
    }

    // ==================== DESKTOP LAYOUT ====================
    return AdminLayoutWrapper(
      title: 'Pengaturan Umum',
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: SingleChildScrollView(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (settings) => buildContent(settings),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child, required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : AdminConstants.radiusMd),
         border: Border.all(color: AdminColors.border),
         boxShadow: isMobile ? null : [ // Remove shadow on mobile for flatter look if desired, or keep light shadow
           BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: isMobile 
            ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) 
            : AdminTypography.h4.copyWith(fontWeight: FontWeight.bold)
          ),
          Divider(height: isMobile ? 24 : 32),
          child,
        ],
      ),
    );
  }
}
