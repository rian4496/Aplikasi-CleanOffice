// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Employee _$EmployeeFromJson(Map json) => $checkedCreate(
  '_Employee',
  json,
  ($checkedConvert) {
    final val = _Employee(
      id: $checkedConvert('id', (v) => v as String),
      nip: $checkedConvert('nip', (v) => v as String),
      fullName: $checkedConvert('full_name', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String?),
      phone: $checkedConvert('phone', (v) => v as String?),
      position: $checkedConvert('position', (v) => v as String?),
      organizationId: $checkedConvert('organization_id', (v) => v as String?),
      status: $checkedConvert('status', (v) => v as String? ?? 'active'),
      photoUrl: $checkedConvert('photo_url', (v) => v as String?),
      departmentName: $checkedConvert('department_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'fullName': 'full_name',
    'organizationId': 'organization_id',
    'photoUrl': 'photo_url',
    'departmentName': 'department_name',
  },
);

Map<String, dynamic> _$EmployeeToJson(_Employee instance) => <String, dynamic>{
  'id': instance.id,
  'nip': instance.nip,
  'full_name': instance.fullName,
  'email': ?instance.email,
  'phone': ?instance.phone,
  'position': ?instance.position,
  'organization_id': ?instance.organizationId,
  'status': instance.status,
  'photo_url': ?instance.photoUrl,
  'department_name': ?instance.departmentName,
};
