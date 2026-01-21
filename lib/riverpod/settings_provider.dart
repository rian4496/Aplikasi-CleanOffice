// lib/riverpod/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_settings.dart';
import '../../../services/settings_service.dart';
import '../../../core/logging/app_logger.dart';

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
    final currentSettings = state.value;
    if (currentSettings == null) return;
    
    // Optimistic update - no loading state
    final newSettings = currentSettings.copyWith(notificationsEnabled: enabled);
    state = AsyncValue.data(newSettings);
    
    try {
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      _logger.info('Notifications enabled updated: $enabled');
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      _logger.error('Error updating notifications', e, stackTrace);
    }
  }

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    
    // Optimistic update - no loading state
    final newSettings = currentSettings.copyWith(soundEnabled: enabled);
    state = AsyncValue.data(newSettings);
    
    try {
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      _logger.info('Sound enabled updated: $enabled');
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      _logger.error('Error updating sound', e, stackTrace);
    }
  }

  /// Update language
  Future<void> setLanguage(String language) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;
    
    // Optimistic update - no loading state
    final newSettings = currentSettings.copyWith(language: language);
    state = AsyncValue.data(newSettings);
    
    try {
      final service = ref.read(settingsServiceProvider);
      await service.saveSettings(newSettings);
      _logger.info('Language updated: $language');
    } catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      _logger.error('Error updating language', e, stackTrace);
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
