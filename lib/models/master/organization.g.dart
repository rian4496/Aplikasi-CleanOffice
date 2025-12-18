// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Organization _$OrganizationFromJson(Map json) => $checkedCreate(
  '_Organization',
  json,
  ($checkedConvert) {
    final val = _Organization(
      id: $checkedConvert('id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      parentId: $checkedConvert('parent_id', (v) => v as String?),
      type: $checkedConvert('type', (v) => v as String),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'parentId': 'parent_id', 'createdAt': 'created_at'},
);

Map<String, dynamic> _$OrganizationToJson(_Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'parent_id': ?instance.parentId,
      'type': instance.type,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };
