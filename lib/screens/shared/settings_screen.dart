// lib/screens/shared/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../riverpod/settings_provider.dart';
import '../../models/app_settings.dart';
import '../../core/theme/app_theme.dart';

/// Settings Screen dengan multi-bahasa (ID/EN)
class SettingsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const SettingsScreen({super.key, this.initialTab = 0});

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
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
      backgroundColor: const Color(0xFFF2F4F7), // Light Gray Background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('title', lang),
          style: const TextStyle(
            color: Color(0xFF101828), 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Profile placeholder from screenshot
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE4D3B5), // Beige color from screenshot
              radius: 16,
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ==================== NOTIFICATIONS SECTION ====================
          _buildSectionHeader(_t('notifications', lang).toUpperCase()),
          
          _buildSettingsGroup([
             _buildSettingsTile(
              icon: Icons.notifications_rounded,
              iconColor: const Color(0xFF2E90FA),
              iconBgColor: const Color(0xFFEFF8FF),
              title: _t('notifications', lang),
              subtitle: _t('notifications_desc', lang),
              trailing: Switch(
                value: settings.notificationsEnabled,
                activeColor: const Color(0xFF2E90FA),
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.volume_up_rounded,
               iconColor: const Color(0xFF7F56D9), // Purple
              iconBgColor: const Color(0xFFF9F5FF),
              title: _t('sound', lang),
              subtitle: _t('sound_desc', lang),
              trailing: Switch(
                value: settings.soundEnabled,
                activeColor: const Color(0xFF2E90FA),
                onChanged: settings.notificationsEnabled ? (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                } : null,
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ==================== PREFERENCES SECTION ====================
          // "PREFERENSI" is roughly "PREFERENCES" or "BAHASA" in screenshot context calls it "PREFERENSI"
          _buildSectionHeader('PREFERENSI'), 
          
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF039855), // Green
              iconBgColor: const Color(0xFFECFDF3),
              title: _t('language', lang),
              subtitle: _t('language_desc', lang),
              onTap: () {
                 // Toggle Language
                 final newLang = lang == 'id' ? 'en' : 'id';
                 ref.read(settingsProvider.notifier).setLanguage(newLang);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                     lang == 'id' ? 'Indonesia' : 'English',
                     style: TextStyle(
                       color: Colors.grey.shade600,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   const SizedBox(width: 8),
                   const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ==================== OTHERS SECTION ====================
          _buildSectionHeader('LAINNYA'),
          
          _buildSettingsGroup([
             _buildSettingsTile(
              icon: Icons.cleaning_services_rounded,
              iconColor: const Color(0xFFDC6803), // Orange
              iconBgColor: const Color(0xFFFFFAEB),
              title: _t('clear_cache', lang),
              subtitle: _t('clear_cache_desc', lang),
              onTap: () => _showClearCacheDialog(lang),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF667085), // Gray
              iconBgColor: const Color(0xFFF2F4F7),
              title: _t('app_version', lang),
              subtitle: 'Build 2023.10.24', // Static from screenshot or use package info
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _appVersion ?? '1.0.0',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF344054),
                  ),
                ),
              ),
            ),
          ]),

           // Footer
          const SizedBox(height: 48),
          Center(
            child: Text(
              '© 2025 Asset Management App',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF667085), 
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Colorful Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (trailing != null) ...[
               const SizedBox(width: 8),
               trailing,
            ]
          ],
        ),
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
