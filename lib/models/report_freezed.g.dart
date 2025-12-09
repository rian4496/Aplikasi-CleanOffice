// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Report _$ReportFromJson(Map json) =>
    $checkedCreate('_Report', json, ($checkedConvert) {
      final val = _Report(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        location: $checkedConvert('location', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => const TimestampConverter().fromJson(v),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ReportStatusEnumMap, v),
        ),
        userId: $checkedConvert('userId', (v) => v as String),
        userName: $checkedConvert('userName', (v) => v as String),
        userEmail: $checkedConvert('userEmail', (v) => v as String?),
        cleanerId: $checkedConvert('cleanerId', (v) => v as String?),
        cleanerName: $checkedConvert('cleanerName', (v) => v as String?),
        verifiedBy: $checkedConvert('verifiedBy', (v) => v as String?),
        verifiedByName: $checkedConvert('verifiedByName', (v) => v as String?),
        verifiedAt: $checkedConvert(
          'verifiedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
        verificationNotes: $checkedConvert(
          'verificationNotes',
          (v) => v as String?,
        ),
        imageUrl: $checkedConvert('imageUrl', (v) => v as String?),
        completionImageUrl: $checkedConvert(
          'completionImageUrl',
          (v) => v as String?,
        ),
        description: $checkedConvert('description', (v) => v as String?),
        isUrgent: $checkedConvert('isUrgent', (v) => v as bool? ?? false),
        assignedAt: $checkedConvert(
          'assignedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
        completedAt: $checkedConvert(
          'completedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
        departmentId: $checkedConvert('departmentId', (v) => v as String?),
        deletedAt: $checkedConvert(
          'deletedAt',
          (v) => const NullableTimestampConverter().fromJson(v),
        ),
        deletedBy: $checkedConvert('deletedBy', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'location': instance.location,
  'date': ?const TimestampConverter().toJson(instance.date),
  'status': _$ReportStatusEnumMap[instance.status]!,
  'userId': instance.userId,
  'userName': instance.userName,
  'userEmail': ?instance.userEmail,
  'cleanerId': ?instance.cleanerId,
  'cleanerName': ?instance.cleanerName,
  'verifiedBy': ?instance.verifiedBy,
  'verifiedByName': ?instance.verifiedByName,
  'verifiedAt': ?const NullableTimestampConverter().toJson(instance.verifiedAt),
  'verificationNotes': ?instance.verificationNotes,
  'imageUrl': ?instance.imageUrl,
  'completionImageUrl': ?instance.completionImageUrl,
  'description': ?instance.description,
  'isUrgent': instance.isUrgent,
  'assignedAt': ?const NullableTimestampConverter().toJson(instance.assignedAt),
  'startedAt': ?const NullableTimestampConverter().toJson(instance.startedAt),
  'completedAt': ?const NullableTimestampConverter().toJson(
    instance.completedAt,
  ),
  'departmentId': ?instance.departmentId,
  'deletedAt': ?const NullableTimestampConverter().toJson(instance.deletedAt),
  'deletedBy': ?instance.deletedBy,
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.assigned: 'assigned',
  ReportStatus.inProgress: 'inProgress',
  ReportStatus.completed: 'completed',
  ReportStatus.verified: 'verified',
  ReportStatus.rejected: 'rejected',
};
