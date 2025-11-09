// lib/screens/shared/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/riverpod/settings_provider.dart';
import '../../models/app_settings.dart';
import '../../core/theme/app_theme.dart';

/// Settings Screen dengan multi-bahasa (ID/EN)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  // Translations helper
  String _t(String key, String lang) {
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

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => _buildContent(settings),
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

  // ✅ FIXED: Added type annotation 'AppSettings settings'
  Widget _buildContent(AppSettings settings) {
    final lang = settings.language;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('title', lang),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ==================== NOTIFICATIONS SECTION ====================
          _buildSectionHeader(_t('notifications', lang)),
          
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: _t('notifications', lang),
            subtitle: _t('notifications_desc', lang),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
            },
          ),
          
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: _t('sound', lang),
            subtitle: _t('sound_desc', lang),
            value: settings.soundEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setSoundEnabled(value);
            },
            enabled: settings.notificationsEnabled,
          ),

          const SizedBox(height: 16),

          // ==================== LANGUAGE SECTION ====================
          _buildSectionHeader(_t('language', lang)),
          
          _buildLanguageTile(
            currentLang: lang,
            onLanguageChanged: (newLang) {
              ref.read(settingsProvider.notifier).setLanguage(newLang);
            },
          ),

          const SizedBox(height: 16),

          // ==================== DATA & PRIVACY SECTION ====================
          _buildSectionHeader(_t('data_privacy', lang)),
          
          _buildActionTile(
            icon: Icons.delete_outline,
            title: _t('clear_cache', lang),
            subtitle: _t('clear_cache_desc', lang),
            onTap: () => _showClearCacheDialog(lang),
          ),

          const SizedBox(height: 16),

          // ==================== ABOUT SECTION ====================
          _buildSectionHeader(_t('about', lang)),
          
          _buildInfoTile(
            icon: Icons.info_outline,
            title: _t('app_version', lang),
            subtitle: _appVersion ?? '1.0.0',
          ),
          
          _buildActionTile(
            icon: Icons.description_outlined,
            title: _t('terms', lang),
            onTap: () => _openURL('https://yourwebsite.com/terms'),
          ),
          
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: _t('privacy_policy', lang),
            onTap: () => _openURL('https://yourwebsite.com/privacy'),
          ),
          
          _buildActionTile(
            icon: Icons.email_outlined,
            title: _t('contact_dev', lang),
            onTap: () => _openURL('mailto:support@cleanoffice.com'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSectionHeader(String title) {
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

  Widget _buildSwitchTile({
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

  Widget _buildLanguageTile({
    required String currentLang,
    required ValueChanged<String> onLanguageChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppTheme.primary),
        title: Text(
          _t('language', currentLang),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_t('language_desc', currentLang)),
        trailing: DropdownButton<String>(
          value: currentLang,
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: 'id',
              child: Text(_t('indonesian', currentLang)),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text(_t('english', currentLang)),
            ),
          ],
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildActionTile({
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

  Widget _buildInfoTile({
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

  // ==================== DIALOGS & ACTIONS ====================

  Future<void> _showClearCacheDialog(String lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('clear_cache_confirm', lang)),
        content: Text(_t('clear_cache_message', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(_t('clear', lang)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(settingsProvider.notifier).clearCache();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('cache_cleared', lang)),
            backgroundColor: AppTheme.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('error_clearing_cache', lang)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open: $url'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}