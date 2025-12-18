// lib/screens/shared/settings_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_settings.dart';
import '../../providers/riverpod/settings_provider.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: State for app version
    final appVersion = useState<String?>('1.0.0');

    // ✅ HOOKS: Load app version on mount (like initState)
    useEffect(() {
      Future<void> loadAppVersion() async {
        try {
          final packageInfo = await PackageInfo.fromPlatform();
          appVersion.value = packageInfo.version;
        } catch (e) {
          appVersion.value = '1.0.0';
        }
      }

      loadAppVersion();
      return null; // No cleanup needed
    }, const []); // Empty deps = run once on mount

    // ✅ Watch settings provider
    final settingsAsync = ref.watch(settingsProvider);

    // ✅ HELPER: Translations
    String t(String key, String lang) {
      const translations = {
        'title': {'id': 'Pengaturan', 'en': 'Settings'},
        'notifications': {'id': 'Notifikasi', 'en': 'Notifications'},
        'notifications_desc': {
          'id': 'Terima pemberitahuan push',
          'en': 'Receive push notifications'
        },
        'sound': {'id': 'Suara Notifikasi', 'en': 'Notification Sound'},
        'sound_desc': {
          'id': 'Putar suara saat notifikasi masuk',
          'en': 'Play sound when notifications arrive'
        },
        'language': {'id': 'Bahasa', 'en': 'Language'},
        'language_desc': {
          'id': 'Pilih bahasa aplikasi',
          'en': 'Select app language'
        },
        'indonesian': {'id': 'Indonesia', 'en': 'Indonesian'},
        'english': {'id': 'English', 'en': 'English'},
        'data_privacy': {'id': 'Data & Privasi', 'en': 'Data & Privacy'},
        'clear_cache': {'id': 'Hapus Cache', 'en': 'Clear Cache'},
        'clear_cache_desc': {
          'id': 'Bersihkan data sementara',
          'en': 'Clear temporary data'
        },
        'about': {'id': 'Tentang', 'en': 'About'},
        'app_version': {'id': 'Versi Aplikasi', 'en': 'App Version'},
        'terms': {'id': 'Syarat & Ketentuan', 'en': 'Terms & Conditions'},
        'privacy_policy': {'id': 'Kebijakan Privasi', 'en': 'Privacy Policy'},
        'contact_dev': {'id': 'Kontak Developer', 'en': 'Contact Developer'},
        'clear_cache_confirm': {
          'id': 'Hapus Cache?',
          'en': 'Clear Cache?'
        },
        'clear_cache_message': {
          'id': 'Apakah Anda yakin ingin menghapus semua data cache?',
          'en': 'Are you sure you want to clear all cache data?'
        },
        'cancel': {'id': 'Batal', 'en': 'Cancel'},
        'clear': {'id': 'Hapus', 'en': 'Clear'},
        'cache_cleared': {
          'id': 'Cache berhasil dihapus',
          'en': 'Cache cleared successfully'
        },
        'error_clearing_cache': {
          'id': 'Gagal menghapus cache',
          'en': 'Failed to clear cache'
        },
      };

      return translations[key]?[lang] ?? key;
    }

    // ✅ HELPER: Show clear cache dialog
    Future<void> showClearCacheDialog(String lang) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t('clear_cache_confirm', lang)),
          content: Text(t('clear_cache_message', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t('cancel', lang)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: Text(t('clear', lang)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await ref.read(settingsProvider.notifier).clearCache();

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('cache_cleared', lang)),
              backgroundColor: AppTheme.success,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('error_clearing_cache', lang)),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }

    // ✅ HELPER: Open URL
    Future<void> openURL(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open: $url'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    // ✅ BUILD UI
    return settingsAsync.when(
      data: (settings) {
        final lang = settings.language;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              t('title', lang),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 8),

              // Notifications Section
              _buildSectionHeader(t('notifications', lang)),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: t('notifications', lang),
                subtitle: t('notifications_desc', lang),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: t('sound', lang),
                subtitle: t('sound_desc', lang),
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                },
                enabled: settings.notificationsEnabled,
              ),

              const SizedBox(height: 16),

              // Language Section
              _buildSectionHeader(t('language', lang)),
              _buildLanguageTile(
                currentLang: lang,
                t: t,
                onLanguageChanged: (newLang) {
                  ref.read(settingsProvider.notifier).setLanguage(newLang);
                },
              ),

              const SizedBox(height: 16),

              // Data & Privacy Section
              _buildSectionHeader(t('data_privacy', lang)),
              _buildActionTile(
                icon: Icons.delete_outline,
                title: t('clear_cache', lang),
                subtitle: t('clear_cache_desc', lang),
                onTap: () => showClearCacheDialog(lang),
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSectionHeader(t('about', lang)),
              _buildInfoTile(
                icon: Icons.info_outline,
                title: t('app_version', lang),
                subtitle: appVersion.value ?? '1.0.0',
              ),
              _buildActionTile(
                icon: Icons.description_outlined,
                title: t('terms', lang),
                onTap: () => openURL('https://yourwebsite.com/terms'),
              ),
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                title: t('privacy_policy', lang),
                onTap: () => openURL('https://yourwebsite.com/privacy'),
              ),
              _buildActionTile(
                icon: Icons.email_outlined,
                title: t('contact_dev', lang),
                onTap: () => openURL('mailto:support@cleanoffice.com'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ STATIC HELPERS: UI widgets
  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  static Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        secondary: Icon(icon, color: enabled ? AppTheme.primary : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: enabled ? AppTheme.textPrimary : Colors.grey,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  static Widget _buildLanguageTile({
    required String currentLang,
    required String Function(String, String) t,
    required ValueChanged<String> onLanguageChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppTheme.primary),
        title: Text(
          t('language', currentLang),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(t('language_desc', currentLang)),
        trailing: DropdownButton<String>(
          value: currentLang,
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: 'id',
              child: Text(t('indonesian', currentLang)),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text(t('english', currentLang)),
            ),
          ],
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
      ),
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  static Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

