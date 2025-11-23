// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map json) => $checkedCreate(
  '_AppSettings',
  json,
  ($checkedConvert) {
    final val = _AppSettings(
      notificationsEnabled: $checkedConvert(
        'notificationsEnabled',
        (v) => v as bool? ?? true,
      ),
      soundEnabled: $checkedConvert('soundEnabled', (v) => v as bool? ?? true),
      language: $checkedConvert('language', (v) => v as String? ?? 'id'),
    );
    return val;
  },
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'language': instance.language,
    };
