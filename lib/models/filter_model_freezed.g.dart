// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_model_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportFilter _$ReportFilterFromJson(Map json) =>
    $checkedCreate('_ReportFilter', json, ($checkedConvert) {
      final val = _ReportFilter(
        searchQuery: $checkedConvert('searchQuery', (v) => v as String?),
        statuses: $checkedConvert(
          'statuses',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        locations: $checkedConvert(
          'locations',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        startDate: $checkedConvert(
          'startDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        endDate: $checkedConvert(
          'endDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        isUrgent: $checkedConvert('isUrgent', (v) => v as bool?),
        assignedTo: $checkedConvert('assignedTo', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ReportFilterToJson(_ReportFilter instance) =>
    <String, dynamic>{
      'searchQuery': ?instance.searchQuery,
      'statuses': ?instance.statuses,
      'locations': ?instance.locations,
      'startDate': ?instance.startDate?.toIso8601String(),
      'endDate': ?instance.endDate?.toIso8601String(),
      'isUrgent': ?instance.isUrgent,
      'assignedTo': ?instance.assignedTo,
    };

_SavedFilter _$SavedFilterFromJson(Map json) =>
    $checkedCreate('_SavedFilter', json, ($checkedConvert) {
      final val = _SavedFilter(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        filter: $checkedConvert(
          'filter',
          (v) => ReportFilter.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => const ISODateTimeConverter().fromJson(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SavedFilterToJson(_SavedFilter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'filter': instance.filter.toJson(),
      'createdAt': const ISODateTimeConverter().toJson(instance.createdAt),
    };
