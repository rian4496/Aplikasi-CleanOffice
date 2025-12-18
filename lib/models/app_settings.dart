// lib/models/app_settings.dart

/// Model untuk menyimpan pengaturan aplikasi
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language; // 'id' atau 'en'

  const AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.language = 'id',
  });

  /// Copy with method
  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
    );
  }

  /// Convert to Map untuk SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
    };
  }

  /// Create from Map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      language: map['language'] as String? ?? 'id',
    );
  }

  @override
  String toString() {
    return 'AppSettings(notifications: $notificationsEnabled, sound: $soundEnabled, language: $language)';
  }
}
