// lib/providers/riverpod/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../core/logging/app_logger.dart';

final _logger = AppLogger('SettingsProvider');

// ==================== SERVICE PROVIDER ====================

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// ==================== SETTINGS STATE NOTIFIER ====================

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    // Load settings saat pertama kali
    final service = ref.read(settingsServiceProvider);
    return await service.loadSettings();
  }

  /// Update notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(notificationsEnabled: enabled);
      
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      
      state = AsyncValue.data(newSettings);
      _logger.info('Notifications enabled updated: $enabled');
    } catch (e, stackTrace) {
      _logger.error('Error updating notifications', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(soundEnabled: enabled);
      
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      
      state = AsyncValue.data(newSettings);
      _logger.info('Sound enabled updated: $enabled');
    } catch (e, stackTrace) {
      _logger.error('Error updating sound', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update language
  Future<void> setLanguage(String language) async {
    state = const AsyncValue.loading();
    
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(language: language);
      
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      
      state = AsyncValue.data(newSettings);
      _logger.info('Language updated: $language');
    } catch (e, stackTrace) {
      _logger.error('Error updating language', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final service = ref.read(settingsServiceProvider);
      await service.clearCache();
      _logger.info('Cache cleared successfully');
    } catch (e, stackTrace) {
      _logger.error('Error clearing cache', e, stackTrace);
      rethrow;
    }
  }

  /// Reset settings to default
  Future<void> resetToDefault() async {
    state = const AsyncValue.loading();
    
    try {
      const defaultSettings = AppSettings();
      
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(defaultSettings);
      
      state = const AsyncValue.data(defaultSettings);
      _logger.info('Settings reset to default');
    } catch (e, stackTrace) {
      _logger.error('Error resetting settings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// ==================== PROVIDER EXPORT ====================

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  () => SettingsNotifier(),
);