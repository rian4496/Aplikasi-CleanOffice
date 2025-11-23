// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkSchedule _$WorkScheduleFromJson(Map json) =>
    $checkedCreate('_WorkSchedule', json, ($checkedConvert) {
      final val = _WorkSchedule(
        id: $checkedConvert('id', (v) => v as String),
        userId: $checkedConvert('userId', (v) => v as String),
        shift: $checkedConvert('shift', (v) => v as String),
        workDays: $checkedConvert(
          'workDays',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        shiftStart: $checkedConvert(
          'shiftStart',
          (v) => const TimeOfDayConverter().fromJson(v as String),
        ),
        shiftEnd: $checkedConvert(
          'shiftEnd',
          (v) => const TimeOfDayConverter().fromJson(v as String),
        ),
        location: $checkedConvert('location', (v) => v as String),
        assignedBy: $checkedConvert('assignedBy', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => const TimestampConverter().fromJson(v),
        ),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkScheduleToJson(
  _WorkSchedule instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'shift': instance.shift,
  'workDays': instance.workDays,
  'shiftStart': const TimeOfDayConverter().toJson(instance.shiftStart),
  'shiftEnd': const TimeOfDayConverter().toJson(instance.shiftEnd),
  'location': instance.location,
  'assignedBy': instance.assignedBy,
  'createdAt': ?const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};
