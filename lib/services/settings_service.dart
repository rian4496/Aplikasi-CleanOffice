// lib/services/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../core/logging/app_logger.dart';

/// Service untuk mengelola settings menggunakan SharedPreferences
class SettingsService {
  static const String _settingsKey = 'app_settings';
  final _logger = AppLogger('SettingsService');

  /// Load settings dari SharedPreferences
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        _logger.info('No saved settings, using defaults');
        return const AppSettings(); // Default settings
      }

      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettings.fromMap(settingsMap);
      
      _logger.info('Settings loaded: $settings');
      return settings;
    } catch (e, stackTrace) {
      _logger.error('Error loading settings', e, stackTrace);
      return const AppSettings(); // Return default on error
    }
  }

  /// Save settings ke SharedPreferences
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toMap());
      
      await prefs.setString(_settingsKey, settingsJson);
      _logger.info('Settings saved: $settings');
    } catch (e, stackTrace) {
      _logger.error('Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all settings (reset to default)
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      _logger.info('Settings cleared');
    } catch (e, stackTrace) {
      _logger.error('Error clearing settings', e, stackTrace);
      rethrow;
    }
  }

  /// Clear app cache (untuk fitur Clear Cache di settings)
  Future<void> clearCache() async {
    try {
      // Di sini Anda bisa tambahkan logic untuk clear cache lainnya
      // Misalnya: clear image cache, clear temporary files, dll
      
      _logger.info('Cache cleared');
      
      // Contoh: Clear semua SharedPreferences KECUALI settings
      final prefs = await SharedPreferences.getInstance();
      final settingsBackup = prefs.getString(_settingsKey);
      
      await prefs.clear();
      
      if (settingsBackup != null) {
        await prefs.setString(_settingsKey, settingsBackup);
      }
      
      _logger.info('All cache cleared except settings');
    } catch (e, stackTrace) {
      _logger.error('Error clearing cache', e, stackTrace);
      rethrow;
    }
  }
}