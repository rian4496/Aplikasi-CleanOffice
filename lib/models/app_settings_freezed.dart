// lib/models/app_settings_freezed.dart
// App Settings model - Freezed Version

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings_freezed.freezed.dart';
part 'app_settings_freezed.g.dart';

/// Model untuk menyimpan pengaturan aplikasi (SharedPreferences)
@freezed
class AppSettings with _$AppSettings {
  const AppSettings._(); // Private constructor for custom methods

  const factory AppSettings({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool soundEnabled,
    @Default('id') String language, // 'id' atau 'en'
  }) = _AppSettings;

  /// Convert dari JSON ke AppSettings object
  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

  /// Convert dari Map ke AppSettings object (backward compatibility)
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings.fromJson({
      'notificationsEnabled': map['notificationsEnabled'] ?? true,
      'soundEnabled': map['soundEnabled'] ?? true,
      'language': map['language'] ?? 'id',
    });
  }

  /// Convert AppSettings object ke Map (backward compatibility)
  Map<String, dynamic> toMap() => toJson();
}
