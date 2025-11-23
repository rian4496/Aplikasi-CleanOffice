// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Request _$RequestFromJson(Map json) => $checkedCreate('_Request', json, (
  $checkedConvert,
) {
  final val = _Request(
    id: $checkedConvert('id', (v) => v as String),
    location: $checkedConvert('location', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    isUrgent: $checkedConvert('isUrgent', (v) => v as bool? ?? false),
    preferredDateTime: $checkedConvert(
      'preferredDateTime',
      (v) => const NullableTimestampConverter().fromJson(v),
    ),
    requestedBy: $checkedConvert('requestedBy', (v) => v as String),
    requestedByName: $checkedConvert('requestedByName', (v) => v as String),
    requestedByRole: $checkedConvert('requestedByRole', (v) => v as String),
    assignedTo: $checkedConvert('assignedTo', (v) => v as String?),
    assignedToName: $checkedConvert('assignedToName', (v) => v as String?),
    assignedAt: $checkedConvert(
      'assignedAt',
      (v) => const NullableTimestampConverter().fromJson(v),
    ),
    assignedBy: $checkedConvert('assignedBy', (v) => v as String?),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$RequestStatusEnumMap, v),
    ),
    imageUrl: $checkedConvert('imageUrl', (v) => v as String?),
    completionImageUrl: $checkedConvert(
      'completionImageUrl',
      (v) => v as String?,
    ),
    completionNotes: $checkedConvert('completionNotes', (v) => v as String?),
    createdAt: $checkedConvert(
      'createdAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => const NullableTimestampConverter().fromJson(v),
    ),
    completedAt: $checkedConvert(
      'completedAt',
      (v) => const NullableTimestampConverter().fromJson(v),
    ),
    deletedAt: $checkedConvert(
      'deletedAt',
      (v) => const NullableTimestampConverter().fromJson(v),
    ),
    deletedBy: $checkedConvert('deletedBy', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$RequestToJson(_Request instance) => <String, dynamic>{
  'id': instance.id,
  'location': instance.location,
  'description': instance.description,
  'isUrgent': instance.isUrgent,
  'preferredDateTime': ?const NullableTimestampConverter().toJson(
    instance.preferredDateTime,
  ),
  'requestedBy': instance.requestedBy,
  'requestedByName': instance.requestedByName,
  'requestedByRole': instance.requestedByRole,
  'assignedTo': ?instance.assignedTo,
  'assignedToName': ?instance.assignedToName,
  'assignedAt': ?const NullableTimestampConverter().toJson(instance.assignedAt),
  'assignedBy': ?instance.assignedBy,
  'status': _$RequestStatusEnumMap[instance.status]!,
  'imageUrl': ?instance.imageUrl,
  'completionImageUrl': ?instance.completionImageUrl,
  'completionNotes': ?instance.completionNotes,
  'createdAt': ?const TimestampConverter().toJson(instance.createdAt),
  'startedAt': ?const NullableTimestampConverter().toJson(instance.startedAt),
  'completedAt': ?const NullableTimestampConverter().toJson(
    instance.completedAt,
  ),
  'deletedAt': ?const NullableTimestampConverter().toJson(instance.deletedAt),
  'deletedBy': ?instance.deletedBy,
};

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.assigned: 'assigned',
  RequestStatus.inProgress: 'inProgress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
};
