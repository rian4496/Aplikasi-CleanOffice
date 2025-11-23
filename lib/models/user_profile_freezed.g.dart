// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map json) =>
    $checkedCreate('_UserProfile', json, ($checkedConvert) {
      final val = _UserProfile(
        uid: $checkedConvert('uid', (v) => v as String),
        displayName: $checkedConvert('displayName', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        photoURL: $checkedConvert('photoURL', (v) => v as String?),
        phoneNumber: $checkedConvert('phoneNumber', (v) => v as String?),
        role: $checkedConvert('role', (v) => v as String),
        joinDate: $checkedConvert(
          'joinDate',
          (v) => const TimestampConverter().fromJson(v),
        ),
        departmentId: $checkedConvert('departmentId', (v) => v as String?),
        staffId: $checkedConvert('staffId', (v) => v as String?),
        status: $checkedConvert('status', (v) => v as String? ?? 'active'),
        location: $checkedConvert('location', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoURL': ?instance.photoURL,
      'phoneNumber': ?instance.phoneNumber,
      'role': instance.role,
      'joinDate': ?const TimestampConverter().toJson(instance.joinDate),
      'departmentId': ?instance.departmentId,
      'staffId': ?instance.staffId,
      'status': instance.status,
      'location': ?instance.location,
    };
