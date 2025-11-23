// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map json) =>
    $checkedCreate('_AppNotification', json, ($checkedConvert) {
      final val = _AppNotification(
        id: $checkedConvert('id', (v) => v as String),
        userId: $checkedConvert('userId', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$NotificationTypeEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => (v as Map?)?.map((k, e) => MapEntry(k as String, e)),
        ),
        read: $checkedConvert('read', (v) => v as bool? ?? false),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => const ISODateTimeConverter().fromJson(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'data': ?instance.data,
      'read': instance.read,
      'createdAt': const ISODateTimeConverter().toJson(instance.createdAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.urgentReport: 'urgentReport',
  NotificationType.reportAssigned: 'reportAssigned',
  NotificationType.reportCompleted: 'reportCompleted',
  NotificationType.reportOverdue: 'reportOverdue',
  NotificationType.reportRejected: 'reportRejected',
  NotificationType.newComment: 'newComment',
  NotificationType.statusUpdated: 'statusUpdated',
  NotificationType.lowStockAlert: 'lowStockAlert',
  NotificationType.general: 'general',
};

_NotificationSettings _$NotificationSettingsFromJson(
  Map json,
) => $checkedCreate('_NotificationSettings', json, ($checkedConvert) {
  final val = _NotificationSettings(
    userId: $checkedConvert('userId', (v) => v as String),
    enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
    urgentReport: $checkedConvert('urgentReport', (v) => v as bool? ?? true),
    reportAssigned: $checkedConvert(
      'reportAssigned',
      (v) => v as bool? ?? true,
    ),
    reportCompleted: $checkedConvert(
      'reportCompleted',
      (v) => v as bool? ?? true,
    ),
    reportOverdue: $checkedConvert('reportOverdue', (v) => v as bool? ?? true),
    reportRejected: $checkedConvert(
      'reportRejected',
      (v) => v as bool? ?? true,
    ),
    newComment: $checkedConvert('newComment', (v) => v as bool? ?? true),
    sound: $checkedConvert('sound', (v) => v as bool? ?? true),
    vibration: $checkedConvert('vibration', (v) => v as bool? ?? true),
  );
  return val;
});

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'enabled': instance.enabled,
  'urgentReport': instance.urgentReport,
  'reportAssigned': instance.reportAssigned,
  'reportCompleted': instance.reportCompleted,
  'reportOverdue': instance.reportOverdue,
  'reportRejected': instance.reportRejected,
  'newComment': instance.newComment,
  'sound': instance.sound,
  'vibration': instance.vibration,
};
