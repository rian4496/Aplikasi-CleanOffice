// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Department _$DepartmentFromJson(Map json) =>
    $checkedCreate('_Department', json, ($checkedConvert) {
      final val = _Department(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        supervisorId: $checkedConvert('supervisorId', (v) => v as String),
        locations: $checkedConvert(
          'locations',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
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

Map<String, dynamic> _$DepartmentToJson(
  _Department instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'supervisorId': instance.supervisorId,
  'locations': instance.locations,
  'createdAt': ?const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};
